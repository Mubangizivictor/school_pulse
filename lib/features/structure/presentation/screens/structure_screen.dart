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

/// Entry point for School Structure.
///
/// During first-time setup this is intentionally *not* a dashboard. It is a
/// sequential survey: one logical task at a time, with the next task resolved
/// from real persisted Structure data. Once required structure is healthy the
/// same screen becomes a compact management/review list.
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
            if (setupState.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final resolution = _engine.resolve(
              _buildContext(structureState, setupState.preferences),
            );

            if (setupState.preferences.onboardingCompleted &&
                resolution.isReady &&
                _manualStepId == null) {
              return _StructureManagementView(
                resolution: resolution,
                onEditStep: (step) => _openStep(context, step),
                onEditSetup: () {
                  setState(() {
                    _manualStepId = resolution.applicableSteps
                        .where((step) => step.id != StructureSetupStepId.review)
                        .firstOrNull
                        ?.id;
                  });
                },
              );
            }

            final current = _resolveCurrentStep(resolution);
            if (current == null) {
              return const Scaffold(
                body: Center(child: Text('No Structure setup step is available.')),
              );
            }

            final visibleSteps = resolution.applicableSteps;
            final index = visibleSteps.indexWhere((step) => step.id == current.id);
            final displayIndex = index < 0 ? 0 : index;

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
                      value: resolution.progress.clamp(0, 1),
                      minHeight: 4,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: _StepBody(
                              step: current,
                              stepNumber: displayIndex + 1,
                              totalSteps: visibleSteps.length,
                              resolution: resolution,
                              structureState: structureState,
                              setupState: setupState,
                              onConfigure: current.route.isEmpty
                                  ? null
                                  : () => _openStep(context, current),
                              onChoice: (choice) => _setChoice(
                                context,
                                structureState,
                                current,
                                choice,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _WizardActions(
                canGoBack: displayIndex > 0,
                canContinue: current.isSatisfied ||
                    (current.id == StructureSetupStepId.review && resolution.isReady),
                isSaving: setupState.isSaving,
                isReview: current.id == StructureSetupStepId.review,
                onBack: () => _goBack(resolution, displayIndex),
                onContinue: () => _continue(context, resolution, current),
              ),
            );
          },
        );
      },
    );
  }

  StructureSetupContext _buildContext(
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

  StructureSetupStepResult? _resolveCurrentStep(
    StructureSetupResolution resolution,
  ) {
    if (_manualStepId != null) {
      final match = resolution.steps.where((step) => step.id == _manualStepId);
      if (match.isNotEmpty) return match.first;
    }
    return resolution.nextStep;
  }

  Future<void> _openStep(
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

  Future<void> _setChoice(
    BuildContext context,
    StructureState structureState,
    StructureSetupStepResult step,
    StructureUseChoice choice,
  ) async {
    setState(() => _manualStepId = step.id);
    final cubit = context.read<StructureSetupCubit>();
    switch (step.id) {
      case StructureSetupStepId.departments:
        await cubit.setDepartments(choice);
      case StructureSetupStepId.streams:
        await cubit.setStreams(choice);
      case StructureSetupStepId.learningSpaces:
        await cubit.setRooms(choice);
      case StructureSetupStepId.houses:
        await cubit.setHouses(choice);
      case StructureSetupStepId.clubs:
        await cubit.setClubs(choice);
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
      default:
        return;
    }
  }

  void _goBack(StructureSetupResolution resolution, int currentIndex) {
    final steps = resolution.applicableSteps;
    if (currentIndex <= 0 || steps.isEmpty) return;
    setState(() => _manualStepId = steps[currentIndex - 1].id);
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
      if (!mounted) return;
      setState(() => _manualStepId = null);
      return;
    }

    if (!current.isSatisfied) return;
    await context.read<StructureSetupCubit>().rememberStep(current.id.name);
    if (!mounted) return;
    setState(() => _manualStepId = null);
  }

  void _showValidation(
    BuildContext context,
    StructureSetupResolution resolution,
  ) {
    final issues = resolution.issues;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolution.isReady ? 'Structure is ready' : 'Structure needs attention',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  resolution.isReady
                      ? 'All required structural checks passed.'
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
                          subtitle: Text(_prettyStepName(issue.stepId)),
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
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  final StructureSetupStepResult step;
  final int stepNumber;
  final int totalSteps;
  final StructureSetupResolution resolution;
  final StructureState structureState;
  final StructureSetupCubitState setupState;
  final VoidCallback? onConfigure;
  final ValueChanged<StructureUseChoice> onChoice;

  const _StepBody({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.resolution,
    required this.structureState,
    required this.setupState,
    required this.onConfigure,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choice = _choiceForStep(step.id, setupState.preferences);
    final isDecision = choice != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $stepNumber of $totalSteps',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          step.section.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
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
          _InfoPanel(
            icon: Icons.lock_outline,
            title: 'Finish the previous step first',
            body: 'This step depends on earlier Structure information. Use Back and complete the required step before continuing.',
          )
        else ...[
          if (isDecision) ...[
            _DecisionPanel(
              step: step.id,
              choice: choice,
              onChoice: onChoice,
            ),
            const SizedBox(height: 20),
          ],
          _CurrentDataPanel(
            step: step,
            state: structureState,
            choice: choice,
          ),
          if (step.issues.isNotEmpty) ...[
            const SizedBox(height: 20),
            _IssuesPanel(issues: step.issues),
          ],
          if (onConfigure != null &&
              (choice == null || choice == StructureUseChoice.enabled)) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onConfigure,
                icon: const Icon(Icons.tune_outlined),
                label: Text(step.complete ? 'Review / Edit ${step.title}' : 'Configure ${step.title}'),
              ),
            ),
          ],
          if (step.id == StructureSetupStepId.review) ...[
            const SizedBox(height: 20),
            _ReviewSummary(resolution: resolution),
          ],
        ],
      ],
    );
  }
}

