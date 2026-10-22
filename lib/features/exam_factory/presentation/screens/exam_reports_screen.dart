import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../domain/entities/exam_factory_entities.dart';
import '../bloc/exam_factory_cubit.dart';
import '../widgets/exam_factory_shell.dart';

/// Cross-cutting summary of the current exam series - question, paper,
/// print and marking counts by status - read entirely from the same
/// streams the rest of the module already uses, so the numbers can never
/// drift from what the individual workspaces show.
class ExamReportsScreen extends StatelessWidget {
  const ExamReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Exam reports',
      backFallback: '/staff/dean/exam-factory',
      child: StreamBuilder<List<ExamQuestion>>(
        stream: cubit.watchQuestions(),
        builder: (context, qSnap) {
          final questions = qSnap.data ?? const <ExamQuestion>[];
          return StreamBuilder<List<ExamPaper>>(
            stream: cubit.watchPapers(),
            builder: (context, pSnap) {
              final papers = pSnap.data ?? const <ExamPaper>[];
              final approvedQuestions = questions
                  .where(
                    (q) =>
                        q.status == ExamQuestionStatus.approved ||
                        q.status == ExamQuestionStatus.usedInPaper,
                  )
                  .length;
              final pendingModeration = questions
                  .where(
                    (q) => const {
                      ExamQuestionStatus.submitted,
                      ExamQuestionStatus.resubmitted,
                      ExamQuestionStatus.underReview,
                    }.contains(q.status),
                  )
                  .length;
              final lockedPapers = papers.where((p) => p.isLocked).length;
              final printedPapers = papers
                  .where(
                    (p) =>
                        p.status == ExamPaperStatus.printed ||
                        p.status == ExamPaperStatus.administered,
                  )
                  .length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  100,
                ),
                children: [
                  Text('Questions', style: AppTypography.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: 'Total',
                          value: '${questions.length}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          label: 'Approved',
                          value: '$approvedQuestions',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          label: 'Pending review',
                          value: '$pendingModeration',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Papers', style: AppTypography.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(label: 'Total', value: '${papers.length}'),
                      ),
                      Expanded(
                        child: _Stat(label: 'Locked', value: '$lockedPapers'),
                      ),
                      Expanded(
                        child: _Stat(label: 'Printed', value: '$printedPapers'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(value, style: AppTypography.titleLarge),
          Text(
            label,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
