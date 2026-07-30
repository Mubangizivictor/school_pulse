import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parent_access_code.dart';
import '../repositories/student_repository.dart';

/// Admin-facing operations on family access codes. Grouped in one file
/// since they're always used together in the User Management screen.
class GetAllAccessCodes {
  final StudentRepository repository;
  GetAllAccessCodes(this.repository);

  Future<Either<Failure, List<ParentAccessCode>>> call({
    String? schoolId,
  }) async {
    return await repository.getAllAccessCodes(schoolId: schoolId);
  }
}

class CreateAccessCode {
  final StudentRepository repository;
  CreateAccessCode(this.repository);

  Future<Either<Failure, String>> call({
    required List<String> studentIds,
    required String schoolId,
    required String phoneNumber,
    String? parentName,
  }) async {
    return await repository.createAccessCode(
      studentIds: studentIds,
      schoolId: schoolId,
      phoneNumber: phoneNumber,
      parentName: parentName,
    );
  }
}

class RegenerateAccessCode {
  final StudentRepository repository;
  RegenerateAccessCode(this.repository);

  Future<Either<Failure, String>> call(String oldCode) async {
    return await repository.regenerateAccessCode(oldCode);
  }
}

class ToggleAccessCodeStatus {
  final StudentRepository repository;
  ToggleAccessCodeStatus(this.repository);

  Future<Either<Failure, void>> call(
    String code,
    bool isActive, {
    String? reason,
  }) async {
    return await repository.toggleAccessCodeStatus(
      code,
      isActive,
      reason: reason,
    );
  }
}

class DeleteAccessCode {
  final StudentRepository repository;
  DeleteAccessCode(this.repository);

  Future<Either<Failure, void>> call(String code) async {
    return await repository.deleteAccessCode(code);
  }
}

class UpdateAccessCode {
  final StudentRepository repository;
  UpdateAccessCode(this.repository);

  Future<Either<Failure, void>> call(ParentAccessCode code) async {
    return await repository.updateAccessCode(code);
  }
}
