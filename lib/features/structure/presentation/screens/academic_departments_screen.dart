import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../bloc/structure_setup_cubit.dart';

const _validator = StructureIntegrityValidator();

/// Step 9: optional academic departments for grouping subjects. HOD
/// assignment happens later, under Academic Assignments, once staff exist -
/// this step only groups subjects.
class AcademicDepartmentsScreen extends StatelessWidget {
  const AcademicDepartmentsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StructureSetupCubit>(
      create: (_) => di.sl<StructureSetupCubit>(),
      child: Scaffold(
        appBar: showAppBar ? AppBar(title: const Text('Academic departments')) : null,
        backgroundColor: showAppBar ? null : Colors.transparent,
        body: BlocBuilder<StructureBloc, StructureState>(
          builder: (context, state) {
            final departments = state.departments
                .where((d) => d.isActive)
                .toList()
              ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
            final subjectsByDept = <String, List<Subject>>{};
            for (final subject in state.subjects.where((s) => s.isActive)) {
              if (subject.departmentId.isEmpty) continue;
              subjectsByDept.putIfAbsent(subject.departmentId, () => []).add(subject);
            }
            final totalGrouped = subjectsByDept.values.fold<int>(0, (sum, l) => sum + l.length);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Organise subjects together',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Group subjects for planning and staff management. Optional — you can complete this later.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () => context.read<StructureSetupCubit>().setDepartments(
                          StructureUseChoice.disabled,
                        ),
                        child: const Text('Skip for now'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (departments.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${departments.length} department${departments.length == 1 ? '' : 's'}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            '$totalGrouped subject${totalGrouped == 1 ? '' : 's'} grouped',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: departments.isEmpty
                          ? _EmptyState(onAdd: () => _openNewDepartment(context, state))
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: departments.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final department = departments[index];
                                final subjects = subjectsByDept[department.id] ?? const [];
                                return _DepartmentCard(
                                  department: department,
                                  subjects: subjects,
                                  onTap: () => _openNewDepartment(
                                    context,
                                    state,
                                    existing: department,
                                    existingSubjects: subjects,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => _openNewDepartment(context, state),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add department'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openNewDepartment(
    BuildContext context,
    StructureState state, {
    Department? existing,
    List<Subject> existingSubjects = const [],
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewDepartmentScreen(
          existing: existing,
          existingSubjectIds: existingSubjects.map((s) => s.id).toSet(),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.folder_outlined,
    title: 'No departments yet',
    message: 'Group related subjects together for planning and staff management.',
    ctaLabel: 'Add department',
    onCtaPressed: onAdd,
  );
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({
    required this.department,
    required this.subjects,
    required this.onTap,
  });

  final Department department;
  final List<Subject> subjects;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = subjects.map((s) => s.name).join(' · ');
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${subjects.length} subject${subjects.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// Screen 2: a dedicated full page (not a bottom sheet) for creating or
/// editing a department. Intentionally excludes department code,
/// description, HOD, teachers, capacity and rooms - those are configured
/// elsewhere, later.
class NewDepartmentScreen extends StatefulWidget {
  const NewDepartmentScreen({
    super.key,
    this.existing,
    this.existingSubjectIds = const {},
  });

  final Department? existing;
  final Set<String> existingSubjectIds;

  @override
  State<NewDepartmentScreen> createState() => _NewDepartmentScreenState();
}

class _NewDepartmentScreenState extends State<NewDepartmentScreen> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final Set<String> _selectedSubjectIds = {...widget.existingSubjectIds};
  String _query = '';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.existing != null;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(edit ? 'Edit department' : 'New department')),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final subjects = [...state.subjects.where((s) => s.isActive)]
            ..sort((a, b) => a.name.compareTo(b.name));
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      const Text(
                        'Department details',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a group for related subjects. You can assign a department lead later.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Department name *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(hintText: 'e.g. Languages'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Subjects (optional)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _pickSubjects(context, subjects),
                              child: Row(
                                children: [
                                  const Expanded(child: Text('Add subjects')),
                                  const Icon(Icons.expand_more),
                                ],
                              ),
                            ),
                            if (_selectedSubjectIds.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final id in _selectedSubjectIds)
                                    if (subjects.where((s) => s.id == id).firstOrNull
                                        case final subject?)
                                      InputChip(
                                        label: Text(subject.name),
                                        onDeleted: () =>
                                            setState(() => _selectedSubjectIds.remove(id)),
                                      ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A subject can belong to one department at a time.',
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      if (!edit && _selectedSubjectIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _selectedSubjectIds.clear()),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                          child: const Text('Skip subjects for now'),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outline),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_error!, style: TextStyle(color: scheme.onSurface)),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _name.text.trim().isEmpty || _saving
                                ? null
                                : () => _save(context, state, subjects),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(edit ? 'Save changes' : 'Create department'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickSubjects(BuildContext context, List<Subject> subjects) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add subjects',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search subjects',
                  ),
                  onChanged: (v) => setSheetState(() => _query = v),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final subject in subjects.where(
                        (s) => s.name.toLowerCase().contains(_query.toLowerCase()),
                      ))
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(subject.name),
                          subtitle: subject.departmentId.isNotEmpty &&
                                  subject.departmentId != widget.existing?.id
                              ? const Text('Currently in another department')
                              : null,
                          value: _selectedSubjectIds.contains(subject.id),
                          onChanged: (checked) => setState(() {
                            setSheetState(() {
                              if (checked == true) {
                                _selectedSubjectIds.add(subject.id);
                              } else {
                                _selectedSubjectIds.remove(subject.id);
                              }
                            });
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
    setState(() {});
  }

  Future<void> _save(
    BuildContext context,
    StructureState state,
    List<Subject> allSubjects,
  ) async {
    final name = _name.text.trim();
    final edit = widget.existing;
    final department = Department(
      id: edit?.id ?? const Uuid().v4(),
      schoolId: edit?.schoolId ?? '',
      name: name,
      headOfDepartmentStaffId: edit?.headOfDepartmentStaffId ?? '',
      displayOrder: edit?.displayOrder ?? state.departments.length,
    );
    final validationError = _validator.validateDepartment(department, state.departments);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    // Subjects moving from another department need an explicit confirmation
    // before this save reassigns them - "a subject can belong to one
    // department at a time" is enforced here, not silently.
    final reassignedFrom = <Subject>[];
    for (final id in _selectedSubjectIds) {
      final subject = allSubjects.where((s) => s.id == id).firstOrNull;
      if (subject != null &&
          subject.departmentId.isNotEmpty &&
          subject.departmentId != department.id) {
        reassignedFrom.add(subject);
      }
    }
    if (reassignedFrom.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Move subjects to this department?'),
          content: Text(
            '${reassignedFrom.map((s) => s.name).join(', ')} '
            '${reassignedFrom.length == 1 ? 'is' : 'are'} currently in another department. '
            'Moving ${reassignedFrom.length == 1 ? 'it' : 'them'} here will remove '
            '${reassignedFrom.length == 1 ? 'it' : 'them'} from the previous one.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move')),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    setState(() => _saving = true);
    final bloc = context.read<StructureBloc>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final removedIds = widget.existingSubjectIds.difference(_selectedSubjectIds);
      final removedSubjects = [
        for (final id in removedIds)
          if (allSubjects.where((s) => s.id == id).firstOrNull case final subject?) subject,
      ];
      final addedSubjects = [
        for (final id in _selectedSubjectIds)
          if (allSubjects.where((s) => s.id == id).firstOrNull case final subject?)
            if (subject.departmentId != department.id) subject,
      ];
      bloc.add(
        SaveDepartmentWithSubjectsRequested(department, addedSubjects, removedSubjects),
      );
      navigator.pop();
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save department: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
