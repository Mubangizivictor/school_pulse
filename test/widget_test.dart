import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/user_roles.dart';

void main() {
  group('UserRoleDisplay', () {
    test('every role has a non-empty display name', () {
      for (final role in UserRole.values) {
        expect(
          UserRoleDisplay.name(role),
          isNotEmpty,
          reason: 'Missing display name for $role',
        );
      }
    });
  });

  group('UserRoleRouting', () {
    test('every staff role resolves to a /staff route', () {
      for (final role in UserRole.values) {
        if (role == UserRole.parent ||
            role == UserRole.superAdmin ||
            role == UserRole.student) {
          continue;
        }
        final path = UserRoleRouting.dashboardPath(role);
        expect(
          path,
          startsWith('/staff/'),
          reason: '$role should land on a staff dashboard, got $path',
        );
      }
    });

    test('super admin lands on the dedicated platform dashboard', () {
      expect(
        UserRoleRouting.dashboardPath(UserRole.superAdmin),
        '/super-admin',
      );
    });

    test(
      'admin-tier roles all land on the admin dashboard, except Director who has a dedicated one',
      () {
        for (final role in UserRoleDisplay.adminRoles) {
          final expected = role == UserRole.director
              ? '/staff/director'
              : '/staff/admin';
          expect(UserRoleRouting.dashboardPath(role), expected);
        }
      },
    );
  });

  group('NotificationGroups', () {
    test('parents only receive parent broadcasts', () {
      expect(NotificationGroups.forRole(UserRole.parent), ['Parents']);
    });

    test('all staff roles receive All Staff broadcasts', () {
      for (final role in UserRole.values) {
        if (role == UserRole.parent) continue;
        expect(
          NotificationGroups.forRole(role),
          contains('All Staff'),
          reason: '$role should be in the All Staff group',
        );
      }
    });

    test('teachers additionally receive Teachers Only broadcasts', () {
      expect(
        NotificationGroups.forRole(UserRole.classTeacher),
        contains('Teachers Only'),
      );
      expect(
        NotificationGroups.forRole(UserRole.subjectTeacher),
        contains('Teachers Only'),
      );
    });
  });
}
