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
  ) async {
    try {
      final doc = await firestore
          .collection('student_identities')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (doc.docs.isEmpty) {
        return Left(ServerFailure('Identity not found'));
      }

      return Right(StudentIdentityModel.fromFirestore(doc.docs.first.data()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentIdentity>> generateStudentIdentity(
    Student student, {
    String? uniqueSystemId,
    String? schoolStudentId,
  }) async {
    try {
      // Check if identity already exists
      final existing = await firestore
          .collection('student_identities')
          .where('studentId', isEqualTo: student.id)
          .get();

      if (existing.docs.isNotEmpty) {
        return Right(
          StudentIdentityModel.fromFirestore(existing.docs.first.data()),
        );
      }

      // AdmissionService must mint a studentCode/uniqueSystemId *before* the
      // Student document exists (finalizeAdmission needs it as an input), so
      // it still supplies both codes here and this path keeps writing
      // directly - the Cloud Function's own sequence reservation would be
      // redundant with AdmissionService's own admission-number sequence.
      // Every other caller (e.g. the "Generate Identity" bloc action, which
      // passes neither) goes through issueStudentIdentity so token minting
      // and sequence reservation happen atomically server-side instead of
      // via two unguarded client writes.
      if (uniqueSystemId != null && schoolStudentId != null) {
        final model = StudentIdentityModel(
          studentId: student.id,
          schoolId: student.schoolId,
          uniqueSystemId: uniqueSystemId,
          schoolStudentId: schoolStudentId,
          qrCodeData: qrCredentialCodec.issuePayload(),
        );

        final identityDoc = await firestore
            .collection('student_identities')
            .add(model.toFirestore());
        await _storeQrCredential(model, identityDoc.id);
        return Right(model);
      }

      final callable = functions.httpsCallable('issueStudentIdentity');
      final result = await callable.call<Map<String, dynamic>>({
        'studentId': student.id,
        'schoolPrefix': student.className.isNotEmpty
            ? student.className.substring(0, min(2, student.className.length))
            : 'SP',
      });
      final identityData = Map<String, dynamic>.from(
        result.data['identity'] as Map,
      );
      final model = StudentIdentityModel.fromFirestore(identityData);
      final token = qrCredentialCodec.parse(model.qrCodeData);
      if (token != null) {
        await verificationLocalDataSource.cacheCredential(
          CachedCredential(
            credentialValue: token,
            credentialType: 'qr',
            identityId: model.uniqueSystemId,
            identityType: 'student',
            schoolId: model.schoolId,
            status: 'active',
            updatedAt: DateTime.now(),
          ),
        );
      }
      return Right(model);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
      final newToken = qrCredentialCodec.parse(newQrCodeData);
      if (newToken != null) {
        await verificationLocalDataSource.cacheCredential(
          CachedCredential(
            credentialValue: newToken,
            credentialType: 'qr',
            identityId: identity.uniqueSystemId,
            identityType: 'student',
            schoolId: identity.schoolId,
            status: 'active',
            updatedAt: DateTime.now(),
          ),
        );
      }
      return Right(updated);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _storeQrCredential(
    StudentIdentity identity,
    String identityDocumentId,
  ) async {
    final token = qrCredentialCodec.parse(identity.qrCodeData);
    if (token == null) throw StateError('QR credential generation failed');
    final credential = CachedCredential(
      credentialValue: token,
      credentialType: 'qr',
      identityId: identity.uniqueSystemId,
      identityType: 'student',
      schoolId: identity.schoolId,
      status: 'active',
      updatedAt: DateTime.now(),
    );
    await verificationLocalDataSource.cacheCredential(credential);
    await firestore
        .collection('schools')
        .doc(identity.schoolId)
        .collection('credentials')
        .doc(token)
        .set({
          'credentialValue': token,
          'credentialType': 'qr',
          'identityId': identity.uniqueSystemId,
          'identityType': 'student',
          'schoolId': identity.schoolId,
          'status': 'active',
          'updatedAt': credential.updatedAt.toIso8601String(),
          'credentialVersion': 1,
          'identityDocumentId': identityDocumentId,
        });
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Future<Either<Failure, List<StudentIdentity>>> getSchoolIdentities(
    String schoolId,
  ) async {
    try {
      // This assumes students have schoolId, or we join with students.
      // Based on Student model, it doesn't have schoolId, but UserEntity does.
      // Usually students are in a subcollection or have schoolId.
      // Assuming a 'student_identities' collection for now.
      final snapshot = await firestore.collection('student_identities').get();
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
        final identityDoc = await firestore
            .collection('student_identities')
            .where('studentId', isEqualTo: student.id)
            .get();

        if (identityDoc.docs.isNotEmpty) {
          final identity = StudentIdentityModel.fromFirestore(
            identityDoc.docs.first.data(),
          );
          await localCache.save(student: student, identity: identity);
          final token = qrCredentialCodec.parse(identity.qrCodeData);
          if (token != null) {
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
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Student?>> getStudentByUniqueId(
    String uniqueSystemId,
  ) async {
    try {
      // First try local cache (no-op/always-miss on web - falls through to
      // the Firestore lookup below)
      final cached = await localCache.findByUniqueSystemId(uniqueSystemId);
      if (cached != null) return Right(cached);

      // Fallback to Firestore
      final identityDoc = await firestore
          .collection('student_identities')
          .where('uniqueSystemId', isEqualTo: uniqueSystemId)
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
