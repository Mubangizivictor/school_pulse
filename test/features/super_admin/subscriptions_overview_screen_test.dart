// Proves SubscriptionsOverviewScreen (the cross-school subscription
// standing rollup) shows pricing-band labels derived from
// subscription_cycles.pricingSnapshot instead of the removed plan-name/
// plan-filter UI. The real screen depends on SuperAdminBloc/Firestore
// (no Firebase.initializeApp, no BlocProvider<SuperAdminBloc> here), so this
// verifies composition at the source level - the same approach
// billing_home_screen_test.dart and school_subscription_screen_test.dart use
// for the same reason.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/subscriptions_overview_screen.dart',
    ).readAsStringSync();
  });

  test('no plan-filter UI or plan-name lookups remain', () {
    expect(source.contains('_PlanFilterChips'), isFalse);
    expect(source.contains('_planFilter'), isFalse);
    expect(source.contains('_planName'), isFalse);
    expect(source.contains('SubscriptionPlan'), isFalse);
  });

  test('subscription rows derive a pricing-band label from pricingSnapshot, absent gracefully', () {
    expect(source.contains('_pricingBandLabel'), isTrue);
    expect(source.contains('cycle?.pricingSnapshot'), isTrue);
    expect(source.contains('learners'), isTrue);
  });

  test('search is scoped to school name only, not plan', () {
    expect(source.contains('Search by school name'), isTrue);
  });
}
