import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/attendance_summary/domain/attendance_summary.dart';
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
    context.read<AcademicBloc>().add(
      GetAcademicRecordsRequested(studentId: studentId),
    );
    context.read<AcademicBloc>().add(
      GetAttendanceRecordsRequested(studentId: studentId),
    );

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
    final config = context.watch<ThemeProvider>().config;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated)
          return const Scaffold(body: Center(child: SchoolPulseLoader()));

        return BlocConsumer<StudentsBloc, StudentsState>(
          listener: (context, state) {
            if (state is StudentsLoaded && state.students.isNotEmpty) {
              final student = state.students.first;
              context.read<SelectedStudentBloc>().add(SelectStudent(student));
              _fetchStudentData(student.id);
            }
          },
          builder: (context, studentsState) {
            if (studentsState is StudentsLoading)
              return const Scaffold(body: Center(child: SchoolPulseLoader()));

            return BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
              builder: (context, selectedState) {
                if (selectedState is! SelectedStudentLoaded) {
                  return const Scaffold(
                    body: Center(child: Text('Loading profile...')),
                  );
                }

                final student = selectedState.student;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Student Portal'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        onPressed: () => context.push('/student/messages'),
                        tooltip: 'Messages',
                      ),
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
                        _buildQuickActions(
                          context,
                          config?.studentPortalConfig,
                        ),
                        const SizedBox(height: 24),
                        _buildAcademicSummary(context),
                        if (config
                                ?.studentPortalConfig
                                .allowSchoolFeeVisibility ??
                            false) ...[
                          const SizedBox(height: 24),
                          _buildFeeSummary(context),
                        ],
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Recent Announcements'),
                        _buildAnnouncements(context),
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
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          student.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Class: ${student.classId}',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ID: ${student.studentCode}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, dynamic portalConfig) {
    return QuickActionGrid(
      items: [
        QuickActionItem(
          label: 'Academics',
          icon: Icons.school_outlined,
          color: AppColors.primary(context),
          onTap: () => context.push('/student/academics'),
        ),
        QuickActionItem(
          label: 'Homework',
          icon: Icons.assignment_outlined,
          color: AppColors.secondary(context),
          onTap: () => context.push('/student/homework'),
        ),
        if (portalConfig?.allowTimetableAccess ?? false)
          QuickActionItem(
            label: 'Timetable',
            icon: Icons.calendar_today_outlined,
            color: AppColors.information(context),
            onTap: () => context.push('/student/timetable'),
          ),
        if (portalConfig?.allowDigitalIdCard ?? false)
          QuickActionItem(
            label: 'ID Card',
            icon: Icons.badge_outlined,
            color: AppColors.secondary(context),
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
          color: AppColors.primary(context),
          onTap: () => context.push('/student/library'),
        ),
        QuickActionItem(
          label: 'Transport',
          icon: Icons.directions_bus_outlined,
          color: AppColors.warning(context),
          onTap: () => context.push('/student/transport'),
        ),
      ],
    );
  }

  Widget _buildAcademicSummary(BuildContext context) {
    return BlocBuilder<AcademicBloc, AcademicState>(
      builder: (context, state) {
        double attendanceRate = 0;
        if (state is AcademicLoaded && state.attendanceRecords.isNotEmpty) {
          final summary = AttendanceRateCalculator.summarize(
            state.attendanceRecords.map(
              (r) => classifyStudentStatus(r.status.name),
            ),
          );
          attendanceRate = summary.ratePercent ?? 0;
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 20,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Academic Overview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
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
                      attendanceRate >= 90
                          ? AppColors.success(context)
                          : AppColors.warning(context),
                    ),
                  ),
                  VerticalDivider(color: AppColors.border(context)),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Subjects',
                      '12 Active',
                      AppColors.primary(context),
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

  Widget _buildFeeSummary(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        double balance = 0;
        if (state is FinanceLoaded) {
          balance = state.fees
              .where((f) => f.status != FeeStatus.paid)
              .fold(0.0, (sum, f) => sum + f.amount);
        }

        final statusColor = balance > 0
            ? AppColors.warning(context)
            : AppColors.success(context);

        return AppCard(
          color: statusColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: statusColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fee Balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      balance > 0
                          ? 'UGX ${NumberFormat('#,###').format(balance)}'
                          : 'Fully Paid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (balance > 0)
                TextButton(
                  onPressed: () => context.push('/student/fees'),
                  child: Text(
                    'View Details',
                    style: TextStyle(color: AppColors.primary(context)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncements(BuildContext context) {
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
          children: state.alerts
              .take(3)
              .map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AlertBanner(
                    title: alert.title,
                    message: alert.message,
                    color: _getAlertColor(alert.severity, context),
                    icon: _getAlertIcon(alert.severity),
                    onDismiss:
                        () {}, // Students probably can't dismiss global announcements here
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted(context)),
        ),
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

  Color _getAlertColor(AlertSeverity severity, BuildContext context) {
    switch (severity) {
      case AlertSeverity.error:
        return AppColors.danger(context);
      case AlertSeverity.warning:
        return AppColors.warning(context);
      case AlertSeverity.success:
        return AppColors.success(context);
      case AlertSeverity.info:
        return AppColors.information(context);
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
}
