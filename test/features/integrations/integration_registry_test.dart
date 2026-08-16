import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/integrations/domain/integration_registry.dart';

void main() {
  test(
    'integration registry has unique keys and complete required metadata',
    () {
      final keys = IntegrationRegistry.definitions
          .map((item) => item.key)
          .toList();
      expect(keys.toSet(), hasLength(keys.length));
      for (final item in IntegrationRegistry.definitions) {
        expect(item.displayName, isNotEmpty);
        expect(item.requiredModule, isNotEmpty);
        expect(item.minimumEntitlement, isNotEmpty);
        expect(IntegrationRegistry.byKey(item.key), same(item));
      }
    },
  );

  test('payment integrations are distinct institution gateway contracts', () {
    final payments = IntegrationRegistry.definitions.where(
      (item) => item.category == IntegrationCategory.payments,
    );
    expect(
      payments.map((item) => item.key),
      containsAll([
        'institution_mtn_momo',
        'institution_airtel_money',
        'pesapal',
      ]),
    );
    expect(payments.every((item) => item.sensitivity == 'high'), isTrue);
  });
}
