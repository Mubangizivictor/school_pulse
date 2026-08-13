import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/structure_dependency_service.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';
import 'years_terms_screen.dart' show AppSearchFieldCompat;

class ClassesStreamsScreen extends StatefulWidget {
  const ClassesStreamsScreen({super.key});

  @override
  State<ClassesStreamsScreen> createState() => _ClassesStreamsScreenState();
}

class _ClassesStreamsScreenState extends State<ClassesStreamsScreen> {
  int _tab = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        return Scaffold(
          appBar: const AdminAppBar(title: 'Classes & Streams'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage classes and their streams.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    AcademicsSegmentedTabs(
                      labels: const ['Classes', 'Streams'],
                      selectedIndex: _tab,
                      onSelected: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 12),
                    AppSearchFieldCompat(
                      hint: _tab == 0
                          ? 'Search classes...'
                          : 'Search streams...',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _tab == 0
                    ? _ClassesList(
                        state: state,
                        bloc: bloc,
                        schoolId: schoolId,
                        query: _query,
                      )
                    : _StreamsList(
                        state: state,
                        bloc: bloc,
                        schoolId: schoolId,
                        query: _query,
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _tab == 0
                ? _openClassForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    levels: state.levels,
                  )
                : _openStreamForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    classes: state.classes,
                  ),
            icon: const Icon(Icons.add),
            label: Text(_tab == 0 ? 'Add Class' : 'Add Stream'),
          ),
        );
      },
    );
  }
}

class _ClassesList extends StatelessWidget {
  final StructureState state;
  final StructureBloc bloc;
  final String schoolId;
  final String query;

  const _ClassesList({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (state.levels.isEmpty) {
      return const StructureEmptyHint(
        'Add an educational level first (see the Levels section).',
      );
    }
    final classes = state.classes
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (classes.isEmpty) {
      return StructureEmptyHint(
        query.isEmpty ? 'No classes defined yet.' : 'No classes match "$query".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final schoolClass = classes[index];
        final level = state.levels
            .where((l) => l.id == schoolClass.levelId)
            .firstOrNull;
        final streamCount = state.streams
            .where((s) => s.classId == schoolClass.id)
            .length;
        return AcademicsListCard(
          icon: Icons.school_outlined,
          color: Colors.amber.shade800,
          title: schoolClass.name,
          subtitle:
              '${streamCount > 0 ? '$streamCount Stream${streamCount == 1 ? '' : 's'} • ' : ''}${level?.name ?? 'No level'}',
          isActive: schoolClass.isActive,
          onTap: () => _openClassForm(
            context,
            schoolId: schoolId,
            bloc: bloc,
            levels: state.levels,
            existing: schoolClass,
          ),
        );
      },
    );
  }
}

class _StreamsList extends StatelessWidget {
  final StructureState state;
  final StructureBloc bloc;
  final String schoolId;
  final String query;

  const _StreamsList({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (state.classes.isEmpty) {
      return const StructureEmptyHint('Add a class first.');
    }
    final streams = state.streams
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final byClass = <String, List<ClassStream>>{};
    for (final s in streams) {
      byClass.putIfAbsent(s.classId, () => []).add(s);
    }
    final classIds = state.classes.map((c) => c.id).where(byClass.containsKey);

    if (streams.isEmpty) {
      return StructureEmptyHint(
        query.isEmpty
            ? 'No streams defined yet.\nAdd East/West, A/B/C, or whatever sections this school uses.'
            : 'No streams match "$query".',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        for (final classId in classIds) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Text(
              state.classes.where((c) => c.id == classId).firstOrNull?.name ??
                  'Unknown class',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
          ),
          for (final stream in byClass[classId]!)
            AcademicsListCard(
              icon: Icons.groups_2_outlined,
              color: Colors.indigo,
              title: stream.name,
              subtitle: stream.capacity > 0
                  ? 'Capacity ${stream.capacity}'
                  : '',
              isActive: stream.isActive,
              onTap: () => _openStreamForm(
                context,
                schoolId: schoolId,
                bloc: bloc,
                classes: state.classes,
                existing: stream,
              ),
            ),
        ],
      ],
    );
  }
}

void _openClassForm(
  BuildContext context, {
  required String schoolId,
  required StructureBloc bloc,
  required List<EducationalLevel> levels,
  SchoolClass? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _ClassFormScreen(
        schoolId: schoolId,
        levels: levels,
        existing: existing,
        onSave: (c) => bloc.add(SaveClassRequested(c)),
        onDelete: existing == null
            ? null
            : () async {
                final dependentCount = await di
                    .sl<StructureDependencyService>()
                    .countStudentsInClass(schoolId, existing.id);
                return dependentCount;
              },
        onDeleteConfirmed: existing == null
            ? null
            : (action) {
                if (action == 'delete') {
                  bloc.add(DeleteClassRequested(existing.id));
                } else if (action == 'archive') {
                  bloc.add(ArchiveClassRequested(existing.id));
                }
              },
      ),
    ),
  );
}

