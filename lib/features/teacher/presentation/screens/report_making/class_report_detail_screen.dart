import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';

/// Edits class-teacher-owned report sections only. Scores and final outputs
/// are intentionally never copied from, or calculated outside, their engines.
class ClassReportDetailScreen extends StatefulWidget {
  const ClassReportDetailScreen({super.key, required this.studentId});
  final String studentId;
  @override
  State<ClassReportDetailScreen> createState() =>
      _ClassReportDetailScreenState();
}

class _ClassReportDetailScreenState extends State<ClassReportDetailScreen> {
  final _comment = TextEditingController();
  final _recommendation = TextEditingController();
  String? _entryId;
  @override
  void dispose() {
    _comment.dispose();
    _recommendation.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ClassReportsBloc, ClassReportsState>(
    listenWhen: (a, b) =>
        a.successMessage != b.successMessage ||
        a.errorMessage != b.errorMessage,
    listener: (context, state) {
      final text = state.successMessage ?? state.errorMessage;
      if (text != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(text)));
      }
    },
    builder: (context, state) {
      final found = state.entries.where((e) => e.studentId == widget.studentId);
      if (found.isEmpty || state.profile == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text('This report is no longer available.'),
          ),
        );
      }
      final entry = found.first;
      final profile = state.profile!;
      if (_entryId != entry.id) {
        _entryId = entry.id;
        _comment.text = entry.teacherComment ?? '';
      }
      final canEdit = entry.isEditable;
      return Scaffold(
        appBar: AppBar(title: const Text('Report Details')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    Text(
                      entry.studentName.isEmpty
                          ? entry.studentId
                          : entry.studentName,
                      style: AppTypography.headlineSmall,
                    ),
                    Text(entry.status.label),
                    if (entry.returnReason?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Returned: ${entry.returnReason}'),
                      ),
                    const SizedBox(height: AppSpacing.l),
                    const _AcademicNotice(),
                    if (profile.isEnabled(ReportSection.competencies))
                      _CompetencyForm(
                        entry: entry,
                        profile: profile,
                        enabled: canEdit,
                        onChanged: (items) =>
                            _save(entry.copyWith(competencies: items)),
                      ),
                    if (profile.isEnabled(ReportSection.conduct))
                      _ConductForm(
                        entry: entry,
                        profile: profile,
                        enabled: canEdit,
                        onChanged: (items, overall) => _save(
                          entry.copyWith(
                            conduct: items,
                            overallConductCode: overall,
                          ),
                        ),
                      ),
                    if (profile.isEnabled(ReportSection.attendanceVerification))
                      _Section(
                        title: 'Attendance verification',
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'I have verified the attendance figures',
                          ),
                          subtitle: const Text(
                            'Figures are provided by the Attendance Engine.',
                          ),
                          value: entry.attendanceVerified,
                          onChanged: canEdit
                              ? (value) => _save(
                                  entry.copyWith(attendanceVerified: value),
                                )
                              : null,
                        ),
                      ),
                    if (profile.isEnabled(ReportSection.teacherComment))
                      _Section(
                        title: 'Teacher comment',
                        child: TextField(
                          controller: _comment,
                          enabled: canEdit,
                          maxLines: 5,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            hintText:
                                'Minimum ${profile.commentMinLength} characters',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    if (profile.isEnabled(ReportSection.recommendations))
                      _Recommendations(
                        entry: entry,
                        controller: _recommendation,
                        enabled: canEdit,
                        onChanged: (items) =>
                            _save(entry.copyWith(recommendations: items)),
                      ),
                  ],
                ),
              ),
              if (canEdit)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isSaving
                              ? null
                              : () => _save(
                                  entry.copyWith(
                                    teacherComment: _comment.text.trim(),
                                  ),
                                ),
                          child: const Text('Save draft'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: FilledButton(
                          onPressed: state.isSaving
                              ? null
                              : () => _save(
                                  entry.copyWith(
                                    teacherComment: _comment.text.trim(),
                                  ),
                                  submit: true,
                                ),
                          child: Text(
                            state.isSaving ? 'Saving...' : 'Submit for review',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
  void _save(ClassReportEntry entry, {bool submit = false}) =>
      context.read<ClassReportsBloc>().add(
        submit
            ? ClassReportEntrySubmitted(entry)
            : ClassReportEntrySaved(entry),
      );
}

class _AcademicNotice extends StatelessWidget {
  const _AcademicNotice();
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Academic performance',
    child: const Text(
      'Approved subject marks, grades, totals, positions and averages are read-only here and remain with the Report Card Engine.',
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: AppSpacing.l),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.s),
          child,
        ],
      ),
    ),
  );
}

class _CompetencyForm extends StatelessWidget {
  const _CompetencyForm({
    required this.entry,
    required this.profile,
    required this.enabled,
    required this.onChanged,
  });
  final ClassReportEntry entry;
  final ReportProfile profile;
  final bool enabled;
  final ValueChanged<List<CompetencyEntry>> onChanged;
  @override
  Widget build(BuildContext context) {
    final items = profile.competencyDomains
        .map(
          (d) =>
              entry.competencies.where((x) => x.domainId == d.id).firstOrNull ??
              CompetencyEntry(domainId: d.id, domainLabel: d.label),
        )
        .toList();
    return _Section(
      title: 'Competencies',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: item.levelCode,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: item.domainLabel),
                  items: profile.competencyLevels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level.code,
                          child: Text(
                            level.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: enabled
                      ? (value) {
                          final next = [...items];
                          next[items.indexOf(item)] = item.copyWith(
                            levelCode: value,
                          );
                          onChanged(next);
                        }
                      : null,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ConductForm extends StatelessWidget {
  const _ConductForm({
    required this.entry,
    required this.profile,
    required this.enabled,
    required this.onChanged,
  });
  final ClassReportEntry entry;
  final ReportProfile profile;
  final bool enabled;
  final void Function(List<ConductEntry>, String?) onChanged;
  @override
  Widget build(BuildContext context) {
    final items = profile.conductCriteria
        .map(
          (c) =>
              entry.conduct.where((x) => x.criterionId == c.id).firstOrNull ??
              ConductEntry(criterionId: c.id, criterionLabel: c.label),
        )
        .toList();
    return _Section(
      title: 'Behaviour & conduct',
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: item.ratingCode,
                isExpanded: true,
                decoration: InputDecoration(labelText: item.criterionLabel),
                items: profile.conductRatings
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.code,
                        child: Text(r.label, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: enabled
                    ? (value) {
                        final next = [...items];
                        next[items.indexOf(item)] = item.copyWith(
                          ratingCode: value,
                        );
                        onChanged(next, entry.overallConductCode);
                      }
                    : null,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: entry.overallConductCode,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Overall conduct'),
            items: profile.conductRatings
                .map(
                  (r) => DropdownMenuItem(value: r.code, child: Text(r.label)),
                )
                .toList(),
            onChanged: enabled ? (value) => onChanged(items, value) : null,
          ),
        ],
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  const _Recommendations({
    required this.entry,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });
  final ClassReportEntry entry;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Recommendations',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...entry.recommendations.map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item),
            trailing: enabled
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => onChanged(
                      entry.recommendations.where((e) => e != item).toList(),
                    ),
                  )
                : null,
          ),
        ),
        if (enabled)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Add recommendation',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  onChanged([...entry.recommendations, text]);
                  controller.clear();
                },
              ),
            ],
          ),
      ],
    ),
  );
}
