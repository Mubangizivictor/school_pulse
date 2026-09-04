// Regression guard for the "tap Review -> flashes back to the list -> works
// on the 2nd/3rd try" bug.
//
// pushSuperAdminDetail syncs the URL with context.go AND pushes the detail
// screen onto the section's nested Navigator. If each /super-admin/* route
// carried its own GoRouter page key (state.pageKey), that context.go would
// swap the SuperAdminDashboard page - disposing the nested Navigator the
// push had just targeted - so the first tap landed back on the section
// list. Every shell-rendering route must therefore share ONE stable page
// key so a URL move within the subtree never rebuilds the dashboard.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/super_admin_routes.dart',
    ).readAsStringSync();
  });

  test('a single shared page key backs every console-shell route', () {
    expect(
      source.contains(
        "const ValueKey<String> _kConsoleShellPageKey = ValueKey('super-admin-shell');",
      ),
      isTrue,
    );
    // The shell builder uses that key, not the per-route state.pageKey.
    expect(source.contains('key: _kConsoleShellPageKey,'), isTrue);
  });

  test('section + detail routes use _shellRoute (shared key), not per-route keys', () {
    final collapsed = source.replaceAll(RegExp(r'\s+'), ' ');
    for (final path in [
      "_shellRoute( 'schools'",
      "_shellRoute( ':schoolId'",
      "_shellRoute('applications/:applicationId')",
      "_shellRoute( 'payments'",
      "_shellRoute(':paymentId')",
      "_shellRoute('audit-logs')",
      "_shellRoute('settings')",
    ]) {
      expect(collapsed.contains(path), isTrue, reason: 'missing $path');
    }
    // No shell route should still be built through _fadeRoute with an
    // inline `SuperAdminDashboard()` child (that carried state.pageKey).
    expect(
      collapsed.contains("_fadeRoute( 'schools'"),
      isFalse,
      reason: 'schools must be a _shellRoute, not a keyed _fadeRoute',
    );
    expect(
      collapsed.contains("_fadeRoute( 'audit-logs'"),
      isFalse,
    );
    expect(
      collapsed.contains("_fadeRoute( 'settings', child:"),
      isFalse,
    );
  });

  test('pushSuperAdminDetail pushes onto the nested Navigator before syncing the URL', () {
    final nav = File(
      'lib/features/super_admin/presentation/widgets/super_admin_tab_navigator.dart',
    ).readAsStringSync();
    final pushIdx = nav.indexOf('navigator.push<T>(');
    final goIdx = nav.indexOf('context.go(detailUrl);');
    expect(pushIdx, isNot(-1));
    expect(goIdx, isNot(-1));
    expect(
      pushIdx < goIdx,
      isTrue,
      reason: 'the nested push must happen before context.go so the URL '
          'sync cannot tear down the Navigator mid-push',
    );
  });

  test('PaymentReviewScreen.open opens the dialog/page before syncing the URL', () {
    final src = File(
      'lib/features/super_admin/presentation/pages/payment_review_screen.dart',
    ).readAsStringSync();
    // The desktop dialog and the mobile page must both start before the
    // detail-URL context.go, mirroring pushSuperAdminDetail.
    final dialogIdx = src.indexOf('showGeneralDialog<bool>(');
    final pushIdx = src.indexOf('Navigator.push<bool>(');
    final firstGoDetail = src.indexOf('context.go(detailUrl);');
    expect(dialogIdx, isNot(-1));
    expect(pushIdx, isNot(-1));
    expect(firstGoDetail, isNot(-1));
    expect(dialogIdx < firstGoDetail, isTrue);
    expect(pushIdx < src.lastIndexOf('context.go(detailUrl);'), isTrue);
    // The old racy form set the URL as the very first statement.
    expect(
      src.contains("context.go('\$sectionUrl/\${payment.id}');\n    final bool? result;"),
      isFalse,
      reason: 'the leading context.go before the push was the flash bug',
    );
  });
}
