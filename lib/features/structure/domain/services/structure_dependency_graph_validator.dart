import 'structure_setup_engine.dart';

/// Defensive validator for the Structure setup graph.
///
/// The wizard is deliberately sequential. A future edit that introduces an
/// unknown prerequisite, a backward dependency, or a cycle must fail tests
/// rather than creating a dead-end onboarding experience for school admins.
class StructureDependencyGraphValidator {
  const StructureDependencyGraphValidator();

  List<String> validate(List<StructureSetupStepResult> steps) {
    final errors = <String>[];
    final byId = {for (final step in steps) step.id: step};
    final order = <StructureSetupStepId, int>{
      for (var i = 0; i < steps.length; i++) steps[i].id: i,
    };

    for (final step in steps) {
      for (final prerequisite in step.prerequisites) {
        if (!byId.containsKey(prerequisite)) {
          errors.add('${step.id.name} references unknown prerequisite ${prerequisite.name}.');
          continue;
        }
        if ((order[prerequisite] ?? -1) >= (order[step.id] ?? 0)) {
          errors.add(
            '${step.id.name} depends on ${prerequisite.name}, which is not earlier in the setup order.',
          );
        }
      }
    }

    final visiting = <StructureSetupStepId>{};
    final visited = <StructureSetupStepId>{};

    bool visit(StructureSetupStepId id) {
      if (visiting.contains(id)) return true;
      if (visited.contains(id)) return false;
      visiting.add(id);
      final step = byId[id];
      if (step != null) {
        for (final prerequisite in step.prerequisites) {
          if (byId.containsKey(prerequisite) && visit(prerequisite)) return true;
        }
      }
      visiting.remove(id);
      visited.add(id);
      return false;
    }

    for (final step in steps) {
      if (visit(step.id)) {
        errors.add('The Structure setup dependency graph contains a cycle involving ${step.id.name}.');
        break;
      }
    }

    return errors;
  }
}
