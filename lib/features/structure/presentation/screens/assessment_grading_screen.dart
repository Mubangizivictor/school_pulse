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
/// grouped by education level or programme. Self-contained (its own
/// repository access goes through StructureBloc like every other Structure
/// screen) so it can move into Academic Settings later without a rewrite.
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

const _iconsByLevelKind = {
  'early_years': Icons.child_care_rounded,
  'primary': Icons.menu_book_rounded,
  'secondary': Icons.school_rounded,
  'international': Icons.public_rounded,
  'custom': Icons.tune_rounded,
};

IconData _iconForLevel(EducationalLevel level) {
  final name = level.name.toLowerCase();
  if (name.contains('early') || name.contains('kinder')) {
    return _iconsByLevelKind['early_years']!;
  }
  if (name.contains('primary')) return _iconsByLevelKind['primary']!;
  if (name.contains('secondary')) return _iconsByLevelKind['secondary']!;
  if (name.contains('international')) {
    return _iconsByLevelKind['international']!;
  }
  return _iconsByLevelKind['custom']!;
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set how marks, grades and report results are calculated for '
              'each level or programme.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Different levels can use different systems.',
                      style: TextStyle(color: scheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final level in levels)
                    _LevelRow(
                      level: level,
                      systems: systems
                          .where((s) => s.levelIds.contains(level.id))
                          .toList(),
                      allBands: state.gradeBands,
                    ),
                  _AddLevelRow(),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showTemplatePicker(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use a template',
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Get started with a pre-built system (e.g. IB, '
                            'British, American).',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplatePicker(BuildContext context) {
    final levels = [...state.levels.where((l) => l.isActive)]
      ..sort((a, b) => a.order.compareTo(b.order));
    if (levels.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _TemplatePickerSheet(
        levels: levels,
        onPicked: (level, template) {
          Navigator.pop(sheetContext);
          _openSetupSheet(context, level: level, template: template);
        },
      ),
    );
  }
}

void _openSetupSheet(
  BuildContext context, {
  required EducationalLevel level,
  GradingSystemDef? existing,
  List<GradeBand>? existingBands,
  _GradingTemplate? template,
}) {
  final wide = MediaQuery.sizeOf(context).width >= 900;
  if (wide) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
          child: _GradingSetupSheet(
            level: level,
            existing: existing,
            existingBands: existingBands,
            template: template,
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _GradingSetupSheet(
          level: level,
          existing: existing,
          existingBands: existingBands,
          template: template,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.level,
    required this.systems,
    required this.allBands,
  });

  final EducationalLevel level;
  final List<GradingSystemDef> systems;
  final List<GradeBand> allBands;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = systems.isNotEmpty ? systems.first : null;
    final bandCount = active == null
        ? 0
        : allBands.where((b) => b.gradingSystemId == active.id).length;

    String subtitle;
    if (active == null) {
      subtitle = 'No system yet';
    } else if (active.type == 'narrative') {
      subtitle = 'Narrative milestones';
    } else if (active.type == 'points') {
      subtitle = 'Points-based';
    } else if (active.type == 'custom_formula') {
      subtitle = 'Custom formula';
    } else {
      subtitle = 'Percentage + grades';
    }
    final countLabel = active == null
        ? '0 subjects'
        : active.type == 'narrative'
        ? '$bandCount milestone area${bandCount == 1 ? '' : 's'}'
        : '$bandCount subject${bandCount == 1 ? '' : 's'}';

    final isReady = active != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => active == null
            ? _openSetupSheet(context, level: level)
            : _openSetupSheet(
                context,
                level: level,
                existing: active,
                existingBands: allBands
                    .where((b) => b.gradingSystemId == active.id)
                    .toList()
                  ..sort((a, b) => a.order.compareTo(b.order)),
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForLevel(level),
                  size: 20,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(ready: isReady),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.ready});
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (ready) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Ready',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Set up',
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _AddLevelRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(Icons.add, size: 18, color: scheme.onSurfaceVariant),
        label: const Text('Add grading system'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

enum _GradingType { marksAndBands, narrative, points, customFormula }

class _GradingTemplate {
  const _GradingTemplate({
    required this.name,
    required this.maximumMark,
    required this.bands,
  });
  final String name;
  final double maximumMark;
  final List<(String grade, double min, double max, String descriptor)> bands;
}

const _templates = [
  _GradingTemplate(
    name: 'British (A*–U)',
    maximumMark: 100,
    bands: [
      ('A*', 90, 100, 'Outstanding'),
      ('A', 80, 89, 'Excellent'),
      ('B', 70, 79, 'Very good'),
      ('C', 60, 69, 'Good'),
      ('D', 50, 59, 'Satisfactory'),
      ('U', 0, 49, 'Ungraded'),
    ],
  ),
  _GradingTemplate(
    name: 'American (A–F)',
    maximumMark: 100,
    bands: [
      ('A', 90, 100, 'Excellent'),
      ('B', 80, 89, 'Good'),
      ('C', 70, 79, 'Satisfactory'),
      ('D', 60, 69, 'Poor'),
      ('F', 0, 59, 'Fail'),
    ],
  ),
  _GradingTemplate(
    name: 'IB (1–7 points)',
    maximumMark: 7,
    bands: [
      ('7', 6, 7, 'Excellent'),
      ('5–6', 4, 5.99, 'Very good / good'),
      ('3–4', 2, 3.99, 'Satisfactory / mediocre'),
      ('1–2', 0, 1.99, 'Poor / very poor'),
    ],
  ),
];

class _TemplatePickerSheet extends StatelessWidget {
  const _TemplatePickerSheet({required this.levels, required this.onPicked});
  final List<EducationalLevel> levels;
  final void Function(EducationalLevel level, _GradingTemplate template)
  onPicked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use a template',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a starting point, then apply it to a level. You can edit '
              'everything afterwards.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            for (final template in _templates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${template.bands.length} grade bands • max '
                          '${template.maximumMark.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final level in levels)
                              OutlinedButton(
                                onPressed: () => onPicked(level, template),
                                child: Text('Apply to ${level.name}'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Single-screen setup for one level's grading system: pick a type, fill in
/// the fields it needs, save. Works as a mobile bottom sheet or a desktop
/// dialog via `_openSetupSheet` above.
class _GradingSetupSheet extends StatefulWidget {
  const _GradingSetupSheet({
    required this.level,
    this.existing,
    this.existingBands,
    this.template,
    this.scrollController,
  });

  final EducationalLevel level;
  final GradingSystemDef? existing;
  final List<GradeBand>? existingBands;
  final _GradingTemplate? template;
  final ScrollController? scrollController;

  @override
  State<_GradingSetupSheet> createState() => _GradingSetupSheetState();
}

class _BandDraft {
  _BandDraft({String? grade, String? min, String? max, String? descriptor})
    : gradeController = TextEditingController(text: grade),
      minController = TextEditingController(text: min),
      maxController = TextEditingController(text: max),
      descriptorController = TextEditingController(text: descriptor);
  final TextEditingController gradeController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final TextEditingController descriptorController;
  void dispose() {
    gradeController.dispose();
    minController.dispose();
    maxController.dispose();
    descriptorController.dispose();
  }
}

class _GradingSetupSheetState extends State<_GradingSetupSheet> {
  late _GradingType _type = switch (widget.existing?.type) {
    'narrative' => _GradingType.narrative,
    'points' => _GradingType.points,
    'custom_formula' => _GradingType.customFormula,
    _ => _GradingType.marksAndBands,
  };
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _maximumMark = TextEditingController(
    text:
        widget.existing?.maximumMark.toStringAsFixed(0) ??
        widget.template?.maximumMark.toStringAsFixed(0) ??
        '100',
  );
  late final _customFormula = TextEditingController(
    text: widget.existing?.description,
  );
  late bool _includeComments = widget.existing?.allowIncomplete ?? true;
  late final List<_BandDraft> _drafts = _initialDrafts();
  String? _error;
  bool _saving = false;

  List<_BandDraft> _initialDrafts() {
    if (widget.existingBands != null && widget.existingBands!.isNotEmpty) {
      return widget.existingBands!
          .map(
            (b) => _BandDraft(
              grade: b.grade,
              min: b.hasNumericBoundary ? b.minScore.toStringAsFixed(0) : null,
              max: b.hasNumericBoundary ? b.maxScore.toStringAsFixed(0) : null,
              descriptor: b.remarks,
            ),
          )
          .toList();
    }
    if (widget.template != null) {
      return widget.template!.bands
          .map(
            (b) => _BandDraft(
              grade: b.$1,
              min: b.$2.toStringAsFixed(0),
              max: b.$3.toStringAsFixed(0),
              descriptor: b.$4,
            ),
          )
          .toList();
    }
    return [_BandDraft()];
  }

  @override
  void dispose() {
    _name.dispose();
    _maximumMark.dispose();
    _customFormula.dispose();
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  bool get _needsBands =>
      _type == _GradingType.marksAndBands || _type == _GradingType.narrative;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Set up ${widget.level.name} grading',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose how results are calculated for ${widget.level.name}. '
                    'You can update this before results are published.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13.5),
                  ),
                  const SizedBox(height: 16),
                  _typeOption(
                    _GradingType.marksAndBands,
                    'Marks & grade bands',
                    'Use a maximum mark and define grade bands',
                  ),
                  _typeOption(
                    _GradingType.narrative,
                    'Narrative milestones',
                    'Use milestone descriptors',
                  ),
                  _typeOption(
                    _GradingType.points,
                    'Points',
                    'Use a points-based system',
                  ),
                  _typeOption(
                    _GradingType.customFormula,
                    'Custom formula',
                    'Create a custom calculation',
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'System name',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      hintText: 'e.g., ${widget.level.name} standard',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_type == _GradingType.marksAndBands ||
                      _type == _GradingType.points) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _type == _GradingType.points
                                ? 'Maximum points'
                                : 'Maximum mark',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _maximumMark,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '100'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_needsBands) ...[
                    Row(
                      children: [
                        Text(
                          _type == _GradingType.narrative
                              ? 'Milestone areas'
                              : 'Grade bands',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          'From',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_type == _GradingType.marksAndBands)
                      Row(
                        children: const [
                          SizedBox(width: 34),
                          Expanded(child: Text('Grade', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                          SizedBox(width: 8),
                          Expanded(child: Text('From', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                          SizedBox(width: 8),
                          Expanded(child: Text('To', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                          SizedBox(width: 8),
                          Expanded(flex: 2, child: Text('Descriptor', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                          SizedBox(width: 40),
                        ],
                      ),
                    const SizedBox(height: 6),
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
                      itemBuilder: (context, index) => _bandRow(index),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _drafts.add(_BandDraft())),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        _type == _GradingType.narrative
                            ? 'Add milestone area'
                            : 'Add grade band',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_type == _GradingType.customFormula) ...[
                    const Text(
                      'Formula description',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customFormula,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe how results are calculated for this '
                            'programme (e.g., weighted coursework + exam).',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Include report comments (optional)',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Add a general comment for each student\'s report.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _includeComments,
                          onChanged: (v) => setState(() => _includeComments = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This system applies to ${widget.level.name} only.',
                            style: TextStyle(color: scheme.primary, fontSize: 12.5),
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
                        border: Border.all(color: scheme.error),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!, style: TextStyle(color: scheme.error)),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
    );
  }

  Widget _typeOption(_GradingType type, String title, String subtitle) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer.withValues(alpha: 0.4)
                : null,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Radio<_GradingType>(
                value: type,
                groupValue: _type,
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bandRow(int index) {
    final scheme = Theme.of(context).colorScheme;
    final draft = _drafts[index];
    return Padding(
      key: ValueKey(draft),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: draft.gradeController,
              decoration: const InputDecoration(isDense: true, hintText: 'A'),
            ),
          ),
          if (_type == _GradingType.marksAndBands) ...[
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: draft.minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(isDense: true, hintText: '80'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: draft.maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(isDense: true, hintText: '100'),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Expanded(
            flex: _type == _GradingType.marksAndBands ? 2 : 3,
            child: TextField(
              controller: draft.descriptorController,
              decoration: const InputDecoration(isDense: true, hintText: 'Excellent'),
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
    );
  }

  void _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a system name.');
      return;
    }
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final typeKey = switch (_type) {
      _GradingType.narrative => 'narrative',
      _GradingType.points => 'points',
      _GradingType.customFormula => 'custom_formula',
      _GradingType.marksAndBands => '',
    };

    var maximumMark = 0.0;
    List<GradeBand> bands = const [];

    if (_type == _GradingType.customFormula) {
      if (_customFormula.text.trim().isEmpty) {
        setState(() => _error = 'Describe the custom formula.');
        return;
      }
    } else if (_type == _GradingType.points || _type == _GradingType.marksAndBands) {
      maximumMark = double.tryParse(_maximumMark.text.trim()) ?? 0;
      if (maximumMark <= 0) {
        setState(() => _error = 'Enter a maximum greater than zero.');
        return;
      }
    }

    if (_needsBands) {
      final built = <GradeBand>[];
      for (var i = 0; i < _drafts.length; i++) {
        final draft = _drafts[i];
        final grade = draft.gradeController.text.trim();
        if (grade.isEmpty) {
          setState(() => _error = 'Every band needs a label.');
          return;
        }
        if (_type == _GradingType.marksAndBands) {
          final min = double.tryParse(draft.minController.text.trim());
          final max = double.tryParse(draft.maxController.text.trim());
          if (min == null || max == null) {
            setState(() => _error = 'Complete every band\'s from/to mark.');
            return;
          }
          built.add(
            GradeBand(
              id: const Uuid().v4(),
              schoolId: schoolId,
              gradingSystemId: '',
              grade: grade,
              minScore: min,
              maxScore: max,
              remarks: draft.descriptorController.text.trim(),
              order: i,
              hasNumericBoundary: true,
            ),
          );
        } else {
          built.add(
            GradeBand(
              id: const Uuid().v4(),
              schoolId: schoolId,
              gradingSystemId: '',
              grade: grade,
              remarks: draft.descriptorController.text.trim(),
              order: i,
              hasNumericBoundary: false,
            ),
          );
        }
      }
      if (_type == _GradingType.marksAndBands) {
        final validationError = GradingBandValidator.validate(
          maximumMark: maximumMark,
          bands: built,
        );
        if (validationError != null) {
          setState(() => _error = validationError);
          return;
        }
      } else {
        final labels = <String>{};
        for (final band in built) {
          if (!labels.add(band.grade.toLowerCase())) {
            setState(() => _error = 'Milestone area labels must be unique.');
            return;
          }
        }
      }
      bands = built;
    }

    if (widget.existing != null) {
      final dependents = await di
          .sl<StructureDependencyService>()
          .countAssessmentsUsingGradingSystem(schoolId, widget.existing!.id);
      if (!mounted) return;
      if (dependents > 0) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Assessments use this grading system'),
            content: Text(
              '$dependents assessment${dependents == 1 ? '' : 's'} already used '
              '"${widget.existing!.name}". Saving will create a new version '
              'instead of changing recorded marks.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        if (proceed != true || !mounted) return;
      }
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final system = GradingSystemDef(
      id: const Uuid().v4(),
      schoolId: schoolId,
      name: name,
      type: typeKey,
      isDefault: widget.existing?.isDefault ?? false,
      description: _type == _GradingType.customFormula
          ? _customFormula.text.trim()
          : '',
      allowIncomplete: _includeComments,
      appliesTo: 'levels',
      levelIds: [widget.level.id],
      maximumMark: maximumMark,
      version: (widget.existing?.version ?? 0) + 1,
    );
    final finalBands = bands
        .map((b) => b.copyWith(gradingSystemId: system.id))
        .toList();

    if (!mounted) return;
    final bloc = context.read<StructureBloc>();
    bloc.add(SaveGradingSystemWithBandsRequested(system, finalBands));
    if (widget.existing != null) {
      bloc.add(
        SaveGradingSystemRequested(
          widget.existing!.copyWith(isActive: false, isDefault: false),
        ),
      );
    }
    Navigator.of(context).pop();
  }
}
