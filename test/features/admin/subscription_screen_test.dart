// Compliance test for the "School Admin must never see price" business rule
// (Phase 3C). lib/features/admin/subscription_screen.dart (SubscriptionScreen)
// is routed live at /school-admin/subscription and reachable by School
// Admins - before this phase it showed a plan-picker with per-plan prices
// and an "Amount" fact row with the school's own subscription price, which
// directly violated the rule. This screen was kept (option b: strip price/
// plan-picker UI, keep usage/entitlements/invoices/history which remain
// useful School-Admin-facing content) rather than redirected to the
// calendar screen, since it has real non-price content worth preserving.
//
// The real screen depends on SubscriptionRepository (Firestore streams via
// injection_container), which this fast widget-test layer doesn't set up
// (no Firebase.initializeApp, no DI container), so this verifies the
// business rule at the source level - the same approach used by
// billing_home_screen_test.dart / school_subscription_screen_test.dart for
// screens with the same real-backend dependency.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/admin/subscription_screen.dart',
    ).readAsStringSync();
  });

  test('no amount/price is ever rendered', () {
    expect(source.contains("_fact(\n                'Amount'"), isFalse);
    expect(source.contains("'Amount',"), isFalse);
    expect(source.contains('sub.amountUgx'), isFalse);
    expect(source.contains('NumberFormat.decimalPattern()'), isFalse);
  });

  test('no plan picker / plan-change / add-on marketplace UI remains', () {
    expect(source.contains('_choosePlan'), isFalse);
    expect(source.contains('_confirmAddOn'), isFalse);
    expect(source.contains('Compare plans'), isFalse);
    expect(source.contains('watchAvailablePlans'), isFalse);
    expect(source.contains("'Plans & add-ons'"), isFalse);
    expect(source.contains("'Plan & entitlements'"), isFalse);
  });

  test('states the every-feature-included rule instead of a plan name', () {
    expect(
      source.contains(
        'All School Pulse features are included for this school.',
      ),
      isTrue,
    );
    expect(source.contains('sub.plan,'), isFalse);
  });

  test('status/renewal/auto-renewal facts are still shown (status, not price)', () {
    expect(source.contains("_fact('Renewal', date)"), isTrue);
    expect(source.contains("'Auto-renewal'"), isTrue);
    expect(source.contains('StatusBadge('), isTrue);
  });

  test('Pay / Renew and Contact billing actions remain reachable', () {
    expect(source.contains('Pay / Renew'), isTrue);
    expect(source.contains('Contact billing'), isTrue);
    expect(source.contains('MtnMomoPaymentScreen'), isTrue);
  });
}
