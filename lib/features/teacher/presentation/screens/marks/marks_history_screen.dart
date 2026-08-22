import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class MarksHistoryScreen extends StatelessWidget {
  const MarksHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Marks History',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<MarksBloc, MarksState>(
        builder: (context, state) {
          final past =
              state.assessments
                  .where(
                    (a) =>
                        a.status == AssessmentAvailability.submitted ||
                        a.status == AssessmentAvailability.approved ||
                        a.status == AssessmentAvailability.published ||
                        a.status == AssessmentAvailability.locked,
                  )
                  .toList()
                ..sort((a, b) {
                  final ad = a.assessmentDate ?? DateTime(1970);
                  final bd = b.assessmentDate ?? DateTime(1970);
                  return bd.compareTo(ad);
                });

          if (past.isEmpty) {
            return Center(
              child: Text(
                'No submitted assessments yet.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: past.length,
            itemBuilder: (context, index) {
              final assessment = past[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border(context).withValues(alpha: 0.5),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.read<MarksBloc>().add(
                      MarksAssessmentSelected(assessment),
                    );
                    context.push('/staff/marks/summary');
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary(
                            context,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.history,
                          color: AppColors.primary(context),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assessment.title.isEmpty
                                  ? assessment.assessmentTypeName
                                  : assessment.title,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              assessment.assessmentDate == null
                                  ? assessment.assessmentTypeName
                                  : '${assessment.assessmentTypeName} • ${_formatDate(assessment.assessmentDate!)}',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            assessment.status.label,
                            style: TextStyle(
                              color: AppColors.success(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted(context),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
