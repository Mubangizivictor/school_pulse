import '../../presentation/bloc/structure_state.dart';
import 'structure_health_resolver.dart';
import 'structure_dependency_graph.dart';

/// Drives the sequential Structure Setup wizard. Reuses
/// [StructureHealthResolver]'s existing dependency-ordered step registry as
/// the single source of truth for what a step is and when it's complete -
/// this resolver only adds wizard-specific concerns: linear ordering,
/// "what's the one next step", and cycle safety.
///
class StructureWizardResolver {
  StructureWizardResolver({StructureHealthResolver? healthResolver})
    : _healthResolver = healthResolver ?? StructureHealthResolver();

  final StructureHealthResolver _healthResolver;

  /// Ordered ids of the steps that belong to the sequential wizard. Order
  /// here is the wizard's presentation order; it must be consistent with
  /// (a topological sort of) each step's hardPrerequisiteIds, which
  /// [validateAcyclic] checks.
  static const List<String> wizardStepIds = [
    'institution-info',
    'institution-settings',
    'campuses',
    'academic-years',
    'terms',
    'levels',
    'departments',
    'classes',
    'streams',
    'subjects',
    'subject-class-assignments',
    'grading',
  ];

  /// Resolves current health, then returns the ordered, wizard-scoped
  /// subset as [ResolvedWizardStep]s (only steps in [wizardStepIds], in
  /// wizard order, filtered to those the health resolver says are
  /// applicable to this school).
  ResolvedStructureWizard resolve(StructureState state) {
    final health = _healthResolver.resolve(state);
    final steps = <ResolvedSetupStep>[];
    for (final id in wizardStepIds) {
      final resolved = health.steps[id];
      if (resolved == null) continue;
      if (resolved.status == SetupStepStatus.notApplicable) continue;
      steps.add(resolved);
    }
    return ResolvedStructureWizard(health, steps);
  }

  /// Verifies the wizard's declared order is a valid topological order of
  /// the underlying dependency graph, and that the graph itself has no
  /// cycles. Throws a [StateError] describing the problem - intended to be
  /// called from a test (see structure_wizard_resolver_test.dart), not at
  /// runtime.
  void validateAcyclic() {
    StructureDependencyGraphValidator(
      StructureDependencyGraph(
        StructureHealthResolver.registry.expand((section) => section.steps),
      ),
    ).validateWizardOrder(wizardStepIds);
  }
}

class ResolvedStructureWizard {
  const ResolvedStructureWizard(this.health, this.steps);

  final StructureHealth health;

  /// Applicable wizard steps in presentation order.
  final List<ResolvedSetupStep> steps;

  int get totalSteps => steps.length;

  int get currentIndex {
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].definition.required && !steps[i].isComplete) return i;
    }
    return steps.length - 1;
  }

  /// The step the admin should be looking at right now, or null if every
  /// required wizard step is complete/not-applicable.
  ///
  /// Optional steps (Departments, Streams) never gate the sequential flow -
  /// an untouched optional step is silently passed over here so the wizard
  /// always advances to the next *required* gap. They stay fully editable
  /// afterwards from Structure Management; this only affects which step the
  /// auto-advancing wizard pushes next.
  ResolvedSetupStep? get currentStep {
    for (final step in steps) {
      if (step.definition.required && !step.isComplete) return step;
    }
    return null;
  }

  bool get isComplete => currentStep == null;

  /// 1-based position of [currentStep] for "Step X of Y" display.
  int get currentStepNumber => currentIndex + 1;
}
