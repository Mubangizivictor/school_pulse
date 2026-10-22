import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_content.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/academic/domain/entities/academic_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/parent/presentation/bloc/parent_timetable_bloc.dart';
import 'package:school_pulse/features/parent/report_card_screen.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_cubit.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/homework.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Tab indices for [AcademicsScreen], so callers deep-linking in (e.g. the
/// Home screen's "View timetable" / "Next lesson" / "Homework" rows) can
/// land on the right tab instead of always opening on Homework.
abstract class AcademicsTab {
  static const homework = 0;
  static const progress = 1;
  static const reportCards = 2;
  static const timetable = 3;
}

class AcademicsScreen extends StatefulWidget {
  final int initialTab;

  const AcademicsScreen({super.key, this.initialTab = AcademicsTab.homework});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ParentTimetableBloc _timetableBloc;
  late final StudentHomeworkBloc _homeworkBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _timetableBloc = di.sl<ParentTimetableBloc>();
    _homeworkBloc = di.sl<StudentHomeworkBloc>();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final selectedStudentState = context.read<SelectedStudentBloc>().state;
      Student? student;

      if (selectedStudentState is SelectedStudentLoaded) {
        student = selectedStudentState.student;
      }

      final studentId = student?.id ?? authState.user.studentIds.firstOrNull;
      if (studentId != null) {
        context.read<AcademicBloc>().add(
          GetAcademicRecordsRequested(studentId: studentId),
        );
        context.read<AcademicBloc>().add(
          GetAttendanceRecordsRequested(studentId: studentId),
        );
      }

