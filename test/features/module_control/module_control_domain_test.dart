import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/module_control/domain/institution_policy.dart';
import 'package:school_pulse/features/module_control/domain/module_dependency_resolver.dart';
import 'package:school_pulse/features/module_control/domain/module_registry.dart';
import 'package:school_pulse/features/module_control/domain/policy_resolver.dart';

void main() {
  test('registry has unique keys and resolvable dependencies', () {
    final keys = ModuleRegistry.all.map((m) => m.key).toList();
    expect(keys.toSet(), hasLength(keys.length));
    for (final module in ModuleRegistry.all) {
      for (final dependency in module.dependencies) {
        expect(() => ModuleRegistry.byKey(dependency), returnsNormally);
      }
    }
  });
  test('dependencies identify missing prerequisites and active dependents', () {
    const resolver = ModuleDependencyResolver();
    final reports = ModuleRegistry.byKey('reports');
    expect(
      resolver.missing(reports, {'students', 'structure'}).single.key,
      'assessments',
    );
    expect(
      resolver.dependentsOf('assessments', {'reports'}).single.key,
      'reports',
    );
  });
  test('more-specific active policy takes precedence', () {
    final now = DateTime(2026);
    InstitutionPolicy policy(String id, PolicyScope scope, int version) =>
        InstitutionPolicy(
          id: id,
          institutionId: 'a',
          name: id,
          createdBy: 'u',
          updatedBy: 'u',
          changeReason: 'test',
          type: InstitutionPolicyType.attendance,
          scope: scope,
          configuration: const {},
          status: PolicyStatus.active,
          version: version,
          effectiveFrom: now.subtract(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        );
    final resolved = const PolicyResolver().resolve(
      [
        policy('institution', const PolicyScope(), 2),
        policy(
          'division',
          const PolicyScope(type: PolicyScopeType.division, targetId: 'p7'),
          1,
        ),
      ],
      InstitutionPolicyType.attendance,
      divisionId: 'p7',
      at: now,
    );
    expect(resolved!.id, 'division');
  });
}
