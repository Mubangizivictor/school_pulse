import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/core/user_roles.dart';

class AccessPreviewEntry {
  final UserRole role;
  final String dashboardPath;
  final List<String> permissionLabels;
  final Set<String> permissionIds;

  const AccessPreviewEntry({
    required this.role,
    required this.dashboardPath,
    required this.permissionLabels,
    required this.permissionIds,
  });
}

/// A permission grouped under its module (e.g. "Attendance", "Approvals")
/// for display, derived from the first dot-segment of the permission id.
class GroupedPermission {
  final String module;
  final String label;

  const GroupedPermission({required this.module, required this.label});
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
        permissionIds: permissions,
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

  /// Groups a flat set of `module.action` permission ids into readable
  /// "Module -> [Action, Action, ...]" sections for display, keyed by the
  /// humanized module name (first dot-segment) and sorted alphabetically.
  static List<MapEntry<String, List<String>>> groupByModule(
    List<String> permissionIds,
  ) {
    final byModule = <String, List<String>>{};
    for (final id in permissionIds) {
      final segments = id.split('.');
      final moduleWords = _splitCamel(segments.first);
      final module = moduleWords
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      final actionWords = segments
          .skip(1)
          .expand((p) => _splitCamel(p))
          .toList();
      final label = actionWords.isEmpty
          ? module
          : actionWords.map((w) => w[0].toUpperCase() + w.substring(1)).join(
              ' ',
            );
      byModule.putIfAbsent(module, () => []).add(label);
    }
    for (final labels in byModule.values) {
      labels.sort();
    }
    final entries = byModule.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }
}
