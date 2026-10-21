import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/teaching_plan.dart';
import '../../domain/repositories/teaching_plan_repository.dart';
import '../bloc/structure_state.dart';

/// Per-class adjustments on top of an education level's [TeachingPlan]. A
/// class inherits the level plan by default; this screen lets an admin
/// add/remove a subject or change weekly lessons for one class only, and
/// reset it back to full inheritance. Streams under this class inherit
/// whatever the class ends up with here - there is no separate stream
/// override screen.
class ClassAdjustmentsScreen extends StatelessWidget {
  const ClassAdjustmentsScreen({
    super.key,
    required this.repository,
    required this.plan,
    required this.schoolClass,
    required this.levelPlanSubjects,
    required this.structure,
  });

  final TeachingPlanRepository repository;
  final TeachingPlan plan;
  final SchoolClass schoolClass;
  final List<TeachingPlanSubject> levelPlanSubjects;
  final StructureState structure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${schoolClass.name} adjustments')),
      body: StreamBuilderOverrides(
        repository: repository,
        plan: plan,
        schoolClass: schoolClass,
        levelPlanSubjects: levelPlanSubjects,
        structure: structure,
      ),
    );
  }
}

class StreamBuilderOverrides extends StatelessWidget {
  const StreamBuilderOverrides({
    super.key,
    required this.repository,
    required this.plan,
    required this.schoolClass,
    required this.levelPlanSubjects,
    required this.structure,
  });

