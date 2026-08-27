import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_state.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selected = context.read<SelectedStudentBloc>().state;
      if (selected is SelectedStudentLoaded) {
        _fetchStudentData(selected.student.id);
      }
    });
  }

  void _fetchStudentData(String studentId) {
    context.read<AcademicBloc>().add(
      GetAcademicRecordsRequested(studentId: studentId),
    );
    context.read<AcademicBloc>().add(
      GetAttendanceRecordsRequested(studentId: studentId),
    );
    context.read<FinanceBloc>().add(FetchFees(studentId));
  }

  Future<void> _refresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<StudentsBloc>().add(
        FetchStudents(authState.user.studentIds),
      );
      context.read<NotificationsBloc>().add(
        FetchAlerts(authState.user.studentIds),
      );
    }
    final selected = context.read<SelectedStudentBloc>().state;
    if (selected is SelectedStudentLoaded) {
      _fetchStudentData(selected.student.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, studentsState) {
            if (studentsState is StudentsInitial) {
              context.read<StudentsBloc>().add(
                FetchStudents(authState.user.studentIds),
              );
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (studentsState is StudentsLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  _fetchStudentData(state.student.id);
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
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                            _buildSliverAppBar(context, myStudents, selectedStudent),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPulseSection(context),
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
    );
  }

  Widget _buildSliverAppBar(BuildContext context, List<Student> students, Student selected) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'School Pulse',
        style: TextStyle(
          color: AppColors.black,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.black),
          onPressed: () => context.push('/parent/notifications'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: GestureDetector(
            onTap: () => _showStudentSwitcher(context, students, selected),
            child: AvatarInitials(name: selected.name, size: 32),
          ),
        ),
      ],
    );
  }

  void _showStudentSwitcher(BuildContext context, List<Student> students, Student selected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Switch Student',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...students.map((s) => ListTile(
                leading: AvatarInitials(name: s.name, size: 40),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(s.className ?? 'Unknown Class'),
                trailing: s.id == selected.id 
                  ? const Icon(Icons.check_circle, color: AppColors.black)
                  : null,
                onTap: () {
                  context.read<SelectedStudentBloc>().add(SelectStudent(s));
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPulseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DAILY PULSE',
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
          color: AppColors.white,
          showShadow: false,
          child: Column(
            children: [
              _buildPulseItem(
                context,
                icon: Icons.check_circle_outline_rounded,
                title: 'Attendance',
                value: 'Present',
                subtitle: 'Arrived at 7:45 AM',
              ),
              const Divider(height: 32),
              _buildPulseItem(
                context,
                icon: Icons.restaurant_menu_rounded,
                title: 'Lunch',
                value: 'Served',
                subtitle: 'Rice and Beans',
              ),
              const Divider(height: 32),
              _buildPulseItem(
                context,
                icon: Icons.directions_bus_outlined,
                title: 'Transport',
                value: 'En Route',
                subtitle: 'Expected at 4:30 PM',
              ),
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
  }) {
    return Row(
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

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
                icon: Icons.account_balance_wallet_outlined,
                label: 'Pay Fees',
                onTap: () => context.go('/parent/payments'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.assignment_outlined,
                label: 'Homework',
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      showShadow: false,
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.black),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

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
              onPressed: () {},
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
        _buildEventItem(
          context,
          date: 'WED 15',
          title: 'Parent-Teacher Meeting',
          time: '2:00 PM - 4:00 PM',
        ),
        const SizedBox(height: 12),
        _buildEventItem(
          context,
          date: 'FRI 17',
          title: 'Sports Day',
          time: 'All Day Event',
        ),
      ],
    );
  }

  Widget _buildEventItem(
    BuildContext context, {
    required String date,
    required String title,
    required String time,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
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
              date.replaceFirst(' ', '\n'),
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
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey500),
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
