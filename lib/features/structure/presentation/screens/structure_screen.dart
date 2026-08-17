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
            if (structure.isLoading || setup.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final resolution = _engine.resolve(
              _context(structure, setup.preferences),
            );

            if (setup.preferences.onboardingCompleted &&
                resolution.isReady &&
                _selectedStep == null) {
              return _management(context, resolution);
            }

            final step = _resolveStep(resolution);
            if (step == null) {
              return const Scaffold(
                body: Center(child: Text('Structure setup is unavailable.')),
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
                    onPressed: () => _showValidation(context, resolution),
                  ),
                ],
              ),
              body: Column(
                children: [
                  LinearProgressIndicator(
                    value: resolution.progress.clamp(0.0, 1.0).toDouble(),
                    minHeight: 4,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: _stepContent(
                            context,
                            structure,
                            setup.preferences,
                            resolution,
                            step,
                            index < 0 ? 1 : index + 1,
                            visible.length,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
  }

  StructureSetupContext _context(
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

  StructureSetupStepResult? _resolveStep(StructureSetupResolution resolution) {
    if (_selectedStep != null) {
      final matches = resolution.steps.where((item) => item.id == _selectedStep);
      if (matches.isNotEmpty) return matches.first;
    }
    return resolution.nextStep;
  }

  Widget _stepContent(
    BuildContext context,
    StructureState state,
    StructureSetupPreferences preferences,
    StructureSetupResolution resolution,
    StructureSetupStepResult step,
    int number,
    int total,
  ) {
    final theme = Theme.of(context);
    final choice = _choice(step.id, preferences);
    final route = _route(step.id);

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
            body: 'Complete the previous Structure step before this one.',
          )
        else ...[
          if (choice != null) ...[
            _DecisionQuestion(
              stepId: step.id,
              value: choice,
              onChanged: (value) => _saveChoice(
                context,
                state,
                step.id,
                value,
              ),
            ),
            const SizedBox(height: 20),
          ],
          _InfoCard(
            icon: step.isSatisfied
                ? Icons.check_circle_outline
                : Icons.pending_actions_outlined,
            title: step.isSatisfied ? 'Ready to continue' : 'Current setup',
            body: _summary(step.id, state, choice),
          ),
          if (step.issues.isNotEmpty) ...[
            const SizedBox(height: 18),
            _IssueCard(issues: step.issues),
          ],
          if (route != null &&
              (choice == null || choice == StructureUseChoice.enabled)) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openStep(context, step, route),
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
                  : 'Structure needs attention',
              body:
                  '${resolution.requiredSteps.where((item) => item.isSatisfied).length} of ${resolution.requiredSteps.length} required steps are valid. ${resolution.issues.length} issue(s) are reported.',
            ),
          ],
        ],
      ],
    );
  }

  Widget _actions(
    BuildContext context,
    StructureSetupResolution resolution,
    StructureSetupStepResult current,
    bool saving,
  ) {
    final previous = _previous(resolution, current);
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
                        height: 20,
                        width: 20,
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

  StructureSetupStepResult? _previous(
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
    String route,
  ) async {
    await context.read<StructureSetupCubit>().rememberStep(step.id.name);
    if (!context.mounted) return;
    await context.push(route);
    if (!mounted) return;
    setState(() => _selectedStep = step.id);
  }

  Future<void> _continue(
    BuildContext context,
    StructureSetupResolution resolution,
    StructureSetupStepResult step,
  ) async {
    if (step.id == StructureSetupStepId.review) {
      if (!resolution.isReady) {
        _showValidation(context, resolution);
        return;
      }
      await context.read<StructureSetupCubit>().markOnboardingCompleted();
    } else {
      await context.read<StructureSetupCubit>().rememberStep(step.id.name);
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
  ) {
    final steps = resolution.steps
        .where((item) => item.applicable && item.id != StructureSetupStepId.review)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('School Structure')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _InfoCard(
            icon: Icons.verified_outlined,
            title: 'Structure ready',
            body:
                'Required school structure is valid. Every completed section remains editable.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: steps.isEmpty
                ? null
                : () => setState(() => _selectedStep = steps.first.id),
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Review step by step'),
          ),
          const SizedBox(height: 24),
          Text(
            'Manage Structure',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ...steps.map(
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
              onTap: _route(step.id) == null
                  ? null
                  : () => _openStep(context, step, _route(step.id)!),
            ),
          ),
        ],
      ),
    );
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
            constraints: const BoxConstraints(maxHeight: 580),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolution.isReady
                      ? 'Structure is ready'
                      : 'Structure needs attention',
                  style: Theme.of(sheet).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                if (resolution.issues.isEmpty)
                  const Text('All required structural checks passed.')
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: resolution.issues.length,
                      separatorBuilder: (_, _) => const Divider(),
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
        'Do you want to manage rooms and learning spaces?',
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
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

