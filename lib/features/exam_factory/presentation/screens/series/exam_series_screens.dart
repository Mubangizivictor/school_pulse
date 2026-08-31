import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import '../../widgets/exam_factory_structure_loader.dart';

String seriesStatusLabel(ExamSeriesStatus status) => switch (status) {
  ExamSeriesStatus.draft => 'Draft',
  ExamSeriesStatus.collectingQuestions => 'Collecting questions',
  ExamSeriesStatus.moderating => 'Moderating',
  ExamSeriesStatus.buildingPapers => 'Building papers',
  ExamSeriesStatus.awaitingApproval => 'Awaiting approval',
  ExamSeriesStatus.printing => 'Printing',
  ExamSeriesStatus.scheduled => 'Scheduled',
  ExamSeriesStatus.inProgress => 'In progress',
  ExamSeriesStatus.marking => 'Marking',
  ExamSeriesStatus.resultsReview => 'Results review',
  ExamSeriesStatus.published => 'Published',
  ExamSeriesStatus.archived => 'Archived',
  ExamSeriesStatus.cancelled => 'Cancelled',
};

class ExamSeriesListScreen extends StatelessWidget {
  const ExamSeriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Examination Series',
      backFallback: '/staff/dean/exam-factory',
      action: IconButton(
        tooltip: 'Create series',
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => context.push('/staff/dean/exam-factory/series-editor'),
      ),
      child: ExamFactoryStreamView<ExamSeries>(
        stream: cubit.watchSeries(),
        emptyIcon: Icons.event_note_outlined,
        emptyTitle: 'No examination series yet',
        emptyMessage: 'Create a series to start collecting exam questions.',
        emptyAction: FilledButton.icon(
          onPressed: () =>
              context.push('/staff/dean/exam-factory/series-editor'),
          icon: const Icon(Icons.add),
          label: const Text('Create series'),
        ),
        builder: (context, items) => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.l),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final series = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(series.name, style: AppTypography.titleSmall),
                subtitle: Text(
                  '${series.academicYear} · ${series.term} · ${seriesStatusLabel(series.status)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/staff/dean/exam-factory/series-editor?seriesId=${series.id}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExamSeriesEditorScreen extends StatefulWidget {
  final String? seriesId;
  const ExamSeriesEditorScreen({super.key, this.seriesId});

  @override
  State<ExamSeriesEditorScreen> createState() => _ExamSeriesEditorScreenState();
}

/// Exam type options shown only when a school has not yet defined its own
/// assessment-type vocabulary in Structure (Settings > Assessment types).
/// Kept as a fallback so Exam Factory still works before that setup step,
/// rather than assuming every school runs midterm/end-of-term/mock/national.
const _fallbackExamTypes = ['midterm', 'endOfTerm', 'mock', 'national'];

String _fallbackExamTypeLabel(String value) => switch (value) {
  'midterm' => 'Midterm',
  'endOfTerm' => 'End of term',
  'mock' => 'Mock',
  'national' => 'National',
  _ => value,
};

class _ExamSeriesEditorScreenState extends State<ExamSeriesEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController(text: '${DateTime.now().year}');
  String? _academicYearId;
  String _term = '';
  String _type = '';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _questionDeadline;
  final Set<String> _classIds = {};
  final Set<String> _subjectIds = {};
  bool _saving = false;
  bool _loadedExisting = false;
  bool _defaultsApplied = false;

