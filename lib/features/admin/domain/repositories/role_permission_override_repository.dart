import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/domain/entities/role_permission_override.dart';

abstract class RolePermissionOverrideRepository {
  /// All overrides an admin has saved for this school, keyed by role. A
  /// role with no entry has no override - callers should fall back to
  /// `RolePermissionDefaults.defaults[role]`.
  Future<Either<Failure, Map<UserRole, RolePermissionOverride>>> getOverrides(
    String schoolId,
  );

  Future<Either<Failure, void>> saveOverride({
    required String schoolId,
    required UserRole role,
    required Set<String> permissions,
    required String updatedBy,
  });
}
