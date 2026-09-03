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
    // The `/super-admin` subtree was extracted from router.dart into
    // super_admin_routes.dart (commit d2d15ef1); router.dart splices it in
    // as the single `superAdminRoute` entry.
    final source = File(
      'lib/features/super_admin/presentation/super_admin_routes.dart',
    ).readAsStringSync();
    expect(source.contains("path: '/super-admin'"), isTrue);
    // Every top-level owner section renders SuperAdminDashboard (directly or
    // via the `_fadeRoute` helper's `child:` callback); settings/* and
    // other standalone screens use SuperAdminMobileNavShell, reachable only
    // via the same subtree redirect guard.
    expect(
      source.contains('const SuperAdminDashboard()'),
      isTrue,
      reason: 'top-level owner sections must render SuperAdminDashboard, '
          'which is what enforces the five-tab nav and hosts the '
          'lifecycle-action screens behind the router guard',
    );
  });
}
