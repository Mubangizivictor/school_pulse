import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../domain/entities/assessment_moderation.dart';

class MarksQAScreen extends StatelessWidget {
  const MarksQAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    return BlocProvider(
      create: (context) =>
          sl<DeanBloc>()
            ..add(PendingModerationAssessmentsRequested(schoolId: schoolId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Marks Quality Assurance')),
        body: BlocListener<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<DeanBloc>().add(
                PendingModerationAssessmentsRequested(schoolId: schoolId),
              );
            }
          },
          child: BlocBuilder<DeanBloc, DeanState>(
            builder: (context, state) {
              if (state is DeanLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PendingModerationAssessmentsLoaded) {
                if (state.assessments.isEmpty) {
                  return const EmptyState(
                    icon: Icons.grading,
                    title: 'All caught up',
                    message: 'No assessments pending moderation.',
                  );
                }
                return _buildAssessmentList(
                  context,
                  state.assessments,
                  schoolId,
                );
              } else if (state is DeanError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('Loading moderation list...'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentList(
    BuildContext context,
    List<AssessmentModeration> assessments,
    String schoolId,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: assessments.length,
      itemBuilder: (context, index) {
        final assessment = assessments[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.l),
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            title: Text(assessment.title, style: AppTypography.titleSmall),
            subtitle: Text(
              '${assessment.className} • ${assessment.subjectName}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teacher: ${assessment.teacherName}',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      'Submissions: ${assessment.submissionCount} / ${assessment.totalStudents}',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      'Average Score: ${assessment.averageScore.toStringAsFixed(1)}%',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showRejectDialog(
                            context,
                            schoolId,
                            assessment.assessmentId,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger(context),
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DeanBloc>().add(
                              ApproveAssessmentMarksRequested(
                                schoolId: schoolId,
                                assessmentId: assessment.assessmentId,
                              ),
                            );
                          },
                          child: const Text('Approve & Publish'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    String schoolId,
    String assessmentId,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Marks'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'e.g. Marks distribution seems irregular',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DeanBloc>().add(
                RejectAssessmentMarksRequested(
                  schoolId: schoolId,
                  assessmentId: assessmentId,
                  reason: reasonController.text,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Submit Rejection',
              style: TextStyle(color: AppColors.danger(dialogContext)),
            ),
          ),
        ],
      ),
    );
  }
}
