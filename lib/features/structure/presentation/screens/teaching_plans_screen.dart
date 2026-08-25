import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../data/repositories/teaching_plan_repository_impl.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/teaching_plan.dart';
import '../../domain/repositories/teaching_plan_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'class_adjustments_screen.dart';

/// Step 8: maps the school's subject catalogue onto education levels for
/// teaching, timetables, teacher assignments and assessment - one teaching
/// plan per level, not a generic one-subject-at-a-time allocation screen.
/// Replaces the old CurriculumAssignmentScreen; that screen's collection
/// (`structure_curriculum_assignments`) is kept in sync underneath so
/// TeachingAssignmentRepositoryImpl's Subject Teacher gate and
/// StructureSetupEngine's completeness check keep working unchanged.
class TeachingPlansScreen extends StatefulWidget {
  const TeachingPlansScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<TeachingPlansScreen> createState() => _TeachingPlansScreenState();
}

class _TeachingPlansScreenState extends State<TeachingPlansScreen> {
  late final TeachingPlanRepository _repository;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _repository = TeachingPlanRepositoryImpl(
      firestore: firestore,
      tenantResolver: StructureTenantResolver(firestore: firestore),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Teaching plans'))
          : null,
      backgroundColor: widget.showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) {
          final currentYear = structure.academicYears
              .where((year) => year.isCurrent && !year.isArchived)
              .firstOrNull;
          if (currentYear == null) {
            return const _Message(
              title: 'Current academic year required',
              body:
                  'Set an academic year as current before setting up teaching plans.',
            );
          }
          final levels = structure.levels.where((l) => l.isActive).toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          if (levels.isEmpty) {
            return const _Message(
              title: 'Education levels required',
              body: 'Add at least one education level before teaching plans.',
            );
          }
          return StreamBuilder<List<TeachingPlan>>(
            stream: _repository.watchPlans(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _Message(
                  title: 'Could not load teaching plans',
                  body: '${snapshot.error}',
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final plans = snapshot.data!
                  .where((p) => p.academicYearId == currentYear.id)
                  .toList();
              return _Overview(
                repository: _repository,
                structure: structure,
                levels: levels,
                plans: plans,
                academicYearId: currentYear.id,
              );
            },
          );
        },
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.repository,
    required this.structure,
    required this.levels,
    required this.plans,
    required this.academicYearId,
  });

  final TeachingPlanRepository repository;
  final StructureState structure;
  final List<EducationalLevel> levels;
  final List<TeachingPlan> plans;
  final String academicYearId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeSubjects = structure.subjects.where((s) => s.isActive).length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set the subjects and weekly lesson load for each education level.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _SubjectsPrerequisiteCard(count: activeSubjects),
            const SizedBox(height: 24),
            Text(
              'Plans by education level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: levels.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  final classCount = structure.classes
                      .where((c) => c.levelId == level.id && c.isActive)
                      .length;
                  final plan = plans
                      .where((p) => p.educationLevelId == level.id)
                      .firstOrNull;
                  return _LevelPlanCard(
                    level: level,
                    classCount: classCount,
                    plan: plan,
                    onSetUp: () => _openStartOrEdit(context, level, plan),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStartOrEdit(
    BuildContext context,
    EducationalLevel level,
    TeachingPlan? plan,
  ) {
    if (plan != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TeachingPlanEditorScreen(
            repository: repository,
            plan: plan,
            level: level,
            structure: structure,
          ),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _StartPlanSheet(
        repository: repository,
        level: level,
        academicYearId: academicYearId,
        existingPlans: plans,
        structure: structure,
      ),
    );
  }
}

class _SubjectsPrerequisiteCard extends StatelessWidget {
  const _SubjectsPrerequisiteCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      showShadow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.menu_book_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'School subjects',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count subject${count == 1 ? '' : 's'} in catalogue',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () =>
                  context.push('/staff/admin/structure?section=subjects'),
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPlanCard extends StatelessWidget {
  const _LevelPlanCard({
    required this.level,
    required this.classCount,
    required this.plan,
    required this.onSetUp,
  });

  final EducationalLevel level;
  final int classCount;
  final TeachingPlan? plan;
  final VoidCallback onSetUp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSetUp = plan != null;
    return AppCard(
      onTap: onSetUp,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$classCount class${classCount == 1 ? '' : 'es'} · ${isSetUp ? 'Set up' : 'Not set up'}',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onSetUp,
              child: Text(isSetUp ? 'Edit plan' : 'Set up plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartPlanSheet extends StatefulWidget {
  const _StartPlanSheet({
    required this.repository,
    required this.level,
    required this.academicYearId,
    required this.existingPlans,
    required this.structure,
  });

  final TeachingPlanRepository repository;
  final EducationalLevel level;
  final String academicYearId;
  final List<TeachingPlan> existingPlans;
  final StructureState structure;

  @override
  State<_StartPlanSheet> createState() => _StartPlanSheetState();
}

class _StartPlanSheetState extends State<_StartPlanSheet> {
  String? _templateSourceId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final otherPlans = widget.existingPlans
        .where((p) => p.educationLevelId != widget.level.id)
        .toList();
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set up ${widget.level.name} plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This plan applies to every class in ${widget.level.name} and can be adjusted per class later.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              if (otherPlans.isNotEmpty) ...[
                const Text(
                  'Use curriculum template',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Copy the subjects from one of this school\'s existing plans.',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _templateSourceId,
                  decoration: const InputDecoration(hintText: 'Choose a plan to copy'),
                  items: [
                    for (final source in otherPlans)
                      DropdownMenuItem(
                        value: source.id,
                        child: Text(
                          widget.structure.levels
                                  .where((l) => l.id == source.educationLevelId)
                                  .firstOrNull
                                  ?.name ??
                              'Plan',
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _templateSourceId = value),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving || _templateSourceId == null
                      ? null
                      : () => _start(context, fromTemplate: true),
                  child: const Text('Use curriculum template'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _saving ? null : () => _start(context, fromTemplate: false),
                  child: const Text('Build from school subjects'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context, {required bool fromTemplate}) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final auth = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.user.id : '';
    try {
      final plan = TeachingPlan(
        id: const Uuid().v4(),
        schoolId: '',
        educationLevelId: widget.level.id,
        academicYearId: widget.academicYearId,
        templateSourceId: fromTemplate ? (_templateSourceId ?? '') : '',
        createdBy: userId,
        updatedBy: userId,
      );
      await widget.repository.savePlan(plan);
      if (fromTemplate && _templateSourceId != null) {
        final sourceSubjects =
            await widget.repository.watchPlanSubjects(_templateSourceId!).first;
        if (sourceSubjects.isNotEmpty) {
          await widget.repository.saveSubjects([
            for (final subject in sourceSubjects)
              TeachingPlanSubject(
                id: const Uuid().v4(),
                schoolId: '',
                planId: plan.id,
                subjectId: subject.subjectId,
                isCore: subject.isCore,
                weeklyLessons: subject.weeklyLessons,
                order: subject.order,
              ),
          ]);
        }
      }
      if (!mounted) return;
      navigator.pop();
      navigator.push(
        MaterialPageRoute(
          builder: (_) => TeachingPlanEditorScreen(
            repository: widget.repository,
            plan: plan,
            level: widget.level,
            structure: widget.structure,
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Could not start plan: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Full teaching plan editor: level-wide subjects and per-class adjustments.
class TeachingPlanEditorScreen extends StatelessWidget {
  const TeachingPlanEditorScreen({
    super.key,
    required this.repository,
    required this.plan,
    required this.level,
    required this.structure,
  });

  final TeachingPlanRepository repository;
  final TeachingPlan plan;
  final EducationalLevel level;
  final StructureState structure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${level.name} teaching plan')),
      body: StreamBuilder<List<TeachingPlanSubject>>(
        stream: repository.watchPlanSubjects(plan.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Message(title: 'Could not load plan', body: '${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final planSubjects = [...snapshot.data!]
            ..sort((a, b) => a.order.compareTo(b.order));
          final classesInLevel = structure.classes
              .where((c) => c.levelId == level.id && c.isActive)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          return _PlanEditorBody(
            repository: repository,
            plan: plan,
            level: level,
            structure: structure,
            planSubjects: planSubjects,
            classesInLevel: classesInLevel,
          );
        },
      ),
    );
  }
}

class _PlanEditorBody extends StatelessWidget {
  const _PlanEditorBody({
    required this.repository,
    required this.plan,
    required this.level,
    required this.structure,
    required this.planSubjects,
    required this.classesInLevel,
  });

  final TeachingPlanRepository repository;
  final TeachingPlan plan;
  final EducationalLevel level;
  final StructureState structure;
  final List<TeachingPlanSubject> planSubjects;
  final List<SchoolClass> classesInLevel;

  int? get _weeklyCapacity {
    final slots = structure.timetableConfig.slots
        .where((slot) => slot.isActive && slot.type == 'period');
    if (slots.isEmpty) return null;
    return slots.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final plannedTotal = planSubjects
        .where((s) => s.isActive)
        .fold<int>(0, (sum, s) => sum + (s.weeklyLessons ?? 0));
    final capacity = _weeklyCapacity;
    final overCapacity = capacity != null && plannedTotal > capacity;
    final assignedSubjectIds = planSubjects.map((s) => s.subjectId).toSet();
    final availableSubjects = structure.subjects
        .where((s) => s.isActive && !assignedSubjectIds.contains(s.id))
        .toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Text(
            '${level.name} · Academic year plan',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            plan.templateSourceId.isNotEmpty
                ? 'Started from template · Version ${plan.templateVersion}'
                : 'Built from school subjects · Version ${plan.templateVersion}',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          if (overCapacity) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_outlined, size: 18, color: scheme.onSurface),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Planned lessons ($plannedTotal/week) exceed the configured school week ($capacity periods). Review the plan or school-day setup.',
                      style: TextStyle(fontSize: 12, color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Subjects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: availableSubjects.isEmpty
                    ? null
                    : () => _addSubject(context, availableSubjects),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add school subject'),
              ),
            ],
          ),
          if (planSubjects.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No subjects yet',
                message: 'Add subjects from the school catalogue for this level.',
                ctaLabel: availableSubjects.isEmpty ? null : 'Add school subject',
                onCtaPressed: availableSubjects.isEmpty
                    ? null
                    : () => _addSubject(context, availableSubjects),
              ),
            )
          else
            ...planSubjects.map(
              (planSubject) => _PlanSubjectRow(
                planSubject: planSubject,
                subject: structure.subjects
                    .where((s) => s.id == planSubject.subjectId)
                    .firstOrNull,
                onEdit: () => _editSubject(context, planSubject),
                onRemove: () => _removeSubject(context, planSubject),
              ),
            ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Class adjustments (optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Classes inherit this plan by default. Adjust an individual class here if it needs to differ.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          if (classesInLevel.isEmpty)
            Text(
              'No classes in this level yet.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            )
          else
            ...classesInLevel.map(
              (schoolClass) => _ClassAdjustmentRow(
                schoolClass: schoolClass,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ClassAdjustmentsScreen(
                      repository: repository,
                      plan: plan,
                      schoolClass: schoolClass,
                      levelPlanSubjects: planSubjects,
                      structure: structure,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save plan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubject(BuildContext context, List<Subject> available) async {
    final result = await showModalBottomSheet<_SubjectFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SubjectFormSheet(availableSubjects: available),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.saveSubject(
        TeachingPlanSubject(
          id: const Uuid().v4(),
          schoolId: '',
          planId: plan.id,
          subjectId: result.subjectId,
          isCore: result.isCore,
          weeklyLessons: result.weeklyLessons,
          order: planSubjects.length,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Could not add subject: $error')));
    }
  }

  Future<void> _editSubject(BuildContext context, TeachingPlanSubject planSubject) async {
    final subject = structure.subjects.where((s) => s.id == planSubject.subjectId).firstOrNull;
    final result = await showModalBottomSheet<_SubjectFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SubjectFormSheet(
        availableSubjects: subject == null ? const [] : [subject],
        existing: planSubject,
        lockSubject: true,
      ),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.saveSubject(
        planSubject.copyWith(
          isCore: result.isCore,
          weeklyLessons: result.weeklyLessons,
          clearWeeklyLessons: result.weeklyLessons == null,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Could not update subject: $error')));
    }
  }

  Future<void> _removeSubject(BuildContext context, TeachingPlanSubject planSubject) async {
    final subject = structure.subjects.where((s) => s.id == planSubject.subjectId).firstOrNull;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove subject'),
        content: Text('Remove "${subject?.name ?? 'this subject'}" from the ${level.name} plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.removeSubject(plan.id, planSubject.subjectId);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Could not remove subject: $error')));
    }
  }
}

class _PlanSubjectRow extends StatelessWidget {
  const _PlanSubjectRow({
    required this.planSubject,
    required this.subject,
    required this.onEdit,
    required this.onRemove,
  });

  final TeachingPlanSubject planSubject;
  final Subject? subject;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: ListTile(
          title: Text(
            subject?.name ?? 'Unknown subject',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${planSubject.isCore ? 'Core' : 'Elective'} • ${planSubject.weeklyLessons == null ? 'Not set' : '${planSubject.weeklyLessons} lessons/week'}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: onRemove),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassAdjustmentRow extends StatelessWidget {
  const _ClassAdjustmentRow({required this.schoolClass, required this.onTap});

  final SchoolClass schoolClass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        child: ListTile(
          title: Text(schoolClass.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Inherits level plan'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _SubjectFormResult {
  final String subjectId;
  final bool isCore;
  final int? weeklyLessons;
  const _SubjectFormResult(this.subjectId, this.isCore, this.weeklyLessons);
}

class _SubjectFormSheet extends StatefulWidget {
  const _SubjectFormSheet({
    required this.availableSubjects,
    this.existing,
    this.lockSubject = false,
  });

  final List<Subject> availableSubjects;
  final TeachingPlanSubject? existing;
  final bool lockSubject;

  @override
  State<_SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<_SubjectFormSheet> {
  String? _subjectId;
  late bool _isCore = widget.existing?.isCore ?? true;
  late final _weeklyLessons = TextEditingController(
    text: widget.existing?.weeklyLessons?.toString() ?? '',
  );
  String? _error;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.existing?.subjectId ??
        (widget.availableSubjects.isNotEmpty ? widget.availableSubjects.first.id : null);
  }

  @override
  void dispose() {
    _weeklyLessons.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Add school subject' : 'Edit subject',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (!widget.lockSubject)
                DropdownButtonFormField<String>(
                  value: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: [
                    for (final subject in widget.availableSubjects)
                      DropdownMenuItem(value: subject.id, child: Text(subject.name)),
                  ],
                  onChanged: (value) => setState(() => _subjectId = value),
                )
              else if (widget.availableSubjects.isNotEmpty)
                Text(
                  widget.availableSubjects.first.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Core'),
                      value: true,
                      groupValue: _isCore,
                      onChanged: (value) => setState(() => _isCore = value ?? true),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Elective'),
                      value: false,
                      groupValue: _isCore,
                      onChanged: (value) => setState(() => _isCore = value ?? true),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _weeklyLessons,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weekly lessons',
                  hintText: 'Leave blank if not yet set',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: TextStyle(color: scheme.onSurface, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(widget.existing == null ? 'Add subject' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_subjectId == null) {
      setState(() => _error = 'Choose a subject.');
      return;
    }
    final raw = _weeklyLessons.text.trim();
    int? weekly;
    if (raw.isNotEmpty) {
      weekly = int.tryParse(raw);
      if (weekly == null || weekly <= 0) {
        setState(() => _error = 'Enter a positive number of weekly lessons, or leave it blank.');
        return;
      }
    }
    Navigator.pop(context, _SubjectFormResult(_subjectId!, _isCore, weekly));
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
