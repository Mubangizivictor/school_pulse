import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/class_timetable_repository_impl.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../data/repositories/structure_people_readiness_repository_impl.dart';
import '../../data/repositories/structure_setup_repository_impl.dart';
import '../../data/repositories/teaching_assignment_repository_impl.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/services/structure_setup_engine.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_extended_setup_cubit.dart';
import '../bloc/structure_setup_cubit.dart';
import '../bloc/structure_state.dart';

class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final tenantResolver = StructureTenantResolver(firestore: firestore);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StructureSetupCubit(
            repository: StructureSetupRepositoryImpl(firestore: firestore),
          ),
        ),
        BlocProvider(
          create: (_) => StructureExtendedSetupCubit(
            tenantResolver: tenantResolver,
            curriculumRepository: CurriculumAssignmentRepositoryImpl(
              firestore: firestore,
              tenantResolver: tenantResolver,
            ),
            teachingAssignmentRepository: TeachingAssignmentRepositoryImpl(
              firestore: firestore,
              tenantResolver: tenantResolver,
            ),
            timetableRepository: ClassTimetableRepositoryImpl(
              firestore: firestore,
              tenantResolver: tenantResolver,
            ),
            peopleRepository: StructurePeopleReadinessRepositoryImpl(
              firestore: firestore,
            ),
          ),
        ),
      ],
      child: const _StructureWizard(),
    );
  }
}

class _StructureWizard extends StatefulWidget {
  const _StructureWizard();

  @override
  State<_StructureWizard> createState() => _StructureWizardState();
}

