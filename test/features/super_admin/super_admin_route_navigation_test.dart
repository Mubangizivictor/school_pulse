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
        // Owner Notifications is reached from the Overview bell, not nested
        // under Settings - Overview stays selected while it's open.
        expect(superAdminSectionForPath('/super-admin/notifications'), 0);
        expect(
          superAdminSectionForPath('/super-admin/notifications/history'),
          0,
        );
        expect(
          superAdminSectionForPath('/super-admin/settings/support/ticket/1'),
          4,
        );
      },
    );
  });
}
