import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../../domain/services/structure_health_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

/// A calm, scannable health summary for the guided setup—not a second settings hub.
class SetupProgressScreen extends StatelessWidget {
  const SetupProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: const AdminAppBar(title: 'Setup Progress'),
    body: BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final health = StructureHealthResolver().resolve(state);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          children: [
            Text(
              'Configuration health',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'Review progress and continue with the next school setup task.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            _HealthSummary(health: health),
            const SizedBox(height: 24),
            Text(
              'Setup areas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...health.sections.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SectionProgressCard(
                  section: entry.$2,
                  health: health,
                  accent: _accentFor(context, entry.$1),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _HealthSummary extends StatelessWidget {
  const _HealthSummary({required this.health});
  final StructureHealth health;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _progressSurface(context, emphasis: true),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _progressBorder(context)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: CircularProgressIndicator(
                    value: health.ratio,
                    strokeWidth: 7,
                    backgroundColor: colors.primary.withValues(alpha: .18),
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
                Text(
                  '${health.percentage}%',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${health.completedRequired} completed • ${health.remaining} remaining',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (health.needsAttention > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${health.needsAttention} step${health.needsAttention == 1 ? '' : 's'} need attention',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionProgressCard extends StatelessWidget {
  const _SectionProgressCard({
    required this.section,
    required this.health,
    required this.accent,
  });
  final StructureSetupSection section;
  final StructureHealth health;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final steps = section.steps.map((s) => health.steps[s.id]!).toList();
    final required = steps
        .where(
          (s) =>
              s.definition.required &&
              s.status != SetupStepStatus.notApplicable,
        )
        .toList();
    final done = required
        .where((s) => s.status == SetupStepStatus.completed)
        .length;
    final progress = required.isEmpty ? 1.0 : done / required.length;
    return Material(
      color: _progressSurface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _progressBorder(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () =>
            context.push('/staff/admin/structure?section=${section.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: Icon(section.icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$done of ${required.length} required steps completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        color: accent,
                        backgroundColor: colors.primary.withValues(alpha: .15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

Color _accentFor(BuildContext context, int index) {
  final colors = Theme.of(context).colorScheme;
  return switch (index % 5) {
    0 => colors.primary,
    1 => colors.tertiary,
    2 => colors.secondary,
    3 => colors.error,
    _ => colors.primaryContainer,
  };
}

Color _progressSurface(BuildContext context, {bool emphasis = false}) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return emphasis ? AppColors.elevatedSurfaceDark : AppColors.surfaceDark;
  }
  return AppColors.surfaceLight;
}

Color _progressBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.borderDark
    : AppColors.borderLight;
