import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_dashboard/subject_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/class_label.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/responsibility_switcher_sheet.dart';

class SubjectTeacherDashboard extends StatefulWidget {
  const SubjectTeacherDashboard({super.key});

  @override
  State<SubjectTeacherDashboard> createState() => _SubjectTeacherDashboardState();
}

class _SubjectTeacherDashboardState extends State<SubjectTeacherDashboard> {
  int _selectedTeachingTab = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<SubjectTeacherContextBloc>().add(
          ContextRequested(
            schoolId: authState.user.schoolId,
            userId: authState.user.id,
          ),
        );
  }

  Future<void> _openSwitcher(SubjectTeacherContextState state) async {
    final chosen = await ResponsibilitySwitcherSheet.show(
      context,
      subjectAssignments: state.subjectAssignments,
      otherResponsibilities: state.otherResponsibilities,
      activeAssignmentId: state.active?.roleAssignmentId,
    );
    if (chosen == null || !mounted) return;
    context.read<SubjectTeacherContextBloc>().add(ContextSwitched(chosen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;

    return BlocConsumer<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      listenWhen: (previous, current) =>
          previous.active?.roleAssignmentId != current.active?.roleAssignmentId ||
          previous.notice != current.notice,
      listener: (context, state) {
        final active = state.active;
        if (active != null) {
          // Every responsibility change reloads the figures, so the previous
          // subject's numbers never linger under the new one.
          context.read<SubjectTeacherDashboardBloc>().add(DashboardRequested(active));
        }
        final notice = state.notice;
        if (notice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(notice)));
          context.read<SubjectTeacherContextBloc>().add(const ContextNoticeCleared());
        }
      },
      builder: (context, contextState) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Custom Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: _buildHeader(user.name, contextState.active),
                  ),
                ),

                if (contextState.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (contextState.unavailableReason != null)
                  SliverFillRemaining(
                    child: _buildUnavailable(contextState),
                  )
                else if (contextState.active != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildMainContextCard(context, contextState),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildTodayLesson(context),
                        const SizedBox(height: 24),
                        _buildMyTeaching(context, contextState),
                        const SizedBox(height: 24),
                        _buildWhatsNext(context),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The states where the panel has nothing to show: no responsibility, one
  /// that has been suspended, or a school with no academic year configured.
  /// Each says which it is, because the fix is different every time.
  Widget _buildUnavailable(SubjectTeacherContextState state) {
    final (icon, title, message) = switch (state.unavailableReason!) {
      ContextUnavailableReason.noAssignments => (
          Icons.school_outlined,
          'No teaching assignments',
          'Your school admin has not assigned you a subject or class yet.',
        ),
      ContextUnavailableReason.assignmentSuspended => (
          Icons.lock_outline,
          'Responsibility suspended',
          state.errorMessage ??
              'This responsibility has been suspended by your school admin.',
        ),
      ContextUnavailableReason.assignmentExpired => (
          Icons.event_busy_outlined,
          'Assignment ended',
          'This responsibility is outside its active dates.',
        ),
      ContextUnavailableReason.noAcademicYear => (
          Icons.calendar_today_outlined,
          'No academic year set',
          'Your school admin needs to set the current academic year before '
              'lessons and marks can be recorded.',
        ),
      ContextUnavailableReason.loadFailed => (
          Icons.cloud_off_outlined,
          'Could not load your panel',
          state.errorMessage ?? 'Something went wrong. Try again.',
        ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      message: message,
      ctaLabel: 'Retry',
      onCtaPressed: _refreshData,
    );
  }

  Widget _buildHeader(String name, ActiveResponsibilityContext? active) {
    return Row(
      children: [
        AvatarInitials(
          name: name,
          size: 48,
          ringColor: AppColors.primary(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                active?.responsibilityLabel ?? 'Subject Teacher',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            color: AppColors.textSecondary(context),
          ),
          onPressed: () {
            final provider = context.read<ThemeProvider>();
            provider.setThemeMode(
              Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary(context)),
          onPressed: () => context.push('/staff/messages'),
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, color: AppColors.textSecondary(context)),
          onPressed: () => context.push('/staff/notifications'),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildMainContextCard(
    BuildContext context,
    SubjectTeacherContextState contextState,
  ) {
    final active = contextState.active!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.functions, color: AppColors.primary(context), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active.subjectName ?? active.roleType.label,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      active.academicSubtitle,
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: contextState.isSwitching
                    ? null
                    : () => _openSwitcher(contextState),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Change Class/Subject',
                        style: TextStyle(color: AppColors.textPrimary(context), fontSize: 10),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary(context), size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.border(context).withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          BlocBuilder<SubjectTeacherDashboardBloc, SubjectTeacherDashboardState>(
            builder: (context, stats) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricItem(
                    'Students Enrolled',
                    _count(stats.studentsEnrolled),
                    'Total',
                    AppColors.primary(context),
                  ),
                  _buildMetricItem(
                    'Present Today',
                    _count(stats.presentToday),
                    _percent(stats.presentPercentage),
                    AppColors.success(context),
                  ),
                  _buildMetricItem(
                    'Absent Today',
                    _count(stats.absentToday),
                    _percent(stats.absentPercentage),
                    AppColors.danger(context),
                  ),
                  _buildMetricItem(
                    'Lessons Today',
                    _count(stats.lessonsToday),
                    'Scheduled',
                    AppColors.warning(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// A tile with nothing behind it yet shows a dash, not a zero. "Attendance
  /// has not been taken" and "nobody turned up" are different facts.
  String _count(int? value) => value?.toString() ?? '–';

  String _percent(double? value) =>
      value == null ? '–' : '${value.round()}%';

  Widget _buildMetricItem(String label, String value, String subValue, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(Icons.people_outline, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 9),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(subValue, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionCard(
          'Take Attendance',
          'Mark students present or absent',
          Icons.how_to_reg,
          AppColors.surfaceElevated(context),
          () => context.push('/staff/attendance'),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          'Enter Marks',
          'Record assessment or exam marks',
          Icons.edit_note,
          AppColors.surfaceElevated(context),
          () => context.push('/staff/marks'),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          'Lesson Notes',
          'Add or view notes for lessons',
          Icons.menu_book,
          AppColors.surfaceElevated(context),
          () => context.push('/staff/lessons'),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary(context), size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted(context), fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayLesson(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Lesson",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/staff/timetable'),
              child: Text(
                'View Timetable',
                style: TextStyle(color: AppColors.primary(context), fontSize: 12),
              ),
            ),
          ],
        ),
        BlocBuilder<SubjectTeacherDashboardBloc, SubjectTeacherDashboardState>(
          builder: (context, stats) {
            final lesson = stats.featuredLesson;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
              ),
              child: lesson == null
                  ? _buildNoLessonRow(context)
                  : _buildLessonRow(context, lesson),
            );
          },
        ),
      ],
    );
  }

  /// The approved lesson card: times on the left, subject and room in the
  /// middle, the action on the right. Everything in it now comes from the
  /// timetable rather than the hardcoded 10:00 Mathematics lesson in Room 12
  /// that every teacher used to see on every day of the year.
  Widget _buildLessonRow(BuildContext context, Lesson lesson) {
    final ongoing = lesson.status == LessonStatus.ongoing;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(lesson.scheduledStart),
              style: TextStyle(
                color: AppColors.primary(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('-', style: TextStyle(color: AppColors.textMuted(context))),
            const SizedBox(height: 4),
            Text(
              _formatTime(lesson.scheduledEnd),
              style: TextStyle(
                color: AppColors.primary(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Container(width: 1, height: 40, color: AppColors.border(context)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      lesson.subjectName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lesson.status.label.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary(context),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [lesson.className, lesson.streamName]
                    .where((e) => e != null && e.isNotEmpty)
                    .join(' '),
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              if (lesson.room != null && lesson.room!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: AppColors.textMuted(context), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      lesson.room!,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => context.push('/staff/lessons/details/${lesson.id}'),
          icon: Icon(ongoing ? Icons.how_to_reg : Icons.play_arrow, size: 18),
          label: Text(
            ongoing ? 'Attendance' : 'Start Lesson',
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  Widget _buildNoLessonRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event_available_outlined, color: AppColors.textMuted(context), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No lesson scheduled',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Nothing on your timetable for this class today.',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyTeaching(BuildContext context, SubjectTeacherContextState state) {
    final subjectClasses = state.currentSubjectClasses;
    final otherSubjects = state.otherSubjectAssignments;
    final classTeacher = state.classTeacherAssignment;

    final items = switch (_selectedTeachingTab) {
      0 => subjectClasses,
      1 => otherSubjects,
      _ => [?classTeacher],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Teaching",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTab('Subject Classes (${subjectClasses.length})', 0),
              _buildTab('Other Subjects (${otherSubjects.length})', 1),
              _buildTab('Class Teacher', 2),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              switch (_selectedTeachingTab) {
                0 => 'No other classes for this subject.',
                1 => 'You teach one subject.',
                _ => 'You are not a class teacher this year.',
              },
              style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
            ),
          )
        else
          ...items.map((a) => _buildTeachingItem(a, state)),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTeachingTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTeachingTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary(context),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeachingItem(
    StaffRoleAssignment assignment,
    SubjectTeacherContextState state,
  ) {
    final className = [assignment.className, assignment.streamName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' ');
    final shortName =
        classInitials(className, fallback: assignment.roleType.label);
    final isActive = assignment.id == state.active?.roleAssignmentId;

    return InkWell(
      onTap: isActive
          ? null
          : () => context
              .read<SubjectTeacherContextBloc>()
              .add(ContextSwitched(assignment.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  shortName,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className.isEmpty ? assignment.displayLabel : className,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    assignment.subjectName ?? assignment.roleType.label,
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
                  ),
                  if (assignment.isSubstitute)
                    Text(
                      'Covering',
                      style: TextStyle(color: AppColors.warning(context), fontSize: 11),
                    ),
                ],
              ),
            ),
            if (isActive)
              Text(
                'Active',
                style: TextStyle(
                  color: AppColors.success(context),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsNext(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "What's Next",
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/staff/lessons'),
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.primary(context), fontSize: 12),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: Text(
            'Nothing due for this class right now.',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
        ),
      ],
    );
  }
}
