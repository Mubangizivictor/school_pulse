import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/services/structure_health_resolver.dart';
import '../../domain/services/structure_wizard_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';
import 'structure_screen.dart';

/// Entry point for `/staff/admin/structure`.
///
/// Before every required wizard step (see [StructureWizardResolver]) is
/// complete or explicitly marked not-applicable, tapping Structure must land
/// the admin directly on the one thing they need to do next - never a card
/// dashboard, never tabs. This screen computes that step and pushes its
/// existing editor screen (each step screen renders a
/// `StructureWizardBanner` in its AppBar while visited this way, added at
/// the call site inside [_stepRoute]).
///
/// Steps are pushed on top of each other (never popped by this shell), so
/// each step screen's own back chevron naturally returns the admin to the
/// previous step already on the navigator stack - "Back" needs no wizard-
/// specific handling. This shell only ever pushes *forward*: whenever the
/// resolved current step changes to one not yet on the stack, it's pushed;
/// a step already visited is never re-pushed.
///
/// Once every wizard step is complete, Structure opens [StructureScreen]
/// (the existing roadmap/management view) instead - the wizard is a one-time
/// gate, not a permanent replacement for that view.
class StructureWizardScreen extends StatefulWidget {
  const StructureWizardScreen({super.key});

  @override
  State<StructureWizardScreen> createState() => _StructureWizardScreenState();
}

class _StructureWizardScreenState extends State<StructureWizardScreen> {
  final Set<String> _pushedStepIds = {};
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePush());
  }

  void _maybePush() {
    if (!mounted || _navigating) return;
    final state = context.read<StructureBloc>().state;
    if (state.isLoading) return;
    final resolved = StructureWizardResolver().resolve(state);
    final step = resolved.currentStep;
    if (step == null || _pushedStepIds.contains(step.definition.id)) return;
    _navigating = true;
    _pushedStepIds.add(step.definition.id);
    context
        .push(
          _stepRoute(step, resolved.currentStepNumber, resolved.totalSteps),
        )
        .then((_) {
          _navigating = false;
          if (!mounted) return;
          // The admin came back from a pushed step (its own back chevron,
          // or system back). Re-evaluate: if that step is now complete a
          // later one may need pushing next; if it's still incomplete
          // nothing new is pushed since it's already in _pushedStepIds.
          WidgetsBinding.instance.addPostFrameCallback((_) => _maybePush());
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StructureBloc, StructureState>(
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybePush());
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final resolved = StructureWizardResolver().resolve(state);
        if (!resolved.isComplete) {
          // The current wizard step is being pushed on top of this by
          // _maybePush; this is only ever visible for a single frame.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const StructureScreen();
      },
    );
  }
}

/// Wizard-aware route for [step] - appends the query params the step's
/// screen reads (`wizardStep`/`wizardTotal`) so it can render
/// `StructureWizardBanner` in its own AppBar without the wizard shell
/// needing to know about that screen's internals.
String _stepRoute(ResolvedSetupStep step, int stepNumber, int totalSteps) {
  final uri = Uri.parse(step.definition.route);
  final params = {
    ...uri.queryParameters,
    'wizardStep': '$stepNumber',
    'wizardTotal': '$totalSteps',
    'wizardStepId': step.definition.id,
  };
  return uri.replace(queryParameters: params).toString();
}
