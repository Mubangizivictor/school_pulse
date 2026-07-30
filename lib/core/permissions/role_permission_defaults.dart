import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Default role -> permission-set seed used when no cached
/// `OperatorPermissionSnapshotIsar` exists yet (first run on a fresh
/// device) or as the source of truth when a snapshot is refreshed.
///
/// Phase 1 only seeds the security/gate permissions, deliberately
/// mirroring the permitted-role set already used for the `/staff/security`
/// route guard in `lib/app/router.dart` - no role that has dashboard
/// access today loses it under the new permission layer.
class RolePermissionDefaults {
  const RolePermissionDefaults._();

  static const Set<String> _gatekeeperPermissions = {
    Permission.securityIdentityVerify,
    Permission.securityEntryRecord,
    Permission.securityExitRecord,
  };

  static const Set<String> _securityLeadPermissions = {
    ..._gatekeeperPermissions,
    Permission.securityOverride,
    Permission.verificationOverride,
    Permission.verificationAuditRead,
    Permission.verificationDeviceManage,
  };

  static const Map<UserRole, Set<String>> defaults = {
    UserRole.gatekeeper: _gatekeeperPermissions,
    UserRole.receptionist: _gatekeeperPermissions,
    UserRole.securityHead: _securityLeadPermissions,
    UserRole.schoolAdmin: _securityLeadPermissions,
    UserRole.director: _securityLeadPermissions,
    UserRole.headTeacher: _securityLeadPermissions,
    UserRole.deputyHead: _securityLeadPermissions,
  };

  static Set<String> permissionsFor(List<UserRole> roles) {
    final result = <String>{};
    for (final role in roles) {
      result.addAll(defaults[role] ?? const {});
    }
    return result;
  }
}
