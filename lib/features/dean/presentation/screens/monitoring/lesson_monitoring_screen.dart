import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/dean/domain/entities/lesson_tracking.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';

class LessonMonitoringScreen extends StatelessWidget {
  const LessonMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(const LessonRecordsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Lesson Monitoring'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LessonRecordsLoaded) {
              if (state.records.isEmpty) {
                return const EmptyState(
                  icon: Icons.history_edu,
                  title: 'No lesson records',
                  message: 'No lesson records found for the selected period.',
                );
              }
              return _buildLessonList(context, state.records);
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initialize monitoring...'));
          },
        ),
      ),
    );
  }

  Widget _buildLessonList(BuildContext context, List<LessonRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.l),
          child: ListTile(
            leading: Icon(
              _statusIcon(record.status),
              color: _statusColor(context, record.status),
            ),
            title: Text(
              '${record.subjectName} - ${record.className}',
              style: AppTypography.titleSmall,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher: ${record.teacherName}',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(record.scheduledAt)}',
                  style: AppTypography.bodySmall,
                ),
                if (record.topicCovered != null)
                  Text(
                    'Topic: ${record.topicCovered}',
                    style: AppTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            trailing: StatusBadge(
              label: record.status.name,
              color: _statusColor(context, record.status),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  IconData _statusIcon(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return Icons.check_circle;
      case LessonStatus.missed:
        return Icons.error;
      case LessonStatus.planned:
        return Icons.schedule;
      case LessonStatus.rescheduled:
        return Icons.swap_horiz;
      case LessonStatus.substituted:
        return Icons.person_outline;
    }
  }

  Color _statusColor(BuildContext context, LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return AppColors.success(context);
      case LessonStatus.missed:
        return AppColors.danger(context);
      case LessonStatus.planned:
        return AppColors.information(context);
      case LessonStatus.rescheduled:
        return AppColors.warning(context);
      case LessonStatus.substituted:
        return AppColors.secondary(context);
    }
  }

  void _showFilterDialog(BuildContext context) {
    // Placeholder for filter logic
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter Lessons', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            // Add date range, teacher, class pickers here
            Text(
              'Filtering options coming soon...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
