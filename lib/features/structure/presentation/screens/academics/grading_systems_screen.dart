import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/assessment_grading_entities.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show kSubjectColorSwatches;
import '../../widgets/structure_empty_hint.dart';
import '../../widgets/structure_wizard_banner.dart';

const _types = [
  'Percentage',
  'Letter Grade',
  'Competency-Based',
  'Points / GPA',
  'Custom',
];

class GradingSystemsScreen extends StatefulWidget {
  const GradingSystemsScreen({super.key, this.wizardStep, this.wizardTotal});
  final int? wizardStep;
  final int? wizardTotal;
  @override
  State<GradingSystemsScreen> createState() => _GradingSystemsScreenState();
}

class _GradingSystemsScreenState extends State<GradingSystemsScreen> {
  String _query = '', _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final authUser =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user;
    final schoolId = authUser.schoolId;
    final userId = authUser.id;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final systems = state.gradingSystems.where((s) {
          final levels = state.levels
              .where((l) => s.levelIds.contains(l.id))
              .map((l) => l.name)
              .join(' ');
          final q = _query.toLowerCase();
          final matches =
              s.name.toLowerCase().contains(q) ||
              s.type.toLowerCase().contains(q) ||
              levels.toLowerCase().contains(q);
          return matches &&
              (_filter == 'All' ||
                  (_filter == 'Active' && s.isActive) ||
                  (_filter == 'Inactive' && !s.isActive) ||
                  (_filter == 'Default' && s.isDefault) ||
                  s.type == _filter);
        }).toList()..sort((a, b) => a.name.compareTo(b.name));
        return AcademicsListScaffold(
          title: 'Grading Systems',
          subtitle: 'Configure grading scales and systems for your school.',
          searchHint: 'Search grading systems...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Grading System',
          onFabPressed: () => _open(context, schoolId, userId, const [], null),
          appBarBottom: widget.wizardStep == null || widget.wizardTotal == null
              ? null
              : StructureWizardBanner(
                  stepId: 'grading',
                  stepNumber: widget.wizardStep!,
                  totalSteps: widget.wizardTotal!,
                ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: DropdownButtonFormField<String>(
                  initialValue: _filter,
                  decoration: const InputDecoration(labelText: 'Filter'),
                  items: ['All', 'Active', 'Inactive', 'Default', ..._types]
                      .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                      .toList(),
                  onChanged: (v) => setState(() => _filter = v!),
                ),
              ),
              Expanded(
                child: systems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StructureEmptyHint(
                              _query.isEmpty
                                  ? 'No grading systems yet.\nConfigure the grading system your school uses.'
                                  : 'No grading systems match "$_query".',
                            ),
                            FilledButton.icon(
                              onPressed: () => _open(
                                context,
                                schoolId,
                                userId,
                                const [],
                                null,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Grading System'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: systems.length,
                        itemBuilder: (_, i) {
                          final s = systems[i];
                          final bands = state.gradeBands
                              .where((b) => b.gradingSystemId == s.id)
                              .toList();
                          return AcademicsListCard(
                            icon: Icons.grading_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            title: s.name,
                            subtitle:
                                '${s.type}${s.isDefault ? ' • Default' : ''} • ${_scopeText(s, state)}',
                            trailingLabel:
                                '${bands.length} range${bands.length == 1 ? '' : 's'}',
                            isActive: s.isActive,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _Details(
                                  schoolId: schoolId,
                                  userId: userId,
                                  system: s,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _open(
    BuildContext c,
    String schoolId,
    String userId,
    List<GradeBand> bands,
    GradingSystemDef? system,
  ) => Navigator.push(
    c,
    MaterialPageRoute(
      builder: (_) => _Form(
        schoolId: schoolId,
        userId: userId,
        existing: system,
        initialBands: bands,
      ),
    ),
  );
}

Color _bandColor(String hex) {
  if (hex.isEmpty) return kSubjectColorSwatches.first;
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (_) {
    return kSubjectColorSwatches.first;
  }
}

String _scopeText(GradingSystemDef s, StructureState state) {
  if (s.appliesTo == 'school') return 'Whole school';
  final names = s.appliesTo == 'levels'
      ? state.levels.where((x) => s.levelIds.contains(x.id)).map((x) => x.name)
      : state.classes
            .where((x) => s.classIds.contains(x.id))
            .map((x) => x.name);
  return names.isEmpty ? 'No scope selected' : names.join(', ');
}

class _Details extends StatelessWidget {
  final String schoolId;
  final String userId;
  final GradingSystemDef system;
  const _Details({
    required this.schoolId,
    required this.userId,
    required this.system,
  });
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, state) {
      final s =
          state.gradingSystems.where((x) => x.id == system.id).firstOrNull ??
          system;
      final bands =
          state.gradeBands.where((x) => x.gradingSystemId == s.id).toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      return Scaffold(
        appBar: AdminAppBar(
          title: s.name,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _Form(
                    schoolId: schoolId,
                    userId: userId,
                    existing: s,
                    initialBands: bands,
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'archive') {
                  context.read<StructureBloc>().add(
                    SaveGradingSystemRequested(
                      s.copyWith(isActive: false, isDefault: false),
                    ),
                  );
                  di.sl<AuditRepository>().logAction(
                    schoolId: schoolId,
                    title: 'Grading system deactivated',
                    description: s.name,
                    iconName: 'grading',
                    colorHex: '#9E9E9E',
                    userId: userId,
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _Form(
                        schoolId: schoolId,
                        userId: userId,
                        existing: s.copyWith(
                          id: const Uuid().v4(),
                          name: 'Copy of ${s.name}',
                          isDefault: false,
                        ),
                        // New band ids ensure duplicating never rewrites the
                        // original system's historical scale.
                        initialBands: bands
                            .map((band) => band.copyWith(id: ''))
                            .toList(),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'duplicate',
                  child: Text('Duplicate Grading System'),
                ),
                PopupMenuItem(value: 'archive', child: Text('Deactivate')),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _info(context, 'Type', s.type),
            _info(context, 'Status', s.isActive ? 'Active' : 'Inactive'),
            _info(context, 'Applicability', _scopeText(s, state)),
            _info(context, 'Grade Format', s.gradeFormat),
            _info(context, 'Scale Type', s.scaleType),
            _info(
              context,
              'Passing Rule',
              s.passingGradeCode ?? s.passingScore?.toString() ?? 'Not set',
            ),
            _info(context, 'Version', 'v${s.version}'),
            if (s.description.isNotEmpty)
              _info(context, 'Description', s.description),
            const SizedBox(height: 12),
            Text('GRADE SCALE', style: Theme.of(context).textTheme.labelLarge),
            if (bands.isEmpty)
              const StructureEmptyHint('No grade ranges added yet.')
            else
              ...bands.map(
                (b) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _bandColor(b.colorHex),
                      foregroundColor: Colors.white,
                      child: Text(
                        b.grade.isNotEmpty ? b.grade.characters.first : '?',
                      ),
                    ),
                    title: Text(
                      b.label.isEmpty ? b.grade : '${b.grade} — ${b.label}',
                    ),
                    subtitle: Text(
                      '${b.hasNumericBoundary ? '${b.minScore} – ${b.maxScore} • ' : ''}${b.remarks}',
                    ),
                    trailing: Icon(
                      b.isPassing
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text('WHERE USED', style: Theme.of(context).textTheme.labelLarge),
            const StructureEmptyHint(
              'Not yet referenced by any assessment, mark or published '
              'report card.',
            ),
          ],
        ),
      );
    },
  );
  Widget _info(BuildContext c, String a, String b) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(a, style: Theme.of(c).textTheme.labelMedium),
        Text(b),
      ],
    ),
  );
}

class _Form extends StatefulWidget {
  final String schoolId;
  final String userId;
  final GradingSystemDef? existing;
  final List<GradeBand> initialBands;
  const _Form({
    required this.schoolId,
    required this.userId,
    this.existing,
    required this.initialBands,
  });
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name),
      _description = TextEditingController(text: widget.existing?.description),
      _passing = TextEditingController(
        text:
            widget.existing?.passingScore?.toString() ??
            widget.existing?.passingGradeCode ??
            '',
      );
  late String _type = widget.existing?.type.isNotEmpty == true
          ? widget.existing!.type
          : _types.first,
      _scale = widget.existing?.scaleType ?? 'Range Based',
      _format = widget.existing?.gradeFormat ?? 'Letter',
      _scope = widget.existing?.appliesTo ?? 'school';
  late int _decimals = widget.existing?.decimalPlaces ?? 2;
  late bool _default = widget.existing?.isDefault ?? false,
      _active = widget.existing?.isActive ?? true,
      _incomplete = widget.existing?.allowIncomplete ?? false;
  late List<String> _levels = [...?widget.existing?.levelIds],
      _classes = [...?widget.existing?.classIds];
  late final List<GradeBand> _bands = [...widget.initialBands];
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _passing.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, state) => AcademicsFormScaffold(
      title: widget.existing == null
          ? 'Add Grading System'
          : 'Edit Grading System',
      subtitle: 'Create a new grading system for your school.',
      saveLabel: 'Save Grading System',
      onSave: () => _save(state),
      fields: [
        Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('BASIC INFORMATION'),
              _label('Name *'),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(hintText: 'e.g. A-F Scale'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _label('Type *'),
              DropdownButtonFormField(
                initialValue: _type,
                decoration: const InputDecoration(
                  hintText: 'Select grading system type',
                ),
                items: _types
                    .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              _label('Description'),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Optional description',
                ),
              ),
              _section('CONFIGURATION'),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(
                          _type == 'Competency-Based'
                              ? 'Passing level'
                              : 'Passing threshold',
                        ),
                        TextFormField(
                          controller: _passing,
                          decoration: const InputDecoration(
                            hintText: 'Optional',
                          ),
                          keyboardType: _type == 'Competency-Based'
                              ? TextInputType.text
                              : const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown('Grade Scale Type *', _scale, [
                      'Range Based',
                      'Descriptor Based',
                      'Points Based',
                    ], (v) => setState(() => _scale = v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      'Grade Format *',
                      _format,
                      _formats(),
                      (v) => setState(() => _format = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown('Decimal Places', '$_decimals', [
                      '0',
                      '1',
                      '2',
                    ], (v) => setState(() => _decimals = int.parse(v))),
                  ),
                ],
              ),
              _section('APPLICABILITY'),
              _label('Applies To'),
              DropdownButtonFormField(
                initialValue: _scope,
                items: const [
                  DropdownMenuItem(
                    value: 'school',
                    child: Text('Whole School'),
                  ),
                  DropdownMenuItem(
                    value: 'levels',
                    child: Text('Specific Levels'),
                  ),
                  DropdownMenuItem(
                    value: 'classes',
                    child: Text('Specific Classes'),
                  ),
                ],
                onChanged: (v) => setState(() => _scope = v!),
              ),
              if (_scope != 'school')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(state),
                    icon: const Icon(Icons.tune),
                    label: Text(
                      _scope == 'levels'
                          ? 'Select levels (${_levels.length})'
                          : 'Select classes (${_classes.length})',
                    ),
                  ),
                ),
              _section('SCALE DEFINITION'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Grade Scale'),
                      subtitle: const Text(
                        'Define the grading scale ranges and labels',
                      ),
                      trailing: OutlinedButton.icon(
                        onPressed: _range,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Range'),
                      ),
                    ),
                    if (_bands.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Text(
                          'No grade ranges added yet.\nClick “Add Range” to define grade scale.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ..._bands.asMap().entries.map(
                        (e) => ListTile(
                          onTap: () => _range(editIndex: e.key),
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: _bandColor(e.value.colorHex),
                          ),
                          title: Text(e.value.grade),
                          subtitle: Text(
                            e.value.hasNumericBoundary
                                ? '${e.value.minScore} – ${e.value.maxScore}${e.value.remarks.isEmpty ? '' : ' • ${e.value.remarks}'}'
                                : e.value.remarks,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                setState(() => _bands.removeAt(e.key)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _section('OPTIONS'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Allow Incomplete Grade'),
                value: _incomplete,
                onChanged: (v) => setState(() => _incomplete = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Default grading system'),
                value: _default,
                onChanged: (v) => setState(() => _default = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _section(String x) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 14),
    child: Text(x, style: Theme.of(context).textTheme.labelLarge),
  );
  Widget _label(String x) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(x));
  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      DropdownButtonFormField(
        initialValue: value,
        items: values
            .map((x) => DropdownMenuItem(value: x, child: Text(x)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    ],
  );
  List<String> _formats() => _type == 'Competency-Based'
      ? ['Descriptor', 'Letter + Descriptor', 'Numeric + Descriptor']
      : _type == 'Percentage'
      ? ['Numeric', 'Numeric + Letter', 'Numeric + Descriptor']
      : _type == 'Points / GPA'
      ? ['Numeric', 'Numeric + Letter']
      : ['Letter', 'Descriptor', 'Numeric + Letter', 'Letter + Descriptor'];
  Future<void> _pick(StructureState state) async {
    final opts = _scope == 'levels'
        ? state.levels.map((x) => (x.id, x.name)).toList()
        : state.classes.map((x) => (x.id, x.name)).toList();
    var selected = [...(_scope == 'levels' ? _levels : _classes)];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(c).height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(title: Text('Select applicability')),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: opts
                          .map(
                            (x) => CheckboxListTile(
                              value: selected.contains(x.$1),
                              title: Text(x.$2),
                              onChanged: (v) => set(
                                () => v!
                                    ? selected.add(x.$1)
                                    : selected.remove(x.$1),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Apply'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    setState(
      () => _scope == 'levels' ? _levels = selected : _classes = selected,
    );
  }

  Future<void> _range({int? editIndex}) async {
    final result = await showModalBottomSheet<GradeBand>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _Range(
        schoolId: widget.schoolId,
        descriptorOnly: _scale == 'Descriptor Based',
        existing: editIndex == null ? null : _bands[editIndex],
      ),
    );
    if (result == null) return;
    setState(() {
      if (editIndex == null) {
        _bands.add(result.copyWith(order: _bands.length));
      } else {
        _bands[editIndex] = result.copyWith(order: editIndex);
      }
    });
  }

  void _save(StructureState state) {
    if (!_key.currentState!.validate()) return;
    if ((_scope == 'levels' && _levels.isEmpty) ||
        (_scope == 'classes' && _classes.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select applicable levels or classes.')),
      );
      return;
    }
    final numeric = _bands.where((b) => b.hasNumericBoundary).toList()
      ..sort((a, b) => a.minScore.compareTo(b.minScore));
    for (var i = 0; i < numeric.length - 1; i++) {
      if (numeric[i].maxScore >= numeric[i + 1].minScore) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade ranges cannot overlap.')),
        );
        return;
      }
    }
    if (_bands.map((b) => b.grade.toLowerCase()).toSet().length !=
        _bands.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grade codes must be unique.')),
      );
      return;
    }
    // Editing the scale itself (not just harmless metadata like name or
    // description) bumps the version, so any future consumer that snapshots
    // gradingSystemVersion at grade-resolution time can tell an old result
    // apart from one computed under an edited scale, without this screen
    // needing to know who those consumers are.
    final scaleChanged =
        widget.existing != null && !_sameBands(widget.initialBands, _bands);
    final s = GradingSystemDef(
      id: widget.existing?.id ?? const Uuid().v4(),
      schoolId: widget.schoolId,
      name: _name.text.trim(),
      type: _type,
      description: _description.text.trim(),
      scaleType: _scale,
      gradeFormat: _format,
      decimalPlaces: _decimals,
      passingScore: double.tryParse(_passing.text),
      passingGradeCode:
          double.tryParse(_passing.text) == null &&
              _passing.text.trim().isNotEmpty
          ? _passing.text.trim()
          : null,
      allowIncomplete: _incomplete,
      isDefault: _default,
      isActive: _active,
      appliesTo: _scope,
      levelIds: _levels,
      classIds: _classes,
      version: scaleChanged
          ? (widget.existing?.version ?? 1) + 1
          : (widget.existing?.version ?? 1),
    );
    final bloc = context.read<StructureBloc>();
    bloc.add(SaveGradingSystemRequested(s));
    for (final b in _bands) {
      bloc.add(
        SaveGradeBandRequested(
          b.copyWith(
            id: b.id.isEmpty ? const Uuid().v4() : b.id,
            schoolId: widget.schoolId,
            gradingSystemId: s.id,
          ),
        ),
      );
    }
    di.sl<AuditRepository>().logAction(
      schoolId: widget.schoolId,
      title: widget.existing == null
          ? 'Grading system created'
          : 'Grading system updated',
      description: '${s.name} (${s.type})',
      iconName: 'grading',
      colorHex: '#3F51B5',
      userId: widget.userId,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Grading system saved.')));
    Navigator.pop(context);
  }

  bool _sameBands(List<GradeBand> a, List<GradeBand> b) {
    if (a.length != b.length) return false;
    final sortedA = [...a]..sort((x, y) => x.grade.compareTo(y.grade));
    final sortedB = [...b]..sort((x, y) => x.grade.compareTo(y.grade));
    for (var i = 0; i < sortedA.length; i++) {
      final x = sortedA[i], y = sortedB[i];
      if (x.grade != y.grade ||
          x.minScore != y.minScore ||
          x.maxScore != y.maxScore ||
          x.gradePoint != y.gradePoint ||
          x.isPassing != y.isPassing ||
          x.hasNumericBoundary != y.hasNumericBoundary) {
        return false;
      }
    }
    return true;
  }
}

class _Range extends StatefulWidget {
  final String schoolId;
  final bool descriptorOnly;
  final GradeBand? existing;
  const _Range({
    required this.schoolId,
    required this.descriptorOnly,
    this.existing,
  });
  @override
  State<_Range> createState() => _RangeState();
}

class _RangeState extends State<_Range> {
  final key = GlobalKey<FormState>();
  late final code = TextEditingController(text: widget.existing?.grade),
      label = TextEditingController(text: widget.existing?.label),
      min = TextEditingController(text: widget.existing?.minScore.toString()),
      max = TextEditingController(text: widget.existing?.maxScore.toString()),
      point = TextEditingController(
        text: widget.existing?.gradePoint?.toString(),
      ),
      descriptor = TextEditingController(text: widget.existing?.remarks);
  late bool numeric = widget.existing?.hasNumericBoundary ?? true,
      passing = widget.existing?.isPassing ?? true;
  late Color color =
      widget.existing == null || widget.existing!.colorHex.isEmpty
      ? kSubjectColorSwatches.first
      : _bandColor(widget.existing!.colorHex);
  @override
  Widget build(BuildContext c) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      20 + MediaQuery.viewInsetsOf(c).bottom,
    ),
    child: Form(
      key: key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Add Grade Range' : 'Edit Grade Range',
              style: Theme.of(c).textTheme.titleLarge,
            ),
            TextFormField(
              controller: code,
              decoration: const InputDecoration(labelText: 'Grade Code *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: label,
              decoration: const InputDecoration(labelText: 'Grade Label'),
            ),
            if (widget.descriptorOnly)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use numeric score range'),
                value: numeric,
                onChanged: (v) => setState(() => numeric = v),
              ),
            if (numeric)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: min,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Score *',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          numeric && double.tryParse(v ?? '') == null
                          ? 'Required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: max,
                      decoration: const InputDecoration(
                        labelText: 'Maximum Score *',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          numeric && double.tryParse(v ?? '') == null
                          ? 'Required'
                          : null,
                    ),
                  ),
                ],
              ),
            TextFormField(
              controller: point,
              decoration: const InputDecoration(labelText: 'Grade Point'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextFormField(
              controller: descriptor,
              decoration: const InputDecoration(labelText: 'Descriptor'),
              maxLines: 2,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Passing grade'),
              value: passing,
              onChanged: (v) => setState(() => passing = v),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('Color'),
            ),
            Wrap(
              spacing: 12,
              children: kSubjectColorSwatches.map((swatch) {
                final selected = swatch.toARGB32() == color.toARGB32();
                return InkWell(
                  onTap: () => setState(() => color = swatch),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Theme.of(c).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!key.currentState!.validate()) return;
                final a = double.tryParse(min.text) ?? 0,
                    b = double.tryParse(max.text) ?? 0;
                if (numeric && b < a) {
                  ScaffoldMessenger.of(c).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Maximum score must be at least minimum score.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(
                  c,
                  GradeBand(
                    id: widget.existing?.id ?? '',
                    schoolId: widget.schoolId,
                    gradingSystemId: widget.existing?.gradingSystemId ?? '',
                    grade: code.text.trim(),
                    label: label.text.trim(),
                    minScore: a,
                    maxScore: b,
                    remarks: descriptor.text.trim(),
                    gradePoint: double.tryParse(point.text),
                    isPassing: passing,
                    hasNumericBoundary: numeric,
                    colorHex:
                        '#${color.toARGB32().toRadixString(16).substring(2)}',
                  ),
                );
              },
              child: Text(widget.existing == null ? 'Add Range' : 'Save Range'),
            ),
          ],
        ),
      ),
    ),
  );
}
