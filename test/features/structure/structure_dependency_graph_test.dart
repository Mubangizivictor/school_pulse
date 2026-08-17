import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_graph.dart';
import 'package:school_pulse/features/structure/domain/services/structure_health_resolver.dart';

StructureSetupStep _step(String id, {List<String> after = const []}) =>
    StructureSetupStep(
      id: id,
      title: id,
      route: '/',
      complete: (_) => false,
      hardPrerequisiteIds: after,
    );

void main() {
  test('rejects an unknown prerequisite', () {
    final validator = StructureDependencyGraphValidator(
      StructureDependencyGraph([
        _step('classes', after: ['levels']),
      ]),
    );
    expect(validator.validate, throwsStateError);
  });

  test('rejects direct and indirect dependency cycles', () {
    final direct = StructureDependencyGraphValidator(
      StructureDependencyGraph([
        _step('a', after: ['b']),
        _step('b', after: ['a']),
      ]),
    );
    final indirect = StructureDependencyGraphValidator(
      StructureDependencyGraph([
        _step('a', after: ['b']),
        _step('b', after: ['c']),
        _step('c', after: ['a']),
      ]),
    );
    expect(direct.validate, throwsStateError);
    expect(indirect.validate, throwsStateError);
  });

  test('returns prerequisites before dependants', () {
    final ordered = StructureDependencyGraph([
      _step('classes', after: ['levels']),
      _step('levels', after: ['terms']),
      _step('terms'),
    ]).topologicalOrder();
    expect(ordered.map((step) => step.id), ['terms', 'levels', 'classes']);
  });
}
