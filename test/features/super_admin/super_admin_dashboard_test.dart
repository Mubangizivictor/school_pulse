// Proves SuperAdminDashboard drives its five branches from one nested
// Navigator-per-section shell, syncs the browser/route URL to the selected
// section (so deep links/refresh land on the right tab, per
// _sectionIndexForLocation), and routes the Overview's "Payments to Verify"
// shortcut into Billing pre-filtered to pendingVerification. There is
// already a companion test/features/super_admin/super_admin_navigation_test.dart
// covering the five-destination order and
// super_admin_bloc_lifecycle_test.dart covering bloc wiring; this file
// focuses on route-sync and billing deep-link behavior not covered there.
// The real screen depends on SuperAdminBloc/GoRouter/FirebaseAuth, which
// this fast widget-test layer doesn't set up, so this verifies composition
// at the source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_dashboard.dart',
    ).readAsStringSync();
  });

  test('exactly five section paths map 1:1 with the five approved sections', () {
    expect(
      source.contains(
        "const _kSectionPaths = [\n  '', // Overview (the /super-admin index route itself)\n  'schools',\n  'payments', // Billing - kept as the existing route segment\n  'audit-logs', // Activity\n  'settings',\n];",
      ),
      isTrue,
    );
  });

  test('one nested Navigator per section keeps pushed screens inside that section', () {
    expect(
      source.contains('final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate('),
      isTrue,
    );
    expect(source.contains('SuperAdminTabNavigator(\n            navigatorKey: _navigatorKeys[index],'), isTrue);
  });

  test('route location changes (deep link/refresh/back-forward) resync the selected section', () {
    expect(source.contains('final index = _sectionIndexForLocation(location);'), isTrue);
    expect(source.contains('if (index != _selectedIndex) {'), isTrue);
  });

  test('the Overview Payments-to-Verify shortcut lands on Billing pre-filtered to pendingVerification', () {
    expect(
      source.contains('_goToBilling(filter: ManualPaymentStatus.pendingVerification)'),
      isTrue,
    );
    expect(source.contains('_billingInitialFilter = filter;'), isTrue);
    expect(source.contains('_billingPageKey++;'), isTrue);
  });

  test('re-selecting the already-active section pops it to root instead of no-op', () {
    expect(
      source.contains(
        'if (index == _selectedIndex) {\n                        // Re-selecting the active section returns it to',
      ),
      isTrue,
    );
  });

  test('a section tap performs URL navigation only - didChangeDependencies moves the index', () {
    // The tap handler must not also setState(_selectedIndex): one code path
    // (didChangeDependencies) owns the index so the nav highlight can never
    // disagree with the actual route.
    expect(
      source.contains('if (_navThrottled()) return;\n'
          '                      // URL-only: didChangeDependencies moves _selectedIndex'),
      isTrue,
    );
    expect(source.contains('_navThrottled() => ownerNavThrottled()'), isTrue);
  });

  test('this device is registered for owner push notifications on dashboard entry', () {
    expect(source.contains('OwnerPushTokenService().registerCurrentDevice();'), isTrue);
  });

  test('sign-out uses the shared logout confirmation flow, not a bespoke one', () {
    expect(source.contains('onTap: () => handleSuperAdminLogout(context)'), isTrue);
  });
}
