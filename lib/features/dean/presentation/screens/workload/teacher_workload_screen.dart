import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

class TeacherWorkloadScreen extends StatelessWidget {
  const TeacherWorkloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(TeacherWorkloadsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Teacher Workload Monitoring')),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is TeacherWorkloadsLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: state.workloads.length,
                itemBuilder: (context, index) {
                  final workload = state.workloads[index];
                  final completionFraction = workload.weeklyLessonsCount > 0
                      ? (workload.lessonsDelivered /
                            workload.weeklyLessonsCount)
                      : 0.0;
                  final completionText = workload.weeklyLessonsCount > 0
                      ? '${(completionFraction * 100).toStringAsFixed(0)}%'
                      : 'N/A';

                  return AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarInitials(
                              name: workload.teacherName,
                              size: 40,
                            ),
                            const SizedBox(width: AppSpacing.l),
                            Expanded(
                              child: Text(
                                workload.teacherName,
                                style: AppTypography.titleSmall,
                              ),
                            ),
                            StatusBadge(
                              label: '${workload.weeklyLessonsCount} hrs/wk',
                              color: AppColors.primary(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.l),
                        LinearProgressIndicator(
                          value: completionFraction,
                          backgroundColor: AppColors.border(context),
                          color: AppColors.success(context),
                          minHeight: 8,
                          borderRadius: AppRadius.small,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lesson Completion: $completionText',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              'Missed: ${workload.lessonsMissed}',
                              style: AppTypography.bodySmall.copyWith(
                                color: workload.lessonsMissed > 0
                                    ? AppColors.danger(context)
                                    : AppColors.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: AppColors.border(context)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _WorkloadMetric(
                              label: 'Assessments',
                              value: '${workload.assessmentsCreated}',
                            ),
                            _WorkloadMetric(
                              label: 'Pending Marks',
                              value: '${workload.marksPending}',
                              color: AppColors.warning(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const EmptyState(
              icon: Icons.assignment_ind,
              title: 'No workload data',
              message: 'No workload data available.',
            );
          },
        ),
      ),
    );
  }
}

class _WorkloadMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _WorkloadMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: color ?? AppColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }
}