class _IssueCard extends StatelessWidget {
  final List<StructureSetupIssue> issues;
  const _IssueCard({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.45),
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
          ...issues.map((issue) => Text('• ${issue.message}')),
        ],
      ),
    );
  }
}

StructureUseChoice? _choice(
  StructureSetupStepId id,
  StructureSetupPreferences preferences,
) {
  return switch (id) {
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

String? _route(StructureSetupStepId id) => switch (id) {
      StructureSetupStepId.institution => '/staff/admin/structure/institution',
      StructureSetupStepId.academicYear =>
        '/staff/admin/structure/academic?section=years',
      StructureSetupStepId.academicTerms =>
        '/staff/admin/structure/academic?section=terms',
      StructureSetupStepId.levels =>
        '/staff/admin/structure/academic?section=levels',
      StructureSetupStepId.departments =>
        '/staff/admin/structure/people?section=departments',
      StructureSetupStepId.classes =>
        '/staff/admin/structure/academic?section=classes',
      StructureSetupStepId.streams =>
        '/staff/admin/structure/academic?section=streams',
      StructureSetupStepId.subjects =>
        '/staff/admin/structure/academic?section=subjects',
      StructureSetupStepId.assessmentAndGrading =>
        '/staff/admin/structure/assessment',
      StructureSetupStepId.learningSpaces =>
        '/staff/admin/structure/campus?section=facilities',
      StructureSetupStepId.schoolDay =>
        '/staff/admin/structure/operations?section=timetable',
      StructureSetupStepId.staffRoles =>
        '/staff/admin/structure/people?section=roles',
      StructureSetupStepId.houses =>
        '/staff/admin/structure/campus?section=houses',
      StructureSetupStepId.clubs =>
        '/staff/admin/structure/campus?section=clubs',
      StructureSetupStepId.boarding =>
        '/staff/admin/structure/campus?section=hostel',
      StructureSetupStepId.transport =>
        '/staff/admin/structure/campus?section=transport',
      StructureSetupStepId.attendance =>
        '/staff/admin/structure/operations?section=attendance',
      StructureSetupStepId.financeFoundation =>
        '/staff/admin/structure/operations?section=fees',
      StructureSetupStepId.communication =>
        '/staff/admin/structure/operations?section=communication',
      StructureSetupStepId.review => null,
    };

String _summary(
  StructureSetupStepId id,
  StructureState state,
  StructureUseChoice? choice,
) {
  if (choice == StructureUseChoice.disabled) return 'Not used by this school.';
  return switch (id) {
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
    StructureSetupStepId.assessmentAndGrading =>
      '${state.assessmentTypes.where((item) => item.isActive).length} assessment type(s) • ${state.gradingSystems.where((item) => item.isActive).length} grading system(s)',
    StructureSetupStepId.learningSpaces =>
      '${state.facilities.where((item) => item.isActive).length} active learning space(s)',
    StructureSetupStepId.schoolDay =>
      '${state.timetableConfig.teachingDays.length} teaching day(s) • ${state.timetableConfig.slots.length} slot(s)',
    StructureSetupStepId.staffRoles =>
      '${state.staffRoles.where((item) => item.isActive).length} active responsibility/role definition(s)',
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
