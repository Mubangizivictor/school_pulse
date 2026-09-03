// Proves Screen B (school_subscription_screen.dart) renders real plan/
// renewal state, a compact recent-payments list, and links into the real
// Billing history - replacing the old black subscription block and giant
// "No payments yet" whitespace. The real screen depends on
// ManualPaymentService (Cloud Functions), which this fast widget-test layer
// doesn't set up (no Firebase.initializeApp), so this verifies composition
// at the source level - the same approach billing_home_screen_test.dart
// uses for the same reason.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/school_subscription_screen.dart',
    ).readAsStringSync();
  });

  test('shows real renewal and days-remaining state, not a black block', () {
    expect(source.contains('school.subscriptionExpiry'), isTrue);
    expect(source.contains('daysRemaining'), isTrue);
    expect(source.contains('Colors.black'), isFalse);
  });

  test('shows verified-student-count pricing, not a plan name/price', () {
    expect(source.contains('cycle.planSnapshot'), isFalse);
    expect(source.contains('pricingSnapshot'), isTrue);
    expect(source.contains('Pricing review needed'), isTrue);
    expect(source.contains('Termly student pricing'), isTrue);
    expect(
      source.contains(
        'All School Pulse features are included for this school.',
      ),
      isTrue,
    );
  });

  test('recent payments are scoped to this school and show status chips', () {
    expect(source.contains('p.schoolId == widget.school.id'), isTrue);
    expect(source.contains('ManualPaymentStatus.approved'), isTrue);
    expect(source.contains('ManualPaymentStatus.rejected'), isTrue);
    expect(source.contains('ManualPaymentStatus.pendingVerification'), isTrue);
  });

  test('empty and error payment states are compact, not giant blank areas', () {
    expect(source.contains('No payments recorded for this school yet.'), isTrue);
    expect(source.contains('EmptyState('), isFalse);
  });

  test('View all payments reaches the real Billing history screen', () {
    expect(source.contains('BillingHomeScreen()'), isTrue);
  });

  test('Manage subscription is present and reaches subscription management', () {
    expect(source.contains('Manage subscription'), isTrue);
  });

  test('Term cycle history section is present, reads from subscription_cycles, and clones the payments-list shape', () {
    expect(source.contains("'Term cycle history'"), isTrue);
    expect(source.contains('_buildCyclesList'), isTrue);
    expect(source.contains('getSubscriptionCyclesForSchool'), isTrue);
    expect(source.contains('ListView.separated('), isTrue);
    expect(source.contains('shrinkWrap: true'), isTrue);
    expect(source.contains('NeverScrollableScrollPhysics()'), isTrue);
  });

  test('cycle rows show a status badge via the shared mapping, not raw Colors', () {
    expect(source.contains('cycleStatusLabel(cycle.cycleStatus)'), isTrue);
    expect(source.contains('cycleStatusColor(context, cycle.cycleStatus)'), isTrue);
  });

  test('compact current-cycle info block shows term price, band, verified learners, invoice/due/grace dates, no raw IDs', () {
    expect(source.contains('_CurrentCycleInfoBlock'), isTrue);
    expect(source.contains("'Term price'"), isTrue);
    expect(source.contains("'Verified learners'"), isTrue);
    expect(source.contains("'Band'"), isTrue);
    expect(source.contains("'Amount due'"), isTrue);
    expect(source.contains("'Payment due'"), isTrue);
    expect(source.contains("'Grace ends'"), isTrue);
    expect(source.contains('cycle.id'), isFalse);
  });
}
