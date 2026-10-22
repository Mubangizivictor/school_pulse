import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/structure_wizard_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

/// "Step X of Y" progress strip + Continue action injected into a step
/// screen's `AdminAppBar.bottom` while it's being visited as part of the
/// sequential Structure Setup wizard. Absent entirely once the admin is
/// editing that same screen from the post-setup Structure Management view -
/// screens stay otherwise unchanged, this is the only wizard chrome they
/// carry.
///
/// Continue always re-derives completion from live [StructureBloc] state via
/// [StructureWizardResolver] rather than trusting a local "did they touch the
/// form" flag - the wizard step this screen represents ([stepId]) must
/// actually be complete (or Skip, only when optional) before this pops the
/// route and lets `StructureWizardScreen` advance.
class StructureWizardBanner extends StatelessWidget
    implements PreferredSizeWidget {
  const StructureWizardBanner({
    super.key,
    required this.stepId,
    required this.stepNumber,
    required this.totalSteps,
  });

  final String stepId;
  final int stepNumber;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = totalSteps == 0 ? 0.0 : stepNumber / totalSteps;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final resolved = StructureWizardResolver().resolve(state);
        final step = resolved.steps
            .where((s) => s.definition.id == stepId)
            .firstOrNull;
        final canContinue = step?.isComplete ?? false;
        final canSkip = step != null && !step.definition.required;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Structure Setup · Step $stepNumber of $totalSteps',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 4,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (canSkip && !canContinue)
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Skip for now'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: canContinue
                        ? () => Navigator.of(context).maybePop()
                        : null,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(78);
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
