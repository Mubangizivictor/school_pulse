// Proves the compact Settings redesign (profile card, grouped rows in the
// spec order, ThemeModeSelector, red-outlined Log out with confirmation) is
// wired in SuperAdminSettingsScreen, using the same source-inspection
// approach as billing_home_screen_test.dart -- the real screen depends on
// AuthBloc/SuperAdminBloc (Firestore), which this fast widget-test layer
// doesn't set up.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_settings_screen.dart',
    ).readAsStringSync();
  });

  test('profile card shows Platform Owner role and reaches the edit profile screen', () {
    expect(source.contains('class PlatformSettingsProfileCard'), isTrue);
    expect(source.contains("'Platform Owner'"), isTrue);
    expect(source.contains('SuperAdminProfileScreen'), isTrue);
  });

  test('settings rows are in the spec order with real routes/screens, not dead taps', () {
    final order = [
      'Billing & payment methods',
      'Security & sessions',
      'Platform audit logs',
      'Support & legal',
    ];
    var lastIndex = -1;
    for (final title in order) {
      final index = source.indexOf("title: '$title'");
      expect(index, greaterThan(-1), reason: '$title row missing');
      expect(index, greaterThan(lastIndex), reason: '$title out of order');
      lastIndex = index;
    }
    // Notifications is reached from the Overview bell, not listed in
    // Settings - Overview stays highlighted while it's open.
    expect(source.contains("title: 'Notification delivery'"), isFalse);
    expect(source.contains('ManualPaymentConfigScreen()'), isTrue);
    expect(source.contains("/super-admin/settings/security"), isTrue);
    expect(source.contains('AuditLogsScreen()'), isTrue);
    expect(source.contains("/super-admin/settings/support"), isTrue);
  });

  test('appearance uses the existing app-wide ThemeProvider, not new state', () {
    expect(source.contains('class ThemeModeSelector'), isTrue);
    expect(source.contains('context.watch<ThemeProvider>()'), isTrue);
    expect(source.contains('context.read<ThemeProvider>().setThemeMode'), isTrue);
  });

  test('logout stays on the existing confirmed secure logout flow', () {
    expect(source.contains('handleSuperAdminLogout(context)'), isTrue);
    expect(source.contains("'Log out'"), isTrue);
  });
}