      if (student != null && student.classId.isNotEmpty) {
        _timetableBloc.add(
          ParentTimetableRequested(
            schoolId: student.schoolId,
            academicYearId: student.academicYearId,
            classId: student.classId,
            streamId: student.streamId,
          ),
        );
        _homeworkBloc.add(
          LoadStudentHomework(student.schoolId, student.className),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timetableBloc.close();
    _homeworkBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _timetableBloc),
        BlocProvider.value(value: _homeworkBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.background(context),
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Academics',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildSegmentedTabBar(context),
            Expanded(
              child: AppResponsiveContent(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHomeworkTab(),
                    _buildProgressTab(),
                    _buildReportCardsTab(),
                    _buildTimetableTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _tabLabels = [
    'Homework',
    'Progress',
    'Report Cards',
    'Timetable',
  ];

  Widget _buildSegmentedTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final activeIndex = _tabController.index;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _tabLabels.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _SegmentButton(
                    label: _tabLabels[i],
                    isActive: activeIndex == i,
                    onTap: () => _tabController.animateTo(i),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeworkTab() {
    return BlocBuilder<StudentHomeworkBloc, StudentHomeworkState>(
      builder: (context, state) {
        if (state is StudentHomeworkLoading ||
            state is StudentHomeworkInitial) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Skeleton(height: 76, borderRadius: 16),
              SizedBox(height: 12),
              Skeleton(height: 76, borderRadius: 16),
              SizedBox(height: 12),
              Skeleton(height: 76, borderRadius: 16),
            ],
          );
        }

        if (state is StudentHomeworkError) {
          return EmptyState(
            icon: Icons.cloud_off,
            title: 'Could not load homework',
            message: state.message,
          );
        }

        final list = state is StudentHomeworkLoaded
            ? List<Homework>.from(state.homeworkList)
            : <Homework>[];
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.assignment_turned_in_outlined,
            title: 'No homework',
            message: 'No homework has been set for this class yet.',
          );
        }

        final now = DateTime.now();
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final homework = list[index];
            final isOverdue = homework.dueDate.isBefore(
              DateTime(now.year, now.month, now.day),
            );
            return _buildHomeworkItem(
              subject: homework.subject,
              title: homework.title,
              dueDate: DateFormat('EEE, d MMM').format(homework.dueDate),
              isOverdue: isOverdue,
            );
          },
        );
      },
    );
  }

  Widget _buildHomeworkItem({
    required String subject,
    required String title,
    required String dueDate,
    bool isOverdue = false,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverdue ? 'Overdue · was due $dueDate' : 'Due $dueDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: isOverdue
                        ? AppColors.textPrimary(context)
                        : AppColors.grey500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isOverdue
                ? Icons.error_outline_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isOverdue
                ? AppColors.textPrimary(context)
                : AppColors.grey300,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return BlocBuilder<AcademicBloc, AcademicState>(
      builder: (context, state) {
        if (state is AcademicLoading || state is AcademicInitial) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Skeleton(height: 60, borderRadius: 16),
              SizedBox(height: 12),
              Skeleton(height: 60, borderRadius: 16),
              SizedBox(height: 12),
              Skeleton(height: 60, borderRadius: 16),
            ],
          );
        }

        final records = state is AcademicLoaded
            ? state.academicRecords
            : <AcademicRecord>[];

        if (records.isEmpty) {
          return const EmptyState(
            icon: Icons.school_outlined,
            title: 'No results yet',
            message: 'Results will appear here once the school publishes them.',
          );
        }

        final latestTerm = records
            .map((r) => r.term)
            .fold<String>('', (a, b) => b.compareTo(a) > 0 ? b : a);
        final termRecords = records.where((r) => r.term == latestTerm).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              latestTerm.isNotEmpty
                  ? '${latestTerm.toUpperCase()} PERFORMANCE'
                  : 'PERFORMANCE',
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
              showShadow: false,
              child: Column(
                children: [
                  for (var i = 0; i < termRecords.length; i++) ...[
                    if (i > 0) const Divider(height: 32),
                    _buildProgressRow(
                      termRecords[i].subject,
                      (termRecords[i].score / 100).clamp(0.0, 1.0),
                      termRecords[i].grade ?? '—',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'View Full Report Card',
              onPressed: () => _tabController.animateTo(2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportCardsTab() {
    return BlocBuilder<ParentAccessCubit, ParentAccessState>(
      builder: (context, state) {
        final visibility = state is ParentAccessResolved
            ? state.visibility
            : null;
        if (visibility != null && !visibility.reportCard) {
          return const EmptyState(
            icon: Icons.lock_outline,
            title: 'Not available',
            message: 'You do not have access to report cards for this child.',
          );
        }
        return const ParentReportCardBody();
      },
    );
  }

  Widget _buildProgressRow(String subject, double value, String grade) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            subject,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.surfaceContainerHigh(context),
              color: AppColors.textPrimary(context),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          grade,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ],
    );
  }

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String? _selectedDay;

  Widget _buildTimetableTab() {
    return BlocBuilder<ParentTimetableBloc, ParentTimetableState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Skeleton(height: 60, borderRadius: 12),
              SizedBox(height: 12),
              Skeleton(height: 60, borderRadius: 12),
              SizedBox(height: 12),
              Skeleton(height: 60, borderRadius: 12),
            ],
          );
        }

        if (state.errorMessage != null) {
          return EmptyState(
            icon: Icons.cloud_off,
            title: 'Could not load timetable',
            message: state.errorMessage!,
          );
        }

        if (!state.hasPublishedTimetable) {
          return const EmptyState(
            icon: Icons.calendar_view_week_outlined,
            title: 'Timetable not published yet',
            message:
                'Check back once the school publishes this class\'s timetable.',
          );
        }

        final days = state.days.isEmpty
            ? _weekdays.take(6).toList()
            : (List<String>.from(state.days)..sort(
                (a, b) => _weekdays.indexOf(a).compareTo(_weekdays.indexOf(b)),
              ));
        final today = _weekdays[DateTime.now().weekday - 1];
        final selected =
            _selectedDay ?? (days.contains(today) ? today : days.first);
        final entries = state.entriesFor(selected);

        return Column(
          children: [
            const SizedBox(height: 12),
            _buildDaySelector(days, selected),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No lessons scheduled for $selected.',
                        style: const TextStyle(color: AppColors.grey500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: entries.length,
                      itemBuilder: (context, index) =>
                          _buildTimetableItem(entries[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaySelector(List<String> days, String selected) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selected;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textPrimary(context)
                    : AppColors.surfaceContainerHigh(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  day.substring(0, 3).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.background(context)
                        : AppColors.grey500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimetableItem(ParentTimetableEntry entry) {
    final subject = entry.lesson.subjectName.isNotEmpty
        ? entry.lesson.subjectName
        : entry.slot.name;
    final location = entry.lesson.roomName?.isNotEmpty == true
        ? entry.lesson.roomName!
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '${entry.slot.startTime} - ${entry.slot.endTime}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.grey500,
              ),
            ),
          ),
          Container(width: 2, height: 40, color: AppColors.grey200),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (location.isNotEmpty)
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.textPrimary(context)
              : AppColors.surfaceContainerHigh(context),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive
                ? AppColors.background(context)
                : AppColors.textMuted(context),
          ),
        ),
      ),
    );
  }
}
