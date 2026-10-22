import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import '../../widgets/exam_factory_structure_loader.dart';

enum ExamQuestionListMode { myQuestions, questionBank, moderationQueue }

String questionStatusLabel(ExamQuestionStatus status) => switch (status) {
  ExamQuestionStatus.draft => 'DRAFT',
  ExamQuestionStatus.submitted => 'SUBMITTED',
  ExamQuestionStatus.underReview => 'UNDER REVIEW',
  ExamQuestionStatus.changesRequested => 'CHANGES REQUESTED',
  ExamQuestionStatus.resubmitted => 'RESUBMITTED',
  ExamQuestionStatus.approved => 'APPROVED',
  ExamQuestionStatus.rejected => 'REJECTED',
  ExamQuestionStatus.usedInPaper => 'USED IN PAPER',
  ExamQuestionStatus.archived => 'ARCHIVED',
};

Color questionStatusColor(BuildContext context, ExamQuestionStatus status) =>
    switch (status) {
      ExamQuestionStatus.approved ||
      ExamQuestionStatus.usedInPaper => AppColors.success(context),
      ExamQuestionStatus.rejected => AppColors.danger(context),
      ExamQuestionStatus.changesRequested => AppColors.warning(context),
      ExamQuestionStatus.draft ||
      ExamQuestionStatus.archived => AppColors.textMuted(context),
      _ => AppColors.information(context),
    };

/// Covers My Exam Questions (teacher), Question Bank (DOS) and the
/// Moderation Queue with real Firestore-backed search and filters.
class ExamQuestionListScreen extends StatefulWidget {
  final ExamQuestionListMode mode;
  const ExamQuestionListScreen({super.key, required this.mode});

  @override
  State<ExamQuestionListScreen> createState() => _ExamQuestionListScreenState();
}

class _ExamQuestionListScreenState extends State<ExamQuestionListScreen> {
  String _search = '';
  String? _seriesId;
  String? _classId;
  String? _subjectId;
  ExamQuestionStatus? _status;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    ensureStructureLoaded(
      context,
      context.read<ExamFactoryCubit>().institutionId,
    );
  }

  String get _title => switch (widget.mode) {
    ExamQuestionListMode.myQuestions => 'My Exam Questions',
    ExamQuestionListMode.questionBank => 'Question Bank',
    ExamQuestionListMode.moderationQueue => 'Moderation Queue',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    final isModeration = widget.mode == ExamQuestionListMode.moderationQueue;
    final isMine = widget.mode == ExamQuestionListMode.myQuestions;

    final stream = cubit.watchQuestions(
      seriesId: _seriesId,
      classId: _classId,
      subjectId: _subjectId,
      creatorId: isMine ? cubit.currentUserId : null,
      status: _status ?? (isModeration ? null : null),
    );

    return ExamFactoryScaffold(
      title: _title,
      backFallback: isMine ? '/staff/dashboard' : '/staff/dean/exam-factory',
      action: !isMine && _selected.isNotEmpty
          ? TextButton(
              onPressed: () {
                context.push(
                  '/staff/dean/exam-factory/paper-builder?questionIds=${_selected.join(',')}',
                );
              },
              child: Text('Add ${_selected.length} to paper'),
            )
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              0,
            ),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search question text or topic',
              ),
              onChanged: (v) =>
                  setState(() => _search = v.trim().toLowerCase()),
            ),
          ),
          BlocBuilder<StructureBloc, StructureState>(
            builder: (context, structure) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                10,
                AppSpacing.l,
                0,
              ),
              child: Row(
                children: [
                  StreamBuilder<List<ExamSeries>>(
                    stream: cubit.watchSeries(),
                    builder: (context, snap) => _FilterDropdown<String>(
                      label: 'Series',
                      value: _seriesId,
                      items: {
                        for (final s in snap.data ?? const <ExamSeries>[])
                          s.id: s.name,
                      },
                      onChanged: (v) => setState(() => _seriesId = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterDropdown<String>(
                    label: 'Class',
                    value: _classId,
                    items: {for (final c in structure.classes) c.id: c.name},
                    onChanged: (v) => setState(() => _classId = v),
                  ),
                  const SizedBox(width: 8),
                  _FilterDropdown<String>(
                    label: 'Subject',
                    value: _subjectId,
                    items: {for (final s in structure.subjects) s.id: s.name},
                    onChanged: (v) => setState(() => _subjectId = v),
                  ),
                  const SizedBox(width: 8),
                  _FilterDropdown<ExamQuestionStatus>(
                    label: 'Status',
                    value: _status,
                    items: {
                      for (final s in ExamQuestionStatus.values)
                        s: questionStatusLabel(s),
                    },
                    onChanged: (v) => setState(() => _status = v),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ExamFactoryStreamView<ExamQuestion>(
              stream: stream,
              emptyIcon: Icons.quiz_outlined,
              emptyTitle: isMine
                  ? 'No questions yet'
                  : 'No questions match these filters',
              emptyMessage: isMine
                  ? 'Submit your first question for this exam series.'
                  : 'Try widening the filters or search terms.',
              emptyAction: isMine
                  ? FilledButton.icon(
                      onPressed: () =>
                          context.push('/staff/exam-factory/submit-question'),
                      icon: const Icon(Icons.add),
                      label: const Text('Submit question'),
                    )
                  : null,
              builder: (context, items) {
                final filtered = _search.isEmpty
                    ? items
                    : items
                          .where(
                            (q) =>
                                q.text.toLowerCase().contains(_search) ||
                                q.topic.toLowerCase().contains(_search),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return const ExamFactoryEmpty(
                    icon: Icons.search_off,
                    title: 'No matches',
                    message: 'No questions match your search.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    12,
                    AppSpacing.l,
                    100,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final q = filtered[index];
                    final selectable = !isMine && !isModeration;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: selectable
                            ? Checkbox(
                                value: _selected.contains(q.id),
                                onChanged: (sel) => setState(
                                  () => sel == true
                                      ? _selected.add(q.id)
                                      : _selected.remove(q.id),
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.all(14),
                        title: Text(
                          q.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${q.topic} · ${q.marks} marks · v${q.version}',
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              questionStatusLabel(q.status),
                              style: TextStyle(
                                fontSize: 10,
                                color: questionStatusColor(context, q.status),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          if (isModeration) {
                            context.push(
                              '/staff/dean/exam-factory/review-question?questionId=${q.id}',
                            );
                          } else if (isMine && q.isEditable) {
                            context.push(
                              '/staff/exam-factory/edit-question?questionId=${q.id}',
                            );
                          } else {
                            context.push(
                              '/staff/dean/exam-factory/question-details?questionId=${q.id}',
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T?>(
        value: value,
        hint: Text(label),
        borderRadius: BorderRadius.circular(10),
        items: [
          DropdownMenuItem<T?>(value: null, child: Text('All $label')),
          ...items.entries.map(
            (e) => DropdownMenuItem<T?>(value: e.key, child: Text(e.value)),
          ),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}
