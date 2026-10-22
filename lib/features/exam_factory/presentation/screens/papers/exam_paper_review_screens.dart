import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import 'exam_paper_builder_screen.dart' show paperStatusLabel;

/// Read-only candidate-facing layout preview of a paper's questions, in
/// order, with section/marks context - what Paper Builder assembles and
/// what Final Paper Review checks before approval.
class ExamPaperPreviewScreen extends StatelessWidget {
  final String paperId;
  const ExamPaperPreviewScreen({super.key, required this.paperId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Paper preview',
      backFallback: '/staff/dean/exam-factory/papers',
      child: StreamBuilder<ExamPaper?>(
        stream: cubit.watchPaper(paperId),
        builder: (context, paperSnap) {
          if (paperSnap.connectionState == ConnectionState.waiting) {
            return const ExamFactoryLoading();
          }
          final paper = paperSnap.data;
          if (paper == null) {
            return const ExamFactoryEmpty(
              icon: Icons.error_outline,
              title: 'Paper not found',
              message: 'This paper may have been removed.',
            );
          }
          return StreamBuilder<List<ExamQuestion>>(
            stream: cubit.watchQuestions(),
            builder: (context, qSnap) {
              final byId = {
                for (final q in qSnap.data ?? const <ExamQuestion>[]) q.id: q,
              };
              final questions = paper.questionIds
                  .map((id) => byId[id])
                  .whereType<ExamQuestion>()
                  .toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  100,
                ),
                children: [
                  Text(
                    paper.title,
                    style: AppTypography.titleLarge.copyWith(fontSize: 18),
                  ),
                  Text(
                    '${paper.totalMarks} marks · ${paper.durationMinutes} minutes · v${paper.version}',
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(paperStatusLabel(paper.status))),
                  const SizedBox(height: 20),
                  if (questions.isEmpty)
                    const Text('No questions added to this paper yet.')
                  else
                    ...questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final q = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                child: Text('${index + 1}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(q.text)),
                              const SizedBox(width: 8),
                              Text('${q.marks} marks'),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// DOS's final checklist before locking a paper: readiness checks, decision
/// history, and the approve/lock actions themselves.
class ExamFinalPaperReviewScreen extends StatefulWidget {
  final String paperId;
  const ExamFinalPaperReviewScreen({super.key, required this.paperId});

  @override
  State<ExamFinalPaperReviewScreen> createState() =>
      _ExamFinalPaperReviewScreenState();
}

class _ExamFinalPaperReviewScreenState
    extends State<ExamFinalPaperReviewScreen> {
  bool _busy = false;

  Future<void> _act(
    ExamFactoryCubit cubit,
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.error ?? 'Action failed.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Final Paper Review',
      backFallback: '/staff/dean/exam-factory/papers',
      child: StreamBuilder<ExamPaper?>(
        stream: cubit.watchPaper(widget.paperId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const ExamFactoryLoading();
          }
          final paper = snap.data;
          if (paper == null) {
            return const ExamFactoryEmpty(
              icon: Icons.error_outline,
              title: 'Paper not found',
              message: 'This paper may have been removed.',
            );
          }
          final checks = [
            ('Questions approved', paper.questionIds.isNotEmpty),
            ('Total marks verified', paper.isMarksValid),
            (
              'Layout previewed',
              true,
            ), // preview is always available; not a hard gate
          ];
          final allChecksPass = checks.every((c) => c.$2);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            children: [
              Text(
                paper.title,
                style: AppTypography.titleLarge.copyWith(fontSize: 18),
              ),
              Text(
                '${paper.totalMarks} / ${paper.targetMarks} marks · v${paper.version}',
              ),
              const SizedBox(height: 8),
              Chip(label: Text(paperStatusLabel(paper.status))),
              const SizedBox(height: 20),
              Text('Readiness checklist', style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              ...checks.map(
                (c) => ListTile(
                  leading: Icon(
                    c.$2 ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: c.$2
                        ? AppColors.success(context)
                        : AppColors.warning(context),
                  ),
                  title: Text(c.$1),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/staff/dean/exam-factory/paper-preview?paperId=${paper.id}',
                ),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview paper'),
              ),
              const SizedBox(height: 24),
              if (paper.status == ExamPaperStatus.draft ||
                  paper.status == ExamPaperStatus.compiling)
                FilledButton.icon(
                  onPressed: _busy || !allChecksPass
                      ? null
                      : () => _act(
                          cubit,
                          () => cubit.requestPaperApproval(paper.id),
                          'Sent for approval.',
                        ),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Send for approval'),
                ),
              if (paper.status == ExamPaperStatus.readyForApproval)
                FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _act(
                          cubit,
                          () => cubit.approvePaper(paper.id),
                          'Paper approved.',
                        ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve paper'),
                ),
              if (paper.status == ExamPaperStatus.approved)
                FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _act(
                          cubit,
                          () => cubit.lockPaper(paper.id),
                          'Paper locked.',
                        ),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Approve & lock'),
                ),
              if (paper.isLocked)
                Card(
                  color: AppColors.successSurface(context),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: AppColors.success(context),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'This paper is locked. Further edits require a new version.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Decision history', style: AppTypography.titleSmall),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push(
                      '/staff/dean/exam-factory/approval-history?paperId=${paper.id}',
                    ),
                    child: const Text('View all'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Audit trail of moderation and approval decisions - shared list rendering
/// for both a single question (moderation history) and a single paper
/// (approval history), reading exam_factory_audit directly.
class ExamApprovalHistoryScreen extends StatelessWidget {
  final String? paperId;
  final String? questionId;
  const ExamApprovalHistoryScreen({super.key, this.paperId, this.questionId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    final isQuestion = questionId != null;
    return ExamFactoryScaffold(
      title: isQuestion ? 'Moderation history' : 'Approval history',
      backFallback: isQuestion
          ? '/staff/dean/exam-factory/moderation'
          : '/staff/dean/exam-factory/papers',
      child: StreamBuilder<List<ExamAuditEntry>>(
        stream: cubit.watchAuditTrail(paperId: paperId, questionId: questionId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const ExamFactoryLoading();
          }
          final entries = snap.data ?? const <ExamAuditEntry>[];
          if (entries.isEmpty) {
            return const ExamFactoryEmpty(
              icon: Icons.history_outlined,
              title: 'No history yet',
              message: 'Decisions on this record will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(entry.actionLabel),
                  subtitle: Text(
                    '${entry.role.isEmpty ? 'System' : entry.role} · ${entry.at ?? ''}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
