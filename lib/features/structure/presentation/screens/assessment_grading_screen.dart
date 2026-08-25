import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/assessment_grading_entities.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/services/grading_band_validator.dart';
import '../../domain/services/structure_dependency_service.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// Step 11: define the grading system(s) used to convert marks into grades,
/// grouped by education level. Self-contained (its own repository access
/// goes through StructureBloc like every other Structure screen) so it can
/// move into Academic Settings later without a rewrite.
class AssessmentGradingScreen extends StatelessWidget {
  const AssessmentGradingScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: const Text('Assessment & grading'))
          : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => _Overview(state: state),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.state});
  final StructureState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final levels = [...state.levels.where((l) => l.isActive)]
      ..sort((a, b) => a.order.compareTo(b.order));
    final systems = state.gradingSystems.where((s) => s.isActive).toList();

    void onAdd([EducationalLevel? level]) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateGradingSystemScreen(
          levels: levels,
          preselectedLevelId: level?.id,
        ),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set the rules used to calculate marks and report results.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: levels.isEmpty
                  ? Center(
                      child: Text(
                        'Add an education level before configuring grading.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final level in levels)
                          _LevelSection(
                            level: level,
                            systems: systems
                                .where((s) => s.levelIds.contains(level.id))
                                .toList(),
                            allBands: state.gradeBands,
                            onAdd: () => onAdd(level),
                            onOpen: (system) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _GradingSystemDetailScreen(
                                  system: system,
                                  bands: state.gradeBands
                                      .where((b) => b.gradingSystemId == system.id)
                                      .toList()
                                    ..sort((a, b) => a.order.compareTo(b.order)),
                                  levels: levels,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.level,
    required this.systems,
    required this.allBands,
    required this.onAdd,
    required this.onOpen,
  });

  final EducationalLevel level;
  final List<GradingSystemDef> systems;
  final List<GradeBand> allBands;
  final VoidCallback onAdd;
  final ValueChanged<GradingSystemDef> onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  systems.isEmpty
                      ? 'No grading system yet'
                      : '${systems.length} grading system${systems.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (systems.isEmpty)
            _EmptyLevelCard(onAdd: onAdd)
          else ...[
            for (final system in systems)
              _SystemCard(
                system: system,
                bandCount: allBands.where((b) => b.gradingSystemId == system.id).length,
                onTap: () => onOpen(system),
              ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add grading system'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyLevelCard extends StatelessWidget {
  const _EmptyLevelCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Text('Add grading system', style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.system, required this.bandCount, required this.onTap});
  final GradingSystemDef system;
  final int bandCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0–${system.maximumMark.toStringAsFixed(0)} marks • $bandCount grade band${bandCount == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (system.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Default', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradingSystemDetailScreen extends StatelessWidget {
  const _GradingSystemDetailScreen({
    required this.system,
    required this.bands,
    required this.levels,
  });

  final GradingSystemDef system;
  final List<GradeBand> bands;
  final List<EducationalLevel> levels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      appBar: AppBar(
        title: Text(system.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _editSystem(context, schoolId),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '0–${system.maximumMark.toStringAsFixed(0)} marks'
              '${system.passingScore != null ? ' • Pass mark ${system.passingScore!.toStringAsFixed(0)}' : ''}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (system.isDefault) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Default for this level', style: TextStyle(fontSize: 12)),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Grade bands',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final band in bands)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(band.grade, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text(
                        '${band.minScore.toStringAsFixed(0)}–${band.maxScore.toStringAsFixed(0)}',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSystem(BuildContext context, String schoolId) async {
    final dependents = await di
        .sl<StructureDependencyService>()
        .countAssessmentsUsingGradingSystem(schoolId, system.id);
    if (!context.mounted) return;
    if (dependents > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Assessments use this grading system'),
          content: Text(
            '$dependents assessment${dependents == 1 ? '' : 's'} already used "${system.name}". '
            'Editing will create a new version instead of changing recorded marks.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
          ],
        ),
      );
      if (proceed != true || !context.mounted) return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateGradingSystemScreen(
          levels: levels,
          existing: system,
          existingBands: bands,
        ),
      ),
    );
  }
}

/// Stage 1 of 2: basic scoring rules.
class CreateGradingSystemScreen extends StatefulWidget {
  const CreateGradingSystemScreen({
    super.key,
    required this.levels,
    this.preselectedLevelId,
    this.existing,
    this.existingBands,
  });

  final List<EducationalLevel> levels;
  final String? preselectedLevelId;
  final GradingSystemDef? existing;
  final List<GradeBand>? existingBands;

  @override
  State<CreateGradingSystemScreen> createState() => _CreateGradingSystemScreenState();
}

class _CreateGradingSystemScreenState extends State<CreateGradingSystemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _maximumMark = TextEditingController(
    text: widget.existing?.maximumMark.toStringAsFixed(0) ?? '',
  );
  late final _passMark = TextEditingController(
    text: widget.existing?.passingScore?.toStringAsFixed(0) ?? '',
  );
  late String? _levelId = widget.existing != null && widget.existing!.levelIds.isNotEmpty
      ? widget.existing!.levelIds.first
      : (widget.preselectedLevelId ?? (widget.levels.isNotEmpty ? widget.levels.first.id : null));
  late bool _isDefault = widget.existing?.isDefault ?? false;

  @override
  void dispose() {
    _name.dispose();
    _maximumMark.dispose();
    _passMark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('1 of 2'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 0.5,
            minHeight: 4,
            backgroundColor: scheme.outlineVariant,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  const Text(
                    'Create grading system',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set the basic scoring rules.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'These settings affect how marks are calculated and reported. Changes apply only after assignment.',
                            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('System name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(hintText: 'e.g., Primary standard'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter a system name.' : null,
                        ),
                        const SizedBox(height: 18),
                        const Text('Education level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _levelId,
                          decoration: const InputDecoration(),
                          items: widget.levels
                              .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
                              .toList(),
                          validator: (v) => v == null ? 'Select an education level.' : null,
                          onChanged: (v) => setState(() => _levelId = v),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Maximum mark', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _maximumMark,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(hintText: '100'),
                                    validator: (v) {
                                      final value = double.tryParse(v ?? '');
                                      return value == null || value <= 0
                                          ? 'Enter a maximum mark greater than zero.'
                                          : null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pass mark (optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passMark,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(hintText: 'e.g., 50'),
                                    validator: (v) {
                                      if ((v ?? '').trim().isEmpty) return null;
                                      final value = double.tryParse(v!);
                                      final maximum = double.tryParse(_maximumMark.text);
                                      if (value == null || value < 0 || maximum == null || value > maximum) {
                                        return 'Enter a value within the maximum mark.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Set as default for this level'),
                            Switch(
                              value: _isDefault,
                              onChanged: (v) => setState(() => _isDefault = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _continue,
                  child: const Text('Continue to grade bands'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final level = widget.levels.where((l) => l.id == _levelId).firstOrNull;
    final schoolId = (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final system = GradingSystemDef(
      id: const Uuid().v4(),
      schoolId: schoolId,
      name: _name.text.trim(),
      isDefault: _isDefault,
      appliesTo: 'levels',
      levelIds: level == null ? const [] : [level.id],
      passingScore: double.tryParse(_passMark.text.trim()),
      maximumMark: double.parse(_maximumMark.text.trim()),
      version: (widget.existing?.version ?? 0) + 1,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DefineGradeBandsScreen(
          system: system,
          level: level,
          existingBands: widget.existingBands,
          replacing: widget.existing,
        ),
      ),
    );
  }
}

/// Stage 2 of 2: grade bands, added/edited/reordered/removed, saved
/// atomically with the system from stage 1.
class DefineGradeBandsScreen extends StatefulWidget {
  const DefineGradeBandsScreen({
    super.key,
    required this.system,
    required this.level,
    this.existingBands,
    this.replacing,
  });

  final GradingSystemDef system;
  final EducationalLevel? level;
  final List<GradeBand>? existingBands;

  /// The previous version being superseded, if this is an edit. Archived
  /// (isActive: false) after the new version saves - never mutated in
  /// place, so any assessment/report that already referenced it by id keeps
  /// reading the same bands it was recorded against.
  final GradingSystemDef? replacing;

  @override
  State<DefineGradeBandsScreen> createState() => _DefineGradeBandsScreenState();
}

class _BandDraft {
  _BandDraft({String? grade, String? min, String? max})
      : gradeController = TextEditingController(text: grade),
        minController = TextEditingController(text: min),
        maxController = TextEditingController(text: max);
  final TextEditingController gradeController;
  final TextEditingController minController;
  final TextEditingController maxController;
  void dispose() {
    gradeController.dispose();
    minController.dispose();
    maxController.dispose();
  }
}

class _DefineGradeBandsScreenState extends State<DefineGradeBandsScreen> {
  late final List<_BandDraft> _drafts = widget.existingBands != null && widget.existingBands!.isNotEmpty
      ? widget.existingBands!
          .map(
            (b) => _BandDraft(
              grade: b.grade,
              min: b.minScore.toStringAsFixed(0),
              max: b.maxScore.toStringAsFixed(0),
            ),
          )
          .toList()
      : [_BandDraft()];
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('2 of 2'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 1,
            minHeight: 4,
            backgroundColor: scheme.outlineVariant,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  const Text(
                    'Define grade bands',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'List all grade bands that cover the full range of marks.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outline),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.bar_chart_rounded, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.system.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              '0–${widget.system.maximumMark.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      SizedBox(width: 24),
                      SizedBox(width: 10),
                      Expanded(child: Text('Band', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      SizedBox(width: 10),
                      Expanded(child: Text('From', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      SizedBox(width: 10),
                      Expanded(child: Text('To', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _drafts.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final moved = _drafts.removeAt(oldIndex);
                        _drafts.insert(newIndex, moved);
                      });
                    },
                    itemBuilder: (context, index) => Padding(
                      key: ValueKey(_drafts[index]),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _drafts[index].gradeController,
                              decoration: const InputDecoration(isDense: true, hintText: 'D1'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _drafts[index].minController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(isDense: true, hintText: '80'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('–'),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _drafts[index].maxController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(isDense: true, hintText: '100'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _drafts.length == 1
                                ? null
                                : () => setState(() {
                                      _drafts[index].dispose();
                                      _drafts.removeAt(index);
                                    }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _drafts.add(_BandDraft())),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add grade band'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Every mark from 0 to ${widget.system.maximumMark.toStringAsFixed(0)} must be covered once.',
                            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save grading system'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final bands = <GradeBand>[];
    for (var i = 0; i < _drafts.length; i++) {
      final draft = _drafts[i];
      final grade = draft.gradeController.text.trim();
      final min = double.tryParse(draft.minController.text.trim());
      final max = double.tryParse(draft.maxController.text.trim());
      if (grade.isEmpty || min == null || max == null) {
        setState(() => _error = 'Complete every grade band\'s label, from and to mark.');
        return;
      }
      bands.add(
        GradeBand(
          id: const Uuid().v4(),
          schoolId: widget.system.schoolId,
          gradingSystemId: widget.system.id,
          grade: grade,
          minScore: min,
          maxScore: max,
          order: i,
          hasNumericBoundary: true,
        ),
      );
    }
    final validationError = GradingBandValidator.validate(
      maximumMark: widget.system.maximumMark,
      bands: bands,
    );
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    final bloc = context.read<StructureBloc>();
    bloc.add(SaveGradingSystemWithBandsRequested(widget.system, bands));
    if (widget.replacing != null) {
      bloc.add(
        SaveGradingSystemRequested(
          widget.replacing!.copyWith(
            isActive: false,
            isDefault: false,
          ),
        ),
      );
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
