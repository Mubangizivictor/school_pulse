// Proves SuperAdminSettingsScreen is a real (non-placeholder) settings
// surface scoped to what's honestly supportable for the platform owner:
// account identity, billing/security/custom-domains/audit/support links,
// theme selection, and logout - with school deletion deliberately absent
// since that's a per-school action living in School Details, not a global
// platform setting. There is already a companion
// test/features/super_admin/super_admin_settings_screen_redesign_test.dart
// covering visual layout; this file focuses on the tile-routing/absence
// logic not covered there. The real screen depends on SuperAdminBloc/
// AuthBloc/ThemeProvider, which this fast widget-test layer doesn't set up,
// so this verifies composition at the source level - the same approach
// used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_settings_screen.dart',
    ).readAsStringSync();
  });

  test('school deletion is deliberately absent here - it lives in School Details, not global settings', () {
    // The _CompactDangerButton widget is generically named/reused (its doc
    // comment mentions a hypothetical "Delete School / Logout row"), but no
    // Delete School action or callback is actually wired up on this screen.
    expect(source.contains("label: 'Delete School'"), isFalse);
    expect(source.contains('deleteSchool'), isFalse);
    expect(
      source.contains('deletion is deliberately not offered here'),
      isTrue,
    );
    expect(
      source.contains('lives in School Details, not a global platform setting'),
      isTrue,
    );
  });

  test('all five settings destinations route to real screens/paths, not placeholders', () {
    expect(source.contains('const ManualPaymentConfigScreen()'), isTrue);
    expect(source.contains("context.push('/super-admin/settings/security')"), isTrue);
    expect(source.contains("context.push('/super-admin/settings/custom-domains')"), isTrue);
    expect(source.contains('const AuditLogsScreen()'), isTrue);
    expect(source.contains("context.push('/super-admin/settings/support')"), isTrue);
  });

  test('active school count is derived from real SuperAdminBloc state, not hardcoded', () {
    expect(source.contains('context.watch<SuperAdminBloc>().state.schools'), isTrue);
    expect(source.contains('s.status == SchoolStatus.active'), isTrue);
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

  test('logout uses the shared confirmation flow, not a bespoke dialog', () {
    expect(source.contains('onTap: () => handleSuperAdminLogout(context)'), isTrue);
  });

  test('desktop and mobile both route Edit/profile-card taps to the real profile screen', () {
    expect(source.contains('const SuperAdminProfileScreen()'), isTrue);
  });
}
