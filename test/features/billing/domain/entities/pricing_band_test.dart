import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/billing/domain/entities/pricing_band.dart';

void main() {
  group('PricingBand.fromMap', () {
    test('parses a bounded, active, past-effective band', () {
      final band = PricingBand.fromMap({
        'id': 'band1',
        'minStudents': 1,
        'maxStudents': 300,
        'amountUgx': 350000,
        'isActive': true,
        'effectiveFrom': '2026-01-01T00:00:00.000Z',
        'effectiveTo': null,
      });

      expect(band.id, 'band1');
      expect(band.minStudents, 1);
      expect(band.maxStudents, 300);
      expect(band.amountUgx, 350000);
      expect(band.isActive, isTrue);
      expect(band.effectiveTo, isNull);
    });

    test('parses maxStudents: null as unbounded', () {
      final band = PricingBand.fromMap({
        'id': 'band-unbounded',
        'minStudents': 1201,
        'maxStudents': null,
        'amountUgx': 900000,
        'isActive': true,
      });

      expect(band.maxStudents, isNull);
    });

    test('defaults missing numeric/bool fields safely', () {
      final band = PricingBand.fromMap({});

      expect(band.id, '');
      expect(band.minStudents, 0);
      expect(band.amountUgx, 0);
      expect(band.isActive, isFalse);
      expect(band.effectiveFrom, isNull);
    });
  });

  group('PricingBand.isFutureEffective', () {
    test('is true when effectiveFrom is in the future', () {
      final band = PricingBand(
        id: 'b',
        minStudents: 1,
        maxStudents: 300,
        amountUgx: 350000,
        isActive: true,
        effectiveFrom: DateTime.now().add(const Duration(days: 30)),
      );
      expect(band.isFutureEffective, isTrue);
    });

    test('is false when effectiveFrom is in the past', () {
      final band = PricingBand(
        id: 'b',
        minStudents: 1,
        maxStudents: 300,
        amountUgx: 350000,
        isActive: true,
        effectiveFrom: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(band.isFutureEffective, isFalse);
    });

    test('is false when effectiveFrom is null', () {
      const band = PricingBand(
        id: 'b',
        minStudents: 1,
        maxStudents: 300,
        amountUgx: 350000,
        isActive: true,
      );
      expect(band.isFutureEffective, isFalse);
    });
  });
}
