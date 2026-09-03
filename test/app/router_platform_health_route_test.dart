// Structural counterpart to router_super_admin_gate_test.dart: proves the
// /super-admin/platform-health route is registered nested inside the
// /super-admin route's routes: array (so it inherits the blanket
// SuperAdmin-only guard tested there for free) and wrapped in
// SuperAdminMobileNavShell like every other standalone Super Admin screen
// (settings/security, settings/support). Does not re-test the guard itself.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    // The /super-admin subtree lives in super_admin_routes.dart since the
    // owner-console route extraction (commit d2d15ef1).
    source = File(
      'lib/features/super_admin/presentation/super_admin_routes.dart',
    ).readAsStringSync();
  });

  test('platform-health is registered as a route within the /super-admin subtree', () {
    final superAdminIndex = source.indexOf("path: '/super-admin'");
    expect(superAdminIndex, isNot(-1));

    // The `_fadeRoute` helper takes the path as its first positional arg,
    // so the route reads `_fadeRoute(\n  'platform-health',` rather than
    // `path: 'platform-health'`.
    final platformHealthIndex = source.indexOf("'platform-health'");
    expect(platformHealthIndex, isNot(-1), reason: 'platform-health route is missing');
    expect(
      platformHealthIndex,
      greaterThan(superAdminIndex),
      reason: 'platform-health must be nested inside /super-admin to inherit its guard',
    );
  });

  test('platform-health route renders PlatformHealthScreen wrapped in SuperAdminMobileNavShell', () {
    final routeIndex = source.indexOf("'platform-health'");
    final window = source.substring(routeIndex, (routeIndex + 200).clamp(0, source.length));
    expect(window.contains('SuperAdminMobileNavShell'), isTrue);
    expect(window.contains('PlatformHealthScreen()'), isTrue);
  });

  test('the subtree imports platform_health_screen.dart', () {
    expect(
      source.contains("import 'package:school_pulse/features/super_admin/presentation/pages/platform_health_screen.dart';"),
      isTrue,
    );
  });
}
