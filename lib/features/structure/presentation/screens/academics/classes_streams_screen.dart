import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/capacity_validation_service.dart';
import '../../../domain/services/structure_dependency_service.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';
import 'years_terms_screen.dart' show AppSearchFieldCompat;
import '../../widgets/structure_wizard_banner.dart';

class ClassesStreamsScreen extends StatefulWidget {
  const ClassesStreamsScreen({
    super.key,
    this.wizardStep,
    this.wizardTotal,
    this.wizardStepId = 'classes',
  });

  final int? wizardStep;
  final int? wizardTotal;
  final String wizardStepId;

  @override
  State<ClassesStreamsScreen> createState() => _ClassesStreamsScreenState();
}

class _ClassesStreamsScreenState extends State<ClassesStreamsScreen> {
  int _tab = 0;
  String _query = '';

  @override
  void didUpdateWidget(covariant ClassesStreamsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wizardStepId == 'streams' &&
        oldWidget.wizardStepId != 'streams') {
      _tab = 1;
    }
  }

  /// One-shot, school-wide aggregate fetched once per screen visit - not
  /// stored in StructureBloc/State since it belongs to Students, not
  /// Structure; Structure only borrows it for this one overview tile.
  late Future<int> _totalStudentsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.wizardStepId == 'streams') _tab = 1;
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    _totalStudentsFuture = di.sl<StructureDependencyService>().countAllStudents(
      schoolId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        return Scaffold(
          appBar: AdminAppBar(
            title: 'Classes & Streams',
            bottom: widget.wizardStep == null || widget.wizardTotal == null
                ? null
                : StructureWizardBanner(
                    stepId: _tab == 0 ? 'classes' : 'streams',
                    stepNumber: widget.wizardStep!,
                    totalSteps: widget.wizardTotal!,
                  ),
          ),
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
                      onFilter: () => _showFilterSheet(context, _tab == 0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _tab == 0
                    ? _ClassesTab(
                        state: state,
                        bloc: bloc,
                        schoolId: schoolId,
                        query: _query,
                        totalStudentsFuture: _totalStudentsFuture,
                      )
                    : _StreamsTab(
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
                    streams: state.streams,
                  )
                : _openStreamForm(
                    context,
                    schoolId: schoolId,
                    bloc: bloc,
                    classes: state.classes,
                    streams: state.streams,
                  ),
            icon: const Icon(Icons.add),
            label: Text(_tab == 0 ? 'Add Class' : 'Add Stream'),
          ),
        );
      },
    );
  }
}

