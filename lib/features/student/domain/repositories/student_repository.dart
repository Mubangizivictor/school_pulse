import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../entities/parent_access_code.dart';

abstract class StudentRepository {
  Future<Either<Failure, List<Student>>> getStudentsByIds(List<String> ids);
  Future<Either<Failure, List<Student>>> getAllStudents();
  Future<Either<Failure, ParentAccessCode?>> resolveAccessCode(String code);
  Future<Either<Failure, List<ParentAccessCode>>> getAllAccessCodes();
  Future<Either<Failure, String>> createAccessCode({required List<String> studentIds, String? parentName});
  Future<Either<Failure, String>> regenerateAccessCode(String oldCode);
  Future<Either<Failure, void>> toggleAccessCodeStatus(String code, bool isActive);
  Future<Either<Failure, void>> deleteAccessCode(String code);
  Future<Either<Failure, void>> updateAccessCode(ParentAccessCode code);
  Future<Either<Failure, void>> createStudent(Student student);
}
