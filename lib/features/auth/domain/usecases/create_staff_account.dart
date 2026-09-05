import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

/// Creates a staff Firebase Auth account + Firestore profile via the
/// `createStaffAccount` Cloud Function. No password is ever generated on,
/// seen by, or returned to the client; the staff member sets their own via
/// a verified invitation. Returns the created staffCode.
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
      signInMethod: params.signInMethod,
      assignedClass: params.assignedClass,
      subjects: params.subjects,
      academicYearId: params.academicYearId,
      departmentId: params.departmentId,
      designationId: params.designationId,
      campusId: params.campusId,
      employmentType: params.employmentType,
      dateJoined: params.dateJoined,
      idempotencyKey: params.idempotencyKey,
      sendLoginDetailsViaEmail: params.sendLoginDetailsViaEmail,
      staffData: params.staffData,
      roleConfigs: params.roleConfigs,
    );
  }
}

class CreateStaffAccountParams extends Equatable {
  final String name;
  final String email;
  final String schoolId;
  final List<UserRole> roles;
  final String signInMethod;
  final String? assignedClass;
  final List<SubjectAssignment>? subjects;
  final String? academicYearId;
  final String? departmentId;
  final String? designationId;
  final String? campusId;
  final String? employmentType;
  final DateTime? dateJoined;
  final String? idempotencyKey;
  final bool sendLoginDetailsViaEmail;
  final Map<String, dynamic>? staffData;
  final Map<String, dynamic>? roleConfigs;

  const CreateStaffAccountParams({
    required this.name,
    required this.email,
    required this.schoolId,
    required this.roles,
    this.signInMethod = 'invite',
    this.assignedClass,
    this.subjects,
    this.academicYearId,
    this.departmentId,
    this.designationId,
    this.campusId,
    this.employmentType,
    this.dateJoined,
    this.idempotencyKey,
    this.sendLoginDetailsViaEmail = false,
    this.staffData,
    this.roleConfigs,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    schoolId,
    roles,
    signInMethod,
    assignedClass,
    subjects,
    academicYearId,
    departmentId,
    designationId,
    campusId,
    employmentType,
    dateJoined,
    idempotencyKey,
    sendLoginDetailsViaEmail,
    staffData,
    roleConfigs,
  ];
}
