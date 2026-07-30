import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

/// Creates a staff Firebase Auth account + Firestore profile via the
/// `createStaffAccount` Cloud Function, and returns the generated temporary
/// password for the admin to hand to the new staff member.
class CreateStaffAccount implements UseCase<String, CreateStaffAccountParams> {
  final AuthRepository repository;

  CreateStaffAccount(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateStaffAccountParams params) async {
    return await repository.createStaffAccount(
      name: params.name,
      email: params.email,
      schoolId: params.schoolId,
      roles: params.roles,
      password: params.password,
      assignedClass: params.assignedClass,
      subjects: params.subjects,
    );
  }
}

class CreateStaffAccountParams extends Equatable {
  final String name;
  final String email;
  final String schoolId;
  final List<UserRole> roles;
  final String password;
  final String? assignedClass;
  final List<SubjectAssignment>? subjects;

  const CreateStaffAccountParams({
    required this.name,
    required this.email,
    required this.schoolId,
    required this.roles,
    required this.password,
    this.assignedClass,
    this.subjects,
  });

  @override
  List<Object?> get props => [name, email, schoolId, roles, password, assignedClass, subjects];
}
