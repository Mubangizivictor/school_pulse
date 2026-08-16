import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/structure_dependency_service.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart'
    show kSubjectColorSwatches, showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});
  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;
  _Order _order = _Order.nameAsc;
  @override
  Widget build(BuildContext context) {
    final user =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user;
    final schoolId = user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final items =
            state.subjects.where((s) {
              final dept =
                  state.departments
                      .where((d) => d.id == s.departmentId)
                      .firstOrNull
                      ?.name ??
                  '';
              return '${s.name} ${s.code} $dept'.toLowerCase().contains(
                    _query.toLowerCase(),
                  ) &&
                  switch (_filter) {
                    _Filter.all => true,
                    _Filter.active => s.isActive,
                    _Filter.inactive => !s.isActive,
                    _Filter.practical => s.isPractical,
                  };
            }).toList()..sort(
              (a, b) => switch (_order) {
                _Order.nameAsc => a.name.toLowerCase().compareTo(
                  b.name.toLowerCase(),
                ),
                _Order.nameDesc => b.name.toLowerCase().compareTo(
                  a.name.toLowerCase(),
                ),
                _Order.codeAsc => a.code.toLowerCase().compareTo(
                  b.code.toLowerCase(),
                ),
                _Order.codeDesc => b.code.toLowerCase().compareTo(
                  a.code.toLowerCase(),
                ),
                _Order.recent => b.id.compareTo(a.id),
              },
            );
        final bloc = context.read<StructureBloc>();
        return AcademicsListScaffold(
          title: 'Subjects',
          subtitle: 'Manage subjects and subject groups.',
          searchHint: 'Search subjects...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Subject',
          onFabPressed: () => _open(context, schoolId, user.id, bloc, state),
          headerExtra: [
            _Summary(
              total: state.subjects.length,
              active: state.subjects.where((s) => s.isActive).length,
              departments: state.departments.where((d) => d.isActive).length,
              practical: state.subjects.where((s) => s.isPractical).length,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SUBJECTS (${items.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _chooseFilter,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: Text(_filter.label),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<_Order>(
                  onSelected: (v) => setState(() => _order = v),
                  itemBuilder: (_) => _Order.values
                      .map((v) => PopupMenuItem(value: v, child: Text(v.label)))
                      .toList(),
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.sort, size: 18),
                    label: Text(
                      _order == _Order.nameAsc ? 'Order' : _order.label,
                    ),
                  ),
                ),
              ],
            ),
          ],
          body: items.isEmpty
              ? StructureEmptyHint(
                  _query.isEmpty
                      ? 'No subjects defined yet.\nCreate your first subject to start configuring academics.'
                      : 'No subjects match "$_query".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final s = items[i];
                    return _Card(
                      subject: s,
                      onTap: () =>
                          _open(context, schoolId, user.id, bloc, state, s),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _chooseFilter() async {
    final value = await showModalBottomSheet<_Filter>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Filter subjects',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ..._Filter.values.map(
              (f) => ListTile(
                selected: f == _filter,
                title: Text(f.label),
                trailing: f == _filter ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(c, f),
              ),
            ),
          ],
        ),
      ),
    );
    if (value != null && mounted) setState(() => _filter = value);
  }

  void _open(
    BuildContext context,
    String schoolId,
    String userId,
    StructureBloc bloc,
    StructureState state, [
    Subject? existing,
  ]) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => _Form(
        schoolId: schoolId,
        userId: userId,
        state: state,
        existing: existing,
        onSave: (s) => bloc.add(SaveSubjectRequested(s)),
        dependencies: existing == null
            ? null
            : () => di.sl<StructureDependencyService>().countSubjectReferences(
                schoolId,
                existing.id,
              ),
        delete: existing == null
            ? null
            : (action) => bloc.add(
                action == 'delete'
                    ? DeleteSubjectRequested(existing.id)
                    : ArchiveSubjectRequested(existing.id),
              ),
      ),
    ),
  );
}

enum _Filter { all, active, inactive, practical }

extension on _Filter {
  String get label => switch (this) {
    _Filter.all => 'All',
    _Filter.active => 'Active',
    _Filter.inactive => 'Inactive',
    _Filter.practical => 'Practical',
  };
}

enum _Order { nameAsc, nameDesc, codeAsc, codeDesc, recent }

extension on _Order {
  String get label => switch (this) {
    _Order.nameAsc => 'Name A–Z',
    _Order.nameDesc => 'Name Z–A',
    _Order.codeAsc => 'Code A–Z',
    _Order.codeDesc => 'Code Z–A',
    _Order.recent => 'Recently added',
  };
}