/// Placeholder for a future Level/status filter sheet - wired to the
/// shared search field's built-in filter icon now so the tap target
/// exists; the sheet itself is a natural follow-up once filtering
/// requirements are settled (Active/Inactive, Level, Parent Class).
void _showFilterSheet(BuildContext context, bool isClassesTab) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isClassesTab ? 'Filter classes' : 'Filter streams',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sorting follows configured Level/Class order by default. '
              'Active/Level filters are coming soon.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ClassesTab extends StatelessWidget {
  final StructureState state;
  final StructureBloc bloc;
  final String schoolId;
  final String query;
  final Future<int> totalStudentsFuture;

  const _ClassesTab({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
    required this.totalStudentsFuture,
  });

  @override
  Widget build(BuildContext context) {
    if (state.levels.isEmpty) {
      return _SetupLevelsFirstHint(
        onSave: () => _openClassForm(
          context,
          schoolId: schoolId,
          bloc: bloc,
          levels: state.levels,
        ),
      );
    }

    final classes =
        state.classes
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    final activeCount = state.classes.where((c) => c.isActive).length;
    final avgSize = state.classes.isEmpty
        ? 0
        : (state.classes.fold<int>(0, (sum, c) => sum + c.capacity) /
                  state.classes.length)
              .round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        FutureBuilder<int>(
          future: totalStudentsFuture,
          builder: (context, snapshot) {
            final totalStudents = snapshot.data;
            return AcademicsOverviewCard(
              tiles: [
                AcademicsStatTile(
                  label: 'Total Classes',
                  value: '${state.classes.length}',
                ),
                AcademicsStatTile(
                  label: 'Active Classes',
                  value: '$activeCount',
                  valueColor: Colors.green.shade700,
                ),
                AcademicsStatTile(
                  label: 'Total Students',
                  value: totalStudents == null ? '—' : '$totalStudents',
                ),
                AcademicsStatTile(
                  label: 'Avg. Class Size',
                  value: state.classes.isEmpty ? '—' : '$avgSize',
                  valueColor: Colors.orange.shade800,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (classes.isEmpty)
          StructureEmptyHint(
            query.isEmpty
                ? 'No classes yet.\nCreate your first class to continue setting up your school.'
                : 'No classes match "$query".',
          )
        else
          for (final schoolClass in classes) ...[
            _ClassCard(
              schoolClass: schoolClass,
              level: state.levels
                  .where((l) => l.id == schoolClass.levelId)
                  .firstOrNull,
              streamCount: state.streams
                  .where((s) => s.classId == schoolClass.id)
                  .length,
              allocatedCapacity: const CapacityValidationService()
                  .activeStreamCapacity(state.streams, schoolClass.id),
              onTap: () => _openClassForm(
                context,
                schoolId: schoolId,
                bloc: bloc,
                levels: state.levels,
                streams: state.streams,
                existing: schoolClass,
              ),
            ),
          ],
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final EducationalLevel? level;
  final int streamCount;
  final int allocatedCapacity;
  final VoidCallback onTap;

  const _ClassCard({
    required this.schoolClass,
    required this.level,
    required this.streamCount,
    required this.allocatedCapacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.indigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        schoolClass.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          decoration: schoolClass.isActive
                              ? null
                              : TextDecoration.lineThrough,
                          color: schoolClass.isActive ? null : Colors.grey,
                        ),
                      ),
                    ),
                    if (!schoolClass.isActive) ...[
                      const SizedBox(width: 8),
                      const AcademicsStatusChip(
                        label: 'Inactive',
                        color: Colors.grey,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (level != null) level!.name,
                    if (streamCount > 0)
                      '$streamCount Stream${streamCount == 1 ? '' : 's'}',
                    if (schoolClass.capacity > 0 && streamCount > 0)
                      '$allocatedCapacity / ${schoolClass.capacity} allocated',
                    if (schoolClass.capacity > 0 && streamCount == 0)
                      'Capacity ${schoolClass.capacity}',
                    if (schoolClass.capacity > 0 && streamCount > 0)
                      '${(schoolClass.capacity - allocatedCapacity).clamp(0, schoolClass.capacity)} seats unallocated',
                  ].join(' • '),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.outline),
        ],
      ),
    );
  }
}

class _SetupLevelsFirstHint extends StatelessWidget {
  final VoidCallback onSave;

  const _SetupLevelsFirstHint({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        AppCard(
          onTap: () =>
              context.push('/staff/admin/structure/academics/levels'),
          showShadow: false,
          color: Colors.orange.withValues(alpha: 0.08),
          borderColor: Colors.orange.withValues(alpha: 0.35),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Set up Levels first',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create academic levels to organize your classes better.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreamsTab extends StatelessWidget {
  final StructureState state;
  final StructureBloc bloc;
  final String schoolId;
  final String query;

  const _StreamsTab({
    required this.state,
    required this.bloc,
    required this.schoolId,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (state.classes.isEmpty) {
      return _CreateClassFirstHint(
        onTap: () => _openClassForm(
          context,
          schoolId: schoolId,
          bloc: bloc,
          levels: state.levels,
        ),
      );
    }

    final streams = state.streams
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final byClass = <String, List<ClassStream>>{};
    for (final s in streams) {
      byClass.putIfAbsent(s.classId, () => []).add(s);
    }
    final classIds = state.classes.map((c) => c.id).where(byClass.containsKey);

    final activeCount = state.streams.where((s) => s.isActive).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        AcademicsOverviewCard(
          tiles: [
            AcademicsStatTile(
              label: 'Total Streams',
              value: '${state.streams.length}',
            ),
            AcademicsStatTile(
              label: 'Active Streams',
              value: '$activeCount',
              valueColor: Colors.green.shade700,
            ),
            AcademicsStatTile(
              label: 'Total Classes',
              value: '${state.classes.length}',
            ),
            AcademicsStatTile(
              label: 'Avg. Stream Size',
              value: state.streams.isEmpty
                  ? '—'
                  : '${(state.streams.fold<int>(0, (sum, s) => sum + s.capacity) / state.streams.length).round()}',
              valueColor: Colors.orange.shade800,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (streams.isEmpty)
          StructureEmptyHint(
            query.isEmpty
                ? 'No streams yet.\nStreams are optional - add Blue/Red, A/B, or whatever sections this school uses.'
                : 'No streams match "$query".',
          )
        else
          for (final classId in classIds) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
              child: Text(
                state.classes.where((c) => c.id == classId).firstOrNull?.name ??
                    'Unknown class',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            for (final stream in byClass[classId]!)
              _StreamCard(
                stream: stream,
                parentClassName:
                    state.classes.where((c) => c.id == classId).firstOrNull?.name ??
                    '',
                onTap: () => _openStreamForm(
                  context,
                  schoolId: schoolId,
                  bloc: bloc,
                  classes: state.classes,
                  streams: state.streams,
                  existing: stream,
                ),
              ),
          ],
      ],
    );
  }
}

class _StreamCard extends StatelessWidget {
  final ClassStream stream;
  final String parentClassName;
  final VoidCallback onTap;

  const _StreamCard({
    required this.stream,
    required this.parentClassName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              color: Colors.teal,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        stream.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          decoration: stream.isActive
                              ? null
                              : TextDecoration.lineThrough,
                          color: stream.isActive ? null : Colors.grey,
                        ),
                      ),
                    ),
                    if (!stream.isActive) ...[
                      const SizedBox(width: 8),
                      const AcademicsStatusChip(
                        label: 'Inactive',
                        color: Colors.grey,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    parentClassName,
                    if (stream.capacity > 0) 'Capacity ${stream.capacity}',
                  ].join(' • '),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.outline),
        ],
      ),
    );
  }
}

