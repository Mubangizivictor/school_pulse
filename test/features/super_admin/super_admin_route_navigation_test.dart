import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/super_admin_mobile_nav_shell.dart';

void main() {
  group('Super Admin route ownership', () {
    test(
      'maps every nested owner section to its persistent navigation tab',
      () {
        expect(superAdminSectionForPath('/super-admin'), 0);
        expect(superAdminSectionForPath('/super-admin/platform-health'), 0);

        expect(superAdminSectionForPath('/super-admin/schools'), 1);
        expect(superAdminSectionForPath('/super-admin/schools/school-1'), 1);
        expect(
          superAdminSectionForPath('/super-admin/schools/applications/app-1'),
          1,
        );

        expect(superAdminSectionForPath('/super-admin/payments'), 2);
        expect(superAdminSectionForPath('/super-admin/payments/payment-1'), 2);
        expect(superAdminSectionForPath('/super-admin/plans'), 2);
        expect(superAdminSectionForPath('/super-admin/subscriptions'), 2);

        expect(superAdminSectionForPath('/super-admin/audit-logs'), 3);
        expect(superAdminSectionForPath('/super-admin/activity/log-1'), 3);

        expect(superAdminSectionForPath('/super-admin/settings'), 4);
        expect(
          superAdminSectionForPath(
            '/super-admin/settings/security/trusted-devices',
          ),
          4,
        );
        expect(superAdminSectionForPath('/super-admin/notifications'), 4);
        // Redesigned owner notification nested routes keep Settings selected.
        expect(
          superAdminSectionForPath('/super-admin/settings/notifications'),
          4,
        );
        expect(
          superAdminSectionForPath(
            '/super-admin/settings/notifications/preferences',
          ),
          4,
        );
        expect(
          superAdminSectionForPath(
            '/super-admin/settings/notifications/history',
          ),
          4,
        );
        expect(
          superAdminSectionForPath('/super-admin/settings/support/ticket/1'),
          4,
        );
      },
    );
  });
}