class _DecisionPanel extends StatelessWidget {
  final StructureSetupStepId step;
  final StructureUseChoice choice;
  final ValueChanged<StructureUseChoice> onChoice;

  const _DecisionPanel({
    required this.step,
    required this.choice,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final prompt = switch (step) {
      StructureSetupStepId.departments => 'Does this school organise academics using departments?',
      StructureSetupStepId.streams => 'Does this school use streams or sections?',
      StructureSetupStepId.learningSpaces => 'Do you want School Pulse to manage rooms and learning spaces?',
      StructureSetupStepId.houses => 'Does this school use houses?',
      StructureSetupStepId.clubs => 'Do you want to configure clubs and societies now?',
      StructureSetupStepId.boarding => 'Does this school provide boarding?',
      StructureSetupStepId.transport => 'Does this school operate school transport?',
      _ => 'Is this part of your school structure?',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChoiceButton(
                label: 'Yes',
                selected: choice == StructureUseChoice.enabled,
                onTap: () => onChoice(StructureUseChoice.enabled),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceButton(
                label: 'No',
                selected: choice == StructureUseChoice.disabled,
                onTap: () => onChoice(StructureUseChoice.disabled),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: selected
          ? FilledButton(onPressed: onTap, child: Text(label))
          : OutlinedButton(onPressed: onTap, child: Text(label)),
    );
  }
}

class _CurrentDataPanel extends StatelessWidget {
  final StructureSetupStepResult step;
  final StructureState state;
  final StructureUseChoice? choice;

  const _CurrentDataPanel({required this.step, required this.state, required this.choice});

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshotFor(step.id, state, choice);
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
          Icon(
            step.isSatisfied ? Icons.check_circle_outline : Icons.pending_actions_outlined,
            color: step.isSatisfied ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.isSatisfied ? 'Ready to continue' : 'Current setup',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(snapshot),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssuesPanel extends StatelessWidget {
  final List<StructureSetupIssue> issues;

  const _IssuesPanel({required this.issues});

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
          Text(
            'Before you continue',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(issue.message)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  final StructureSetupResolution resolution;

  const _ReviewSummary({required this.resolution});

  @override
  Widget build(BuildContext context) {
    final completed = resolution.requiredSteps.where((step) => step.isSatisfied).length;
    final total = resolution.requiredSteps.length;
    return _InfoPanel(
      icon: resolution.isReady ? Icons.verified_outlined : Icons.rule_folder_outlined,
      title: resolution.isReady ? 'Structure is ready' : 'Final checks are not clean yet',
      body: '$completed of $total required steps are valid. ${resolution.issues.length} issue(s) are currently reported.',
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoPanel({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
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

class _WizardActions extends StatelessWidget {
  final bool canGoBack;
  final bool canContinue;
  final bool isSaving;
  final bool isReview;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _WizardActions({
    required this.canGoBack,
    required this.canContinue,
    required this.isSaving,
    required this.isReview,
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
                onPressed: canGoBack && !isSaving ? onBack : null,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: canContinue && !isSaving ? onContinue : null,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isReview ? 'Finish setup' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StructureManagementView extends StatelessWidget {
  final StructureSetupResolution resolution;
  final ValueChanged<StructureSetupStepResult> onEditStep;
  final VoidCallback onEditSetup;

  const _StructureManagementView({
    required this.resolution,
    required this.onEditStep,
    required this.onEditSetup,
  });

  @override
  Widget build(BuildContext context) {
    final manageable = resolution.steps
        .where((step) => step.applicable && step.id != StructureSetupStepId.review)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('School Structure')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoPanel(
            icon: resolution.isReady ? Icons.verified_outlined : Icons.warning_amber_outlined,
            title: resolution.isReady ? 'Structure ready' : 'Structure needs attention',
            body: resolution.isReady
                ? 'Required school structure is valid. You can edit any section below.'
                : '${resolution.issues.length} issue(s) need attention.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onEditSetup,
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Review setup step by step'),
          ),
          const SizedBox(height: 24),
          Text(
            'Manage structure',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...manageable.map(
            (step) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                step.isSatisfied ? Icons.check_circle_outline : Icons.error_outline,
              ),
              title: Text(step.title),
              subtitle: Text(step.section),
              trailing: const Icon(Icons.chevron_right),
              onTap: step.route.isEmpty ? null : () => onEditStep(step),
            ),
          ),
        ],
      ),
    );
  }
}

StructureUseChoice? _choiceForStep(
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

String _snapshotFor(
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
      '${state.academicYears.length} academic year(s) • ${state.academicYears.where((year) => year.isCurrent).length} current',
    StructureSetupStepId.academicTerms =>
      '${state.academicTerms.length} term/semester record(s)',
    StructureSetupStepId.levels => '${state.levels.where((item) => item.isActive).length} active level(s)',
    StructureSetupStepId.departments => '${state.departments.where((item) => item.isActive).length} active department(s)',
    StructureSetupStepId.classes => '${state.classes.where((item) => item.isActive).length} active class(es)',
    StructureSetupStepId.streams => '${state.streams.where((item) => item.isActive).length} active stream(s)',
    StructureSetupStepId.subjects => '${state.subjects.where((item) => item.isActive).length} active subject(s)',
    StructureSetupStepId.assessmentAndGrading =>
      '${state.assessmentTypes.where((item) => item.isActive).length} assessment type(s) • ${state.gradingSystems.where((item) => item.isActive).length} grading system(s)',
    StructureSetupStepId.learningSpaces => '${state.facilities.where((item) => item.isActive).length} active space(s)',
    StructureSetupStepId.schoolDay =>
      '${state.timetableConfig.teachingDays.length} teaching day(s) • ${state.timetableConfig.slots.length} slot(s)',
    StructureSetupStepId.staffRoles => '${state.staffRoles.where((item) => item.isActive).length} active role(s)',
    StructureSetupStepId.houses => '${state.houses.where((item) => item.isActive).length} active house(s)',
    StructureSetupStepId.clubs => '${state.clubs.where((item) => item.isActive).length} active club(s)',
    StructureSetupStepId.boarding => '${state.hostels.where((item) => item.isActive).length} active hostel/dormitory record(s)',
    StructureSetupStepId.transport =>
      '${state.transportRoutes.where((item) => item.isActive).length} route(s) • ${state.transportVehicles.where((item) => item.isActive).length} vehicle(s)',
    StructureSetupStepId.attendance => '${state.attendanceTypes.where((item) => item.isActive).length} active attendance type(s)',
    StructureSetupStepId.financeFoundation => '${state.feeCategories.where((item) => item.isActive).length} active fee category(s)',
    StructureSetupStepId.communication =>
      '${state.announcementCategories.where((item) => item.isActive).length + state.notificationCategories.where((item) => item.isActive).length} category(s) • ${state.messageTemplates.where((item) => item.isActive).length} template(s)',
    StructureSetupStepId.review => 'Run the final integrity review before completing setup.',
  };
}

String _prettyStepName(StructureSetupStepId id) {
  return id.name
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .trim()
      .replaceFirstMapped(RegExp(r'^.'), (match) => match.group(0)!.toUpperCase());
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
