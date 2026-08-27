import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/academic/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/announcements/domain/entities/announcement_entity.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/parent/presentation/bloc/parent_timetable_bloc.dart';
import 'package:school_pulse/features/parent/widgets/child_selector_sheet.dart';
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
    context.read<FinanceBloc>().add(FetchFees(student.id));
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

                    return Scaffold(
                      backgroundColor: AppColors.white,
                      body: SafeArea(
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          child: CustomScrollView(
                            slivers: [
                              _buildSliverAppBar(
                                context,
                                authState.user.name,
                                myStudents,
                                selectedStudent,
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildPulseSection(
                                        context,
                                        selectedStudent,
                                      ),
                                      const SizedBox(height: 32),
                                      _buildActionsSection(context),
                                      const SizedBox(height: 32),
                                      _buildWeekSection(context),
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildSliverAppBar(
    BuildContext context,
    String parentName,
    List<Student> students,
    Student selected,
  ) {
    final firstName = parentName.trim().isEmpty
        ? 'there'
        : parentName.trim().split(RegExp(r'\s+')).first;

    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Good morning, $firstName',
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        const NotificationBellButton(),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: GestureDetector(
            onTap: () => ChildSelectorSheet.show(context),
            child: SizedBox(
              height: 32,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < students.length && i < 3; i++)
                    Positioned(
                      left: i * 18.0,
                      child: AvatarInitials(
                        name: students[i].name,
                        size: 32,
                        ringColor: students[i].id == selected.id
                            ? AppColors.black
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Today's pulse
  // ---------------------------------------------------------------------

  Widget _buildPulseSection(BuildContext context, Student student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TODAY'S PULSE · ${_firstName(student.name)}",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.grey500,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          color: AppColors.white,
          showShadow: false,
          child: Column(
            children: [
              _buildAttendanceRow(context, student),
              const Divider(height: 32),
              _buildNextLessonRow(context),
              const Divider(height: 32),
              _buildHomeworkRow(context),
              const Divider(height: 32),
              _buildFeesRow(context),
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

        final (label, icon) = switch (today.status) {
          StudentStatus.present => (
            'At school',
            Icons.check_circle_outline_rounded,
          ),
          StudentStatus.absent => ('Absent', Icons.cancel_outlined),
          StudentStatus.late => ('Late', Icons.watch_later_outlined),
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
            onTap: () => context.go('/parent/learn'),
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
            onTap: () => context.go('/parent/learn'),
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
          onTap: () => context.go('/parent/learn'),
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
            onTap: () => context.go('/parent/learn'),
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
          title: 'Homework: $dueThisWeek due this week',
          value: '',
          subtitle: 'View and manage',
          onTap: () => context.go('/parent/learn'),
          hideValue: true,
        );
      },
    );
  }

  Widget _buildFeesRow(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return _pulseSkeletonRow(Icons.account_balance_wallet_outlined);
        }

        final fees = state is FinanceLoaded ? state.fees : <FeeItem>[];
        final unpaid = fees.where((f) => f.status != FeeStatus.paid).toList();

        if (unpaid.isEmpty) {
          return _buildPulseItem(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Fees',
            value: 'All paid',
            subtitle: 'Term fees',
            onTap: () => context.go('/parent/payments'),
          );
        }

        final balance = unpaid.fold<double>(0, (sum, f) => sum + f.amount);
        unpaid.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final earliestDue = unpaid.first.dueDate;
        final formattedBalance = NumberFormat.currency(
          symbol: '',
          decimalDigits: 0,
        ).format(balance).trim();

        return _buildPulseItem(
          context,
          icon: Icons.account_balance_wallet_outlined,
          title:
              'Fees: $formattedBalance due ${DateFormat('d MMM').format(earliestDue)}',
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
  }) {
    final content = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.black),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ),
        if (!hideValue && value.isNotEmpty)
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
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

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.grey500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Message teacher',
                onTap: () => context.go('/parent/messages'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.report_gmailerrorred_outlined,
                label: 'Report absence',
                // No dedicated "report absence" flow exists yet - messaging
                // the school is the closest real action.
                onTap: () => context.go('/parent/messages'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.account_balance_wallet_outlined,
                label: 'Pay fees',
                onTap: () => context.go('/parent/payments'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.calendar_view_week_outlined,
                label: 'View timetable',
                onTap: () => context.go('/parent/learn'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      showShadow: false,
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.black),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
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
              child: const Text(
                'Full Calendar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
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
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              size: 20,
              color: AppColors.black,
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
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateLabel.replaceFirst(' ', '\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                height: 1.2,
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

  String _firstName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
