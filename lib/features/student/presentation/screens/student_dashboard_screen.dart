import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/academic/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/alert.dart';
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
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.studentId != null) {
        final studentId = authState.user.studentId!;
        context.read<StudentsBloc>().add(FetchStudents([studentId]));
      }
    });
  }

  void _fetchStudentData(String studentId) {
    context.read<AcademicBloc>().add(GetAcademicRecordsRequested(studentId: studentId));
    context.read<AcademicBloc>().add(GetAttendanceRecordsRequested(studentId: studentId));
    
    final systemConfig = context.read<ThemeProvider>().config;
    if (systemConfig?.studentPortalConfig.allowSchoolFeeVisibility ?? false) {
      context.read<FinanceBloc>().add(FetchFees(studentId));
    }
    
    context.read<NotificationsBloc>().add(FetchAlerts([studentId]));
  }

  Future<void> _refresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.studentId != null) {
      _fetchStudentData(authState.user.studentId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final config = context.watch<ThemeProvider>().config;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return BlocConsumer<StudentsBloc, StudentsState>(
          listener: (context, state) {
            if (state is StudentsLoaded && state.students.isNotEmpty) {
              final student = state.students.first;
              context.read<SelectedStudentBloc>().add(SelectStudent(student));
              _fetchStudentData(student.id);
            }
          },
          builder: (context, studentsState) {
            if (studentsState is StudentsLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

            return BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
              builder: (context, selectedState) {
                if (selectedState is! SelectedStudentLoaded) {
                  return const Scaffold(body: Center(child: Text('Loading profile...')));
                }

                final student = selectedState.student;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Student Portal'),
                    actions: [
                      const NotificationBellButton(),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Hero(
                          tag: 'student_avatar_${student.id}',
                          child: AvatarInitials(name: student.name, size: 32),
                        ),
                      ),
                    ],
                  ),
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildWelcomeHeader(context, student),
                        const SizedBox(height: 24),
                        _buildQuickActions(context, semanticColors, config?.studentPortalConfig),
                        const SizedBox(height: 24),
                        _buildAcademicSummary(context, semanticColors),
                        if (config?.studentPortalConfig.allowSchoolFeeVisibility ?? false) ...[
                          const SizedBox(height: 24),
                          _buildFeeSummary(context, semanticColors),
                        ],
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Recent Announcements'),
                        _buildAnnouncements(context, semanticColors),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, Student student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        Text(
          student.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Class: ${student.classId}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ID: ${student.studentCode}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, SemanticColors colors, dynamic portalConfig) {
    return QuickActionGrid(
      items: [
        QuickActionItem(
          label: 'Academics',
          icon: Icons.school_outlined,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.push('/student/academics'),
        ),
        QuickActionItem(
          label: 'Homework',
          icon: Icons.assignment_outlined,
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push('/student/homework'),
        ),
        if (portalConfig?.allowTimetableAccess ?? false)
          QuickActionItem(
            label: 'Timetable',
            icon: Icons.calendar_today_outlined,
            color: colors.info,
            onTap: () => context.push('/student/timetable'),
          ),
        if (portalConfig?.allowDigitalIdCard ?? false)
          QuickActionItem(
            label: 'ID Card',
            icon: Icons.badge_outlined,
            color: colors.warning,
            onTap: () {
               final state = context.read<SelectedStudentBloc>().state;
               if (state is SelectedStudentLoaded) {
                 context.push('/student/id-card', extra: state.student);
               }
            },
          ),
        QuickActionItem(
          label: 'Library',
          icon: Icons.library_books_outlined,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => context.push('/student/library'),
        ),
        QuickActionItem(
          label: 'Transport',
          icon: Icons.directions_bus_outlined,
          color: Colors.orange,
          onTap: () => context.push('/student/transport'),
        ),
      ],
    );
  }

  Widget _buildAcademicSummary(BuildContext context, SemanticColors colors) {
    return BlocBuilder<AcademicBloc, AcademicState>(
      builder: (context, state) {
        double attendanceRate = 0;
        if (state is AcademicLoaded && state.attendanceRecords.isNotEmpty) {
          final presentCount = state.attendanceRecords.where((r) => r.status != StudentStatus.absent).length;
          attendanceRate = presentCount / state.attendanceRecords.length * 100;
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Academic Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Attendance',
                      '${attendanceRate.toStringAsFixed(1)}%',
                      attendanceRate >= 90 ? colors.success : colors.warning,
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Subjects',
                      '12 Active',
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeeSummary(BuildContext context, SemanticColors colors) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        double balance = 0;
        if (state is FinanceLoaded) {
          balance = state.fees.where((f) => f.status != FeeStatus.paid).fold(0.0, (sum, f) => sum + f.amount);
        }

        return AppCard(
          color: balance > 0 ? colors.warning.withValues(alpha: 0.1) : colors.success.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: balance > 0 ? colors.warning : colors.success),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fee Balance', style: TextStyle(fontSize: 12)),
                    Text(
                      balance > 0 ? 'UGX ${NumberFormat('#,###').format(balance)}' : 'Fully Paid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: balance > 0 ? colors.warning : colors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (balance > 0)
                TextButton(
                  onPressed: () => context.push('/student/fees'),
                  child: const Text('View Details'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncements(BuildContext context, SemanticColors colors) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is! NotificationsLoaded || state.alerts.isEmpty) {
          return const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No new announcements'),
              ),
            ),
          );
        }

        return Column(
          children: state.alerts.take(3).map((alert) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AlertBanner(
              title: alert.title,
              message: alert.message,
              color: _getAlertColor(alert.severity, colors),
              icon: _getAlertIcon(alert.severity),
              onDismiss: () {}, // Students probably can't dismiss global announcements here
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(AlertSeverity severity, SemanticColors colors) {
    switch (severity) {
      case AlertSeverity.error: return colors.error;
      case AlertSeverity.warning: return colors.warning;
      case AlertSeverity.success: return colors.success;
      case AlertSeverity.info: return colors.info;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.error: return Icons.error_outline;
      case AlertSeverity.warning: return Icons.warning_amber_rounded;
      case AlertSeverity.success: return Icons.check_circle_outline;
      case AlertSeverity.info: return Icons.info_outline;
    }
  }
}
