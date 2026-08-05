import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/domain/entities/role_permission_override.dart';
import 'package:school_pulse/features/admin/domain/repositories/role_permission_override_repository.dart';

class GetRolePermissionOverrides
    implements UseCase<Map<UserRole, RolePermissionOverride>, String> {
  final RolePermissionOverrideRepository repository;

  GetRolePermissionOverrides(this.repository);

  @override
  Future<Either<Failure, Map<UserRole, RolePermissionOverride>>> call(
    String schoolId,
  ) {
    return repository.getOverrides(schoolId);
  }
}
