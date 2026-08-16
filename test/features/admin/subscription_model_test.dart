import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/data/models/subscription.dart';

void main() {
  group('Subscription', () {
    test('keeps all non-active subscription states distinct', () {
      for (final status in SubscriptionStatus.values.where(
        (value) => value != SubscriptionStatus.none,
      )) {
        final subscription = Subscription.fromFirestore({
          'status': status.name,
          'planNameSnapshot': 'Growth',
        });
        expect(subscription.status, status);
      }
    });

    test(
      'uses SaaS snapshots for plan, currency, entitlements and add-ons',
      () {
        final subscription = Subscription.fromFirestore({
          'subscriptionId': 'current',
          'planId': 'growth',
          'planNameSnapshot': 'Growth',
          'basePriceSnapshot': 550000,
          'currency': 'UGX',
          'billingCycle': 'termly',
          'includedModules': ['Students', 'Attendance'],
          'activeAddOns': ['Biometrics'],
        });

        expect(subscription.plan, 'Growth');
        expect(subscription.amountUgx, 550000);
        expect(subscription.modules, ['Students', 'Attendance']);
        expect(subscription.addOns, ['Biometrics']);
      },
    );
  });

  group('UsageMetric', () {
    test('distinguishes unlimited and hard-limit usage', () {
      final unlimited = UsageMetric.fromFirestore('storage', {
        'currentValue': 12,
        'status': 'unlimited',
      });
      final limited = UsageMetric.fromFirestore('students', {
        'currentValue': 2000,
        'limitValue': 2000,
        'status': 'hardLimitReached',
      });

      expect(unlimited.isUnlimited, isTrue);
      expect(limited.isUnlimited, isFalse);
      expect(limited.fraction, 1);
      expect(limited.status, UsageStatus.hardLimitReached);
    });
  });
}
