import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_dashboard_summary.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/routing/class_activity_navigation.dart';

/// Full activity history for the class, one screen deeper than the capped
/// 5-row preview the dashboard shows. Reads the same bloc the dashboard
/// already populated - no separate fetch, since the repository already
/// loads up to 20 entries per [class_dashboard_repository_impl.dart].
class ClassActivitiesScreen extends StatelessWidget {
  const ClassActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Recent Activities')),
      body: BlocBuilder<ClassTeacherDashboardBloc, ClassTeacherDashboardState>(
        builder: (context, state) {
          final activities = state.recentActivities;
          if (activities.isEmpty) {
            return EmptyState(
              icon: Icons.history_outlined,
              title: 'No activity yet',
              message: 'Nothing has happened in your class yet.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: activities.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
            itemBuilder: (context, index) =>
                _ActivityRow(activity: activities[index]),
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ClassActivityEntry activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xl,
      ),
      onTap: () => navigateToClassActivity(context, activity),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconForClassActivity(activity.action),
              color: AppColors.primary(context),
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description.isEmpty
                      ? _relativeTime(activity.occurredAt)
                      : activity.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime when) {
    final difference = DateTime.now().difference(when);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('d MMM').format(when);
  }
}
