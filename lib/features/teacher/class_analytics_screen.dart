import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
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
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Class Analytics')),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading || state is TeacherInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeacherError) {
            return Center(child: Text(state.message));
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
                    color: semanticColors.success,
                  ),
                  DashboardStatCard(
                    title: 'Classes Today',
                    value: state.classesToday.toDouble(),
                    icon: Icons.class_outlined,
                    color: semanticColors.info,
                  ),
                  DashboardStatCard(
                    title: 'Total Students',
                    value: state.totalStudents.toDouble(),
                    icon: Icons.groups_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  DashboardStatCard(
                    title: 'Submissions Due',
                    value: state.submissionsDue.toDouble(),
                    icon: Icons.pending_actions_outlined,
                    color: semanticColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Class Progress'),
              const SizedBox(height: 12),
              if (state.classProgress.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No class progress data yet.'),
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
                      color: index.isOdd ? semanticColors.info : null,
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
