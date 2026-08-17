import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/structure_setup_repository_impl.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/services/structure_setup_engine.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_setup_cubit.dart';
import '../bloc/structure_state.dart';

class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StructureSetupCubit(
        repository: StructureSetupRepositoryImpl(
          firestore: FirebaseFirestore.instance,
        ),
      ),
      child: const _StructureSetupView(),
    );
  }
}

class _StructureSetupView extends StatefulWidget {
  const _StructureSetupView();

  @override
  State<_StructureSetupView> createState() => _StructureSetupViewState();
}

class _StructureSetupViewState extends State<_StructureSetupView> {
  static const _engine = StructureSetupEngine();
  StructureSetupStepId? _manualStepId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, structureState) {
        return BlocBuilder<StructureSetupCubit, StructureSetupCubitState>(
          builder: (context, setupState) {
            if (structureState.isLoading || setupState.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final resolution = _engine.resolve(
              _contextFrom(structureState, setupState.preferences),
            );

            if (setupState.preferences.onboardingCompleted &&
                resolution.isReady &&
                _manualStepId == null) {
              return _ManagementView(
                resolution: resolution,
                onOpen: (step) => _openConfiguration(context, step),
                onReviewWizard: () {
                  final first = resolution.steps
                      .where((step) =>
                          step.id != StructureSetupStepId.review &&
                          (step.applicable || step.isSatisfied))
                      .firstOrNull;
                  if (first != null) {
                    setState(() => _manualStepId = first.id);
                  }
                },
              );
            }

            final current = _currentStep(resolution);
            if (current == null) {
              return const Scaffold(
                body: Center(child: Text('No Structure setup step is available.')),
              );
            }

            final ordered = resolution.steps
                .where((step) => step.applicable || step.id == current.id)
                .toList(growable: false);
            final index = ordered.indexWhere((step) => step.id == current.id);
            final safeIndex = index < 0 ? 0 : index;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Structure Setup'),
                actions: [
                  IconButton(
                    tooltip: 'Validate structure',
                    onPressed: () => _showValidation(context, resolution),
                    icon: const Icon(Icons.fact_check_outlined),
                  ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: resolution.progress.clamp(0.0, 1.0).toDouble(),
                      minHeight: 4,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: _StepContent(
                              step: current,
                              number: safeIndex + 1,
                              total: ordered.length,
                              resolution: resolution,
                              state: structureState,
                              preferences: setupState.preferences,
                              onConfigure: current.route.isEmpty
                                  ? null
                                  : () => _openConfiguration(context, current),
                              onChoice: (choice) => _choose(
                                context,
                                current,
                                choice,
                                structureState,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _BottomActions(
                canBack: _previousStep(resolution, current) != null,
                canContinue: current.isSatisfied ||
                    (current.id == StructureSetupStepId.review &&
                        resolution.isReady),
                saving: setupState.isSaving,
                finish: current.id == StructureSetupStepId.review,
                onBack: () {
                  final previous = _previousStep(resolution, current);
                  if (previous != null) {
                    setState(() => _manualStepId = previous.id);
                  }
                },
                onContinue: () => _continue(context, resolution, current),
              ),
            );
          },
        );
      },
    );
  }

  StructureSetupContext _contextFrom(
    StructureState state,
    StructureSetupPreferences preferences,
  ) {
    return StructureSetupContext(
      institutionProfile: state.institutionProfile,
      preferences: preferences,
      featureToggles: state.featureToggles,
      academicYears: state.academicYears,
      academicTerms: state.academicTerms,
      levels: state.levels,
      departments: state.departments,
      classes: state.classes,
      streams: state.streams,
      subjects: state.subjects,
      assessmentTypes: state.assessmentTypes,
      gradingSystems: state.gradingSystems,
      gradeBands: state.gradeBands,
      facilities: state.facilities,
      timetableConfig: state.timetableConfig,
      designations: state.designations,
      staffRoles: state.staffRoles,
      houses: state.houses,
      clubs: state.clubs,
      hostels: state.hostels,
      hostelRooms: state.hostelRooms,
      transportRoutes: state.transportRoutes,
      transportStops: state.transportStops,
      transportVehicles: state.transportVehicles,
      attendanceTypes: state.attendanceTypes,
      feeCategories: state.feeCategories,
      announcementCategories: state.announcementCategories,
      notificationCategories: state.notificationCategories,
      messageTemplates: state.messageTemplates,
    );
  }

  StructureSetupStepResult? _currentStep(StructureSetupResolution resolution) {
    if (_manualStepId != null) {
      final match = resolution.steps.where((step) => step.id == _manualStepId);
      if (match.isNotEmpty) return match.first;
    }
    return resolution.nextStep;
  }

  StructureSetupStepResult? _previousStep(
    StructureSetupResolution resolution,
    StructureSetupStepResult current,
  ) {
    final index = resolution.steps.indexWhere((step) => step.id == current.id);
    for (var i = index - 1; i >= 0; i--) {
      final candidate = resolution.steps[i];
      if (candidate.applicable || candidate.isSatisfied) return candidate;
    }
    return null;
  }

  Future<void> _openConfiguration(
    BuildContext context,
    StructureSetupStepResult step,
  ) async {
    if (step.route.isEmpty) return;
    await context.read<StructureSetupCubit>().rememberStep(step.id.name);
    if (!context.mounted) return;
    await context.push(step.route);
    if (!mounted) return;
    setState(() => _manualStepId = step.id);
  }

  Future<void> _choose(
    BuildContext context,
    StructureSetupStepResult step,
    StructureUseChoice choice,
    StructureState structureState,
  ) async {
    setState(() => _manualStepId = step.id);
    final cubit = context.read<StructureSetupCubit>();

    switch (step.id) {
      case StructureSetupStepId.departments:
        await cubit.setDepartments(choice);
        return;
      case StructureSetupStepId.streams:
        await cubit.setStreams(choice);
        return;
      case StructureSetupStepId.learningSpaces:
        await cubit.setRooms(choice);
        return;
      case StructureSetupStepId.houses:
        await cubit.setHouses(choice);
        return;
      case StructureSetupStepId.clubs:
        await cubit.setClubs(choice);
        return;
      case StructureSetupStepId.boarding:
        await cubit.setBoarding(choice);
        if (!context.mounted) return;
        context.read<StructureBloc>().add(
              UpdateFeatureTogglesRequested(
                structureState.featureToggles.copyWith(
                  boarding: choice == StructureUseChoice.enabled,
                  hostel: choice == StructureUseChoice.enabled,
                ),
              ),
            );
        return;
      case StructureSetupStepId.transport:
        await cubit.setTransport(choice);
        if (!context.mounted) return;
        context.read<StructureBloc>().add(
              UpdateFeatureTogglesRequested(
                structureState.featureToggles.copyWith(
                  transport: choice == StructureUseChoice.enabled,
                ),
              ),
            );
        return;
      default:
        return;
    }
  }

  Future<void> _continue(
    BuildContext context,
    StructureSetupResolution resolution,
    StructureSetupStepResult current,
  ) async {
    if (current.id == StructureSetupStepId.review) {
      if (!resolution.isReady) {
        _showValidation(context, resolution);
        return;
      }
      await context.read<StructureSetupCubit>().markOnboardingCompleted();
      if (mounted) setState(() => _manualStepId = null);
      return;
    }
    if (!current.isSatisfied) return;
    await context.read<StructureSetupCubit>().rememberStep(current.id.name);
    if (mounted) setState(() => _manualStepId = null);
  }

  void _showValidation(
    BuildContext context,
    StructureSetupResolution resolution,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final issues = resolution.issues;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 580),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolution.isReady
                        ? 'Structure is ready'
                        : 'Structure needs attention',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resolution.isReady
                        ? 'All required Structure checks passed.'
                        : '${issues.where((issue) => issue.severity == StructureIssueSeverity.critical).length} critical issue(s) found.',
                  ),
                  const SizedBox(height: 16),
                  if (issues.isEmpty)
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('No structural integrity issues found.'),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: issues.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final issue = issues[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              issue.severity == StructureIssueSeverity.critical
                                  ? Icons.error_outline
                                  : Icons.warning_amber_outlined,
                            ),
                            title: Text(issue.message),
                            subtitle: Text(_pretty(issue.stepId.name)),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepContent extends StatelessWidget {
  final StructureSetupStepResult step;
  final int number;
  final int total;
  final StructureSetupResolution resolution;
  final StructureState state;
  final StructureSetupPreferences preferences;
  final VoidCallback? onConfigure;
  final ValueChanged<StructureUseChoice> onChoice;

  const _StepContent({
    required this.step,
    required this.number,
    required this.total,
    required this.resolution,
    required this.state,
    required this.preferences,
    required this.onConfigure,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choice = _choiceFor(step.id, preferences);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $number of $total',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          step.section.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.1,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.title,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          step.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        if (!step.prerequisitesComplete)
          const _Panel(
            icon: Icons.lock_outline,
            title: 'Previous setup is required',
            body: 'Complete the previous Structure step before configuring this one.',
          )
        else ...[
          if (choice != null) ...[
            _ChoiceQuestion(
              stepId: step.id,
              value: choice,
              onChanged: onChoice,
            ),
            const SizedBox(height: 20),
          ],
          _Panel(
            icon: step.isSatisfied
                ? Icons.check_circle_outline
                : Icons.pending_actions_outlined,
            title: step.isSatisfied ? 'Ready to continue' : 'Current setup',
            body: _snapshot(step.id, state, choice),
          ),
          if (step.issues.isNotEmpty) ...[
            const SizedBox(height: 20),
            _IssuePanel(issues: step.issues),
          ],
          if (onConfigure != null &&
              (choice == null || choice == StructureUseChoice.enabled)) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onConfigure,
                icon: const Icon(Icons.tune_outlined),
                label: Text(
                  step.complete
                      ? 'Review / Edit ${step.title}'
                      : 'Configure ${step.title}',
                ),
              ),
            ),
          ],
          if (step.id == StructureSetupStepId.review) ...[
            const SizedBox(height: 20),
            _Panel(
              icon: resolution.isReady
                  ? Icons.verified_outlined
                  : Icons.rule_folder_outlined,
              title: resolution.isReady
                  ? 'Structure is ready'
                  : 'Final checks are not clean yet',
              body:
                  '${resolution.requiredSteps.where((item) => item.isSatisfied).length} of ${resolution.requiredSteps.length} required steps are valid. ${resolution.issues.length} issue(s) are reported.',
            ),
          ],
        ],
      ],
    );
  }
}

