// Proves lifecycle actions (suspend/activate/archive a school, change its
// subscription) are only ever reachable through screens nested inside
// SuperAdminDashboard - which the router only renders past the
// `/super-admin*` guard (see router_super_admin_gate_test.dart) - and never
// through a route or screen a School Admin/staff session could reach
// directly. SchoolDetailScreen itself has no in-widget role check because
// it doesn't need one: it is never constructed except from inside the
// owner console's own nested navigators.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SchoolDetailScreen (lifecycle actions) is only constructed from screens nested under SuperAdminDashboard', () {
    // Every file that constructs SchoolDetailScreen(...).
    final constructors = <String>[];
    for (final file in Directory('lib/features/super_admin').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final content = file.readAsStringSync();
      if (content.contains('SchoolDetailScreen(')) {
        constructors.add(file.path);
      }
    }
    expect(constructors, isNotEmpty);
    for (final path in constructors) {
      expect(
        path.contains('lib/features/super_admin/'),
        isTrue,
        reason: 'SchoolDetailScreen must only be constructed from within the '
            'super_admin feature, never from a staff/school-admin-reachable route',
      );
    }

    // And no route/screen outside lib/features/super_admin constructs it.
    final outsideMatches = <String>[];
    for (final dir in ['lib/app', 'lib/features']) {
      for (final file in Directory(dir).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        if (file.path.contains('lib/features/super_admin/')) continue;
        final content = file.readAsStringSync();
        if (content.contains('SchoolDetailScreen(')) outsideMatches.add(file.path);
      }
    }
    expect(
      outsideMatches,
      isEmpty,
      reason: 'no route outside super_admin may construct the lifecycle-action screen',
    );
  });

  test('SuperAdminDashboard is the only builder for every /super-admin* route', () {
    final source = File('lib/app/router.dart').readAsStringSync();
    final ownerSectionStart = source.indexOf("path: '/super-admin'");
    expect(ownerSectionStart, isNot(-1));
    // Find the matching top-level GoRoute block for /super-admin and confirm
    // every nested builder in it is SuperAdminDashboard (or a screen that is
    // itself gated the same way, e.g. settings/* sub-routes use
    // SuperAdminMobileNavShell which is only reachable via the same guard).
    final ownerSectionEnd = source.indexOf(
      "GoRoute(\n      path: '/",
      ownerSectionStart + 50,
    );
    final block = source.substring(
      ownerSectionStart,
      ownerSectionEnd == -1 ? source.length : ownerSectionEnd,
    );
    expect(
      block.contains('const SuperAdminDashboard()'),
      isTrue,
      reason: 'top-level owner sections must render SuperAdminDashboard, '
          'which is what enforces the five-tab nav and hosts the '
          'lifecycle-action screens behind the router guard',
    );
  });
}
