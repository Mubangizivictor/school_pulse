import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/parent/academics_screen.dart'
    show AcademicsTab;

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_content.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/academic/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/announcements/domain/entities/announcement_entity.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/parent/presentation/bloc/parent_timetable_bloc.dart';
import 'package:school_pulse/features/parent/widgets/child_selector_sheet.dart';
import 'package:school_pulse/features/parent_access/domain/entities/parent_module_visibility.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_cubit.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_state.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event.dart';
import 'package:school_pulse/features/school_calendar/presentation/bloc/school_calendar_bloc.dart';
import 'package:school_pulse/features/school_calendar/presentation/bloc/school_calendar_event.dart';
import 'package:school_pulse/features/school_calendar/presentation/bloc/school_calendar_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/homework.dart';
import 'package:school_pulse/injection_container.dart' as di;

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  late final StudentHomeworkBloc _homeworkBloc;
  late final AnnouncementBloc _announcementBloc;
  late final SchoolCalendarBloc _calendarBloc;
  late final ParentTimetableBloc _timetableBloc;

  @override
  void initState() {
    super.initState();
    _homeworkBloc = di.sl<StudentHomeworkBloc>();
    _announcementBloc = di.sl<AnnouncementBloc>();
    _calendarBloc = di.sl<SchoolCalendarBloc>();
    _timetableBloc = di.sl<ParentTimetableBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selected = context.read<SelectedStudentBloc>().state;
      if (selected is SelectedStudentLoaded) {
        _fetchStudentData(selected.student);
      }
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _fetchSchoolData(authState);
      }
    });
  }

  @override
  void dispose() {
    _homeworkBloc.close();
    _announcementBloc.close();
    _calendarBloc.close();
    _timetableBloc.close();
    super.dispose();
  }

  void _fetchStudentData(Student student) {
    context.read<AcademicBloc>().add(
      GetAcademicRecordsRequested(studentId: student.id),
    );
    context.read<AcademicBloc>().add(
      GetAttendanceRecordsRequested(studentId: student.id),
    );
    if (student.className.isNotEmpty) {
      _homeworkBloc.add(
        LoadStudentHomework(student.schoolId, student.className),
      );
    }
    _timetableBloc.add(
      ParentTimetableRequested(
        schoolId: student.schoolId,
        academicYearId: student.academicYearId,
        classId: student.classId,
        streamId: student.streamId,
      ),
    );
  }

  void _fetchSchoolData(AuthAuthenticated authState) {
    _announcementBloc.add(
      LoadAnnouncementsRequested(
        schoolId: authState.user.schoolId,
        operatorUser: authState.user,
      ),
    );
    _calendarBloc.add(
      LoadCalendarRequested(
        schoolId: authState.user.schoolId,
        operatorUser: authState.user,
      ),
    );
  }

  Future<void> _refresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<StudentsBloc>().add(
        FetchStudents(authState.user.studentIds),
      );
      _fetchSchoolData(authState);
    }
    final selected = context.read<SelectedStudentBloc>().state;
    if (selected is SelectedStudentLoaded) {
      _fetchStudentData(selected.student);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeworkBloc),
        BlocProvider.value(value: _announcementBloc),
        BlocProvider.value(value: _calendarBloc),
        BlocProvider.value(value: _timetableBloc),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return BlocBuilder<StudentsBloc, StudentsState>(
            builder: (context, studentsState) {
              if (studentsState is StudentsInitial) {
                context.read<StudentsBloc>().add(
                  FetchStudents(authState.user.studentIds),
                );
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (studentsState is StudentsLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (studentsState is StudentsError) {
                return Scaffold(
                  body: EmptyState(
                    icon: Icons.cloud_off,
                    title: 'Could not load students',
                    message: studentsState.message,
                    ctaLabel: 'Retry',
                    onCtaPressed: () => context.read<StudentsBloc>().add(
                      FetchStudents(authState.user.studentIds),
                    ),
                  ),
                );
              }

              final myStudents = (studentsState as StudentsLoaded).students;

              return BlocListener<SelectedStudentBloc, SelectedStudentState>(
                listener: (context, state) {
                  if (state is SelectedStudentLoaded) {
                    _fetchStudentData(state.student);
                  }
                },
                child: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
                  builder: (context, studentState) {
                    if (studentState is SelectedStudentInitial) {
                      if (myStudents.isNotEmpty) {
                        context.read<SelectedStudentBloc>().add(
                          SelectStudent(myStudents.first),
                        );
                      }
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (studentState is! SelectedStudentLoaded) {
                      return const Scaffold(
                        body: Center(
                          child: EmptyState(
                            title: 'No Student Selected',
                            message: 'Select a student to view their profile.',
                            icon: Icons.person_off,
                          ),
                        ),
                      );
                    }

                    final selectedStudent = studentState.student;

                    return BlocBuilder<ParentAccessCubit, ParentAccessState>(
                      builder: (context, accessState) {
                        final visibility = accessState is ParentAccessResolved
                            ? accessState.visibility
                            : ParentModuleVisibility.none;

                        return Scaffold(
                          backgroundColor: AppColors.background(context),
                          body: SafeArea(
                            child: RefreshIndicator(
                              onRefresh: _refresh,
                              child: CustomScrollView(
                                slivers: [
                                  _buildSliverAppBar(
                                    context,
                                    authState.user.name,
                                  ),
                                  SliverToBoxAdapter(
                                    child: AppResponsiveContent(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildChildSwitcher(
                                              context,
                                              selectedStudent,
                                            ),
                                            const SizedBox(height: 28),
                                            _buildPulseSection(
                                              context,
                                              selectedStudent,
                                              visibility,
                                            ),
                                            const SizedBox(height: 32),
                                            _buildActionsSection(
                                              context,
                                              visibility,
                                            ),
                                            const SizedBox(height: 32),
                                            _buildWeekSection(context),
                                            const SizedBox(height: 32),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------

  Widget _buildSliverAppBar(BuildContext context, String parentName) {
    final themeProvider = context.watch<ThemeProvider>();
    final firstName = parentName.trim().isEmpty
        ? 'there'
        : parentName.trim().split(RegExp(r'\s+')).first;

    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background(context),
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Good morning, $firstName',
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        const NotificationBellButton(),
        IconButton(
          tooltip: themeProvider.themeMode == ThemeMode.dark
              ? 'Use light theme'
              : 'Use dark theme',
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          onPressed: () => themeProvider.setThemeMode(
            themeProvider.themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Today's pulse
  // ---------------------------------------------------------------------

  Widget _buildChildSwitcher(BuildContext context, Student student) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => ChildSelectorSheet.show(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(context), width: 1.2),
        ),
        child: Row(
          children: [
            AvatarInitials(name: student.name, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.className.isEmpty
                        ? 'Linked student'
                        : student.className,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseSection(
    BuildContext context,
    Student student,
    ParentModuleVisibility visibility,
  ) {
    final rows = <Widget>[
      if (visibility.attendance) _buildAttendanceRow(context, student),
      if (visibility.academics) _buildNextLessonRow(context),
      if (visibility.academics) _buildHomeworkRow(context),
      if (visibility.fees) _buildFeesRow(context, student),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's pulse",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(12),
          color: AppColors.surfaceContainer(context),
          showShadow: false,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  children: [
                    for (final row in rows)
                      SizedBox(
                        width: constraints.maxWidth / 2,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: row,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 12),
              TextButton.icon(
                onPressed: () =>
                    context.go('/parent/learn', extra: AcademicsTab.timetable),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('View full day'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceRow(BuildContext context, Student student) {
    return BlocBuilder<AcademicBloc, AcademicState>(
      builder: (context, state) {
        if (state is AcademicLoading || state is AcademicInitial) {
          return _pulseSkeletonRow(Icons.check_circle_outline_rounded);
        }

        AttendanceRecord? today;
        if (state is AcademicLoaded) {
          final now = DateTime.now();
          for (final record in state.attendanceRecords) {
            if (record.studentId == student.id &&
                record.date.year == now.year &&
                record.date.month == now.month &&
                record.date.day == now.day) {
              today = record;
              break;
            }
          }
        }

        if (today == null) {
          return _buildPulseItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Attendance',
            value: 'Not recorded',
            subtitle: 'No record for today yet',
          );
        }

        final (label, icon, statusColor) = switch (today.status) {
          StudentStatus.present => (
            'At school',
            Icons.check_circle_outline_rounded,
            AppColors.success(context),
          ),
          StudentStatus.absent => (
            'Absent',
            Icons.cancel_outlined,
            AppColors.danger(context),
          ),
          StudentStatus.late => (
            'Late',
            Icons.watch_later_outlined,
            AppColors.warning(context),
          ),
        };

        // AttendanceRecord has no dedicated check-in timestamp field - `date`
        // is the only time-bearing value on the record. Only show a "Since"
        // subtitle when that DateTime actually carries a non-midnight time
        // component, so a date-only record doesn't fabricate a 12:00 AM
        // check-in time.
        final hasTimeComponent = today.date.hour != 0 || today.date.minute != 0;
        final subtitle = hasTimeComponent
            ? 'Since ${DateFormat('h:mm a').format(today.date)}'
            : (today.note.isNotEmpty ? today.note : 'Recorded today');

        return _buildPulseItem(
          context,
          icon: icon,
          title: 'Attendance',
          value: label,
          valueColor: statusColor,
          subtitle: subtitle,
        );
      },
    );
  }

  Widget _buildNextLessonRow(BuildContext context) {
    return BlocBuilder<ParentTimetableBloc, ParentTimetableState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _pulseSkeletonRow(Icons.schedule_rounded);
        }

        if (!state.hasPublishedTimetable) {
          return _buildPulseItem(
            context,
            icon: Icons.schedule_rounded,
            title: 'Next lesson',
            value: '—',
            subtitle: 'Timetable not published yet',
            onTap: () =>
                context.go('/parent/learn', extra: AcademicsTab.timetable),
          );
        }

        final next = nextLessonForNow(state.entries, DateTime.now());
        if (next == null) {
          return _buildPulseItem(
            context,
            icon: Icons.schedule_rounded,
            title: 'Next lesson',
            value: '—',
            subtitle: 'No more lessons today',
            onTap: () =>
                context.go('/parent/learn', extra: AcademicsTab.timetable),
          );
        }

        final subject = next.lesson.subjectName.isNotEmpty
            ? next.lesson.subjectName
            : next.slot.name;

        return _buildPulseItem(
          context,
          icon: Icons.schedule_rounded,
          title: 'Next: $subject · ${next.slot.startTime}',
          value: '',
          subtitle: next.lesson.roomName?.isNotEmpty == true
              ? next.lesson.roomName!
              : next.slot.name,
          onTap: () =>
              context.go('/parent/learn', extra: AcademicsTab.timetable),
          hideValue: true,
        );
      },
    );
  }

  Widget _buildHomeworkRow(BuildContext context) {
    return BlocBuilder<StudentHomeworkBloc, StudentHomeworkState>(
      builder: (context, state) {
        if (state is StudentHomeworkLoading ||
            state is StudentHomeworkInitial) {
          return _pulseSkeletonRow(Icons.assignment_outlined);
        }

        if (state is StudentHomeworkError) {
          return _buildPulseItem(
            context,
            icon: Icons.assignment_outlined,
            title: 'Homework',
            value: '—',
            subtitle: 'Could not load homework',
            onTap: () =>
                context.go('/parent/learn', extra: AcademicsTab.homework),
          );
        }

        final list = state is StudentHomeworkLoaded
            ? state.homeworkList
            : <Homework>[];
        final now = DateTime.now();
        final weekFromNow = now.add(const Duration(days: 7));
        final dueThisWeek = list
            .where(
              (h) => h.dueDate.isAfter(now) && h.dueDate.isBefore(weekFromNow),
            )
            .length;

        return _buildPulseItem(
          context,
          icon: Icons.assignment_outlined,
          title: 'Homework: $dueThisWeek',
          titleSuffix: TextSpan(
            text: ' due this week',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dueThisWeek > 0
                  ? AppColors.warning(context)
                  : AppColors.grey500,
            ),
          ),
          value: '',
          subtitle: 'View and manage',
          onTap: () =>
              context.go('/parent/learn', extra: AcademicsTab.homework),
          hideValue: true,
        );
      },
    );
  }

  Widget _buildFeesRow(BuildContext context, Student student) {
    return StreamBuilder<List<StudentBill>>(
      stream: di.sl<StudentBillingRepository>().watchBills(
        student.schoolId,
        student.id,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _pulseSkeletonRow(Icons.account_balance_wallet_outlined);
        }

        final bills = snapshot.data!;
        final outstanding = bills.where((b) => b.balanceUgx > 0).toList();

        if (outstanding.isEmpty) {
          final isAllPaid = bills.isNotEmpty;
          return _buildPulseItem(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Fees',
            value: bills.isEmpty ? 'No bills yet' : 'All paid',
            valueColor: isAllPaid ? AppColors.success(context) : null,
            subtitle: 'Term fees',
            onTap: () => context.go('/parent/payments'),
          );
        }

        final balance = outstanding.fold<int>(
          0,
          (sum, b) => sum + b.balanceUgx,
        );
        final formattedBalance = NumberFormat.currency(
          symbol: '',
          decimalDigits: 0,
        ).format(balance).trim();

        return _buildPulseItem(
          context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Fees: UGX $formattedBalance',
          titleSuffix: TextSpan(
            text: ' due',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.danger(context),
            ),
          ),
          value: '',
          subtitle: 'Term fees',
          onTap: () => context.go('/parent/payments'),
          hideValue: true,
        );
      },
    );
  }

  Widget _pulseSkeletonRow(IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.grey300),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(height: 12, width: 100),
              SizedBox(height: 6),
              Skeleton(height: 10, width: 70),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPulseItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    VoidCallback? onTap,
    bool hideValue = false,
    InlineSpan? titleSuffix,
    Color? valueColor,
  }) {
    final content = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: title,
                  children: titleSuffix != null ? [titleSuffix] : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ),
        if (!hideValue && value.isNotEmpty) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
        if (onTap != null)
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: content,
    );
  }

  // ---------------------------------------------------------------------
  // Quick actions
  // ---------------------------------------------------------------------

  Widget _buildActionsSection(
    BuildContext context,
    ParentModuleVisibility visibility,
  ) {
    final actions = <Widget>[
      if (visibility.messages)
        _buildActionCard(
          context,
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Message teacher',
          onTap: () => context.go('/parent/messages'),
        ),
      if (visibility.messages)
        _buildActionCard(
          context,
          icon: Icons.report_gmailerrorred_outlined,
          label: 'Report absence',
          // No dedicated "report absence" flow exists yet - messaging
          // the school is the closest real action.
          onTap: () => context.go('/parent/messages'),
        ),
      if (visibility.fees)
        _buildActionCard(
          context,
          icon: Icons.receipt_long_outlined,
          label: 'Payment guide',
          onTap: () => context.push('/parent/payments/how-to-pay'),
        ),
      if (visibility.academics)
        _buildActionCard(
          context,
          icon: Icons.calendar_view_week_outlined,
          label: 'View timetable',
          onTap: () =>
              context.go('/parent/learn', extra: AcademicsTab.timetable),
        ),
      if (visibility.health)
        _buildActionCard(
          context,
          icon: Icons.health_and_safety_outlined,
          label: 'Health visits',
          onTap: () => context.push('/parent/health'),
        ),
      if (visibility.transport)
        _buildActionCard(
          context,
          icon: Icons.directions_bus_outlined,
          label: 'Transport routes',
          onTap: () => context.push('/parent/transport'),
        ),
      if (visibility.security)
        _buildActionCard(
          context,
          icon: Icons.door_front_door_outlined,
          label: 'Gate activity',
          onTap: () => context.push('/parent/security'),
        ),
      if (visibility.academics)
        _buildActionCard(
          context,
          icon: Icons.calendar_month_outlined,
          label: 'School calendar',
          onTap: () => context.push('/parent/calendar'),
        ),
      if (visibility.library)
        _buildActionCard(
          context,
          icon: Icons.library_books_outlined,
          label: 'Library',
          onTap: () => context.push('/parent/library'),
        ),
      if (visibility.appointments)
        _buildActionCard(
          context,
          icon: Icons.event_available_outlined,
          label: 'Appointments',
          onTap: () => context.push('/parent/appointments'),
        ),
      if (visibility.discipline)
        _buildActionCard(
          context,
          icon: Icons.gavel_outlined,
          label: 'Discipline',
          onTap: () => context.push('/parent/discipline'),
        ),
      if (visibility.boarding)
        _buildActionCard(
          context,
          icon: Icons.night_shelter_outlined,
          label: 'Boarding',
          onTap: () => context.push('/parent/boarding'),
        ),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (var i = 0; i < actions.length; i += 2) {
      final hasSecond = i + 1 < actions.length;
      rows.add(
        Row(
          children: [
            Expanded(child: actions[i]),
            if (hasSecond) ...[
              const SizedBox(width: 12),
              Expanded(child: actions[i + 1]),
            ] else
              const Spacer(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School services',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          rows[i],
        ],
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 62,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        showShadow: false,
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary(context)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // This week
  // ---------------------------------------------------------------------

  Widget _buildWeekSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'THIS WEEK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.grey500,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/parent/calendar'),
              child: Text(
                'Full Calendar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, announcementState) {
            return BlocBuilder<SchoolCalendarBloc, SchoolCalendarState>(
              builder: (context, calendarState) {
                final loading =
                    announcementState is AnnouncementLoading ||
                    calendarState is SchoolCalendarLoading;

                if (loading) {
                  return Column(
                    children: const [
                      Skeleton(height: 64, borderRadius: 16),
                      SizedBox(height: 12),
                      Skeleton(height: 64, borderRadius: 16),
                    ],
                  );
                }

                final announcements = announcementState is AnnouncementLoaded
                    ? announcementState.announcements
                          .where(
                            (a) => a.status == AnnouncementStatus.published,
                          )
                          .toList()
                    : <AnnouncementEntity>[];
                announcements.sort(
                  (a, b) => (b.publishedAt ?? b.createdAt).compareTo(
                    a.publishedAt ?? a.createdAt,
                  ),
                );

                final events = calendarState is SchoolCalendarLoaded
                    ? calendarState.events
                          .where(
                            (e) =>
                                !e.archived &&
                                e.startDate.isAfter(DateTime.now()),
                          )
                          .toList()
                    : <CalendarEvent>[];
                events.sort((a, b) => a.startDate.compareTo(b.startDate));

                final topAnnouncements = announcements.take(3).toList();
                final topEvents = events.take(3).toList();

                if (topAnnouncements.isEmpty && topEvents.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nothing new this week.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey500),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final announcement in topAnnouncements) ...[
                      _buildAnnouncementItem(context, announcement),
                      const SizedBox(height: 12),
                    ],
                    for (final event in topEvents) ...[
                      _buildEventItem(context, event),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementItem(
    BuildContext context,
    AnnouncementEntity announcement,
  ) {
    final when = announcement.publishedAt ?? announcement.createdAt;
    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              AnnouncementDetailScreen(announcementId: announcement.id),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 20,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('EEE d MMM').format(when),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, CalendarEvent event) {
    final dateLabel =
        '${DateFormat('EEE').format(event.startDate).toUpperCase()} '
        '${event.startDate.day}';
    final timeLabel = event.allDay
        ? 'All Day Event'
        : '${DateFormat('h:mm a').format(event.startDate)} - '
              '${DateFormat('h:mm a').format(event.endDate)}';

    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
      onTap: () => context.push('/parent/calendar'),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateLabel.replaceFirst(' ', '\n'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
        ],
      ),
    );
  }
}
