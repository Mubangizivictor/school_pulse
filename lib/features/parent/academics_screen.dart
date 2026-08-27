import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final selectedStudentState = context.read<SelectedStudentBloc>().state;
      String? studentId;

      if (selectedStudentState is SelectedStudentLoaded) {
        studentId = selectedStudentState.student.id;
      } else {
        studentId = authState.user.studentIds.firstOrNull;
      }

      if (studentId != null) {
        context.read<AcademicBloc>().add(
          GetAcademicRecordsRequested(studentId: studentId),
        );
        context.read<AcademicBloc>().add(
          GetAttendanceRecordsRequested(studentId: studentId),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
    );
  }

  Widget _buildHomeworkTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHomeworkItem(
          subject: 'Mathematics',
          title: 'Algebraic Expressions',
          dueDate: 'Tomorrow',
          status: 'Pending',
        ),
        const SizedBox(height: 12),
        _buildHomeworkItem(
          subject: 'English',
          title: 'Creative Writing - The Lost City',
          dueDate: 'Fri, 17 Nov',
          status: 'Pending',
        ),
        const SizedBox(height: 12),
        _buildHomeworkItem(
          subject: 'Science',
          title: 'Photosynthesis Lab Report',
          dueDate: 'Submitted',
          status: 'Completed',
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildHomeworkItem({
    required String subject,
    required String title,
    required String dueDate,
    required String status,
    bool isCompleted = false,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
      color: isCompleted ? AppColors.grey50 : AppColors.white,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'Done' : 'Due $dueDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted ? AppColors.successLight : AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.grey300)
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.successLight),
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

  Widget _buildTimetableTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'TODAY\'S SCHEDULE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.grey500,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimetableItem('08:00 - 09:30', 'Mathematics', 'Room 204'),
        _buildTimetableItem('09:30 - 10:00', 'Break', 'Cafeteria'),
        _buildTimetableItem('10:00 - 11:30', 'English Literature', 'Main Hall'),
        _buildTimetableItem('11:30 - 13:00', 'Lunch', 'Cafeteria'),
        _buildTimetableItem('13:00 - 14:30', 'Physical Education', 'Sports Field'),
      ],
    );
  }

  Widget _buildTimetableItem(String time, String subject, String location) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.grey500,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 40,
            color: AppColors.grey200,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 13, color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
