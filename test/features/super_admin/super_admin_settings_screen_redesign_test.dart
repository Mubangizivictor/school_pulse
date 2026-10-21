// Proves the redesigned Settings control centre (two-column: My Account /
// Appearance / Security on the left, a Platform Configuration card grid on
// the right) is wired in SuperAdminSettingsScreen, using the same
// source-inspection approach as billing_home_screen_test.dart -- the real
// screen depends on AuthBloc/ThemeProvider/Firestore, which this fast
// widget-test layer doesn't set up.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_settings_screen.dart',
    ).readAsStringSync();
  });

  test(
    'account section shows Platform Owner role and reaches the edit profile screen',
    () {
      expect(source.contains("title: 'My account'"), isTrue);
      expect(source.contains("'Platform Owner'"), isTrue);
      expect(source.contains('SuperAdminProfileScreen'), isTrue);
    },
  );

  test('left column carries My Account, Appearance and Security in order', () {
    final order = [
      "title: 'My account'",
      "title: 'Appearance'",
      "title: 'Security'",
    ];
    var lastIndex = -1;
    for (final title in order) {
      final index = source.indexOf(title);
      expect(index, greaterThan(-1), reason: '$title section missing');
      expect(index, greaterThan(lastIndex), reason: '$title out of order');
      lastIndex = index;
    }
  });

  test(
    'Security card exposes 2FA, active sessions and change password, all routing to the security screen',
    () {
      for (final title in const [
        "title: 'Two-factor authentication'",
        "title: 'Active sessions'",
        "title: 'Change password'",
      ]) {
        expect(source.contains(title), isTrue, reason: '$title missing');
      }
      expect(
        source.contains("context.push('/super-admin/settings/security')"),
        isTrue,
      );
    },
  );

  test(
    'platform configuration grid lists the six real destinations, not dead taps',
    () {
      for (final entry in const {
        "title: 'School onboarding'": "context.push('/super-admin/schools')",
        "title: 'Custom domains'":
            "context.push('/super-admin/settings/custom-domains')",
        "title: 'Subdomain change requests'":
            "context.push('/super-admin/settings/subdomain-requests')",
        "title: 'Branding & communications'":
            "context.push('/super-admin/settings/support')",
        "title: 'Platform health'":
            "context.push('/super-admin/platform-health')",
        "title: 'Support & legal'":
            "context.push('/super-admin/settings/support')",
      }.entries) {
        expect(
          source.contains(entry.key),
          isTrue,
          reason: '${entry.key} missing',
        );
        expect(
          source.contains(entry.value),
          isTrue,
          reason: '${entry.key} not routed to ${entry.value}',
        );
      }
    },
  );

  test(
    'configuration status is shown only where real data exists (custom domains stream)',
    () {
      expect(source.contains('CustomDomainService().watchRequests()'), isTrue);
      // No fabricated "Configured" / "API enabled" style badges for surfaces
      // that have no backing data.
      expect(source.contains("'API enabled'"), isFalse);
      expect(source.contains("'Branding configured'"), isFalse);
    },
  );

  test(
    'appearance uses the existing app-wide ThemeProvider, not new state',
    () {
      expect(source.contains('context.watch<ThemeProvider>()'), isTrue);
      expect(
        source.contains('context.read<ThemeProvider>().setThemeMode'),
        isTrue,
      );
    },
  );
}
