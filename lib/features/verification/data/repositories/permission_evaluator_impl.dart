import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

const _permissionCacheTtl = Duration(hours: 12);
const _permissionCatalogVersion = 1;

class PermissionEvaluatorImpl implements PermissionEvaluator {
  final VerificationLocalDataSource localDataSource;

  PermissionEvaluatorImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> can(
    String permissionId,
    UserEntity operatorUser, {
    Gate? gate,
  }) async {
    try {
      final permissions = await _resolvePermissions(operatorUser);
      if (!permissions.contains(permissionId)) return const Right(false);

      if (gate != null && !_passesGateScoping(permissions, operatorUser, gate)) {
        return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  bool _passesGateScoping(Set<String> permissions, UserEntity operatorUser, Gate gate) {
    final hasOverride = permissions.contains(Permission.securityOverride);
    if (hasOverride) return true;

    if (gate.assignedOfficerIds.isNotEmpty && !gate.assignedOfficerIds.contains(operatorUser.id)) {
      return false;
    }
    if (gate.allowedUserRoles.isNotEmpty &&
        !operatorUser.roles.any((r) => gate.allowedUserRoles.contains(r.name))) {
      return false;
    }
    return true;
  }

  Future<Set<String>> _resolvePermissions(UserEntity operatorUser) async {
    final snapshot = await localDataSource.getPermissionSnapshot(operatorUser.id);
    final isFresh = snapshot != null &&
        snapshot.version == _permissionCatalogVersion &&
        snapshot.expiresAt.isAfter(DateTime.now());

    if (isFresh) return snapshot.permissionIds.toSet();

    // Fail-open on a stale/missing cache: compute live from role defaults
    // rather than locking the operator out on a fresh device or after a
    // connectivity drop, then opportunistically persist the snapshot.
    final computed = RolePermissionDefaults.permissionsFor(operatorUser.roles);
    await localDataSource.savePermissionSnapshot(
      OperatorPermissionSnapshotIsar()
        ..operatorId = operatorUser.id
        ..schoolId = operatorUser.schoolId
        ..permissionIds = computed.toList()
        ..version = _permissionCatalogVersion
        ..expiresAt = DateTime.now().add(_permissionCacheTtl),
    );
    return computed;
  }
}
