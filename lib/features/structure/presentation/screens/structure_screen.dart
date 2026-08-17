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
import 'academic_staff_assignment_screen.dart';
import 'class_timetable_screen.dart';
import 'curriculum_assignment_screen.dart';

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
                if (structure.isLoading || setup.isLoading || extended.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final error =
                    setup.errorMessage ?? extended.errorMessage ?? structure.errorMessage;
                if (error != null && error.trim().isNotEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Structure Setup')),
                    body: _Message(
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
                    body: _Message(
                      icon: Icons.account_tree_outlined,
                      title: 'No setup step is available',
                      body: 'Structure could not determine the next valid step.',
                    ),
                  );
                }
                final visible = resolution.steps
                    .where((item) => item.applicable || item.id == step.id)
                    .toList(growable: false);
                final index = visible.indexWhere((item) => item.id == step.id);
                final choice = _choiceFor(step.id, setup.preferences);

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Structure Setup'),
                    actions: [
                      IconButton(
                        tooltip: 'Validate Structure',
                        icon: const Icon(Icons.fact_check_outlined),
                        onPressed: () => _showValidation(context, resolution),
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
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 720),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Step ${index < 0 ? 1 : index + 1} of ${visible.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      step.section.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            letterSpacing: 1.1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      step.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      step.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(height: 1.45),
                                    ),
                                    const SizedBox(height: 24),
                                    if (!step.prerequisitesComplete)
                                      const _InfoCard(
                                        icon: Icons.lock_outline,
                                        title: 'Previous setup is required',
                                        body:
                                            'Complete the previous Structure step before this one.',
                                      )
                                    else ...[
                                      if (choice != null) ...[
                                        _ChoiceCard(
                                          value: choice,
                                          onChanged: (value) => _saveChoice(
                                            context,
                                            structure,
                                            step.id,
                                            value,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      _InfoCard(
                                        icon: step.isSatisfied
                                            ? Icons.check_circle_outline
                                            : Icons.pending_actions_outlined,
                                        title: step.isSatisfied
                                            ? 'Ready to continue'
                                            : 'Current setup',
                                        body: _summary(
                                          step.id,
                                          structure,
                                          extended,
                                          choice,
                                        ),
                                      ),
                                      if (step.issues.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        _IssueCard(issues: step.issues),
                                      ],
                                      if (_canConfigure(step, choice)) ...[
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: () => _openStep(context, step),
                                            icon: const Icon(Icons.tune_outlined),
                                            label: Text(
                                              step.complete
                                                  ? 'Review / Edit ${step.title}'
                                                  : 'Configure ${step.title}',
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (step.id == StructureSetupStepId.review)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 18),
                                          child: _InfoCard(
                                            icon: resolution.isReady
                                                ? Icons.verified_outlined
                                                : Icons.rule_folder_outlined,
                                            title: resolution.isReady
                                                ? 'Structure is ready'
                                                : 'Structure needs attention',
                                            body:
                                                '${resolution.requiredSteps.where((item) => item.isSatisfied).length} of ${resolution.requiredSteps.length} required steps are valid. ${resolution.issues.length} issue(s) reported.',
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: _actions(
                    context,
                    resolution,
                    step,
                    setup.isSaving,
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
    final selected = _selectedStep;
    if (selected != null) {
      final matches = resolution.steps.where((item) => item.id == selected);
      if (matches.isNotEmpty) return matches.first;
    }
    return resolution.nextStep;
  }

  Widget _actions(
    BuildContext context,
    StructureSetupResolution resolution,
    StructureSetupStepResult current,
    bool saving,
  ) {
    final previous = _previousStep(resolution, current);
    final isReview = current.id == StructureSetupStepId.review;
    final canContinue = current.isSatisfied || (isReview && resolution.isReady);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              child: OutlinedButton(
                onPressed: previous == null || saving
                    ? null
                    : () => setState(() => _selectedStep = previous.id),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: !canContinue || saving
                    ? null
                    : () => _continue(context, resolution, current),
                child: saving
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

  StructureSetupStepResult? _previousStep(
    StructureSetupResolution resolution,
    StructureSetupStepResult current,
  ) {
    final index = resolution.steps.indexWhere((item) => item.id == current.id);
    for (var i = index - 1; i >= 0; i--) {
      final item = resolution.steps[i];
      if (item.applicable || item.isSatisfied) return item;
    }
    return null;
  }

  Future<void> _openStep(
    BuildContext context,
    StructureSetupStepResult step,
  ) async {
    await context.read<StructureSetupCubit>().rememberStep(step.id.name);
    if (!context.mounted) return;

    switch (step.id) {
      case StructureSetupStepId.curriculum:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: const CurriculumAssignmentScreen(),
            ),
          ),
        );
        break;
      case StructureSetupStepId.academicAssignments:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: const AcademicStaffAssignmentScreen(),
            ),
          ),
        );
        break;
      case StructureSetupStepId.classTimetables:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: const ClassTimetableScreen(),
            ),
          ),
        );
        break;
      default:
        if (step.route.isNotEmpty) await context.push(step.route);
    }

    if (mounted) setState(() => _selectedStep = step.id);
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
    StructureState state,
    StructureSetupStepId id,
    StructureUseChoice value,
  ) async {
    setState(() => _selectedStep = id);
    final cubit = context.read<StructureSetupCubit>();
    switch (id) {
      case StructureSetupStepId.departments:
        await cubit.setDepartments(value);
        return;
      case StructureSetupStepId.streams:
        await cubit.setStreams(value);
        return;
      case StructureSetupStepId.learningSpaces:
        await cubit.setRooms(value);
        return;
      case StructureSetupStepId.houses:
        await cubit.setHouses(value);
        return;
      case StructureSetupStepId.clubs:
        await cubit.setClubs(value);
        return;
      case StructureSetupStepId.boarding:
        await cubit.setBoarding(value);
        if (!context.mounted) return;
        context.read<StructureBloc>().add(
              UpdateFeatureTogglesRequested(
                state.featureToggles.copyWith(
                  boarding: value == StructureUseChoice.enabled,
                  hostel: value == StructureUseChoice.enabled,
                ),
              ),
            );
        return;
      case StructureSetupStepId.transport:
        await cubit.setTransport(value);
        if (!context.mounted) return;
        context.read<StructureBloc>().add(
              UpdateFeatureTogglesRequested(
                state.featureToggles.copyWith(
                  transport: value == StructureUseChoice.enabled,
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
    final steps = resolution.steps
        .where((item) => item.applicable && item.id != StructureSetupStepId.review)
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
          const _InfoCard(
            icon: Icons.verified_outlined,
            title: 'Structure ready',
            body:
                'Required Structure is valid. Every completed section remains editable.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: steps.isEmpty
                ? null
                : () => setState(() => _selectedStep = steps.first.id),
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Review step by step'),
          ),
          const SizedBox(height: 20),
          ...steps.map(
            (step) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                step.isSatisfied
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
              ),
              title: Text(step.title),
              subtitle: Text(_managementSubtitle(step, extended)),
              trailing: _canConfigure(step, null)
                  ? const Icon(Icons.chevron_right)
                  : null,
              onTap: _canConfigure(step, null)
                  ? () => _openStep(context, step)
                  : null,
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

  bool _canConfigure(
    StructureSetupStepResult step,
    StructureUseChoice? choice,
  ) {
    if (!step.prerequisitesComplete || step.id == StructureSetupStepId.review) {
      return false;
    }
    if (choice == StructureUseChoice.disabled) return false;
    return step.route.isNotEmpty ||
        step.id == StructureSetupStepId.curriculum ||
        step.id == StructureSetupStepId.academicAssignments ||
        step.id == StructureSetupStepId.classTimetables;
  }

  StructureUseChoice? _choiceFor(
    StructureSetupStepId id,
    StructureSetupPreferences value,
  ) {
    return switch (id) {
      StructureSetupStepId.departments => value.departments,
      StructureSetupStepId.streams => value.streams,
      StructureSetupStepId.learningSpaces => value.rooms,
      StructureSetupStepId.houses => value.houses,
      StructureSetupStepId.clubs => value.clubs,
      StructureSetupStepId.boarding => value.boarding,
      StructureSetupStepId.transport => value.transport,
      _ => null,
    };
  }

  String _summary(
    StructureSetupStepId id,
    StructureState state,
    StructureExtendedSetupState extended,
    StructureUseChoice? choice,
  ) {
    if (choice == StructureUseChoice.disabled) {
      return 'This school marked this optional Structure feature as not used.';
    }
    return switch (id) {
      StructureSetupStepId.institution =>
        state.institutionProfile.name.isEmpty
            ? 'Institution profile has not been completed.'
            : state.institutionProfile.name,
      StructureSetupStepId.academicYear =>
        '${state.academicYears.where((item) => item.isCurrent && !item.isArchived).length} current academic year(s)',
      StructureSetupStepId.academicTerms =>
        '${state.academicTerms.length} term / semester record(s)',
      StructureSetupStepId.levels => '${state.levels.length} educational level(s)',
      StructureSetupStepId.departments => '${state.departments.length} department(s)',
      StructureSetupStepId.classes => '${state.classes.length} class(es)',
      StructureSetupStepId.streams => '${state.streams.length} stream / section(s)',
      StructureSetupStepId.subjects => '${state.subjects.length} subject definition(s)',
      StructureSetupStepId.curriculum =>
        '${extended.curriculum.length} current curriculum allocation(s)',
      StructureSetupStepId.assessmentAndGrading =>
        '${state.assessmentTypes.length} assessment type(s), ${state.gradingSystems.length} grading system(s)',
      StructureSetupStepId.learningSpaces => '${state.facilities.length} learning space(s)',
      StructureSetupStepId.schoolDay =>
        '${state.timetableConfig.teachingDays.length} teaching day(s), ${state.timetableConfig.slots.length} slot(s)',
      StructureSetupStepId.staffRoles => '${state.staffRoles.length} role definition(s)',
      StructureSetupStepId.staffAccounts =>
        '${extended.staff.where((item) => item.isActive).length} active staff account(s)',
      StructureSetupStepId.academicAssignments =>
        '${extended.teachingAssignments.where((item) => item.isActive).length} active academic assignment(s)',
      StructureSetupStepId.classTimetables =>
        '${extended.timetables.where((item) => item.status.name == 'active').length} published timetable(s)',
      StructureSetupStepId.houses => '${state.houses.length} house(s)',
      StructureSetupStepId.clubs => '${state.clubs.length} club / society record(s)',
      StructureSetupStepId.boarding =>
        '${state.hostels.length} hostel(s), ${state.hostelRooms.length} room(s)',
      StructureSetupStepId.transport =>
        '${state.transportRoutes.length} route(s), ${state.transportVehicles.length} vehicle(s)',
      StructureSetupStepId.attendance =>
        '${state.attendanceTypes.length} attendance status definition(s)',
      StructureSetupStepId.financeFoundation =>
        '${state.feeCategories.length} fee category definition(s)',
      StructureSetupStepId.communication =>
        '${state.announcementCategories.length} announcement category(s), ${state.notificationCategories.length} notification category(s)',
      StructureSetupStepId.review => 'Review all required Structure dependencies before finishing.',
    };
  }

  void _showValidation(
    BuildContext context,
    StructureSetupResolution resolution,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
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
                  style: Theme.of(sheet)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (resolution.issues.isEmpty)
                  const Text('All required structural checks passed.')
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: resolution.issues.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
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
                          subtitle: Text(issue.stepId.name),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheet),
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

class _ChoiceCard extends StatelessWidget {
  final StructureUseChoice value;
  final ValueChanged<StructureUseChoice> onChanged;

  const _ChoiceCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Does this school use this?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SegmentedButton<StructureUseChoice>(
              segments: const [
                ButtonSegment(
                  value: StructureUseChoice.enabled,
                  label: Text('Yes'),
                  icon: Icon(Icons.check),
                ),
                ButtonSegment(
                  value: StructureUseChoice.disabled,
                  label: Text('No'),
                  icon: Icon(Icons.close),
                ),
              ],
              selected: value == StructureUseChoice.undecided
                  ? const <StructureUseChoice>{}
                  : <StructureUseChoice>{value},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) onChanged(selection.first);
              },
            ),
          ],
        ),
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final List<StructureSetupIssue> issues;

  const _IssueCard({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: issues
              .map(
                (issue) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    issue.severity == StructureIssueSeverity.critical
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
                  ),
                  title: Text(issue.message),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _Message({
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
