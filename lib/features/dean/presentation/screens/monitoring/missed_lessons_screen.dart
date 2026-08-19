import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/lesson_tracking.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Missed Lessons — lists all [LessonRecord]s with [LessonStatus.missed],
/// each tagged Resolved/Unresolved from the out-of-band resolved map.
class MissedLessonsScreen extends StatelessWidget {
  const MissedLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(MissedLessonsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
          title: Text('Missed Lessons', style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is MissedLessonsLoaded) {
              if (state.lessons.isEmpty) {
                return const EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'No missed lessons',
                  message: 'Every scheduled lesson has been delivered.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: state.lessons.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.l),
                itemBuilder: (context, index) {
                  final lesson = state.lessons[index];
                  final resolved = state.resolvedById[lesson.id] ?? false;
                  return _MissedLessonCard(lesson: lesson, resolved: resolved);
                },
              );
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load missed lessons',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _MissedLessonCard extends StatelessWidget {
  final LessonRecord lesson;
  final bool resolved;

  const _MissedLessonCard({required this.lesson, required this.resolved});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${lesson.subjectName} • ${lesson.className}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              StatusBadge(
                label: resolved ? 'Resolved' : 'Unresolved',
                color: resolved
                    ? AppColors.success(context)
                    : AppColors.danger(context),
                icon: resolved ? Icons.check : Icons.priority_high,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                lesson.teacherName,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                _formatDateTime(lesson.scheduledAt),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          if (lesson.remarks != null) ...[
            const SizedBox(height: AppSpacing.m),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: AppRadius.small,
              ),
              child: Text(
                lesson.remarks!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';
  }
}
