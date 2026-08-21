import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_dashboard_widgets.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_dashboard_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/routing/class_activity_navigation.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/responsibility_switcher_sheet.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_ui.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _requestContext();
  }

  void _requestContext({bool forceRefresh = false}) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<ClassTeacherContextBloc>().add(
      ClassContextRequested(
        schoolId: authState.user.schoolId,
        userId: authState.user.id,
        forceRefresh: forceRefresh,
      ),
    );
  }

  Future<void> _openResponsibilitySwitcher(
    ClassTeacherContextState state,
  ) async {
    final chosen = await ResponsibilitySwitcherSheet.show(
      context,
      subjectAssignments: state.subjectAssignments,
      otherResponsibilities: state.otherResponsibilities,
      activeAssignmentId: state.active?.roleAssignmentId,
    );
    if (!mounted || chosen == null) return;
    context.read<ClassTeacherContextBloc>().add(ClassContextSwitched(chosen));
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
      appBar: staffDashboardAppBar(
        context,
        roleLabel: 'Class Teacher',
        actions: [
          BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
            buildWhen: (previous, current) =>
                previous.available != current.available ||
                previous.active?.roleAssignmentId !=
                    current.active?.roleAssignmentId,
            builder: (context, state) {
              if (state.available.length < 2) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Switch active role',
                icon: const Icon(Icons.swap_horiz_rounded),
                onPressed: () => _openResponsibilitySwitcher(state),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ClassTeacherContextBloc, ClassTeacherContextState>(
        listenWhen: (previous, current) =>
            previous.active?.roleAssignmentId !=
                current.active?.roleAssignmentId ||
            previous.notice != current.notice,
        listener: (context, contextState) {
          // A class teacher can switch to a subject responsibility from the
          // same account. Clear class-scoped state first, resolve the subject
          // context, then replace the dashboard location so Back cannot
          // reopen the previous class under the new responsibility.
          if (contextState.handOffTo != null) {
            final auth = context.read<AuthBloc>().state;
            if (contextState.handOffTo ==
                    StaffResponsibilityType.subjectTeacher &&
                auth is AuthAuthenticated) {
              context.read<SubjectTeacherContextBloc>().add(
                ContextRequested(
                  schoolId: auth.user.schoolId,
                  userId: auth.user.id,
                ),
              );
              context.go('/staff/dashboard');
            } else {
              // Responsibility types without a teacher panel are resolved by
              // the staff hub. Do not leave the (now cleared) class panel on
              // screen after a successful switch.
              context.go('/staff/hub');
            }
            context.read<ClassTeacherContextBloc>().add(
              const ClassContextHandOffConsumed(),
            );
            return;
          }
          final active = contextState.active;
          if (active != null) {
            // Every responsibility change reloads the figures, so the previous
            // class's numbers never linger under the new one.
            context.read<ClassTeacherDashboardBloc>().add(
              ClassDashboardRequested(active),
            );
          }
          final notice = contextState.notice;
          if (notice != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(notice)));
            context.read<ClassTeacherContextBloc>().add(
              const ClassContextNoticeCleared(),
            );
          }
        },
        builder: (context, contextState) {
          if (contextState.isLoading) {
            return const _TeacherDashboardSkeleton();
          }

          if (contextState.unavailableReason != null) {
            return _unavailableState(context, contextState);
          }

          final active = contextState.active;
          if (active == null) return const _TeacherDashboardSkeleton();

          return BlocBuilder<
            ClassTeacherDashboardBloc,
            ClassTeacherDashboardState
          >(
            builder: (context, state) {
              if (state.isLoading && !state.hasSummary) {
                return const _TeacherDashboardSkeleton();
              }

              if (!state.hasSummary && state.errorMessage != null) {
                return EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Could not load dashboard',
                  message: state.errorMessage!,
                  ctaLabel: 'Retry',
                  onCtaPressed: () => context
                      .read<ClassTeacherDashboardBloc>()
                      .add(ClassDashboardRequested(active, forceRefresh: true)),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _requestContext(forceRefresh: true);
                  context.read<ClassTeacherDashboardBloc>().add(
                    ClassDashboardRequested(active, forceRefresh: true),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.l,
                    AppSpacing.xl,
                    AppSpacing.x4l,
                  ),
                  children: [
                    // 1. Shared hero summary card
                    StaffHeroSummaryCard(
                      greetingNameFallback: 'Class Teacher',
                      kpis: _buildKpis(context, state),
                      useGlassIconContainers: true,
                    ),
                    const SizedBox(height: AppSpacing.x3l),

                    // 2. Quick Actions
                    const SizedBox(height: 10),
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.x3l),

                    // 3. Today's Schedule
                    _buildSchedule(context, state),
                    const SizedBox(height: AppSpacing.x3l),

                    // 4. Recent Activities
                    _buildRecentActivities(context, state),
                    const SizedBox(height: AppSpacing.x6l),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Each unavailable reason is its own explanation, because the teacher's
  /// next step differs: waiting on an admin, asking for a suspension to be
  /// lifted, or simply retrying.
  Widget _unavailableState(
    BuildContext context,
    ClassTeacherContextState state,
  ) {
    final (icon, title, message) = switch (state.unavailableReason!) {
      ClassContextUnavailableReason.noClassAssignment => (
        Icons.class_outlined,
        'No class assigned',
        'You are not currently the Class Teacher for any class. Your school '
            'administrator assigns this.',
      ),
      ClassContextUnavailableReason.assignmentSuspended => (
        Icons.pause_circle_outline,
        'Class responsibility suspended',
        'Your Class Teacher assignment has been suspended. Contact your '
            'school administrator.',
      ),
      ClassContextUnavailableReason.assignmentExpired => (
        Icons.event_busy_outlined,
        'Class responsibility ended',
        'Your Class Teacher assignment has reached its end date.',
      ),
      ClassContextUnavailableReason.noAcademicYear => (
        Icons.calendar_today_outlined,
        'No academic year set',
        'Your school has not opened an academic year yet. Class work becomes '
            'available once it does.',
      ),
      ClassContextUnavailableReason.loadFailed => (
        Icons.cloud_off,
        'Could not load your class',
        state.errorMessage ?? 'Pull down to retry.',
      ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      message: message,
      ctaLabel: 'Retry',
      onCtaPressed: () => _requestContext(forceRefresh: true),
    );
  }

  List<StaffKpiData> _buildKpis(
    BuildContext context,
    ClassTeacherDashboardState state,
  ) {
    final total = state.totalStudents ?? 0;
    final present = state.presentToday;
    final absent = state.absentToday;

    String share(double? percentage) =>
        percentage == null ? 'Not taken' : '${percentage.toStringAsFixed(1)}%';

    return [
      StaffKpiData(
        title: 'Students',
        valueText: '$total',
        subtitle: 'Total',
        icon: Icons.people_outline,
        color: AppColors.information(context),
        onTap: () => context.push('/staff/students'),
      ),
      StaffKpiData(
        title: 'Present Today',
        valueText: '${present ?? 0}',
        // "Not taken" rather than 0% - an unmarked register and a class with
        // nobody present are different facts.
        subtitle: share(state.presentPercentage),
        icon: Icons.how_to_reg_outlined,
        color: AppColors.success(context),
        onTap: () => context.push('/staff/roll-call'),
      ),
      StaffKpiData(
        title: 'Absent Today',
        valueText: '${absent ?? 0}',
        subtitle: share(state.absentPercentage),
        icon: Icons.person_off_outlined,
        color: AppColors.danger(context),
        onTap: () => context.push('/staff/roll-call'),
      ),
      StaffKpiData(
        title: 'Assignments',
        valueText: '${state.pendingAssignments ?? 0}',
        subtitle: 'Pending',
        icon: Icons.assignment_outlined,
        onTap: () => context.push('/staff/class-tasks'),
        color: AppColors.warning(context),
      ),
    ];
  }

  Widget _buildQuickActions(BuildContext context) {
    return BoardingQuickActionGrid(
      useGlassIconContainers: true,
      actions: [
        BoardingQuickAction(
          label: 'Roll Call',
          icon: Icons.how_to_reg,
          color: AppColors.success(context),
          onTap: () => context.push('/staff/roll-call'),
        ),
        BoardingQuickAction(
          label: 'Submit Marks',
          icon: Icons.edit_note,
          color: AppColors.primary(context),
          onTap: () => context.push('/staff/marks'),
        ),
        BoardingQuickAction(
          label: 'Resources',
          icon: Icons.folder_open,
          color: AppColors.information(context),
          onTap: () => context.push('/staff/resources'),
        ),
      ],
    );
  }

  Widget _buildSchedule(
    BuildContext context,
    ClassTeacherDashboardState state,
  ) {
    final schedule = state.todaysSchedule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoardingSectionHeading(
          title: "Today's Schedule",
          onViewAll: () => context.push('/staff/timetable'),
        ),
        const SizedBox(height: AppSpacing.l),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: schedule.isEmpty
              ? _EmptyRow(
                  icon: Icons.event_available_outlined,
                  message: 'No lessons scheduled for your class today.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < schedule.length; i++) ...[
                      if (i > 0) const Divider(height: AppSpacing.x4l),
                      _ScheduleItem(
                        time: _timeRange(schedule[i]),
                        subject: schedule[i].subjectName.isEmpty
                            ? schedule[i].title
                            : schedule[i].subjectName,
                        classRoom: _lessonSubtitle(schedule[i]),
                        status: schedule[i].status.label,
                        statusColor: _statusColor(context, schedule[i].status),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  static String _timeRange(Lesson lesson) {
    final format = DateFormat('HH:mm');
    return '${format.format(lesson.scheduledStart)} - '
        '${format.format(lesson.scheduledEnd)}';
  }

  /// The room where the timetable gives one, otherwise the class placement -
  /// the line is never left blank.
  static String _lessonSubtitle(Lesson lesson) {
    final room = lesson.room;
    if (room != null && room.isNotEmpty) return room;
    return [
      lesson.className,
      lesson.streamName,
    ].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  static Color _statusColor(BuildContext context, LessonStatus status) =>
      switch (status) {
        LessonStatus.ongoing => AppColors.success(context),
        LessonStatus.completed => AppColors.textMuted(context),
        LessonStatus.cancelled ||
        LessonStatus.missed => AppColors.danger(context),
        LessonStatus.substituted ||
        LessonStatus.rescheduled => AppColors.warning(context),
        _ => AppColors.primary(context),
      };

  Widget _buildRecentActivities(
    BuildContext context,
    ClassTeacherDashboardState state,
  ) {
    final activities = state.recentActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoardingSectionHeading(
          title: 'Recent Activities',
          onViewAll: () => context.push('/staff/activities'),
        ),
        const SizedBox(height: AppSpacing.l),
        if (activities.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: _EmptyRow(
              icon: Icons.history_outlined,
              message: 'Nothing has happened in your class yet.',
            ),
          )
        else
          for (var i = 0; i < activities.length && i < 5; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.l),
            _ActivityCard(activity: activities[i]),
          ],
      ],
    );
  }
}

/// One audit row as the activity feed shows it. Same card shape the approved
/// dashboard used for its single static entry.
class _ActivityCard extends StatelessWidget {
  final ClassActivityEntry activity;

  const _ActivityCard({required this.activity});

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
          _DashboardGlassIcon(
            icon: iconForClassActivity(activity.action),
            color: AppColors.primary(context),
            size: 44,
            iconSize: 22,
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

/// The in-card empty line used where the approved layout keeps its card but
/// has nothing to put in it. Same typography as the rows it replaces.
class _EmptyRow extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyRow({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _DashboardGlassIcon(
          icon: icon,
          color: AppColors.textMuted(context),
          size: 40,
          iconSize: 20,
        ),
        const SizedBox(width: AppSpacing.l),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary(context),
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// The Class Teacher dashboard uses this same translucent surface for every
/// informational icon, keeping icons visible over both light and dark cards.
class _DashboardGlassIcon extends StatelessWidget {
  const _DashboardGlassIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String subject;
  final String classRoom;
  final String status;
  final Color statusColor;

  const _ScheduleItem({
    required this.time,
    required this.subject,
    required this.classRoom,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subject,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                classRoom,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        StatusBadge(label: status, color: statusColor),
      ],
    );
  }
}

class _TeacherDashboardSkeleton extends StatelessWidget {
  const _TeacherDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.x8l,
        AppSpacing.xl,
        AppSpacing.x4l,
      ),
      children: [
        const Skeleton(width: 250, height: 80, borderRadius: 12),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(height: 160, borderRadius: 16),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: AppSpacing.l),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.l,
          crossAxisSpacing: AppSpacing.l,
          childAspectRatio: 1.35,
          children: List.generate(
            6,
            (index) => const Skeleton(borderRadius: 12),
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: AppSpacing.l),
        const Skeleton(height: 180, borderRadius: 16),
        const SizedBox(height: AppSpacing.x3l),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: AppSpacing.l),
        const Skeleton(height: 80, borderRadius: 16),
      ],
    );
  }
}
