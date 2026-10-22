import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_dashboard_widgets.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_dashboard_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
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

/// Compact, data-backed header for the Class Teacher home. It intentionally
/// keeps the person, active role, placement and term as separate facts.
class _ClassTeacherHomeHeader extends StatelessWidget {
  const _ClassTeacherHomeHeader({required this.active, required this.onSwitch});

  final ActiveResponsibilityContext active;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated && auth.user.name.trim().isNotEmpty
        ? auth.user.name.trim().split(RegExp(r'\s+')).first
        : 'there';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    final placement = [
      active.className,
      active.streamName,
    ].where((value) => value != null && value.isNotEmpty).join(' • ');
    final term = active.termName.isEmpty ? 'Current term' : active.termName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$greeting, $name',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Messages',
              onPressed: () => context.push('/staff/messages'),
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push('/staff/notifications'),
              icon: const Icon(Icons.notifications_none_outlined),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: onSwitch,
          icon: const Icon(Icons.expand_more, size: 18),
          label: Text(
            'Class Teacher${placement.isEmpty ? '' : ' • $placement'}',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$term • ${DateFormat.yMMMMEEEEd().format(DateTime.now())}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _TodayAttendanceCard extends StatelessWidget {
  const _TodayAttendanceCard({required this.state, required this.onOpen});

  final ClassTeacherDashboardState state;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;
    final attendance = summary.attendance;
    final taken = attendance.isSubmitted;
    final metrics = <(String, String, Color)>[
      ('Total', '${summary.totalStudents}', AppColors.textPrimary(context)),
      (
        'Present',
        taken ? '${attendance.presentCount}' : '—',
        AppColors.success(context),
      ),
      (
        'Absent',
        taken ? '${attendance.absentCount}' : '—',
        AppColors.danger(context),
      ),
      (
        'Late',
        taken ? '${attendance.lateCount}' : '—',
        AppColors.warning(context),
      ),
    ];
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s attendance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                taken
                    ? 'Taken${attendance.submittedAt == null ? '' : ' • ${DateFormat.jm().format(attendance.submittedAt!)}'}'
                    : 'Not taken',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: taken
                      ? AppColors.success(context)
                      : AppColors.warning(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: metrics
                .map(
                  (metric) => Expanded(
                    child: Column(
                      children: [
                        Text(
                          metric.$2,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: metric.$3,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          metric.$1,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(height: AppSpacing.x3l),
          TextButton.icon(
            onPressed: onOpen,
            icon: Icon(
              taken ? Icons.visibility_outlined : Icons.how_to_reg_outlined,
            ),
            label: Text(taken ? 'View register' : 'Take attendance'),
          ),
        ],
      ),
    );
  }
}

class _NeedsAttention extends StatelessWidget {
  const _NeedsAttention({
    required this.state,
    required this.onAttendance,
    required this.onMessages,
    required this.onClasswork,
    required this.onReports,
  });
  final ClassTeacherDashboardState state;
  final VoidCallback onAttendance, onMessages, onClasswork, onReports;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;
    final rows = <(String, String, IconData, VoidCallback)>[];
    if (state.attendanceOutstanding) {
      rows.add((
        'Attendance not taken',
        'Record today’s class register',
        Icons.how_to_reg_outlined,
        onAttendance,
      ));
    }
    if (summary.unreadMessages > 0) {
      rows.add((
        'Unread parent messages',
        '${summary.unreadMessages} need a response',
        Icons.chat_outlined,
        onMessages,
      ));
    }
    if (summary.pendingAssignments > 0) {
      rows.add((
        'Classwork due',
        '${summary.pendingAssignments} open item${summary.pendingAssignments == 1 ? '' : 's'}',
        Icons.assignment_outlined,
        onClasswork,
      ));
    }
    if (summary.pendingReports > 0) {
      rows.add((
        'Report comments remaining',
        '${summary.pendingReports} learner${summary.pendingReports == 1 ? '' : 's'} need review',
        Icons.rate_review_outlined,
        onReports,
      ));
    }
    if (summary.pendingBehaviourFollowUps > 0) {
      rows.add((
        'Learners requiring follow-up',
        '${summary.pendingBehaviourFollowUps} open follow-up${summary.pendingBehaviourFollowUps == 1 ? '' : 's'}',
        Icons.follow_the_signs_outlined,
        onMessages,
      ));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs your attention',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.s),
        AppCard(
          child: Column(
            children: rows
                .map(
                  (row) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    leading: Icon(row.$3, color: AppColors.warning(context)),
                    title: Text(row.$1),
                    subtitle: Text(row.$2),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: row.$4,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
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

  Future<void> _openResponsibilitySwitcher() async {
    final state = context.read<ClassTeacherContextBloc>().state;
    // The switcher's "other responsibilities" section is meant to show every
    // role the account holds, including the Class Teacher assignment that is
    // already active - otherwise a single-role account sees an empty sheet
    // with no indication of what its current role even is.
    final chosen = await ResponsibilitySwitcherSheet.show(
      context,
      subjectAssignments: state.subjectAssignments,
      otherResponsibilities: [
        ...state.classAssignments,
        ...state.otherResponsibilities,
      ],
      activeAssignmentId: state.active?.roleAssignmentId,
    );
    if (!mounted || chosen == null) return;
    context.read<ClassTeacherContextBloc>().add(ClassContextSwitched(chosen));
  }

  @override
  Widget build(BuildContext context) {
    return TeacherScaffold(
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

              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _requestContext(forceRefresh: true);
                    context.read<ClassTeacherDashboardBloc>().add(
                      ClassDashboardRequested(active, forceRefresh: true),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.x4l,
                    ),
                    children: [
                      _ClassTeacherHomeHeader(
                        active: active,
                        onSwitch: _openResponsibilitySwitcher,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      _TodayAttendanceCard(
                        state: state,
                        onOpen: () => context.push('/staff/roll-call'),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _NeedsAttention(
                        state: state,
                        onAttendance: () => context.push('/staff/roll-call'),
                        onMessages: () => context.push('/staff/messages'),
                        onClasswork: () => context.go('/staff/classwork'),
                        onReports: () => context.go('/staff/reports'),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildQuickActions(context, active),

                      // Show each content section only when it has something to
                      // show. An empty timetable/feed does not need a heading,
                      // a View All action, or an empty-state card on the home
                      // dashboard.
                      if (state.todaysSchedule.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x3l),
                        _buildSchedule(context, state),
                      ],
                      if (state.recentActivities.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x3l),
                        _buildRecentActivities(context, state),
                      ],
                      const SizedBox(height: AppSpacing.x6l),
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

  Widget _buildQuickActions(
    BuildContext context,
    ActiveResponsibilityContext active,
  ) {
    const blue = Color(0xFF2F80ED);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.m),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 620;
            final actions = [
              (
                Icons.how_to_reg_outlined,
                'Take attendance',
                AppColors.success(context),
                () => context.push('/staff/roll-call'),
              ),
              (
                Icons.note_add_outlined,
                'Add class note',
                blue,
                () => context.push('/staff/students'),
              ),
              (
                Icons.chat_bubble_outline,
                'Message parents',
                AppColors.information(context),
                () => context.push('/staff/messages'),
              ),
              if (active.can(Permission.classHomeworkCreate))
                (
                  Icons.assignment_add,
                  'Create classwork',
                  AppColors.warning(context),
                  () => context.go('/staff/classwork'),
                ),
            ];
            return GridView.count(
              crossAxisCount: wide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.m,
              crossAxisSpacing: AppSpacing.m,
              childAspectRatio: wide ? 1.55 : 1.35,
              children: actions
                  .map(
                    (action) => _ClassTeacherActionCard(
                      icon: action.$1,
                      label: action.$2,
                      color: action.$3,
                      onTap: action.$4,
                    ),
                  )
                  .toList(),
            );
          },
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
          child: Column(
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
        for (var i = 0; i < activities.length && i < 5; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.l),
          _ActivityCard(activity: activities[i]),
        ],
      ],
    );
  }
}

class _ClassTeacherActionCard extends StatelessWidget {
  const _ClassTeacherActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceElevated(context),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
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
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: AppColors.border(context)),
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
