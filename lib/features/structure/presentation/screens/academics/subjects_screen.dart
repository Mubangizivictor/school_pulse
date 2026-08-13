import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/structure_entities.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart'
    show showDeleteConfirmDialog, kSubjectColorSwatches;
import '../../widgets/structure_empty_hint.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final subjects =
            state.subjects
                .where(
                  (s) => s.name.toLowerCase().contains(_query.toLowerCase()),
                )
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        return AcademicsListScaffold(
          title: 'Subjects',
          subtitle: 'Manage subjects and subject groups.',
          searchHint: 'Search subjects...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Subject',
          onFabPressed: () =>
              _openForm(context, schoolId: schoolId, bloc: bloc, state: state),
          body: subjects.isEmpty
              ? StructureEmptyHint(
                  _query.isEmpty
                      ? 'No subjects defined yet.'
                      : 'No subjects match "$_query".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final department = state.departments
                        .where((d) => d.id == subject.departmentId)
                        .firstOrNull;
                    final color = subject.color.isNotEmpty
                        ? Color(
                            int.parse(subject.color.replaceFirst('#', '0xff')),
                          )
                        : Colors.blueGrey;
                    final typeLabel = subject.isElective ? 'Elective' : 'Core';
                    return AcademicsListCard(
                      icon: Icons.menu_book_outlined,
                      color: color,
                      title: subject.name,
                      subtitle: department?.name ?? 'No department',
                      trailingLabel: typeLabel,
                      isActive: subject.isActive,
                      onTap: () => _openForm(
                        context,
                        schoolId: schoolId,
                        bloc: bloc,
                        state: state,
                        existing: subject,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _openForm(
    BuildContext context, {
    required String schoolId,
    required StructureBloc bloc,
    required StructureState state,
    Subject? existing,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SubjectFormScreen(
          schoolId: schoolId,
          departments: state.departments,
          levels: state.levels,
          classes: state.classes,
          existing: existing,
          onSave: (s) => bloc.add(SaveSubjectRequested(s)),
          onDelete: existing == null
              ? null
              : () => bloc.add(DeleteSubjectRequested(existing.id)),
        ),
      ),
    );
  }
}

class _SubjectFormScreen extends StatefulWidget {
  final String schoolId;
  final List<Department> departments;
  final List<EducationalLevel> levels;
  final List<SchoolClass> classes;
  final Subject? existing;
  final void Function(Subject) onSave;
  final VoidCallback? onDelete;

  const _SubjectFormScreen({
    required this.schoolId,
    required this.departments,
    required this.levels,
    required this.classes,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<_SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _codeController = TextEditingController(
    text: widget.existing?.code,
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late String? _departmentId = widget.existing?.departmentId.isNotEmpty == true
      ? widget.existing!.departmentId
      : null;
  late String _subjectType = widget.existing?.isElective == true
      ? 'Elective'
      : 'Core';
  late bool _isPractical = widget.existing?.isPractical ?? false;
  late bool _isActive = widget.existing?.isActive ?? true;
  late Set<String> _levelIds = {...?widget.existing?.assignedLevelIds};
  late Set<String> _classIds = {...?widget.existing?.assignedClassIds};
  late Color _color = widget.existing?.color.isNotEmpty == true
      ? Color(int.parse(widget.existing!.color.replaceFirst('#', '0xff')))
      : kSubjectColorSwatches.first;

  static const _types = ['Core', 'Elective', 'Optional', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Subject' : 'Add Subject',
      subtitle: isEdit
          ? 'Update this subject.'
          : 'Create a new subject for your school.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Subject',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Subject Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Mathematics'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Subject name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Subject Code *'),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. MATH'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Subject code is required'
                    : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Department'),
              DropdownButtonFormField<String>(
                initialValue: _departmentId,
                decoration: const InputDecoration(
                  hintText: 'Select department',
                ),
                items: widget.departments
                    .map(
                      (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _departmentId = v),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Applicable Level(s)'),
              _MultiSelectChips(
                options: {for (final l in widget.levels) l.id: l.name},
                selected: _levelIds,
                onChanged: (ids) => setState(() => _levelIds = ids),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Applicable Class(es)'),
              _MultiSelectChips(
                options: {for (final c in widget.classes) c.id: c.name},
                selected: _classIds,
                onChanged: (ids) => setState(() => _classIds = ids),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Subject Type'),
              DropdownButtonFormField<String>(
                initialValue: _subjectType,
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _subjectType = v ?? 'Core'),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Color'),
              Wrap(
                spacing: 8,
                children: kSubjectColorSwatches.map((c) {
                  final selected = c.toARGB32() == _color.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 14,
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Description'),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Optional description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Practical'),
                value: _isPractical,
                onChanged: (v) => setState(() => _isPractical = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Subject',
                      message: 'Delete "${widget.existing!.name}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Subject',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      Subject(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        departmentId: _departmentId ?? '',
        color: '#${_color.toARGB32().toRadixString(16).substring(2)}',
        description: _descController.text.trim(),
        isElective: _subjectType == 'Elective' || _subjectType == 'Optional',
        isPractical: _isPractical,
        creditUnits: widget.existing?.creditUnits ?? 0,
        isActive: _isActive,
        assignedLevelIds: _levelIds.toList(),
        assignedClassIds: _classIds.toList(),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _MultiSelectChips extends StatelessWidget {
  final Map<String, String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _MultiSelectChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(
        'None configured yet',
        style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: options.entries.map((e) {
        final isSelected = selected.contains(e.key);
        return FilterChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (v) {
            final next = {...selected};
            if (v) {
              next.add(e.key);
            } else {
              next.remove(e.key);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
