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
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test('platform-health is registered as a path within the /super-admin route', () {
    final superAdminIndex = source.indexOf("path: '/super-admin'");
    expect(superAdminIndex, isNot(-1));

    final platformHealthIndex = source.indexOf("path: 'platform-health'");
    expect(platformHealthIndex, isNot(-1), reason: 'platform-health route is missing');
    expect(
      platformHealthIndex,
      greaterThan(superAdminIndex),
      reason: 'platform-health must be nested inside /super-admin to inherit its guard',
    );
  });

  test('platform-health route renders PlatformHealthScreen wrapped in SuperAdminMobileNavShell', () {
    final routeIndex = source.indexOf("path: 'platform-health'");
    final window = source.substring(routeIndex, (routeIndex + 200).clamp(0, source.length));
    expect(window.contains('SuperAdminMobileNavShell'), isTrue);
    expect(window.contains('PlatformHealthScreen()'), isTrue);
  });

  test('router imports platform_health_screen.dart', () {
    expect(
      source.contains("import 'package:school_pulse/features/super_admin/presentation/pages/platform_health_screen.dart';"),
      isTrue,
    );
  });
}
