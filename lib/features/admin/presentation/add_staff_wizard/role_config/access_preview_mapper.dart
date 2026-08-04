import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/core/user_roles.dart';

class AccessPreviewEntry {
  final UserRole role;
  final String dashboardPath;
  final List<String> permissionLabels;

  const AccessPreviewEntry({
    required this.role,
    required this.dashboardPath,
    required this.permissionLabels,
  });
}

/// Builds a read-only "what this staff member will be able to see and do"
/// summary from the roles selected in Step 6, for Step 8 (Access Preview).
/// Reuses RolePermissionDefaults.defaults as the source of truth rather than
/// re-deriving permission strings.
class AccessPreviewMapper {
  AccessPreviewMapper._();

  static List<AccessPreviewEntry> build(Set<UserRole> roles) {
    return roles.map((role) {
      final permissions =
          RolePermissionDefaults.defaults[role] ?? const <String>{};
      return AccessPreviewEntry(
        role: role,
        dashboardPath: UserRoleRouting.dashboardPath(role),
        permissionLabels: permissions.map(_humanize).toList()..sort(),
      );
    }).toList();
  }

  static String _humanize(String permissionId) {
    final parts = permissionId.split('.');
    final words = parts.expand((p) => _splitCamel(p)).toList();
    return words.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  static List<String> _splitCamel(String s) {
    return s
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .toLowerCase()
        .split(' ');
  }
}
