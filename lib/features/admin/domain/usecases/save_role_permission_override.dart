import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/domain/repositories/role_permission_override_repository.dart';

class SaveRolePermissionOverride implements UseCase<void, SaveRolePermissionOverrideParams> {
  final RolePermissionOverrideRepository repository;

  SaveRolePermissionOverride(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveRolePermissionOverrideParams params) {
    return repository.saveOverride(
      schoolId: params.schoolId,
      role: params.role,
      permissions: params.permissions,
      updatedBy: params.updatedBy,
    );
  }
}

class SaveRolePermissionOverrideParams extends Equatable {
  final String schoolId;
  final UserRole role;
  final Set<String> permissions;
  final String updatedBy;

  const SaveRolePermissionOverrideParams({
    required this.schoolId,
    required this.role,
    required this.permissions,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [schoolId, role, permissions, updatedBy];
}
