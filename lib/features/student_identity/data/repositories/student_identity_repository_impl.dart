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

class StudentIdentityRepositoryImpl implements StudentIdentityRepository {
  final FirebaseFirestore firestore;
  final StudentIdentityLocalCache localCache;
  final IdGeneratorService idGenerator;
  final FirebaseFunctions functions;

  StudentIdentityRepositoryImpl({
    required this.firestore,
    required this.localCache,
    required this.idGenerator,
    required this.functions,
  });

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

      // Callers that already generated codes (e.g. AdmissionService, which
      // must mint a studentCode before the student doc exists) pass them in
      // so the Student record and its identity stay consistent. Otherwise
      // fall back to generating them here.
      final resolvedUniqueSystemId =
          uniqueSystemId ?? idGenerator.generateUniqueSystemId();
      String resolvedSchoolStudentId;
      if (schoolStudentId != null) {
        resolvedSchoolStudentId = schoolStudentId;
      } else {
        final schoolPrefix = student.className
            .substring(0, min(2, student.className.length))
            .toUpperCase();
        final year = DateTime.now().year;
        resolvedSchoolStudentId = '$schoolPrefix-$year-${student.studentId}';
      }

      final model = StudentIdentityModel(
        studentId: student.id,
        schoolId: student.schoolId,
        uniqueSystemId: resolvedUniqueSystemId,
        schoolStudentId: resolvedSchoolStudentId,
        qrCodeData: resolvedUniqueSystemId,
      );

      await firestore.collection('student_identities').add(model.toFirestore());

      // Best-effort: sign the credential server-side so the QR carries a
      // verifiable envelope, not just the bare id. If this fails (offline,
      // secret not configured yet, etc.) the identity record still exists
      // with qrCodeData == uniqueSystemId, and can be re-signed later.
      final signed = await _trySignCredential(student.id);
      return Right(signed ?? model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<StudentIdentityModel?> _trySignCredential(String studentId) async {
    try {
      final callable = functions.httpsCallable('signStudentCredential');
      final result = await callable.call({'studentId': studentId});
      final qrCodeData = result.data['qrCodeData'] as String?;
      if (qrCodeData == null) return null;

      final refreshed = await firestore
          .collection('student_identities')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      if (refreshed.docs.isEmpty) return null;
      return StudentIdentityModel.fromFirestore(refreshed.docs.first.data());
    } catch (_) {
      return null;
    }
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