  final TeachingPlanRepository repository;
  final TeachingPlan plan;
  final SchoolClass schoolClass;
  final List<TeachingPlanSubject> levelPlanSubjects;
  final StructureState structure;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClassPlanOverride>>(
      stream: repository.watchClassOverrides(plan.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load overrides: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final overrides = snapshot.data!
            .where((o) => o.classId == schoolClass.id)
            .toList();
        return _Body(
          repository: repository,
          plan: plan,
          schoolClass: schoolClass,
          levelPlanSubjects: levelPlanSubjects,
          overrides: overrides,
          structure: structure,
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.repository,
    required this.plan,
    required this.schoolClass,
    required this.levelPlanSubjects,
    required this.overrides,
    required this.structure,
  });

  final TeachingPlanRepository repository;
  final TeachingPlan plan;
  final SchoolClass schoolClass;
  final List<TeachingPlanSubject> levelPlanSubjects;
  final List<ClassPlanOverride> overrides;
  final StructureState structure;

  /// The effective subject list for this class: the level plan, with
  /// per-class overrides applied (add/remove/modify), computed for display
  /// only - reads never need to touch the level plan's own rows.
  List<_EffectiveSubject> get _effective {
    final overridesBySubject = {for (final o in overrides) o.subjectId: o};
    final result = <_EffectiveSubject>[];
    for (final planSubject in levelPlanSubjects) {
      final override = overridesBySubject[planSubject.subjectId];
      if (override?.action == ClassPlanOverrideAction.remove) continue;
      if (override != null &&
          override.action == ClassPlanOverrideAction.modify) {
        result.add(
          _EffectiveSubject(
            subjectId: planSubject.subjectId,
            isCore: override.isCore ?? planSubject.isCore,
            weeklyLessons: override.weeklyLessons ?? planSubject.weeklyLessons,
            isOverridden: true,
            override: override,
          ),
        );
      } else {
        result.add(
          _EffectiveSubject(
            subjectId: planSubject.subjectId,
            isCore: planSubject.isCore,
            weeklyLessons: planSubject.weeklyLessons,
            isOverridden: false,
          ),
        );
      }
    }
    for (final override in overrides) {
      if (override.action == ClassPlanOverrideAction.add) {
        result.add(
          _EffectiveSubject(
            subjectId: override.subjectId,
            isCore: override.isCore ?? true,
            weeklyLessons: override.weeklyLessons,
            isOverridden: true,
            override: override,
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effective = _effective;
    final planSubjectIds = levelPlanSubjects.map((s) => s.subjectId).toSet();
    final effectiveIds = effective.map((s) => s.subjectId).toSet();
    final availableToAdd = structure.subjects
        .where((s) => s.isActive && !effectiveIds.contains(s.id))
        .toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Text(
            'Overrides for ${schoolClass.name}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'This class inherits the education level plan. Any change here applies only to this class.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          if (overrides.isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _resetToInherited(context),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset to inherited plan'),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Effective subjects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: availableToAdd.isEmpty
                    ? null
                    : () => _addOverride(context, availableToAdd),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add subject'),
              ),
            ],
          ),
          if (effective.isEmpty)
            Text(
              'No subjects in the level plan yet.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            )
          else
            ...effective.map(
              (item) => _EffectiveSubjectRow(
                item: item,
                subject: structure.subjects
                    .where((s) => s.id == item.subjectId)
                    .firstOrNull,
                inheritedFromPlan: planSubjectIds.contains(item.subjectId),
                onEdit: () => _editOverride(context, item),
                onRemove: () => _removeSubjectForClass(context, item),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _resetToInherited(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to inherited plan'),
        content: Text(
          'Remove all overrides for ${schoolClass.name}? It will fully inherit the education level plan again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.resetClassToInherited(plan.id, schoolClass.id);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not reset: $error')),
      );
    }
  }

  Future<void> _addOverride(
    BuildContext context,
    List<Subject> available,
  ) async {
    final result = await showModalBottomSheet<_OverrideFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _OverrideFormSheet(availableSubjects: available),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.saveClassOverride(
        ClassPlanOverride(
          id: const Uuid().v4(),
          schoolId: '',
          planId: plan.id,
          classId: schoolClass.id,
          subjectId: result.subjectId,
          action: ClassPlanOverrideAction.add,
          isCore: result.isCore,
          weeklyLessons: result.weeklyLessons,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not add subject: $error')),
      );
    }
  }

  Future<void> _editOverride(
    BuildContext context,
    _EffectiveSubject item,
  ) async {
    final subject = structure.subjects
        .where((s) => s.id == item.subjectId)
        .firstOrNull;
    final result = await showModalBottomSheet<_OverrideFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _OverrideFormSheet(
        availableSubjects: subject == null ? const [] : [subject],
        lockSubject: true,
        initialIsCore: item.isCore,
        initialWeeklyLessons: item.weeklyLessons,
      ),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.saveClassOverride(
        (item.override ??
                ClassPlanOverride(
                  id: const Uuid().v4(),
                  schoolId: '',
                  planId: plan.id,
                  classId: schoolClass.id,
                  subjectId: item.subjectId,
                  action: ClassPlanOverrideAction.modify,
                ))
            .copyWith(
              action: ClassPlanOverrideAction.modify,
              isCore: result.isCore,
              weeklyLessons: result.weeklyLessons,
            ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update: $error')),
      );
    }
  }

  Future<void> _removeSubjectForClass(
    BuildContext context,
    _EffectiveSubject item,
  ) async {
    final subject = structure.subjects
        .where((s) => s.id == item.subjectId)
        .firstOrNull;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove subject for this class'),
        content: Text(
          'Remove "${subject?.name ?? 'this subject'}" from ${schoolClass.name} only? Other classes in this level keep it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (item.override != null &&
          item.override!.action == ClassPlanOverrideAction.add) {
        await repository.deleteClassOverride(item.override!.id);
      } else {
        await repository.saveClassOverride(
          ClassPlanOverride(
            id: item.override?.id ?? const Uuid().v4(),
            schoolId: '',
            planId: plan.id,
            classId: schoolClass.id,
            subjectId: item.subjectId,
            action: ClassPlanOverrideAction.remove,
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not remove: $error')),
      );
    }
  }
}

class _EffectiveSubject {
  final String subjectId;
  final bool isCore;
  final int? weeklyLessons;
  final bool isOverridden;
  final ClassPlanOverride? override;

  const _EffectiveSubject({
    required this.subjectId,
    required this.isCore,
    required this.weeklyLessons,
    required this.isOverridden,
    this.override,
  });
}

class _EffectiveSubjectRow extends StatelessWidget {
  const _EffectiveSubjectRow({
    required this.item,
    required this.subject,
    required this.inheritedFromPlan,
    required this.onEdit,
    required this.onRemove,
  });

  final _EffectiveSubject item;
  final Subject? subject;
  final bool inheritedFromPlan;
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
            [
              item.isCore ? 'Core' : 'Elective',
              item.weeklyLessons == null
                  ? 'Not set'
                  : '${item.weeklyLessons} lessons/week',
              if (item.isOverridden)
                'Overridden'
              else if (inheritedFromPlan)
                'Inherited',
            ].join(' • '),
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverrideFormResult {
  final String subjectId;
  final bool isCore;
  final int? weeklyLessons;
  const _OverrideFormResult(this.subjectId, this.isCore, this.weeklyLessons);
}

class _OverrideFormSheet extends StatefulWidget {
  const _OverrideFormSheet({
    required this.availableSubjects,
    this.lockSubject = false,
    this.initialIsCore = true,
    this.initialWeeklyLessons,
  });

  final List<Subject> availableSubjects;
  final bool lockSubject;
  final bool initialIsCore;
  final int? initialWeeklyLessons;

  @override
  State<_OverrideFormSheet> createState() => _OverrideFormSheetState();
}

class _OverrideFormSheetState extends State<_OverrideFormSheet> {
  String? _subjectId;
  late bool _isCore = widget.initialIsCore;
  late final _weeklyLessons = TextEditingController(
    text: widget.initialWeeklyLessons?.toString() ?? '',
  );
  String? _error;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.availableSubjects.isNotEmpty
        ? widget.availableSubjects.first.id
        : null;
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
                'Subject override',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (!widget.lockSubject)
                DropdownButtonFormField<String>(
                  initialValue: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: [
                    for (final subject in widget.availableSubjects)
                      DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _subjectId = value),
                )
              else if (widget.availableSubjects.isNotEmpty)
                Text(
                  widget.availableSubjects.first.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
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
                      onChanged: (value) =>
                          setState(() => _isCore = value ?? true),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Elective'),
                      value: false,
                      groupValue: _isCore,
                      onChanged: (value) =>
                          setState(() => _isCore = value ?? true),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _weeklyLessons,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weekly lessons',
                  hintText: 'Leave blank to inherit / not set',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: scheme.onSurface, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Save'),
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
        setState(
          () => _error =
              'Enter a positive number of weekly lessons, or leave it blank.',
        );
        return;
      }
    }
    Navigator.pop(context, _OverrideFormResult(_subjectId!, _isCore, weekly));
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
