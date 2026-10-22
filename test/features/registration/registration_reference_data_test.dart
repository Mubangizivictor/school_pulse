import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/registration/data/registration_reference_data.dart';

void main() {
  group('tierForCount', () {
    test('maps learner counts to the A1 plan bands', () {
      expect(tierForCount(1).label, 'Starter');
      expect(tierForCount(300).label, 'Starter');
      expect(tierForCount(301).label, 'Growth');
      expect(tierForCount(700).label, 'Growth');
      expect(tierForCount(701).label, 'Pro');
      expect(tierForCount(1500).label, 'Pro');
      expect(tierForCount(1501).label, 'Enterprise');
    });

    test('Enterprise has no price and no submittable plan', () {
      final tier = tierForCount(5000);
      expect(tier.price, isNull);
      expect(tier.plan, isNull);
      expect(yearlyPrice(tier), isNull);
    });

    test('price is flat per term, matching the backend plan defaults', () {
      expect(tierForCount(450).price, 550000);
      expect(tierForCount(450).plan, 'Growth');
    });
  });

  test('yearly price is 3 terms at about 10% off', () {
    expect(yearlyPrice(tierForCount(450)), 1485000);
    expect(yearlyPrice(tierForCount(100)), 945000);
    expect(yearlyPrice(tierForCount(1000)), 2160000);
  });
}