class _CreateClassFirstHint extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateClassFirstHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create a class first',
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Streams belong to a class - add a class before adding streams.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add),
              label: const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }
}

void _openClassForm(
  BuildContext context, {
  required String schoolId,
  required StructureBloc bloc,
  required List<EducationalLevel> levels,
  List<ClassStream> streams = const [],
  SchoolClass? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _ClassFormScreen(
        schoolId: schoolId,
        levels: levels,
        streams: streams,
        existing: existing,
        onSave: (c) => bloc.add(SaveClassRequested(c)),
        onDelete: existing == null
            ? null
            : () async {
                final studentCount = await di
                    .sl<StructureDependencyService>()
                    .countStudentsInClass(schoolId, existing.id);
                final streamCount = streams
                    .where((s) => s.classId == existing.id)
                    .length;
                return studentCount + streamCount;
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
  List<ClassStream> streams = const [],
  ClassStream? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _StreamFormScreen(
        schoolId: schoolId,
        classes: classes,
        streams: streams,
        existing: existing,
        onSave: (s) => bloc.add(SaveStreamRequested(s)),
        onDelete: existing == null
            ? null
            : () async {
                final dependentCount = await di
                    .sl<StructureDependencyService>()
                    .countStudentsInStream(schoolId, existing.id);
                return dependentCount;
              },
        onDeleteConfirmed: existing == null
            ? null
            : (action) {
                if (action == 'delete') {
                  bloc.add(DeleteStreamRequested(existing.id));
                } else if (action == 'archive') {
                  bloc.add(ArchiveStreamRequested(existing.id));
                }
              },
      ),
    ),
  );
}

class _ClassFormScreen extends StatefulWidget {
  final String schoolId;
  final List<EducationalLevel> levels;
  final List<ClassStream> streams;
  final SchoolClass? existing;
  final void Function(SchoolClass) onSave;
  final Future<int> Function()? onDelete;
  final void Function(String action)? onDeleteConfirmed;

  const _ClassFormScreen({
    required this.schoolId,
    required this.levels,
    this.streams = const [],
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
  late String? _levelId = widget.existing?.levelId.isNotEmpty == true
      ? widget.existing!.levelId
      : (widget.levels.where((l) => l.isActive).firstOrNull?.id);
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _isSaving = false;

  List<EducationalLevel> get _activeLevels =>
      widget.levels.where((l) => l.isActive).toList();

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
      isSaving: _isSaving,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AcademicsFieldLabel('Level *'),
              DropdownButtonFormField<String>(
                initialValue: _levelId,
                decoration: const InputDecoration(hintText: 'Select level'),
                items: _activeLevels
                    .map(
                      (l) => DropdownMenuItem(value: l.id, child: Text(l.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _levelId = v),
                validator: (v) => v == null ? 'Select a level' : null,
              ),
              const _AcademicsFieldHint(
                'Choose the academic level this class belongs to.',
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Class Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Primary 1, Senior 1',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Class name is required'
                    : null,
              ),
              const _AcademicsFieldHint('Use a clear and familiar name.'),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Class Code *'),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. P1, S1'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Class code is required'
                    : null,
              ),
              const _AcademicsFieldHint('Short code used across the system.'),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Capacity'),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(hintText: 'e.g. 45'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) {
                    return 'Enter a positive number';
                  }
                  if (widget.existing != null) {
                    final result = const CapacityValidationService()
                        .validateClassCapacityChange(
                          candidate: widget.existing!,
                          newCapacity: n,
                          streams: widget.streams,
                        );
                    if (!result.isValid) return result.errorMessage;
                  }
                  return null;
                },
              ),
              const _AcademicsFieldHint('Maximum number of students.'),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Description (Optional)'),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Add any additional information about this class.',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Status'),
              AcademicsStatusToggle(
                isActive: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const _AcademicsFieldHint(
                "Inactive classes won't be available for selection.",
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _isSaving ? null : _confirmDelete,
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

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_levelId == null) return;
    setState(() => _isSaving = true);
    widget.onSave(
      SchoolClass(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        levelId: _levelId ?? '',
        capacity: int.tryParse(_capacityController.text.trim()) ?? 0,
        description: _descController.text.trim(),
        isActive: _isActive,
      ),
    );
    if (mounted) Navigator.of(context).pop();
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
  final List<ClassStream> streams;
  final ClassStream? existing;
  final void Function(ClassStream) onSave;
  final Future<int> Function()? onDelete;
  final void Function(String action)? onDeleteConfirmed;

  const _StreamFormScreen({
    required this.schoolId,
    required this.classes,
    this.streams = const [],
    this.existing,
    required this.onSave,
    this.onDelete,
    this.onDeleteConfirmed,
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
      (widget.classes.where((c) => c.isActive).firstOrNull?.id);
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _isSaving = false;

  List<SchoolClass> get _activeClasses =>
      widget.classes.where((c) => c.isActive).toList();

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
          : 'Create a new stream/section under a class.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Stream',
      onSave: _submit,
      isSaving: _isSaving,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AcademicsFieldLabel('Parent Class *'),
              DropdownButtonFormField<String>(
                initialValue: _classId,
                decoration: const InputDecoration(hintText: 'Select class'),
                items: _activeClasses
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _classId = v),
                validator: (v) => v == null ? 'Select a class' : null,
              ),
              const _AcademicsFieldHint(
                'Choose the class this stream belongs to.',
              ),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Stream Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Blue, Green, A',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Stream name is required'
                    : null,
              ),
              const _AcademicsFieldHint('Use a clear name for the stream.'),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Stream Code *'),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. BL, GR, A'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Stream code is required'
                    : null,
              ),
              const _AcademicsFieldHint('Short code for the stream.'),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Capacity'),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(hintText: 'e.g. 30'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  var n = 0;
                  if (v != null && v.trim().isNotEmpty) {
                    n = int.tryParse(v.trim()) ?? -1;
                    if (n <= 0) return 'Enter a positive number';
                  }
                  if (_classId == null) return null;
                  final candidate = ClassStream(
                    id: widget.existing?.id ?? '',
                    schoolId: widget.existing?.schoolId ?? widget.schoolId,
                    name: _nameController.text.trim(),
                    code: _codeController.text.trim(),
                    classId: _classId!,
                    capacity: n,
                    isActive: _isActive,
                  );
                  final result = const CapacityValidationService()
                      .validateStreamSave(
                        candidate: candidate,
                        existingStreams: widget.streams,
                        classes: widget.classes,
                      );
                  if (!result.isValid) return result.errorMessage;
                  return null;
                },
              ),
              const _AcademicsFieldHint('Maximum number of students.'),
              const SizedBox(height: 16),
              const _AcademicsFieldLabel('Status'),
              AcademicsStatusToggle(
                isActive: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const _AcademicsFieldHint(
                "Inactive streams won't be available for selection.",
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _isSaving ? null : _confirmDelete,
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

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null) return;
    setState(() => _isSaving = true);
    widget.onSave(
      ClassStream(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        classId: _classId!,
        capacity: int.tryParse(_capacityController.text.trim()) ?? 0,
        isActive: _isActive,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final dependentCount = await widget.onDelete!();
    if (!mounted) return;
    final itemName = widget.existing!.name;
    String? action;
    if (dependentCount == 0) {
      final confirmed = await showDeleteConfirmDialog(
        context,
        title: 'Delete Stream',
        message: 'Delete "$itemName"?',
      );
      action = confirmed == true ? 'delete' : null;
    } else {
      action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Stream'),
          content: Text(
            '"$itemName" is still referenced by $dependentCount student(s) '
            '(via its parent class). Archive it instead of deleting it to '
            'keep that data intact.',
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

class _AcademicsFieldHint extends StatelessWidget {
  final String text;
  const _AcademicsFieldHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
      ),
    );
  }
}
