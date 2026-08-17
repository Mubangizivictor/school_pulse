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

  /// Identity reads used to query the top-level `student_identities`
  /// collection directly. That collection is intentionally not exposed to
  /// arbitrary client queries, so the Student ID screen failed with
  /// cloud_firestore/permission-denied before an admin could even generate
  /// or assign a card. The existing callable is already idempotent: it
  /// verifies the signed-in staff member's school, returns the existing
  /// identity if present, or creates one atomically if missing.
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
    // Always use the server-authorized, tenant-checked issuance path. The
    // older client path first queried and then wrote `student_identities`
    // directly, which is exactly what caused the permission-denied failure
    // seen by School Admin on the Student ID Card screen.
    return _issueOrLoadStudentIdentity(
      studentId: student.id,
      schoolPrefix: _schoolPrefix(student, schoolStudentId),
    );
  }

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
      final model = StudentIdentityModel.fromFirestore(identityData);
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

  Future<void> _cacheQrCredential(StudentIdentity identity) async {
    final token = qrCredentialCodec.parse(identity.qrCodeData);
    if (token == null) return;
    await verificationLocalDataSource.cacheCredential(
      CachedCredential(
        credentialValue: token,
        credentialType: 'qr',
        identityId: identity.uniqueSystemId,
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
      final callable = functions.httpsCallable(
        'regenerateStudentQrCredential',
      );
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
      // Keep this query tenant-scoped. This path is used for administrative
      // bulk operations; it must never return another school's identities.
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
        await identityResult.fold(
          (_) async {},
          (identity) async {
            final model = identity is StudentIdentityModel
                ? identity
                : StudentIdentityModel(
                    studentId: identity.studentId,
                    schoolId: identity.schoolId,
                    uniqueSystemId: identity.uniqueSystemId,
                    schoolStudentId: identity.schoolStudentId,
                    qrCodeData: identity.qrCodeData,
                    nfcStatus: identity.nfcStatus,
                  );
            await localCache.save(student: student, identity: model);
            await _cacheQrCredential(model);
          },
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Student?>> getStudentByUniqueId(
    String uniqueSystemId,
  ) async {
    try {
      final cached = await localCache.findByUniqueSystemId(uniqueSystemId);
      if (cached != null) return Right(cached);

      // This fallback remains for legacy callers. The returned student is
      // still protected by the students collection rules; credential
      // assignment itself is server-authorized by assignNfcCredential.
      final identityDoc = await firestore
          .collection('student_identities')
          .where('uniqueSystemId', isEqualTo: uniqueSystemId)
          .limit(1)
          .get();

      if (identityDoc.docs.isEmpty) {
        return const Right(null);
      }

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
    try {
      final existing = await firestore
          .collection('student_identities')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        return Left(ServerFailure('No StudentIdentity found for this student'));
      }

      await existing.docs.first.reference.update({'nfcStatus': nfcStatus});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
