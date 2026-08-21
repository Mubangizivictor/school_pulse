import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
/// each tagged Resolved/Unresolved from the out-of-band resolved map, split
/// into Unresolved/Resolved tabs.
class MissedLessonsScreen extends StatefulWidget {
  const MissedLessonsScreen({super.key});

  @override
  State<MissedLessonsScreen> createState() => _MissedLessonsScreenState();
}

class _MissedLessonsScreenState extends State<MissedLessonsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _locallyResolved = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(MissedLessonsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainer(context),
          title: Text('Missed Lessons', style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is MissedLessonsLoaded) {
              final unresolved = state.lessons
                  .where(
                    (l) =>
                        !(state.resolvedById[l.id] ?? false) &&
                        !_locallyResolved.contains(l.id),
                  )
                  .toList();
              final resolved = state.lessons
                  .where(
                    (l) =>
                        (state.resolvedById[l.id] ?? false) ||
                        _locallyResolved.contains(l.id),
                  )
                  .toList();
              return Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Unresolved (${unresolved.length})'),
                      Tab(text: 'Resolved (${resolved.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _MissedLessonsList(
                          lessons: unresolved,
                          resolved: false,
                          onReschedule: (lesson) =>
                              _showRescheduleSheet(context, lesson),
                        ),
                        _MissedLessonsList(lessons: resolved, resolved: true),
                      ],
                    ),
                  ),
                ],
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

  Future<void> _showRescheduleSheet(
    BuildContext context,
    LessonRecord lesson,
  ) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (newDate == null || !context.mounted) return;
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(lesson.scheduledAt),
    );
    if (newTime == null || !context.mounted) return;

    setState(() => _locallyResolved.add(lesson.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${lesson.subjectName} • ${lesson.className} rescheduled to '
          '${DateFormat('d MMM').format(newDate)} at ${newTime.format(context)}',
        ),
      ),
    );
  }
}

class _MissedLessonsList extends StatelessWidget {
  final List<LessonRecord> lessons;
  final bool resolved;
  final void Function(LessonRecord)? onReschedule;

  const _MissedLessonsList({
    required this.lessons,
    required this.resolved,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return EmptyState(
        icon: resolved ? Icons.history : Icons.check_circle_outline,
        title: resolved ? 'No resolved lessons' : 'No missed lessons',
        message: resolved
            ? 'Resolved missed lessons will appear here.'
            : 'Every scheduled lesson has been delivered.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: lessons.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
      itemBuilder: (context, index) => _MissedLessonCard(
        lesson: lessons[index],
        resolved: resolved,
        onReschedule: onReschedule,
      ),
    );
  }
}

class _MissedLessonCard extends StatelessWidget {
  final LessonRecord lesson;
  final bool resolved;
  final void Function(LessonRecord)? onReschedule;

  const _MissedLessonCard({
    required this.lesson,
    required this.resolved,
    this.onReschedule,
  });

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
          const SizedBox(height: AppSpacing.m),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: AppRadius.small,
            ),
            child: Text(
              lesson.remarks ?? 'No reason provided',
              style: AppTypography.bodySmall.copyWith(
                color: lesson.remarks != null
                    ? AppColors.textMuted(context)
                    : AppColors.textMuted(context).withValues(alpha: 0.6),
                fontStyle: lesson.remarks == null
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          if (!resolved) ...[
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onReschedule == null
                    ? null
                    : () => onReschedule!(lesson),
                child: const Text('Reschedule'),
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
