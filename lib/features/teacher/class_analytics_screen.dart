import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class ClassAnalyticsScreen extends StatefulWidget {
  const ClassAnalyticsScreen({super.key});

  @override
  State<ClassAnalyticsScreen> createState() => _ClassAnalyticsScreenState();
}

class _ClassAnalyticsScreenState extends State<ClassAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeacherBloc>().add(TeacherDashboardRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Class Analytics',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading || state is TeacherInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeacherError) {
            return Center(child: Text(state.message, style: TextStyle(color: AppColors.textPrimary(context))));
          }
          if (state is! TeacherLoaded) {
            return const SizedBox.shrink();
          }

          final attendanceRate = state.totalStudents > 0 ? state.studentsToday / state.totalStudents : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  DashboardStatCard(
                    title: 'Attendance Rate',
                    value: (attendanceRate * 100),
                    suffix: '%',
                    icon: Icons.how_to_reg_outlined,
                    color: AppColors.success(context),
                  ),
                  DashboardStatCard(
                    title: 'Classes Today',
                    value: state.classesToday.toDouble(),
                    icon: Icons.class_outlined,
                    color: AppColors.information(context),
                  ),
                  DashboardStatCard(
                    title: 'Total Students',
                    value: state.totalStudents.toDouble(),
                    icon: Icons.groups_outlined,
                    color: AppColors.primary(context),
                  ),
                  DashboardStatCard(
                    title: 'Submissions Due',
                    value: state.submissionsDue.toDouble(),
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.warning(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Class Progress'),
              const SizedBox(height: 12),
              if (state.classProgress.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No class progress data yet.',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                )
              else
                ...state.classProgress.asMap().entries.map((entry) {
                  final index = entry.key;
                  final progress = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProgressCard(
                      title: progress.title,
                      progress: progress.progress,
                      subtitle: progress.subtitle,
                      color: index.isOdd ? AppColors.information(context) : AppColors.primary(context),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