class _Summary extends StatelessWidget {
  final int total, active, departments, practical;
  const _Summary({
    required this.total,
    required this.active,
    required this.departments,
    required this.practical,
  });
  @override
  Widget build(BuildContext context) => AppCard(
    showShadow: false,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    child: Row(
      children: [
        _item(
          Icons.menu_book_outlined,
          total,
          'Total\nSubjects',
          Colors.indigo,
        ),
        _item(Icons.check_circle_outline, active, 'Active', Colors.green),
        _item(
          Icons.account_balance_outlined,
          departments,
          'Departments',
          Colors.purple,
        ),
        _item(Icons.science_outlined, practical, 'Practical', Colors.orange),
      ],
    ),
  );
  Widget _item(IconData icon, int value, String label, Color color) => Expanded(
    child: Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 7),
        Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  const _Card({required this.subject, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = _color(subject.color);
    return AppCard(
      onTap: onTap,
      showShadow: false,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: subject.isActive
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject.code,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _pill(context, subject.subjectType),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext c, String label) {
    final color = Theme.of(c).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  final String schoolId;
  final String userId;
  final StructureState state;
  final Subject? existing;
  final ValueChanged<Subject> onSave;
  final Future<int> Function()? dependencies;
  final void Function(String action)? delete;
  const _Form({
    required this.schoolId,
    required this.userId,
    required this.state,
    this.existing,
    required this.onSave,
    this.dependencies,
    this.delete,
  });
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.existing?.name);
  late final code = TextEditingController(text: widget.existing?.code);
  late final description = TextEditingController(
    text: widget.existing?.description,
  );
  late String? department = widget.existing?.departmentId.isNotEmpty == true
      ? widget.existing!.departmentId
      : null;
  late String type =
      widget.existing?.subjectType ??
      (widget.existing?.isElective == true ? 'Elective' : 'Core');
  late bool practical = widget.existing?.isPractical ?? false,
      active = widget.existing?.isActive ?? true,
      saving = false;
  late Set<String> levels = {...?widget.existing?.assignedLevelIds},
      classes = {...?widget.existing?.assignedClassIds};
  late Color color = _color(widget.existing?.color ?? '');
  static const types = [
    'Core',
    'Optional',
    'Elective',
    'Co-curricular',
    'Vocational',
    'Other',
  ];
  @override
  void dispose() {
    name.dispose();
    code.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AcademicsFormScaffold(
    title: widget.existing == null ? 'Add Subject' : 'Edit Subject',
    subtitle: widget.existing == null
        ? 'Create a new subject for your school.'
        : 'Update this subject.',
    saveLabel: widget.existing == null ? 'Save Subject' : 'Save Changes',
    isSaving: saving,
    onSave: _save,
    fields: [
      Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Subject Name *'),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(hintText: 'e.g. Mathematics'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Subject name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            _label('Subject Code *'),
            TextFormField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'e.g. MATH'),
              validator: _codeValidator,
            ),
            const SizedBox(height: 16),
            _label('Department'),
            DropdownButtonFormField<String>(
              initialValue: department,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Select department'),
              items: widget.state.departments
                  .where((d) => d.isActive)
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => department = v),
            ),
            const SizedBox(height: 16),
            _selector(
              'Applicable Level(s)',
              'Add Levels',
              levels,
              widget.state.levels
                  .where((x) => x.isActive)
                  .map((x) => _Option(x.id, x.name))
                  .toList(),
              (v) => setState(() => levels = v),
            ),
            const SizedBox(height: 16),
            _selector(
              'Applicable Class(es)',
              'Add Classes',
              classes,
              widget.state.classes
                  .where(
                    (x) =>
                        x.isActive &&
                        (levels.isEmpty || levels.contains(x.levelId)),
                  )
                  .map((x) => _Option(x.id, x.name))
                  .toList(),
              (v) => setState(() => classes = v),
            ),
            const SizedBox(height: 16),
            _label('Subject Type'),
            DropdownButtonFormField<String>(
              initialValue: type,
              items: types
                  .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                  .toList(),
              onChanged: (v) => setState(() => type = v ?? 'Core'),
            ),
            const SizedBox(height: 16),
            _label('Color'),
            Wrap(
              spacing: 12,
              children: kSubjectColorSwatches.map((c) {
                final selected = c.toARGB32() == color.toARGB32();
                return InkWell(
                  onTap: () => setState(() => color = c),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Description'),
            TextFormField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Optional description',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Practical'),
              subtitle: const Text('Subject has practical components'),
              value: practical,
              onChanged: (v) => setState(() => practical = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text('Active subjects are available for use'),
              value: active,
              onChanged: (v) => setState(() => active = v),
            ),
            if (widget.existing != null && widget.dependencies != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: saving ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Subject'),
              ),
            ],
          ],
        ),
      ),
    ],
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );
  String? _codeValidator(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Subject code is required';
    if (widget.state.subjects.any(
      (s) =>
          s.id != widget.existing?.id &&
          s.code.trim().toLowerCase() == value.toLowerCase(),
    )) {
      return 'This subject code is already in use';
    }
    return null;
  }

  Widget _selector(
    String label,
    String button,
    Set<String> selected,
    List<_Option> options,
    ValueChanged<Set<String>> changed,
  ) {
    final names = options
        .where((x) => selected.contains(x.id))
        .map((x) => x.name)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Row(
          children: [
            Expanded(
              child: names.isEmpty
                  ? Text(
                      options.isEmpty ? 'None configured yet' : 'None selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Wrap(
                      spacing: 5,
                      runSpacing: 3,
                      children: names.map((x) => Chip(label: Text(x))).toList(),
                    ),
            ),
            OutlinedButton.icon(
              onPressed: options.isEmpty
                  ? null
                  : () async {
                      final result = await showModalBottomSheet<Set<String>>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => _Multi(
                          title: 'Select ${label.replaceAll('(s)', '')}',
                          options: options,
                          initial: selected,
                        ),
                      );
                      if (result != null) changed(result);
                    },
              icon: const Icon(Icons.add, size: 18),
              label: Text(button),
            ),
          ],
        ),
      ],
    );
  }

  void _save() {
    if (!key.currentState!.validate()) return;
    final selectedDepartment = department == null
        ? null
        : widget.state.departments.where((x) => x.id == department).firstOrNull;
    if (selectedDepartment != null &&
        (!selectedDepartment.isActive ||
            selectedDepartment.schoolId != widget.schoolId)) {
      _error('Please choose an active department in this school.');
      return;
    }
    final validLevels = widget.state.levels
            .where((x) => x.schoolId == widget.schoolId)
            .map((x) => x.id)
            .toSet(),
        validClasses = widget.state.classes
            .where((x) => x.schoolId == widget.schoolId)
            .map((x) => x.id)
            .toSet();
    if (!levels.every(validLevels.contains) ||
        !classes.every(validClasses.contains)) {
      _error('Selected levels and classes must belong to this school.');
      return;
    }
    if (levels.isNotEmpty &&
        classes.any((id) {
          final item = widget.state.classes
              .where((x) => x.id == id)
              .firstOrNull;
          return item != null &&
              item.levelId.isNotEmpty &&
              !levels.contains(item.levelId);
        })) {
      _error('Selected classes must match the selected levels.');
      return;
    }
    setState(() => saving = true);
    final isEdit = widget.existing != null;
    final subject = Subject(
      id: widget.existing?.id ?? const Uuid().v4(),
      schoolId: widget.schoolId,
      name: name.text.trim(),
      code: code.text.trim(),
      departmentId: department ?? '',
      subjectType: type,
      color: '#${color.toARGB32().toRadixString(16).substring(2)}',
      description: description.text.trim(),
      isElective: type == 'Elective' || type == 'Optional',
      isPractical: practical,
      creditUnits: widget.existing?.creditUnits ?? 0,
      isActive: active,
      assignedLevelIds: levels.toList(),
      assignedClassIds: classes.toList(),
    );
    widget.onSave(subject);
    di.sl<AuditRepository>().logAction(
      schoolId: widget.schoolId,
      title: isEdit ? 'Subject updated' : 'Subject created',
      description: '${subject.name} (${subject.code})',
      iconName: 'menu_book',
      colorHex: subject.color,
      userId: widget.userId,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Subject saved.')));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final n = await widget.dependencies!();
    if (!mounted) return;
    final action = n == 0
        ? ((await showDeleteConfirmDialog(
                    context,
                    title: 'Delete Subject',
                    message: 'Delete "${widget.existing!.name}"?',
                  )) ==
                  true
              ? 'delete'
              : null)
        : await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Subject is in use'),
              content: Text(
                'This subject is referenced by $n teacher assignment(s) or '
                'assessment(s). Deactivate it instead to preserve those '
                'records.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'archive'),
                  child: const Text('Deactivate'),
                ),
              ],
            ),
          );
    if (action == null || !mounted) return;
    widget.delete!(action);
    di.sl<AuditRepository>().logAction(
      schoolId: widget.schoolId,
      title: action == 'delete' ? 'Subject deleted' : 'Subject deactivated',
      description: widget.existing!.name,
      iconName: 'menu_book',
      colorHex: widget.existing!.color,
      userId: widget.userId,
    );
    Navigator.pop(context);
  }

  void _error(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _Option {
  final String id, name;
  const _Option(this.id, this.name);
}

class _Multi extends StatefulWidget {
  final String title;
  final List<_Option> options;
  final Set<String> initial;
  const _Multi({
    required this.title,
    required this.options,
    required this.initial,
  });
  @override
  State<_Multi> createState() => _MultiState();
}

class _MultiState extends State<_Multi> {
  late Set<String> selected = {...widget.initial};
  String query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.options
        .where((x) => x.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: 480,
          child: Column(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: items
                      .map(
                        (x) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: selected.contains(x.id),
                          title: Text(x.name),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              selected.add(x.id);
                            } else {
                              selected.remove(x.id);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, selected),
                      child: const Text('Done'),
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

Color _color(String hex) {
  try {
    return hex.isEmpty
        ? kSubjectColorSwatches.first
        : Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (_) {
    return kSubjectColorSwatches.first;
  }
}