class _StructureWizardState extends State<_StructureWizard> {
  static const _engine = StructureSetupEngine();
  StructureSetupStepId? _selectedStep;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, structure) {
        return BlocBuilder<StructureSetupCubit, StructureSetupCubitState>(
          builder: (context, setup) {
            return BlocBuilder<StructureExtendedSetupCubit,
                StructureExtendedSetupState>(
              builder: (context, extended) {
                if (structure.isLoading ||
                    setup.isLoading ||
                    extended.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final error = setup.errorMessage ??
                    extended.errorMessage ??
                    structure.errorMessage;
                if (error != null && error.trim().isNotEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Structure Setup')),
                    body: _CenteredMessage(
                      icon: Icons.error_outline,
                      title: 'Structure setup could not load',
                      body: error,
                    ),
                  );
                }

                final resolution = _engine.resolve(
                  _context(structure, setup.preferences, extended),
                );

                if (setup.preferences.onboardingCompleted &&
                    resolution.isReady &&
                    _selectedStep == null) {
                  return _management(context, resolution, extended);
                }

                final step = _resolveStep(resolution);
                if (step == null) {
                  return const Scaffold(
                    body: _CenteredMessage(
                      icon: Icons.account_tree_outlined,
                      title: 'No Structure setup step is available',
                      body:
                          'The setup engine could not determine the next school Structure step.',
                    ),
                  );
                }

                final visible = resolution.steps
                    .where((item) => item.applicable || item.id == step.id)
                    .toList(growable: false);
                final index = visible.indexWhere((item) => item.id == step.id);

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Structure Setup'),
                    actions: [
                      IconButton(
                        tooltip: 'Validate Structure',
                        icon: const Icon(Icons.fact_check_outlined),
                        onPressed: () =>
                            _showValidation(context, resolution),
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: resolution.progress.clamp(0.0, 1.0),
                          minHeight: 4,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding:
                                const EdgeInsets.fromLTRB(20, 24, 20, 42),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 720),
                                child: _StepContent(
                                  step: step,
                                  number: index < 0 ? 1 : index + 1,
                                  total: visible.length,
                                  structure: structure,
                                  preferences: setup.preferences,
                                  extended: extended,
                                  resolution: resolution,
                                  onConfigure: step.route.isEmpty
                                      ? null
                                      : () => _openStep(context, step),
                                  onChoice: (choice) => _saveChoice(
                                    context,
                                    structure,
                                    step.id,
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
                    canBack: _previousStep(resolution, step) != null,
                    canContinue: step.isSatisfied ||
                        (step.id == StructureSetupStepId.review &&
                            resolution.isReady),
                    isSaving: setup.isSaving,
                    isReview: step.id == StructureSetupStepId.review,
                    onBack: () {
                      final previous = _previousStep(resolution, step);
                      if (previous != null) {
                        setState(() => _selectedStep = previous.id);
                      }
                    },
                    onContinue: () =>
                        _continue(context, resolution, step),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  StructureSetupContext _context(
    StructureState state,
    StructureSetupPreferences preferences,
    StructureExtendedSetupState extended,
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
      extendedDataLoaded: true,
      curriculumAssignments: extended.curriculum,
      staff: extended.staff,
      teachingAssignments: extended.teachingAssignments,
      classTimetables: extended.timetables,
      timetableLessons: extended.lessons,
    );
  }

  StructureSetupStepResult? _resolveStep(StructureSetupResolution resolution) {
    if (_selectedStep != null) {
      final matches = resolution.steps.where((item) => item.id == _selectedStep);
      if (matches.isNotEmpty) return matches.first;
    }
    return resolution.nextStep;
  }

  StructureSetupStepResult? _previousStep(
    StructureSetupResolution resolution,
    StructureSetupStepResult current,
  ) {
    final index = resolution.steps.indexWhere((item) => item.id == current.id);
    for (var i = index - 1; i >= 0; i--) {
      final candidate = resolution.steps[i];
      if (candidate.applicable || candidate.isSatisfied) return candidate;
    }
    return null;
  }

  Future<void> _openStep(
    BuildContext context,
    StructureSetupStepResult step,
  ) async {
    await context.read<StructureSetupCubit>().rememberStep(step.id.name);
    if (!context.mounted) return;
    await context.push(step.route);
    if (!mounted) return;
    setState(() => _selectedStep = step.id);
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
    } else {
      await context.read<StructureSetupCubit>().rememberStep(current.id.name);
    }
    if (mounted) setState(() => _selectedStep = null);
  }

  Future<void> _saveChoice(
    BuildContext context,
    StructureState structure,
    StructureSetupStepId step,
    StructureUseChoice choice,
  ) async {
    setState(() => _selectedStep = step);
    final cubit = context.read<StructureSetupCubit>();

    switch (step) {
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
                structure.featureToggles.copyWith(
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
                structure.featureToggles.copyWith(
                  transport: choice == StructureUseChoice.enabled,
                ),
              ),
            );
        return;
      default:
        return;
    }
  }

  Scaffold _management(
    BuildContext context,
    StructureSetupResolution resolution,
    StructureExtendedSetupState extended,
  ) {
    final items = resolution.steps
        .where(
          (item) =>
              item.applicable && item.id != StructureSetupStepId.review,
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Structure'),
        actions: [
          IconButton(
            tooltip: 'Validate Structure',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => _showValidation(context, resolution),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            icon: resolution.isReady
                ? Icons.verified_outlined
                : Icons.warning_amber_outlined,
            title: resolution.isReady
                ? 'Structure ready'
                : 'Structure needs attention',
            body: resolution.isReady
                ? 'Required school Structure is valid. Completed sections remain editable.'
                : '${resolution.issues.length} integrity issue(s) need attention.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: items.isEmpty
                ? null
                : () => setState(() => _selectedStep = items.first.id),
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Review setup step by step'),
          ),
          const SizedBox(height: 24),
          Text(
            'Manage Structure',
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
              subtitle: Text(_managementSubtitle(step, extended)),
              trailing: step.route.isEmpty
                  ? null
                  : const Icon(Icons.chevron_right),
              onTap: step.route.isEmpty
                  ? null
                  : () => _openStep(context, step),
            ),
          ),
        ],
      ),
    );
  }

  String _managementSubtitle(
    StructureSetupStepResult step,
    StructureExtendedSetupState extended,
  ) {
    return switch (step.id) {
      StructureSetupStepId.curriculum =>
        '${extended.curriculum.length} curriculum allocation(s)',
      StructureSetupStepId.staffAccounts =>
        '${extended.staff.where((item) => item.isActive).length} active staff account(s)',
      StructureSetupStepId.academicAssignments =>
        '${extended.teachingAssignments.length} academic assignment(s)',
      StructureSetupStepId.classTimetables =>
        '${extended.timetables.where((item) => item.status.name == 'active').length} published timetable(s)',
      _ => step.section,
    };
  }

  void _showValidation(
    BuildContext context,
    StructureSetupResolution resolution,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 620),
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
                      ? 'All required dependency and integrity checks passed.'
                      : '${resolution.issues.where((issue) => issue.severity == StructureIssueSeverity.critical).length} critical issue(s) found.',
                ),
                const SizedBox(height: 16),
                if (resolution.issues.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('No structural integrity issues found.'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: resolution.issues.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final issue = resolution.issues[index];
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
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final StructureSetupStepResult step;
  final int number;
  final int total;
  final StructureState structure;
  final StructureSetupPreferences preferences;
  final StructureExtendedSetupState extended;
  final StructureSetupResolution resolution;
  final VoidCallback? onConfigure;
  final ValueChanged<StructureUseChoice> onChoice;

  const _StepContent({
    required this.step,
    required this.number,
    required this.total,
    required this.structure,
    required this.preferences,
    required this.extended,
    required this.resolution,
    required this.onConfigure,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choice = _choice(step.id, preferences);

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
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
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
          const _InfoCard(
            icon: Icons.lock_outline,
            title: 'Previous setup is required',
            body:
                'Complete the previous Structure step before configuring this one.',
          )
        else ...[
          if (choice != null) ...[
            _DecisionQuestion(
              stepId: step.id,
              value: choice,
              onChanged: onChoice,
            ),
            const SizedBox(height: 20),
          ],
          _InfoCard(
            icon: step.isSatisfied
                ? Icons.check_circle_outline
                : Icons.pending_actions_outlined,
            title: step.isSatisfied ? 'Ready to continue' : 'Current setup',
            body: _summary(step.id, structure, extended, choice),
          ),
          if (step.issues.isNotEmpty) ...[
            const SizedBox(height: 18),
            _IssueCard(issues: step.issues),
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
            _InfoCard(
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

class _DecisionQuestion extends StatelessWidget {
  final StructureSetupStepId stepId;
  final StructureUseChoice value;
  final ValueChanged<StructureUseChoice> onChanged;

  const _DecisionQuestion({
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
        'Do you want to configure clubs and societies?',
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
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
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
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

class _IssueCard extends StatelessWidget {
  final List<StructureSetupIssue> issues;

  const _IssueCard({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before you continue',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
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

class _WizardActions extends StatelessWidget {
  final bool canBack;
  final bool canContinue;
  final bool isSaving;
  final bool isReview;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _WizardActions({
    required this.canBack,
    required this.canContinue,
    required this.isSaving,
    required this.isReview,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              child: OutlinedButton(
                onPressed: canBack && !isSaving ? onBack : null,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed:
                    canContinue && !isSaving ? onContinue : null,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isReview ? 'Finish Setup' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

StructureUseChoice? _choice(
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

String _summary(
  StructureSetupStepId step,
  StructureState state,
  StructureExtendedSetupState extended,
  StructureUseChoice? choice,
) {
  if (choice == StructureUseChoice.disabled) return 'Not used by this school.';
  return switch (step) {
    StructureSetupStepId.institution => state.institutionProfile.name.isEmpty
        ? 'School identity is incomplete.'
        : state.institutionProfile.name,
    StructureSetupStepId.academicYear =>
      '${state.academicYears.length} year(s) • ${state.academicYears.where((item) => item.isCurrent).length} current',
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
    StructureSetupStepId.curriculum =>
      '${extended.curriculum.where((item) => item.isActive).length} active curriculum allocation(s)',
    StructureSetupStepId.assessmentAndGrading =>
      '${state.assessmentTypes.where((item) => item.isActive).length} assessment type(s) • ${state.gradingSystems.where((item) => item.isActive).length} grading system(s)',
    StructureSetupStepId.learningSpaces =>
      '${state.facilities.where((item) => item.isActive).length} active learning space(s)',
    StructureSetupStepId.schoolDay =>
      '${state.timetableConfig.teachingDays.length} teaching day(s) • ${state.timetableConfig.slots.length} slot(s)',
    StructureSetupStepId.staffRoles =>
      '${state.staffRoles.where((item) => item.isActive).length} active role/responsibility definition(s)',
    StructureSetupStepId.staffAccounts =>
      '${extended.staff.where((item) => item.isActive).length} active staff account(s)',
    StructureSetupStepId.academicAssignments =>
      '${extended.teachingAssignments.length} academic staff assignment(s)',
    StructureSetupStepId.classTimetables =>
      '${extended.timetables.where((item) => item.status.name == 'active').length} published timetable(s) • ${extended.lessons.where((item) => item.isActive).length} active lesson(s)',
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
      '${state.announcementCategories.where((item) => item.isActive).length + state.notificationCategories.where((item) => item.isActive).length} communication category(s) • ${state.messageTemplates.where((item) => item.isActive).length} template(s)',
    StructureSetupStepId.review => 'Run the final integrity review.',
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
