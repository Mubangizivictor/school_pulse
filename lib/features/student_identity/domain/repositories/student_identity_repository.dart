import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_identity.dart';
import '../../../student/domain/entities/student.dart';

abstract class StudentIdentityRepository {
  Future<Either<Failure, StudentIdentity>> getStudentIdentity(String studentId);
  Future<Either<Failure, StudentIdentity>> generateStudentIdentity(
    Student student, {
    String? uniqueSystemId,
    String? schoolStudentId,
  });
  Future<Either<Failure, List<StudentIdentity>>> getSchoolIdentities(
    String schoolId,
  );

  // Local caching
  Future<Either<Failure, void>> cacheStudentsForOffline(List<Student> students);
  Future<Either<Failure, Student?>> getStudentByUniqueId(String uniqueSystemId);

  /// Issues a new opaque printable QR credential and retires the previous
  /// credential without deleting its audit history.
  Future<Either<Failure, StudentIdentity>> regenerateQrCredential(
    StudentIdentity identity,
  );

  // NFC lifecycle
  Future<Either<Failure, void>> updateNfcStatus(
    String studentId,
    String nfcStatus,
  );
}
