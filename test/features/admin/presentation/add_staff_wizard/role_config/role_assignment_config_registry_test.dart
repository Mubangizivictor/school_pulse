import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/role_config/role_assignment_config_registry.dart';

void main() {
  group('RoleAssignmentConfigRegistry.forRole', () {
    test('every UserRole produces a spec without throwing', () {
      for (final role in UserRole.values) {
        expect(
          () => RoleAssignmentConfigRegistry.forRole(role),
          returnsNormally,
          reason: 'forRole must be exhaustive over UserRole (missing: $role)',
        );
      }
    });

    test('admissions gets an approvalScope field, matching deanOfStudies', () {
      final spec = RoleAssignmentConfigRegistry.forRole(UserRole.admissions);
      expect(spec.fields, [RoleFieldKind.approvalScope]);
    });

    test('registrar gets a department field, matching bursar/hrOfficer', () {
      final spec = RoleAssignmentConfigRegistry.forRole(UserRole.registrar);
      expect(spec.fields, [RoleFieldKind.department]);
    });
  });
}