void _openStreamForm(
  BuildContext context, {
  required String schoolId,
  required StructureBloc bloc,
  required List<SchoolClass> classes,
  ClassStream? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _StreamFormScreen(
        schoolId: schoolId,
        classes: classes,
        existing: existing,
        onSave: (s) => bloc.add(SaveStreamRequested(s)),
        onDelete: existing == null
            ? null
            : () => bloc.add(DeleteStreamRequested(existing.id)),
      ),
    ),
  );
}

class _ClassFormScreen extends StatefulWidget {
  final String schoolId;
  final List<EducationalLevel> levels;
  final SchoolClass? existing;
  final void Function(SchoolClass) onSave;
  final Future<int> Function()? onDelete;
  final void Function(String action)? onDeleteConfirmed;

  const _ClassFormScreen({
    required this.schoolId,
    required this.levels,
    this.existing,
    required this.onSave,
    this.onDelete,
    this.onDeleteConfirmed,
  });

  @override
  State<_ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<_ClassFormScreen> {
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
  late final _capacityController = TextEditingController(
    text: widget.existing?.capacity == null || widget.existing!.capacity == 0
        ? ''
        : widget.existing!.capacity.toString(),
  );
  late String? _levelId =
      widget.existing?.levelId.isNotEmpty == true
      ? widget.existing!.levelId
      : (widget.levels.isNotEmpty ? widget.levels.first.id : null);
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Class' : 'Add New Class',
      subtitle: isEdit
          ? 'Update this class.'
          : 'Create a new class in your school.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Class',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AcademicsFieldLabel('Class Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Primary 1'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Class name is required' : null,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Class Code *'),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. P1'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Class code is required' : null,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Level *'),
              DropdownButtonFormField<String>(
                initialValue: _levelId,
                decoration: const InputDecoration(hintText: 'Select level'),
                items: widget.levels
                    .map(
                      (l) => DropdownMenuItem(value: l.id, child: Text(l.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _levelId = v),
                validator: (v) => v == null ? 'Select a level' : null,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Capacity'),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(hintText: 'e.g. 45'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Description'),
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
                title: const Text('Active'),
                subtitle: const Text('Inactive classes won\'t be available'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Class',
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
      SchoolClass(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        levelId: _levelId ?? '',
        capacity: int.tryParse(_capacityController.text) ?? 0,
        description: _descController.text.trim(),
        isActive: _isActive,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final dependentCount = await widget.onDelete!();
    if (!mounted) return;
    final itemName = widget.existing!.name;
    String? action;
    if (dependentCount == 0) {
      final confirmed = await showDeleteConfirmDialog(
        context,
        title: 'Delete Class',
        message: 'Delete "$itemName"?',
      );
      action = confirmed == true ? 'delete' : null;
    } else {
      action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Class'),
          content: Text(
            '"$itemName" is still referenced by $dependentCount student(s). '
            'Archive it instead of deleting it to keep that data intact.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'archive'),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
    }
    if (action == null || !mounted) return;
    widget.onDeleteConfirmed!(action);
    Navigator.of(context).pop();
  }
}

class _StreamFormScreen extends StatefulWidget {
  final String schoolId;
  final List<SchoolClass> classes;
  final ClassStream? existing;
  final void Function(ClassStream) onSave;
  final VoidCallback? onDelete;

  const _StreamFormScreen({
    required this.schoolId,
    required this.classes,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_StreamFormScreen> createState() => _StreamFormScreenState();
}

class _StreamFormScreenState extends State<_StreamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _codeController = TextEditingController(
    text: widget.existing?.code,
  );
  late final _capacityController = TextEditingController(
    text: widget.existing?.capacity == null || widget.existing!.capacity == 0
        ? ''
        : widget.existing!.capacity.toString(),
  );
  late String? _classId =
      widget.existing?.classId ??
      (widget.classes.isNotEmpty ? widget.classes.first.id : null);
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Stream' : 'Add Stream',
      subtitle: isEdit
          ? 'Update this stream.'
          : 'Create a new stream or section under a class.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Stream',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AcademicsFieldLabel('Stream Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Blue'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Stream name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Stream Code'),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. BL'),
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Parent Class *'),
              DropdownButtonFormField<String>(
                initialValue: _classId,
                decoration: const InputDecoration(hintText: 'Select class'),
                items: widget.classes
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _classId = v),
                validator: (v) => v == null ? 'Select a class' : null,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Capacity'),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(hintText: 'e.g. 30'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
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
                      title: 'Delete Stream',
                      message: 'Delete "${widget.existing!.name}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Stream',
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
      ClassStream(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        classId: _classId!,
        capacity: int.tryParse(_capacityController.text) ?? 0,
        isActive: _isActive,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _AcademicsFieldLabel extends StatelessWidget {
  final String text;
  const _AcademicsFieldLabel(this.text);

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