  @override
  void initState() {
    super.initState();
    ensureStructureLoaded(
      context,
      context.read<ExamFactoryCubit>().institutionId,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _applyExisting(ExamSeries series, StructureState structureState) {
    if (_loadedExisting) return;
    _loadedExisting = true;
    _nameController.text = series.name;
    _yearController.text = series.academicYear;
    _academicYearId = structureState.academicYears
        .where((y) => y.name == series.academicYear)
        .map((y) => y.id)
        .firstOrNull;
    _term = series.term;
    _type = series.type;
    _startDate = series.startDate;
    _endDate = series.endDate;
    _questionDeadline = series.questionDeadline;
    _classIds
      ..clear()
      ..addAll(series.classIds);
    _subjectIds
      ..clear()
      ..addAll(series.subjectIds);
  }

  /// Seeds sensible starting values the first time Structure data is
  /// available for a brand-new series, without overwriting anything a user
  /// (or an existing series being edited) has already set.
  void _applyDefaults(StructureState structureState) {
    if (_defaultsApplied || _loadedExisting) return;
    _defaultsApplied = true;
    final currentYear = structureState.academicYears
        .where((y) => y.isCurrent)
        .firstOrNull;
    if (currentYear != null) {
      _academicYearId = currentYear.id;
      _yearController.text = currentYear.name;
    }
    if (_term.isEmpty) {
      final terms = _termsForYear(structureState);
      final currentTerm = terms.where((t) => t.isCurrent).firstOrNull;
      // Falls back to 'Term 1' when the school hasn't configured its term
      // calendar in Structure yet, matching the free-text field shown below
      // in that case rather than leaving the form's required field blank.
      _term = (currentTerm ?? terms.firstOrNull)?.name ?? 'Term 1';
    }
    if (_type.isEmpty) {
      _type = structureState.assessmentTypes.isNotEmpty
          ? structureState.assessmentTypes.first.name
          : _fallbackExamTypes.first;
    }
  }

  List<AcademicTerm> _termsForYear(StructureState structureState) {
    if (_academicYearId == null) return structureState.academicTerms;
    return structureState.academicTerms
        .where((t) => t.academicYearId == _academicYearId)
        .toList();
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save(ExamFactoryCubit cubit, String existingId) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a start and end date.')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after the start date.')),
      );
      return;
    }
    setState(() => _saving = true);
    final id = existingId.isNotEmpty ? existingId : const Uuid().v4();
    try {
      await cubit.saveSeries(
        ExamSeries(
          id: id,
          institutionId: cubit.institutionId,
          name: _nameController.text.trim(),
          academicYear: _yearController.text.trim(),
          term: _term,
          type: _type,
          startDate: _startDate!,
          endDate: _endDate!,
          status: ExamSeriesStatus.draft,
          classIds: _classIds.toList(),
          subjectIds: _subjectIds.toList(),
          questionDeadline: _questionDeadline,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examination series saved.')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not save the series.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    final seriesId = widget.seriesId ?? '';

    Widget form(StructureState structureState) {
      final classes = structureState.classes;
      final subjects = structureState.subjects;
      final academicYears = structureState.academicYears;
      final terms = _termsForYear(structureState);
      final examTypes = structureState.assessmentTypes;
      final levels = [...structureState.levels]
        ..sort((a, b) => a.order.compareTo(b.order));
      final classesByLevel = <String, List<SchoolClass>>{};
      for (final level in levels) {
        classesByLevel[level.id] = classes
            .where((c) => c.levelId == level.id && c.isActive)
            .toList();
      }
      final unleveled = classes
          .where((c) => !levels.any((l) => l.id == c.levelId))
          .toList();

      Widget classChips(List<SchoolClass> group) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: group
            .map(
              (c) => FilterChip(
                label: Text(c.name),
                selected: _classIds.contains(c.id),
                onSelected: (sel) => setState(
                  () => sel ? _classIds.add(c.id) : _classIds.remove(c.id),
                ),
              ),
            )
            .toList(),
      );

      return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Series name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: academicYears.isEmpty
                      ? TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Academic year',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        )
                      : DropdownButtonFormField<String>(
                          initialValue:
                              academicYears.any((y) => y.id == _academicYearId)
                              ? _academicYearId
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Academic year',
                          ),
                          items: academicYears
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y.id,
                                  child: Text(y.name),
                                ),
                              )
                              .toList(),
                          validator: (v) => v == null ? 'Required' : null,
                          onChanged: (v) => setState(() {
                            _academicYearId = v;
                            _yearController.text = academicYears
                                .firstWhere((y) => y.id == v)
                                .name;
                            // The selected term may belong to a different
                            // academic year - reset it so the user picks one
                            // from the newly-filtered list below.
                            _term = '';
                          }),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: terms.isEmpty
                      ? TextFormField(
                          initialValue: _term,
                          decoration: const InputDecoration(labelText: 'Term'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                          onChanged: (v) => _term = v,
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: terms.any((t) => t.name == _term)
                              ? _term
                              : null,
                          decoration: const InputDecoration(labelText: 'Term'),
                          items: terms
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t.name,
                                  child: Text(t.name),
                                ),
                              )
                              .toList(),
                          validator: (v) => v == null ? 'Required' : null,
                          onChanged: (v) => setState(() => _term = v ?? _term),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            examTypes.isEmpty
                ? DropdownButtonFormField<String>(
                    initialValue: _fallbackExamTypes.contains(_type)
                        ? _type
                        : _fallbackExamTypes.first,
                    decoration: const InputDecoration(
                      labelText: 'Examination type',
                    ),
                    items: _fallbackExamTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(_fallbackExamTypeLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: examTypes.any((t) => t.name == _type)
                        ? _type
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Examination type',
                    ),
                    items: examTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.name,
                            child: Text(t.name),
                          ),
                        )
                        .toList(),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Start date',
                    value: _startDate,
                    onTap: () => _pickDate(
                      initial: _startDate,
                      onPicked: (d) => setState(() => _startDate = d),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DatePickerTile(
                    label: 'End date',
                    value: _endDate,
                    onTap: () => _pickDate(
                      initial: _endDate,
                      onPicked: (d) => setState(() => _endDate = d),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DatePickerTile(
              label: 'Question submission deadline',
              value: _questionDeadline,
              onTap: () => _pickDate(
                initial: _questionDeadline,
                onPicked: (d) => setState(() => _questionDeadline = d),
              ),
            ),
            const SizedBox(height: 18),
            Text('Included classes', style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            for (final level in levels)
              if (classesByLevel[level.id]!.isNotEmpty) ...[
                Text(
                  level.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
                const SizedBox(height: 8),
                classChips(classesByLevel[level.id]!),
                const SizedBox(height: 14),
              ],
            if (unleveled.isNotEmpty) ...[
              if (levels.isNotEmpty) ...[
                Text(
                  'Other classes',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              classChips(unleveled),
            ],
            const SizedBox(height: 18),
            Text('Included subjects', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects
                  .map(
                    (s) => FilterChip(
                      label: Text(s.name),
                      selected: _subjectIds.contains(s.id),
                      onSelected: (sel) => setState(
                        () => sel
                            ? _subjectIds.add(s.id)
                            : _subjectIds.remove(s.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : () => _save(cubit, seriesId),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving…' : 'Save series'),
            ),
          ],
        ),
      );
    }

    return ExamFactoryScaffold(
      title: seriesId.isEmpty
          ? 'Create examination series'
          : 'Edit examination series',
      backFallback: '/staff/dean/exam-factory/series',
      child: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structureState) {
          if (structureState.classes.isEmpty &&
              structureState.subjects.isEmpty) {
            return const ExamFactoryLoading();
          }
          if (seriesId.isEmpty) {
            _applyDefaults(structureState);
            return form(structureState);
          }
          return StreamBuilder<ExamSeries?>(
            stream: cubit.repository.watchSeriesById(
              cubit.institutionId,
              seriesId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ExamFactoryLoading();
              }
              final series = snapshot.data;
              if (series == null) {
                return const ExamFactoryEmpty(
                  icon: Icons.error_outline,
                  title: 'Series not found',
                  message: 'This examination series may have been removed.',
                );
              }
              _applyExisting(series, structureState);
              return form(structureState);
            },
          );
        },
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(
        value == null
            ? 'Select date'
            : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: value == null ? AppColors.textMuted(context) : null,
        ),
      ),
    ),
  );
}
