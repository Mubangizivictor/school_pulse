import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/structure/domain/services/structure_health_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

/// A live roadmap. Editors stay in their existing feature screens; all status
/// here is derived from the current school’s StructureBloc data.
class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key, this.initialSection = 'overview'});
  final String initialSection;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AdminAppBar(
      title: 'Structure Setup',
      actions: [
        IconButton(
          tooltip: 'Progress details',
          onPressed: () => context.push('/staff/admin/structure/progress'),
          icon: const Icon(Icons.task_alt_outlined),
        ),
      ],
    ),
    body: BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final health = StructureHealthResolver().resolve(state);
        final section = health.sections
            .where((s) => s.id == initialSection)
            .firstOrNull;
        return section == null ? _Overview(health) : _Details(health, section);
      },
    ),
  );
}

class _Overview extends StatelessWidget {
  const _Overview(this.health);
  final StructureHealth health;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    children: [
      Text(
        'Structure Setup',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        'Complete your school structure step by step.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 18),
      _ProgressCard(health),
      const SizedBox(height: 20),
      ...health.sections.map(
        (section) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _SectionCard(health, section),
        ),
      ),
    ],
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard(this.health);
  final StructureHealth health;
  @override
  Widget build(BuildContext context) => Material(
    color: _setupSurface(context, emphasis: true),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _setupBorder(context)),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/staff/admin/structure/progress'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: health.ratio,
                    strokeWidth: 6,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .18),
                  ),
                  Text(
                    '${health.percentage}%',
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
                    'Overall Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${health.completedRequired} completed • ${health.remaining} remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(this.health, this.section);
  final StructureHealth health;
  final StructureSetupSection section;
  @override
  Widget build(BuildContext context) {
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
    final next = steps
        .where(
          (s) =>
              s.definition.required &&
              (s.status == SetupStepStatus.available ||
                  s.status == SetupStepStatus.inProgress ||
                  s.status == SetupStepStatus.needsAttention),
        )
        .firstOrNull;
    final completed = required.isNotEmpty && done == required.length;
    return Material(
      color: _setupSurface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _setupBorder(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            context.push('/staff/admin/structure?section=${section.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      section.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          section.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '$done/${required.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: required.isEmpty ? 1 : done / required.length,
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 82,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: completed
                          ? null
                          : () => next == null
                                ? context.push(
                                    '/staff/admin/structure?section=${section.id}',
                                  )
                                : _open(context, next),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: Text(
                        completed
                            ? 'Completed'
                            : next == null
                            ? 'View'
                            : done == 0
                            ? 'Start'
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details(this.health, this.section);
  final StructureHealth health;
  final StructureSetupSection section;
  @override
  Widget build(BuildContext context) {
    final required = section.steps
        .map((step) => health.steps[step.id]!)
        .where(
          (step) =>
              step.definition.required &&
              step.status != SetupStepStatus.notApplicable,
        )
        .toList();
    final isComplete =
        required.isNotEmpty &&
        required.every((step) => step.status == SetupStepStatus.completed);
    final sectionIndex = health.sections.indexOf(section);
    final nextSection = health.sections.skip(sectionIndex + 1).firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(
          section.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          section.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        ...section.steps.indexed.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StepTile(entry.$1 + 1, health.steps[entry.$2.id]!, health),
          ),
        ),
        if (section.steps.length == 1 && !isComplete) ...[
          const SizedBox(height: 6),
          _SectionGuideCard(step: required.firstOrNull, health: health),
        ],
        if (isComplete && nextSection != null) ...[
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This part is complete',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('Continue with ${nextSection.title}.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push(
                      '/staff/admin/structure?section=${nextSection.id}',
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('Continue to ${nextSection.title}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Single-action areas such as Finance and Communication used to leave a
/// nearly empty screen under their lone setup tile. Give administrators a
/// clear explanation and an immediate way forward instead.
class _SectionGuideCard extends StatelessWidget {
  const _SectionGuideCard({required this.step, required this.health});
  final ResolvedSetupStep? step;
  final StructureHealth health;

  @override
  Widget build(BuildContext context) {
    if (step == null) return const SizedBox.shrink();
    final locked = step!.status == SetupStepStatus.locked;
    final prerequisite = locked && step!.blockedBy.isNotEmpty
        ? health.steps[step!.blockedBy.first]
        : null;
    final title = locked ? 'Before you begin' : 'Ready when you are';
    final message = locked
        ? '${step!.definition.title} becomes available after ${prerequisite?.definition.title ?? 'the required setup'} is complete.'
        : 'This area has one setup action. Open it to configure ${step!.definition.title.toLowerCase()}.';
    return Material(
      color: _setupSurface(context, emphasis: true),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _setupBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  locked ? Icons.lock_outline : Icons.task_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            if (prerequisite != null)
              FilledButton.icon(
                onPressed: () => _open(context, prerequisite),
                icon: const Icon(Icons.arrow_forward),
                label: Text('Go to ${prerequisite.definition.title}'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _open(context, step!),
                icon: const Icon(Icons.open_in_new),
                label: Text('Open ${step!.definition.title}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile(this.number, this.step, this.health);
  final int number;
  final ResolvedSetupStep step;
  final StructureHealth health;
  @override
  Widget build(BuildContext context) {
    final locked = step.status == SetupStepStatus.locked;
    final color = switch (step.status) {
      SetupStepStatus.completed => Colors.green,
      SetupStepStatus.needsAttention => Colors.orange,
      SetupStepStatus.available ||
      SetupStepStatus.inProgress => Theme.of(context).colorScheme.primary,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    final label = switch (step.status) {
      SetupStepStatus.completed => 'Completed',
      SetupStepStatus.needsAttention => 'Needs attention',
      SetupStepStatus.locked => 'Complete earlier steps first',
      SetupStepStatus.optional => 'Optional',
      SetupStepStatus.notApplicable => 'Not applicable',
      SetupStepStatus.inProgress => 'In progress',
      _ => 'Ready to set up',
    };
    final icon = switch (step.status) {
      SetupStepStatus.completed => Icons.check,
      SetupStepStatus.locked => Icons.lock_outline,
      SetupStepStatus.needsAttention => Icons.priority_high,
      SetupStepStatus.notApplicable => Icons.remove,
      _ => Icons.circle_outlined,
    };
    return Material(
      color: step.status == SetupStepStatus.inProgress
          ? _setupSurface(context, emphasis: true)
          : _setupSurface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _setupBorder(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            locked ? _blocked(context, step, health) : _open(context, step),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: .16),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$number. ${step.definition.title}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _open(BuildContext context, ResolvedSetupStep step) =>
    context.push(step.definition.route);
void _blocked(
  BuildContext context,
  ResolvedSetupStep step,
  StructureHealth health,
) {
  final names = step.blockedBy
      .map((id) => health.steps[id]?.definition.title ?? id)
      .toList();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheet) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          color: _setupSurface(sheet, emphasis: true),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 34,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(sheet).colorScheme.outline,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Complete this first',
                  style: Theme.of(sheet).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...names.map(
                  (name) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        sheet,
                      ).colorScheme.primary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.checklist_outlined,
                          size: 18,
                          color: Theme.of(sheet).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(name)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheet);
                      _open(context, health.steps[step.blockedBy.first]!);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Go to required step'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Uses the application’s actual surface tokens. `ColorScheme` generates
/// intermediate seed colours, which can become overly saturated on a branded
/// navy palette; these tokens are the surfaces used by the rest of the app.
Color _setupSurface(BuildContext context, {bool emphasis = false}) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return emphasis ? AppColors.elevatedSurfaceDark : AppColors.surfaceDark;
  }
  return AppColors.surfaceLight;
}

Color _setupBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.borderDark
    : AppColors.borderLight;
