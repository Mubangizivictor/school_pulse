import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/parent/presentation/bloc/parent_timetable_bloc.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/homework.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

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
    _tabController = TabController(length: 3, vsync: this);
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
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Learn',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.black,
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.grey500,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Homework'),
              Tab(text: 'Progress'),
              Tab(text: 'Timetable'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHomeworkTab(),
            _buildProgressTab(),
            _buildTimetableTab(),
          ],
        ),
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
                    color: isOverdue ? AppColors.black : AppColors.grey500,
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
            color: isOverdue ? AppColors.black : AppColors.grey300,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'TERM 3 PERFORMANCE',
          style: TextStyle(
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
              _buildProgressRow('Mathematics', 0.85, 'A'),
              const Divider(height: 32),
              _buildProgressRow('English', 0.78, 'B+'),
              const Divider(height: 32),
              _buildProgressRow('Science', 0.92, 'A+'),
              const Divider(height: 32),
              _buildProgressRow('History', 0.65, 'C'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'View Full Report Card',
          onPressed: () => context.push('/parent/learn/report-card'),
        ),
      ],
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
              backgroundColor: AppColors.grey100,
              color: AppColors.black,
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
                color: isSelected ? AppColors.black : AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  day.substring(0, 3).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.grey500,
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
