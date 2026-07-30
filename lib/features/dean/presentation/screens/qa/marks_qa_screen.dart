import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../domain/entities/assessment_moderation.dart';

class MarksQAScreen extends StatelessWidget {
  const MarksQAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(PendingModerationAssessmentsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marks Quality Assurance'),
        ),
        body: BlocListener<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.read<DeanBloc>().add(PendingModerationAssessmentsRequested());
            }
          },
          child: BlocBuilder<DeanBloc, DeanState>(
            builder: (context, state) {
              if (state is DeanLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PendingModerationAssessmentsLoaded) {
                if (state.assessments.isEmpty) {
                  return const Center(child: Text('No assessments pending moderation.'));
                }
                return _buildAssessmentList(context, state.assessments);
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

  Widget _buildAssessmentList(BuildContext context, List<AssessmentModeration> assessments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assessments.length,
      itemBuilder: (context, index) {
        final assessment = assessments[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(assessment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${assessment.className} • ${assessment.subjectName}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Teacher: ${assessment.teacherName}'),
                    Text('Submissions: ${assessment.submissionCount} / ${assessment.totalStudents}'),
                    Text('Average Score: ${assessment.averageScore.toStringAsFixed(1)}%'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showRejectDialog(context, assessment.assessmentId),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DeanBloc>().add(ApproveAssessmentMarksRequested(assessment.assessmentId));
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

  void _showRejectDialog(BuildContext context, String assessmentId) {
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<DeanBloc>().add(RejectAssessmentMarksRequested(assessmentId, reasonController.text));
              Navigator.pop(dialogContext);
            },
            child: const Text('Submit Rejection', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
