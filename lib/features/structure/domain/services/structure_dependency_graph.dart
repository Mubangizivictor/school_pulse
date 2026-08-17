import 'structure_health_resolver.dart';

/// The dependency graph used by Structure setup.  This intentionally lives
/// outside widgets: navigation, health, validation and tests all ask this
/// object the same question rather than carrying their own prerequisite
/// lists.
class StructureDependencyGraph {
  const StructureDependencyGraph(this.steps);

  final Iterable<StructureSetupStep> steps;

  Map<String, StructureSetupStep> get byId => {
    for (final step in steps) step.id: step,
  };

  /// Returns prerequisite ids which are not registered, in stable order.
  List<String> unknownPrerequisites() {
    final known = byId;
    return [
      for (final step in steps)
        for (final prerequisite in step.hardPrerequisiteIds)
          if (!known.containsKey(prerequisite)) '${step.id} -> $prerequisite',
    ];
  }

  /// A topological order of the registered graph. Throws rather than
  /// guessing when a graph error would make onboarding unsafe.
  List<StructureSetupStep> topologicalOrder() {
    final definitions = byId;
    final unknown = unknownPrerequisites();
    if (unknown.isNotEmpty) {
      throw StateError(
        'Unknown Structure prerequisite(s): ${unknown.join(', ')}',
      );
    }
    final visiting = <String>{};
    final visited = <String>{};
    final result = <StructureSetupStep>[];
    void visit(String id, List<String> path) {
      if (visited.contains(id)) return;
      if (!visiting.add(id)) {
        throw StateError(
          'Circular Structure dependency: ${[...path, id].join(' -> ')}',
        );
      }
      final step = definitions[id]!;
      for (final prerequisite in step.hardPrerequisiteIds) {
        visit(prerequisite, [...path, id]);
      }
      visiting.remove(id);
      visited.add(id);
      result.add(step);
    }

    for (final step in steps) {
      visit(step.id, const []);
    }
    return result;
  }
}

/// Testable guard for the registry. A broken graph is a release blocker: it
/// otherwise produces locked screens that an administrator cannot resolve.
class StructureDependencyGraphValidator {
  const StructureDependencyGraphValidator(this.graph);

  final StructureDependencyGraph graph;

  void validate() {
    graph.topologicalOrder();
  }

  void validateWizardOrder(List<String> wizardStepIds) {
    validate();
    final all = graph.byId;
    final positions = <String, int>{
      for (var index = 0; index < wizardStepIds.length; index++)
        wizardStepIds[index]: index,
    };
    for (final id in wizardStepIds) {
      if (!all.containsKey(id)) {
        throw StateError('Wizard step "$id" is not registered.');
      }
    }
    for (final step in all.values) {
      final stepPosition = positions[step.id];
      if (stepPosition == null) continue;
      for (final prerequisite in step.hardPrerequisiteIds) {
        final prerequisitePosition = positions[prerequisite];
        if (prerequisitePosition != null &&
            prerequisitePosition >= stepPosition) {
          throw StateError(
            'Wizard step "${step.id}" is ordered before "$prerequisite".',
          );
        }
      }
    }
  }
}
