import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_access_code.dart';
import '../repositories/student_repository.dart';

class ProvisionStudentAccessCode {
  final StudentRepository repository;
  ProvisionStudentAccessCode(this.repository);

  Future<Either<Failure, String>> call(String studentId) {
    return repository.provisionStudentAccessCode(studentId);
  }
}

class ResetStudentPin {
  final StudentRepository repository;
  ResetStudentPin(this.repository);

  Future<Either<Failure, void>> call(String code) {
    return repository.resetStudentPin(code);
  }
}

class SetStudentAccessCodeStatus {
  final StudentRepository repository;
  SetStudentAccessCodeStatus(this.repository);

  Future<Either<Failure, void>> call(
    String code,
    bool isActive, {
    String? reason,
  }) {
    return repository.setStudentAccessCodeStatus(
      code,
      isActive,
      reason: reason,
    );
  }
}

class GetStudentAccessCode {
  final StudentRepository repository;
  GetStudentAccessCode(this.repository);

  Future<Either<Failure, StudentAccessCode?>> call(String studentId) {
    return repository.getStudentAccessCode(studentId);
  }
}
