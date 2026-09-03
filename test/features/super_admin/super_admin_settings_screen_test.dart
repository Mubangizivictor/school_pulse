// Proves SuperAdminSettingsScreen is a real (non-placeholder) settings
// control centre for the platform owner, and that duplicated navigation is
// deliberately absent: billing / payment methods live only in the Billing
// section, audit logs only in Activity, and sign out appears once (sidebar
// footer on desktop, the account menu in this screen's header on mobile) --
// never as an in-page button here. School deletion is likewise absent: it's
// a per-school action in School Details, not a global platform setting.
// There is a companion
// test/features/super_admin/super_admin_settings_screen_redesign_test.dart
// covering the layout; this file focuses on the routing / absence logic.
// The real screen depends on AuthBloc/ThemeProvider/Firestore, which this
// fast widget-test layer doesn't set up, so this verifies composition at
// the source level -- the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_settings_screen.dart',
    ).readAsStringSync();
  });

  test('no duplicated navigation: billing / payment methods and audit logs are not linked from Settings', () {
    expect(source.contains('ManualPaymentConfigScreen'), isFalse);
    expect(source.contains('Billing & payment methods'), isFalse);
    expect(source.contains('AuditLogsScreen'), isFalse);
    expect(source.contains("'Platform audit logs'"), isFalse);
    expect(source.contains('/super-admin/audit-logs'), isFalse);
  });

  test('sign out is not an in-page button; it is reached only through the account menu', () {
    // The only logout call site is inside the header account menu handler.
    expect(source.contains("'Log out'"), isFalse);
    expect(source.contains("label: 'Logout'"), isFalse);
    expect(source.contains('_showAccountMenu'), isTrue);
    expect(source.contains('handleSuperAdminLogout(context)'), isTrue);
  });

  test('school / platform deletion is deliberately absent from global settings', () {
    expect(source.contains('deleteSchool'), isFalse);
    expect(source.contains("'Delete platform'"), isFalse);
    expect(source.contains("'Delete School'"), isFalse);
  });

  test('platform configuration destinations route to real screens / paths, not placeholders', () {
    for (final path in const [
      "context.push('/super-admin/schools')",
      "context.push('/super-admin/settings/custom-domains')",
      "context.push('/super-admin/settings/subdomain-requests')",
      "context.push('/super-admin/settings/support')",
      "context.push('/super-admin/platform-health')",
      "context.push('/super-admin/settings/security')",
    ]) {
      expect(source.contains(path), isTrue, reason: '$path missing');
    }
  });

  test('unsigned-in state falls back to a safe placeholder, not a crash on null user', () {
    expect(source.contains('final ownerName ='), isTrue);
    expect(source.contains("'SaaS Owner'"), isTrue);
    expect(source.contains("'Not signed in'"), isTrue);
  });

  test('theme selection uses the app-wide ThemeProvider, so it persists and affects the whole app', () {
    expect(source.contains('context.watch<ThemeProvider>().themeMode'), isTrue);
    expect(source.contains('context.read<ThemeProvider>().setThemeMode(value)'), isTrue);
  });

  test('edit-profile taps route to the real profile screen', () {
    expect(source.contains('const SuperAdminProfileScreen()'), isTrue);
  });
}
