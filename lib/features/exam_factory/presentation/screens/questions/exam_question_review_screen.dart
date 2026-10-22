import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import 'exam_question_form_screen.dart';
import 'exam_question_list_screen.dart';

/// Moderator/DOS review of a single submitted question: approve, reject or
/// request changes, with a mandatory comment on non-approve decisions.
class ExamQuestionReviewScreen extends StatefulWidget {
  final String questionId;
  final bool readOnly;
  const ExamQuestionReviewScreen({
    super.key,
    required this.questionId,
    this.readOnly = false,
  });

  @override
  State<ExamQuestionReviewScreen> createState() =>
      _ExamQuestionReviewScreenState();
}

class _ExamQuestionReviewScreenState extends State<ExamQuestionReviewScreen> {
  final _commentController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _decide(
    ExamFactoryCubit cubit,
    ExamQuestionStatus decision,
  ) async {
    if (decision != ExamQuestionStatus.approved &&
        _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a comment explaining the decision.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await cubit.moderateQuestion(
        widget.questionId,
        decision,
        comment: _commentController.text.trim(),
        operationId: DateTime.now().microsecondsSinceEpoch.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Question ${questionStatusLabel(decision).toLowerCase()}.',
          ),
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not save this decision.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: widget.readOnly ? 'Question details' : 'Review Question',
      backFallback: '/staff/dean/exam-factory/moderation',
      child: StreamBuilder<ExamQuestion?>(
        stream: cubit.watchQuestion(widget.questionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ExamFactoryLoading();
          }
          final q = snapshot.data;
          if (q == null) {
            return const ExamFactoryEmpty(
              icon: Icons.error_outline,
              title: 'Question not found',
              message: 'This question may have been removed.',
            );
          }
          final canDecide =
              !widget.readOnly &&
              const {
                ExamQuestionStatus.submitted,
                ExamQuestionStatus.resubmitted,
                ExamQuestionStatus.underReview,
              }.contains(q.status);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            children: [
              Chip(label: Text(questionStatusLabel(q.status))),
              const SizedBox(height: 14),
              Text(
                '${q.topic} · ${questionTypeLabel(q.type)} · ${q.marks} marks',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question', style: AppTypography.titleSmall),
                      const SizedBox(height: 8),
                      Text(q.text),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (q.suggestedAnswer.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected answer',
                          style: AppTypography.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(q.suggestedAnswer),
                      ],
                    ),
                  ),
                ),
              if (q.markingGuide.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Marking guide', style: AppTypography.titleSmall),
                        const SizedBox(height: 8),
                        Text(q.markingGuide),
                      ],
                    ),
                  ),
                ),
              ],
              if (q.moderationComment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moderation comments',
                          style: AppTypography.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(q.moderationComment),
                      ],
                    ),
                  ),
                ),
              ],
              if (canDecide) ...[
                const SizedBox(height: 18),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comment (required for changes/rejection)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _decide(
                                cubit,
                                ExamQuestionStatus.changesRequested,
                              ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Request changes'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _decide(cubit, ExamQuestionStatus.approved),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _decide(cubit, ExamQuestionStatus.rejected),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
