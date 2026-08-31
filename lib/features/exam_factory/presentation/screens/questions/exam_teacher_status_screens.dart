import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import 'exam_question_list_screen.dart'
    show questionStatusLabel, questionStatusColor;

/// Teacher's own questions currently sent back with feedback - the subset
/// of My Exam Questions that needs action, surfaced as its own screen so a
/// teacher can jump straight to what to fix.
class ExamChangesRequestedScreen extends StatelessWidget {
  const ExamChangesRequestedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Changes Requested',
      backFallback: '/staff/exam-factory/my-questions',
      child: ExamFactoryStreamView<ExamQuestion>(
        stream: cubit.watchQuestions(
          creatorId: cubit.currentUserId,
          status: ExamQuestionStatus.changesRequested,
        ),
        emptyIcon: Icons.check_circle_outline,
        emptyTitle: 'Nothing to fix',
        emptyMessage: 'Questions sent back with feedback will appear here.',
        builder: (context, items) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            100,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final q = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  q.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: q.moderationComment.isEmpty
                    ? null
                    : Text(
                        q.moderationComment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/staff/exam-factory/edit-question?questionId=${q.id}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Full status history of a teacher's own submissions, across every state -
/// distinct from My Exam Questions' filter chips, which only show current
/// status per question, not the timeline.
class ExamSubmissionHistoryScreen extends StatelessWidget {
  const ExamSubmissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Submission history',
      backFallback: '/staff/exam-factory/my-questions',
      child: ExamFactoryStreamView<ExamQuestion>(
        stream: cubit.watchQuestions(creatorId: cubit.currentUserId),
        emptyIcon: Icons.history_outlined,
        emptyTitle: 'No submissions yet',
        emptyMessage: 'Every question you submit will show its history here.',
        builder: (context, items) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            100,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final q = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  q.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('v${q.version} · ${q.topic}'),
                trailing: Text(
                  questionStatusLabel(q.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: questionStatusColor(context, q.status),
                  ),
                ),
                onTap: () => context.push(
                  '/staff/exam-factory/question-details?questionId=${q.id}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Papers a teacher/marker has entered marks on, for quick navigation back
/// into Mark Entry - the teacher-side counterpart to the DOS Marking
/// Dashboard, scoped to what this marker has actually touched.
class ExamAssignedMarkingScreen extends StatelessWidget {
  const ExamAssignedMarkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Assigned marking',
      backFallback: '/staff/dashboard',
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.fact_check_outlined,
        emptyTitle: 'No marking assigned',
        emptyMessage: 'Papers you are marking will appear here once scheduled.',
        builder: (context, items) {
          final markable = items.where((p) => p.isLocked).toList();
          if (markable.isEmpty) {
            return const ExamFactoryEmpty(
              icon: Icons.fact_check_outlined,
              title: 'No marking assigned',
              message:
                  'Papers you are marking will appear here once scheduled.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            itemCount: markable.length,
            itemBuilder: (context, index) {
              final paper = markable[index];
              return StreamBuilder<List<ExamMarkEntry>>(
                stream: cubit.watchMarkEntries(paperId: paper.id),
                builder: (context, snap) {
                  final entries = (snap.data ?? const <ExamMarkEntry>[])
                      .where((e) => e.enteredAt != null)
                      .toList();
                  if (entries.isEmpty) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(paper.title, style: AppTypography.titleSmall),
                      subtitle: Text('${entries.length} mark(s) entered'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        '/staff/exam-factory/mark-entry?paperId=${paper.id}',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// A marker's own progress across their assigned papers - how many
/// candidates marked vs. remaining, mirroring the DOS Marking Dashboard's
/// counts but scoped to the signed-in marker.
class ExamMarkingProgressScreen extends StatelessWidget {
  const ExamMarkingProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Marking progress',
      backFallback: '/staff/dashboard',
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.trending_up_outlined,
        emptyTitle: 'No marking in progress',
        emptyMessage: 'Progress on papers you mark will appear here.',
        builder: (context, items) {
          final markable = items.where((p) => p.isLocked).toList();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            itemCount: markable.length,
            itemBuilder: (context, index) {
              final paper = markable[index];
              return StreamBuilder<List<ExamMarkEntry>>(
                stream: cubit.watchMarkEntries(paperId: paper.id),
                builder: (context, snap) {
                  final entries = snap.data ?? const <ExamMarkEntry>[];
                  final mine = entries.where((e) => e.enteredAt != null).length;
                  final submitted = entries
                      .where((e) => e.status != MarkEntryStatus.draft)
                      .length;
                  if (entries.isEmpty) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(paper.title, style: AppTypography.titleSmall),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: mine == 0 ? 0 : submitted / mine,
                            backgroundColor: AppColors.border(context),
                          ),
                          const SizedBox(height: 6),
                          Text('$submitted of $mine submitted'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