class _ChoiceQuestion extends StatelessWidget {
  final StructureSetupStepId stepId;
  final StructureUseChoice value;
  final ValueChanged<StructureUseChoice> onChanged;

  const _ChoiceQuestion({
    required this.stepId,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final question = switch (stepId) {
      StructureSetupStepId.departments =>
        'Does this school organise academics using departments?',
      StructureSetupStepId.streams =>
        'Does this school use streams or sections?',
      StructureSetupStepId.learningSpaces =>
        'Do you want School Pulse to manage rooms and learning spaces?',
      StructureSetupStepId.houses => 'Does this school use houses?',
      StructureSetupStepId.clubs =>
        'Do you want to configure clubs and societies now?',
      StructureSetupStepId.boarding => 'Does this school provide boarding?',
      StructureSetupStepId.transport =>
        'Does this school operate school transport?',
      _ => 'Is this used by your school?',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: value == StructureUseChoice.enabled
                  ? FilledButton(
                      onPressed: () => onChanged(StructureUseChoice.enabled),
                      child: const Text('Yes'),
                    )
                  : OutlinedButton(
                      onPressed: () => onChanged(StructureUseChoice.enabled),
                      child: const Text('Yes'),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: value == StructureUseChoice.disabled
                  ? FilledButton(
                      onPressed: () => onChanged(StructureUseChoice.disabled),
                      child: const Text('No'),
                    )
                  : OutlinedButton(
                      onPressed: () => onChanged(StructureUseChoice.disabled),
                      child: const Text('No'),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _Panel({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssuePanel extends StatelessWidget {
  final List<StructureSetupIssue> issues;

  const _IssuePanel({required this.issues});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Before you continue', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• ${issue.message}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool canBack;
  final bool canContinue;
  final bool saving;
  final bool finish;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _BottomActions({
    required this.canBack,
    required this.canContinue,
    required this.saving,
    required this.finish,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              child: OutlinedButton(
                onPressed: canBack && !saving ? onBack : null,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: canContinue && !saving ? onContinue : null,
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(finish ? 'Finish setup' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementView extends StatelessWidget {
  final StructureSetupResolution resolution;
  final ValueChanged<StructureSetupStepResult> onOpen;
  final VoidCallback onReviewWizard;

  const _ManagementView({
    required this.resolution,
    required this.onOpen,
    required this.onReviewWizard,
  });

  @override
  Widget build(BuildContext context) {
    final items = resolution.steps
        .where((step) =>
            step.id != StructureSetupStepId.review && step.applicable)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('School Structure')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Panel(
            icon: resolution.isReady
                ? Icons.verified_outlined
                : Icons.warning_amber_outlined,
            title:
                resolution.isReady ? 'Structure ready' : 'Structure needs attention',
            body: resolution.isReady
                ? 'Required school structure is valid. Completed sections remain editable.'
                : '${resolution.issues.length} issue(s) need attention.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReviewWizard,
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Review setup step by step'),
          ),
          const SizedBox(height: 24),
          Text(
            'Manage structure',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (step) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                step.isSatisfied
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
              ),
              title: Text(step.title),
              subtitle: Text(step.section),
              trailing: const Icon(Icons.chevron_right),
              onTap: step.route.isEmpty ? null : () => onOpen(step),
            ),
          ),
        ],
      ),
    );
  }
}

StructureUseChoice? _choiceFor(
  StructureSetupStepId step,
  StructureSetupPreferences preferences,
) {
  return switch (step) {
    StructureSetupStepId.departments => preferences.departments,
    StructureSetupStepId.streams => preferences.streams,
    StructureSetupStepId.learningSpaces => preferences.rooms,
    StructureSetupStepId.houses => preferences.houses,
    StructureSetupStepId.clubs => preferences.clubs,
    StructureSetupStepId.boarding => preferences.boarding,
    StructureSetupStepId.transport => preferences.transport,
    _ => null,
  };
}

String _snapshot(
  StructureSetupStepId step,
  StructureState state,
  StructureUseChoice? choice,
) {
  if (choice == StructureUseChoice.disabled) return 'Not used by this school.';
  return switch (step) {
    StructureSetupStepId.institution => state.institutionProfile.name.isEmpty
        ? 'School identity has not been completed.'
        : state.institutionProfile.name,
    StructureSetupStepId.academicYear =>
      '${state.academicYears.length} academic year(s) • ${state.academicYears.where((item) => item.isCurrent).length} current',
    StructureSetupStepId.academicTerms =>
      '${state.academicTerms.length} term/semester record(s)',
    StructureSetupStepId.levels =>
      '${state.levels.where((item) => item.isActive).length} active level(s)',
    StructureSetupStepId.departments =>
      '${state.departments.where((item) => item.isActive).length} active department(s)',
    StructureSetupStepId.classes =>
      '${state.classes.where((item) => item.isActive).length} active class(es)',
    StructureSetupStepId.streams =>
      '${state.streams.where((item) => item.isActive).length} active stream(s)',
    StructureSetupStepId.subjects =>
      '${state.subjects.where((item) => item.isActive).length} active subject(s)',
    StructureSetupStepId.assessmentAndGrading =>
      '${state.assessmentTypes.where((item) => item.isActive).length} assessment type(s) • ${state.gradingSystems.where((item) => item.isActive).length} grading system(s)',
    StructureSetupStepId.learningSpaces =>
      '${state.facilities.where((item) => item.isActive).length} active space(s)',
    StructureSetupStepId.schoolDay =>
      '${state.timetableConfig.teachingDays.length} teaching day(s) • ${state.timetableConfig.slots.length} slot(s)',
    StructureSetupStepId.staffRoles =>
      '${state.staffRoles.where((item) => item.isActive).length} active role(s)',
    StructureSetupStepId.houses =>
      '${state.houses.where((item) => item.isActive).length} active house(s)',
    StructureSetupStepId.clubs =>
      '${state.clubs.where((item) => item.isActive).length} active club(s)',
    StructureSetupStepId.boarding =>
      '${state.hostels.where((item) => item.isActive).length} active hostel/dormitory record(s)',
    StructureSetupStepId.transport =>
      '${state.transportRoutes.where((item) => item.isActive).length} route(s) • ${state.transportVehicles.where((item) => item.isActive).length} vehicle(s)',
    StructureSetupStepId.attendance =>
      '${state.attendanceTypes.where((item) => item.isActive).length} active attendance type(s)',
    StructureSetupStepId.financeFoundation =>
      '${state.feeCategories.where((item) => item.isActive).length} active fee category(s)',
    StructureSetupStepId.communication =>
      '${state.announcementCategories.where((item) => item.isActive).length + state.notificationCategories.where((item) => item.isActive).length} category(s) • ${state.messageTemplates.where((item) => item.isActive).length} template(s)',
    StructureSetupStepId.review =>
      'Run the final integrity review before completing setup.',
  };
}

String _pretty(String raw) {
  final spaced = raw.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (match) => ' ${match.group(1)}',
  );
  return spaced.isEmpty
      ? raw
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
