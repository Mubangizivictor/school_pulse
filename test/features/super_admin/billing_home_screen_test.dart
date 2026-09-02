// Proves BillingHomeScreen (the compact "Billing" dashboard that replaced
// the separate Payments & Billing / Subscription Plans nav destinations)
// combines plan performance and payment review data on one screen, and
// exposes "Manage plans" / "Payment methods" actions that reach
// SubscriptionPlansScreen / ManualPaymentConfigScreen. The real screen
// depends on SuperAdminBloc/ManualPaymentService (Firestore/Functions),
// which this fast widget-test layer doesn't set up (no Firebase.initializeApp,
// no BlocProvider<SuperAdminBloc>), so this verifies the composition at the
// source level - the same source-inspection approach used by
// test/app/router_owner_staff_gate_test.dart for guards that need real
// BuildContext-scoped state to execute for real.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/billing_home_screen.dart',
    ).readAsStringSync();
  });

  test('BillingHomeScreen title reads Billing, not a separate Payments/Plans label', () {
    expect(source.contains("Text('Billing'"), isTrue);
    expect(source.contains("'Payments & Billing'"), isFalse);
  });

  test('BillingHomeScreen surfaces payment review (needs-review) data', () {
    expect(source.contains('_needsReviewSection'), isTrue);
    expect(source.contains('ManualPaymentStatus.pendingVerification'), isTrue);
    expect(source.contains('PaymentReviewRow'), isTrue);
  });

  test('BillingHomeScreen surfaces subscription plan performance', () {
    expect(source.contains('_planPerformanceSection'), isTrue);
    expect(source.contains('PlanPerformanceRow'), isTrue);
    expect(source.contains('state.plans'), isTrue);
  });

  test('BillingHomeScreen reaches Manage Plans and Payment Methods', () {
    expect(source.contains('Manage plans'), isTrue);
    expect(source.contains('Payment methods'), isTrue);
    expect(source.contains('_openPlans'), isTrue);
    expect(source.contains('_openPaymentMethods'), isTrue);
    expect(source.contains('SubscriptionPlansScreen()'), isTrue);
    expect(source.contains('ManualPaymentConfigScreen()'), isTrue);
  });

  test('a review row tapped opens the real PaymentReviewScreen for that payment', () {
    expect(source.contains('_openReview'), isTrue);
    expect(source.contains('PaymentReviewScreen(payment: payment)'), isTrue);
  });
}
