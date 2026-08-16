import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/module_control/domain/institution_policy.dart';
import 'package:school_pulse/features/module_control/domain/policy_field_schema.dart';

void main() {
  test('every policy type has a non-empty schema with unique field keys', () {
    for (final type in InstitutionPolicyType.values) {
      final fields = PolicyFieldSchema.forType(type);
      expect(fields, isNotEmpty, reason: '$type has no fields');
      final keys = fields.map((f) => f.key).toList();
      expect(keys.toSet(), hasLength(keys.length), reason: '$type has duplicate keys');
    }
  });

  test('emergency alerts default to enabled and cannot be silently defaulted off', () {
    final defaults = PolicyFieldSchema.defaults(InstitutionPolicyType.notifications);
    expect(defaults['emergencyAlerts'], true);
  });

  test('defaults map matches every field key', () {
    for (final type in InstitutionPolicyType.values) {
      final fields = PolicyFieldSchema.forType(type);
      final defaults = PolicyFieldSchema.defaults(type);
      expect(defaults.keys.toSet(), fields.map((f) => f.key).toSet());
    }
  });
}
