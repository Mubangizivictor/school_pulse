import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/data/models/student_model.dart';
import '../../domain/entities/student_identity.dart';
import '../../domain/repositories/student_identity_repository.dart';
import '../models/student_identity_model.dart';
import '../../domain/services/id_generator_service.dart';
import 'student_identity_local_cache.dart';
import '../../../verification/data/datasources/verification_local_data_source.dart';
import '../../../verification/domain/entities/verification_cache_records.dart';
import '../../../verification/domain/services/qr_credential_codec.dart';

class StudentIdentityRepositoryImpl implements StudentIdentityRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final StudentIdentityLocalCache localCache;
  final IdGeneratorService idGenerator;
  final VerificationLocalDataSource verificationLocalDataSource;
  final QrCredentialCodec qrCredentialCodec;

  StudentIdentityRepositoryImpl({
    required this.firestore,
    required this.functions,
    required this.localCache,
    required this.idGenerator,
    required this.verificationLocalDataSource,
    QrCredentialCodec? qrCredentialCodec,
  }) : qrCredentialCodec = qrCredentialCodec ?? const QrCredentialCodec();

  @override
  Future<Either<Failure, StudentIdentity>> getStudentIdentity(
    String studentId,
  ) {
    return _issueOrLoadStudentIdentity(studentId: studentId);
  }

  @override
  Future<Either<Failure, StudentIdentity>> generateStudentIdentity(
    Student student, {
    String? uniqueSystemId,
    String? schoolStudentId,
  }) {
    return _issueOrLoadStudentIdentity(
      studentId: student.id,
      schoolPrefix: _schoolPrefix(student, schoolStudentId),
    );
  }

  /// Canonical identity bootstrap.
  ///
  /// The callable validates the authenticated staff member and the Student
  /// document's tenant before returning an existing identity or creating one.
  /// Older identity documents may have an empty/stale schoolId, so the Student
  /// document is the canonical tenant source after the server check succeeds.
  /// This method also seeds the local Student+Identity cache used by NFC/QR
  /// attendance resolution.
  Future<Either<Failure, StudentIdentity>> _issueOrLoadStudentIdentity({
    required String studentId,
    String schoolPrefix = 'SP',
  }) async {
    try {
      final callable = functions.httpsCallable('issueStudentIdentity');
      final result = await callable.call<Map<String, dynamic>>({
        'studentId': studentId,
        'schoolPrefix': schoolPrefix,
      });
      final identityData = Map<String, dynamic>.from(
        result.data['identity'] as Map,
      );
      final returned = StudentIdentityModel.fromFirestore(identityData);

      final studentDoc = await firestore
          .collection('students')
          .doc(studentId)
          .get();
      if (!studentDoc.exists) {
        return Left(
          ServerFailure('Student record not found while preparing identity.'),
        );
      }
      final student = StudentModel.fromMap(studentDoc.data()!, studentDoc.id);
      if (student.schoolId.trim().isEmpty) {
        return Left(
          ServerFailure(
            'Student record has no school assigned. Fix the student record before issuing credentials.',
          ),
        );
      }

      // Server has already verified this Student belongs to the caller's
      // school. Repair legacy identity tenant metadata locally instead of
      // rejecting a valid student because an old identity document is stale.
      final model = StudentIdentityModel(
        studentId: returned.studentId,
        schoolId: student.schoolId,
        uniqueSystemId: returned.uniqueSystemId,
        schoolStudentId: returned.schoolStudentId,
        qrCodeData: returned.qrCodeData,
        nfcStatus: returned.nfcStatus,
      );

      await localCache.save(student: student, identity: model);
      await _cacheQrCredential(model);
      return Right(model);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _schoolPrefix(Student student, String? suppliedStudentCode) {
    final code = suppliedStudentCode?.trim();
    if (code != null && code.isNotEmpty) {
      final letters = code.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
      if (letters.isNotEmpty) {
        return letters.substring(0, letters.length > 8 ? 8 : letters.length);
      }
    }
    if (student.className.isNotEmpty) {
      return student.className
          .substring(
            0,
            student.className.length > 2 ? 2 : student.className.length,
          )
          .toUpperCase();
    }
    return 'SP';
  }

  /// Credentials resolve straight to the canonical Student document id.
  /// StudentIdentity.uniqueSystemId remains printable/auditable metadata but
  /// is no longer required by Attendance just to discover who was scanned.
  Future<void> _cacheQrCredential(StudentIdentity identity) async {
    final token = qrCredentialCodec.parse(identity.qrCodeData);
    if (token == null) return;
    await verificationLocalDataSource.cacheCredential(
      CachedCredential(
        credentialValue: token,
        credentialType: 'qr',
        identityId: identity.studentId,
        identityType: 'student',
        schoolId: identity.schoolId,
        status: 'active',
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, StudentIdentity>> regenerateQrCredential(
    StudentIdentity identity,
  ) async {
    try {
      final callable = functions.httpsCallable('regenerateStudentQrCredential');
      final result = await callable.call<Map<String, dynamic>>({
        'studentId': identity.studentId,
      });
      final newQrCodeData = result.data['qrCodeData'] as String;

      final oldToken = qrCredentialCodec.parse(identity.qrCodeData);
      if (oldToken != null) {
        final old = await verificationLocalDataSource.findCredential(
          oldToken,
          identity.schoolId,
        );
        if (old != null) {
          old.status = 'replaced';
          old.updatedAt = DateTime.now();
          await verificationLocalDataSource.cacheCredential(old);
        }
      }

      final updated = StudentIdentityModel(
        studentId: identity.studentId,
        schoolId: identity.schoolId,
        uniqueSystemId: identity.uniqueSystemId,
        schoolStudentId: identity.schoolStudentId,
        qrCodeData: newQrCodeData,
        nfcStatus: identity.nfcStatus,
      );
      await _cacheQrCredential(updated);
      return Right(updated);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentIdentity>>> getSchoolIdentities(
    String schoolId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('student_identities')
          .where('schoolId', isEqualTo: schoolId)
          .get();
      return Right(
        snapshot.docs
            .map((doc) => StudentIdentityModel.fromFirestore(doc.data()))
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheStudentsForOffline(
    List<Student> students,
  ) async {
    try {
      for (final student in students) {
        final identityResult = await _issueOrLoadStudentIdentity(
          studentId: student.id,
          schoolPrefix: _schoolPrefix(student, student.studentCode),
        );
        await identityResult.fold((_) async {}, (identity) async {
          final model = identity is StudentIdentityModel
              ? identity
              : StudentIdentityModel(
                  studentId: identity.studentId,
                  schoolId: student.schoolId,
                  uniqueSystemId: identity.uniqueSystemId,
                  schoolStudentId: identity.schoolStudentId,
                  qrCodeData: identity.qrCodeData,
                  nfcStatus: identity.nfcStatus,
                );
          await localCache.save(student: student, identity: model);
          await _cacheQrCredential(model);
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student?>> getStudentByUniqueId(
    String reference,
  ) async {
    try {
      // New canonical path: NFC/QR credentials carry Student.id directly.
      final direct = await firestore
          .collection('students')
          .doc(reference)
          .get();
      if (direct.exists) {
        return Right(StudentModel.fromMap(direct.data()!, direct.id));
      }

      // Legacy/offline path: older credentials may still carry uniqueSystemId.
      final cached = await localCache.findByUniqueSystemId(reference);
      if (cached != null) return Right(cached);

      // Last-resort legacy migration lookup. New credentials never require it.
      final identityDoc = await firestore
          .collection('student_identities')
          .where('uniqueSystemId', isEqualTo: reference)
          .limit(1)
          .get();
      if (identityDoc.docs.isEmpty) return const Right(null);

      final studentId = identityDoc.docs.first.data()['studentId'];
      final studentDoc = await firestore
          .collection('students')
          .doc(studentId)
          .get();
      if (!studentDoc.exists) return const Right(null);
      return Right(StudentModel.fromMap(studentDoc.data()!, studentDoc.id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNfcStatus(
    String studentId,
    String nfcStatus,
  ) async {
    // NFC lifecycle persistence belongs to the secure credential service /
    // Cloud Function. Client-side writes to top-level student_identities are
    // intentionally avoided because that collection is not a client write API.
    return const Right(null);
  }
}
