// Proves StudentPricingScreen (Phase 3C replacement for
// SubscriptionPlansScreen) renders the pricing-band catalog and its owner-
// only mutation actions, and shows none of the removed plan concepts. The
// real screen depends on PricingBandRemoteDataSource (Firestore/Functions)
// and SuperAdminRepository (via injection_container), neither of which this
// fast widget-test layer sets up (no Firebase.initializeApp, no DI
// container), so this verifies composition at the source level - the same
// approach billing_home_screen_test.dart and school_subscription_screen_test.dart
// use for the same reason.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/student_pricing_screen.dart',
    ).readAsStringSync();
  });

  test(
    'renders a pricing-band list from student_pricing_bands, not a plan list',
    () {
      expect(source.contains('PricingBandRemoteDataSource'), isTrue);
      expect(source.contains('_bandsSection'), isTrue);
      expect(source.contains('getPricingBands'), isTrue);
      expect(source.contains('_rangeLabel'), isTrue);
    },
  );

  test('empty state is present for an empty band catalog', () {
    expect(source.contains('No pricing bands configured yet'), isTrue);
  });

  test('loading and error/retry states are present', () {
    expect(source.contains('SchoolPulseLoader'), isTrue);
    expect(source.contains("Text('Retry')"), isTrue);
  });

  test(
    'add pricing band action calls the owner-only createPricingBand callable',
    () {
      expect(source.contains('Add pricing band'), isTrue);
      expect(source.contains('_openCreate'), isTrue);
      expect(source.contains('createPricingBand'), isTrue);
    },
  );

  test(
    'edit action is gated to future-effective bands and calls updatePricingBand',
    () {
      expect(source.contains('isFutureEffective'), isTrue);
      expect(source.contains('Edit future-effective band'), isTrue);
      expect(source.contains('updatePricingBand'), isTrue);
    },
  );

  test(
    'deactivate action is gated to active bands and calls deactivatePricingBand',
    () {
      expect(source.contains('Deactivate band'), isTrue);
      expect(source.contains('band.isActive'), isTrue);
      expect(source.contains('deactivatePricingBand'), isTrue);
    },
  );

  test(
    'pricing-change history section reads the platform audit log filtered to pricing-band actions',
    () {
      expect(source.contains('getAuditLogs'), isTrue);
      expect(source.contains('CREATE_PRICING_BAND'), isTrue);
      expect(source.contains('UPDATE_PRICING_BAND'), isTrue);
      expect(source.contains('DEACTIVATE_PRICING_BAND'), isTrue);
    },
  );

  test('shows none of the removed plan concepts', () {
    expect(source.contains('planName'), isFalse);
    expect(source.contains('BillingCycle'), isFalse);
    expect(source.contains('Monthly'), isFalse);
    expect(source.contains('Annual'), isFalse);
    expect(source.contains('isPopular'), isFalse);
    expect(source.contains('customPricing'), isFalse);
    expect(source.contains('Save plan'), isFalse);
  });

  test(
    'states the every-feature-included / student-count-only pricing rule',
    () {
      expect(
        source.contains('All School Pulse features are included.'),
        isTrue,
      );
      expect(source.contains('Price is based only'), isTrue);
      expect(source.contains('verified enrolled learners per term'), isTrue);
    },
  );
}
