import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
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
import 'package:school_pulse/features/notifications/domain/entities/alert.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(body: _HomeSkeleton());
        }

        return BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, studentsState) {
            if (studentsState is StudentsInitial) {
              context.read<StudentsBloc>().add(
                FetchStudents(authState.user.studentIds),
              );
              return const Scaffold(body: _HomeSkeleton());
            }

            if (studentsState is StudentsLoading) {
              return const Scaffold(body: _HomeSkeleton());
            }

            if (studentsState is StudentsError) {
              return Scaffold(body: Center(child: Text(studentsState.message)));
            }

            final myStudents = (studentsState as StudentsLoaded).students;

            return BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
              builder: (context, studentState) {
                // Initializing selected student if not already done
                if (studentState is SelectedStudentInitial) {
                  if (myStudents.isNotEmpty) {
                    context.read<SelectedStudentBloc>().add(
                      SelectStudent(myStudents.first),
                    );
                    return const Scaffold(body: _HomeSkeleton());
                  }
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
                  appBar: StudentAppBar(
                    title: 'School Pulse',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // TODO: Implement search
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () => context.push('/parent/notifications'),
                      ),
                    ],
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (myStudents.length > 1) ...[
                        FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: _buildStudentTabs(
                            context,
                            myStudents,
                            selectedStudent.id,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: _buildHeader(context, selectedStudent),
                        ),
                        const SizedBox(height: 24),
                      ],
                      FadeInSlide(
                        delay: const Duration(milliseconds: 300),
                        child: QuickActionGrid(
                          items: [
                            QuickActionItem(
                              label: 'Academics',
                              icon: Icons.school_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              onTap: () => context.push('/parent/academics'),
                            ),
                            QuickActionItem(
                              label: 'Fees',
                              icon: Icons.account_balance_wallet_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                              onTap: () => context.push('/parent/fees'),
                            ),
                            QuickActionItem(
                              label: 'Health',
                              icon: Icons.health_and_safety_outlined,
                              color: semanticColors.info,
                              onTap: () => context.push('/parent/health'),
                            ),
                            QuickActionItem(
                              label: 'Transport',
                              icon: Icons.directions_bus_outlined,
                              color: semanticColors.warning,
                              onTap: () => context.push('/parent/transport'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<NotificationsBloc, NotificationsState>(
                        builder: (context, notificationsState) {
                          if (notificationsState is NotificationsInitial) {
                            final ids = myStudents.map((s) => s.id).toList();
                            context.read<NotificationsBloc>().add(
                              FetchAlerts(ids),
                            );
                            return const SizedBox.shrink();
                          }
                          if (notificationsState is! NotificationsLoaded) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: notificationsState.alerts
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final alert = entry.value;
                                  return FadeInSlide(
                                    delay: Duration(
                                      milliseconds: 400 + (index * 100),
                                    ),
                                    child: AlertBanner(
                                      title: alert.title,
                                      message: alert.message,
                                      color: _getAlertColor(
                                        alert.severity,
                                        semanticColors,
                                      ),
                                      icon: _getAlertIcon(alert.severity),
                                      onDismiss: () {},
                                    ),
                                  );
                                })
                                .toList(),
                          );
                        },
                      ),
                      const FadeInSlide(
                        delay: Duration(milliseconds: 500),
                        child: SectionHeader(title: 'Overview'),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 600),
                        child: _buildStudentSummary(
                          context,
                          selectedStudent,
                          semanticColors,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 700),
                        child: SectionHeader(
                          title: 'Recent Activity',
                          actionLabel: 'See All',
                          onActionPressed: () {},
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 800),
                        child: _buildActivityItem(
                          context,
                          icon: Icons.check_circle_outline,
                          iconColor: semanticColors.success,
                          title: 'Attendance Marked',
                          subtitle: '${selectedStudent.name} is present today',
                          time: '2 hours ago',
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 900),
                        child: _buildActivityItem(
                          context,
                          icon: Icons.assignment_outlined,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          title: 'New Marks Posted',
                          subtitle: 'Mathematics: 85% (Mid-term Assessment)',
                          time: 'Yesterday',
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStudentTabs(
    BuildContext context,
    List<Student> students,
    String selectedId,
  ) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: students.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final student = students[index];
          final isSelected = student.id == selectedId;
          return ChoiceChip(
            label: Text(student.name.split(' ').first),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                context.read<SelectedStudentBloc>().add(SelectStudent(student));
              }
            },
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Student student) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Viewing profile of',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                student.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Hero(
          tag: 'student_avatar_${student.id}',
          child: AvatarInitials(name: student.name, size: 48),
        ),
      ],
    );
  }

  Widget _buildStudentSummary(
    BuildContext context,
    Student student,
    SemanticColors colors,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DashboardStatCard(
              title: 'Attendance',
              value: 94,
              suffix: '%',
              icon: Icons.calendar_today,
              color: colors.success,
              trend: 'Above avg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardStatCard(
              title: 'Fee Balance',
              value: 400,
              suffix: 'k',
              icon: Icons.payments_outlined,
              color: colors.warning,
              trend: 'Due 15th',
              isPositiveTrend: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(time, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60), // Space for status bar/app bar
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(height: 12, width: 100),
                  const SizedBox(height: 8),
                  const Skeleton(height: 24, width: 180),
                ],
              ),
            ),
            const Skeleton(height: 48, width: 48, borderRadius: 24),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(height: 48),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (index) => const Skeleton(height: 80, width: 70),
          ),
        ),
        const SizedBox(height: 32),
        const Skeleton(height: 60),
        const SizedBox(height: 16),
        const Skeleton(height: 24, width: 150),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Skeleton(height: 120)),
            const SizedBox(width: 12),
            const Expanded(child: Skeleton(height: 120)),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(height: 24, width: 150),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 70),
          ),
        ),
      ],
    );
  }
}

Color _getAlertColor(AlertSeverity severity, SemanticColors colors) {
  switch (severity) {
    case AlertSeverity.error:
      return colors.error;
    case AlertSeverity.warning:
      return colors.warning;
    case AlertSeverity.success:
      return colors.success;
    case AlertSeverity.info:
      return colors.info;
  }
}

IconData _getAlertIcon(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.error:
      return Icons.error_outline;
    case AlertSeverity.warning:
      return Icons.warning_amber_rounded;
    case AlertSeverity.success:
      return Icons.check_circle_outline;
    case AlertSeverity.info:
      return Icons.info_outline;
  }
}
