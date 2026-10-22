import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/core/user_roles.dart';

void main() {
  const integrationsPermissions = [
    Permission.integrationsView,
    Permission.integrationsConfigure,
    Permission.integrationsConnect,
    Permission.integrationsDisconnect,
    Permission.integrationsTest,
    Permission.integrationsSync,
    Permission.integrationsViewLogs,
    Permission.integrationsManagePayments,
    Permission.integrationsManageCommunication,
    Permission.integrationsManageDevices,
    Permission.integrationsManageDomains,
    Permission.integrationsManageWebhooks,
    Permission.integrationsManagePrinters,
    Permission.integrationsViewSensitiveMetadata,
  ];

  test(
    'every integrations.* permission id follows the dot-form convention',
    () {
      for (final id in integrationsPermissions) {
        expect(id, startsWith('integrations.'));
      }
      expect(
        integrationsPermissions.toSet(),
        hasLength(integrationsPermissions.length),
      );
    },
  );

  test(
    'every integrations.* permission id is registered in Permission.all',
    () {
      final allIds = Permission.all.map((entry) => entry.$2).toSet();
      for (final id in integrationsPermissions) {
        expect(
          allIds.contains(id),
          isTrue,
          reason: '$id missing from Permission.all',
        );
      }
    },
  );

  test(
    'schoolAdmin/headTeacher/director hold the full integrations permission set by default',
    () {
      for (final role in [
        UserRole.schoolAdmin,
        UserRole.headTeacher,
        UserRole.director,
      ]) {
        final granted = RolePermissionDefaults.permissionsFor([role]);
        for (final id in integrationsPermissions) {
          expect(
            granted.contains(id),
            isTrue,
            reason: '$role is missing default permission $id',
          );
        }
      }
    },
  );

  test(
    'ordinary teaching roles do not receive integrations permissions by default',
    () {
      final granted = RolePermissionDefaults.permissionsFor([
        UserRole.subjectTeacher,
      ]);
      for (final id in integrationsPermissions) {
        expect(granted.contains(id), isFalse);
      }
    },
  );
}
