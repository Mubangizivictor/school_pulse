import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';
import 'package:school_pulse/features/academic/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/attendance_summary/domain/attendance_summary.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
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
import 'package:school_pulse/features/parent_access/domain/entities/parent_module_visibility.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_cubit.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_state.dart';

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
                    appBar: const StudentAppBar(title: 'School Pulse'),
                    body: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                            child:
                                BlocBuilder<
                                  ParentAccessCubit,
                                  ParentAccessState
                                >(
                                  builder: (context, accessState) {
                                    final visibility =
                                        accessState is ParentAccessResolved
                                        ? accessState.visibility
                                        : ParentModuleVisibility.none;
                                    return QuickActionGrid(
                                      items: _buildQuickActions(
                                        context,
                                        visibility,
                                      ),
                                    );
                                  },
                                ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<NotificationsBloc, NotificationsState>(
                            builder: (context, notificationsState) {
                              if (notificationsState is NotificationsInitial) {
                                final ids = myStudents
                                    .map((s) => s.id)
                                    .toList();
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
                                            context,
                                          ),
                                          icon: _getAlertIcon(alert.severity),
                                          onDismiss: () {
                                            final authState = context
                                                .read<AuthBloc>()
                                                .state;
                                            if (authState is! AuthAuthenticated)
                                              return;
                                            context
                                                .read<NotificationsBloc>()
                                                .add(
                                                  DismissAlert(
                                                    alert.id,
                                                    authState.user.id,
                                                  ),
                                                );
                                          },
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
                            ),
                          ),
                          FadeInSlide(
                            delay: const Duration(milliseconds: 700),
                            child: SectionHeader(
                              title: 'Recent Activity',
                              actionLabel: 'See All',
                              onActionPressed: () =>
                                  context.push('/parent/notifications'),
                            ),
                          ),
                          FadeInSlide(
                            delay: const Duration(milliseconds: 800),
                            child: _buildRecentActivity(
                              context,
                              selectedStudent,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
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

  List<QuickActionItem> _buildQuickActions(
    BuildContext context,
    ParentModuleVisibility visibility,
  ) {
    return [
      if (visibility.academics)
        QuickActionItem(
          label: 'Academics',
          icon: Icons.school_outlined,
          color: AppColors.primary(context),
          onTap: () => context.push('/parent/academics'),
        ),
      if (visibility.fees)
        QuickActionItem(
          label: 'Fees',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.secondary(context),
          onTap: () => context.push('/parent/fees'),
        ),
      if (visibility.health)
        QuickActionItem(
          label: 'Health',
          icon: Icons.health_and_safety_outlined,
          color: AppColors.information(context),
          onTap: () => context.push('/parent/health'),
        ),
      if (visibility.transport)
        QuickActionItem(
          label: 'Transport',
          icon: Icons.directions_bus_outlined,
          color: AppColors.warning(context),
          onTap: () => context.push('/parent/transport'),
        ),
      if (visibility.library)
        QuickActionItem(
          label: 'Library',
          icon: Icons.library_books_outlined,
          color: AppColors.primaryStrong(context),
          onTap: () => context.push('/parent/library'),
        ),
      if (visibility.discipline)
        QuickActionItem(
          label: 'Discipline',
          icon: Icons.gavel_outlined,
          color: AppColors.danger(context),
          onTap: () => context.push('/parent/discipline'),
        ),
      if (visibility.boarding)
        QuickActionItem(
          label: 'Boarding',
          icon: Icons.bed_outlined,
          color: AppColors.primary(context),
          onTap: () => context.push('/parent/boarding'),
        ),
      if (visibility.messages)
        QuickActionItem(
          label: 'Messages',
          icon: Icons.chat_bubble_outline,
          color: AppColors.information(context),
          onTap: () => context.push('/parent/messages'),
        ),
      if (visibility.profile)
        QuickActionItem(
          label: 'Profile',
          icon: Icons.person_outline,
          color: AppColors.textMuted(context),
          onTap: () => context.push('/parent/profile'),
        ),
    ];
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
            selectedColor: AppColors.primary(context),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary(context),
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
                  color: AppColors.textMuted(context),
                ),
              ),
              Text(
                student.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildStudentSummary(BuildContext context, Student student) {
    return BlocBuilder<AcademicBloc, AcademicState>(
      builder: (context, academicState) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, financeState) {
            double attendanceRate = 0;
            String? attendanceTrend;
            if (academicState is AcademicLoaded &&
                academicState.attendanceRecords.isNotEmpty) {
              // Strictly "present" only - late still counts as an absence
              // here, distinct from the student dashboard's more lenient
              // present-or-late reading of the same records. Preserved as
              // its own MarkClassification mapping rather than reusing
              // classifyStudentStatus, which would silently change this
              // screen's existing behaviour.
              final summary = AttendanceRateCalculator.summarize(
                academicState.attendanceRecords.map(
                  (r) => r.status == StudentStatus.present
                      ? MarkClassification.present
                      : MarkClassification.unauthorisedAbsent,
                ),
              );
              attendanceRate = summary.ratePercent ?? 0;
              attendanceTrend = attendanceRate >= 90 ? 'On track' : 'Watch';
            }

            double feeBalance = 0;
            String? feeTrend;
            if (financeState is FinanceLoaded) {
              feeBalance = financeState.fees
                  .where((f) => f.status != FeeStatus.paid)
                  .fold<double>(0, (sum, f) => sum + f.amount);
              feeTrend = feeBalance > 0 ? 'Unpaid' : 'Cleared';
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Attendance',
                      value: attendanceRate,
                      suffix: '%',
                      icon: Icons.calendar_today,
                      color: AppColors.success(context),
                      trend: attendanceTrend,
                      isPositiveTrend: attendanceRate >= 90,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Fee Balance (UGX)',
                      value: feeBalance,
                      icon: Icons.payments_outlined,
                      color: feeBalance > 0
                          ? AppColors.warning(context)
                          : AppColors.success(context),
                      trend: feeTrend,
                      isPositiveTrend: feeBalance <= 0,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context, Student student) {
    return BlocBuilder<AcademicBloc, AcademicState>(
      builder: (context, state) {
        if (state is! AcademicLoaded ||
            (state.attendanceRecords.isEmpty &&
                state.academicRecords.isEmpty)) {
          return AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.disabled(context),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'No recent activity yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final items = <Widget>[];

        if (state.attendanceRecords.isNotEmpty) {
          final latest = state.attendanceRecords.reduce(
            (a, b) => a.date.isAfter(b.date) ? a : b,
          );
          final statusLabel = switch (latest.status) {
            StudentStatus.present => 'was present',
            StudentStatus.absent => 'was absent',
            StudentStatus.late => 'arrived late',
          };
          items.add(
            _buildActivityItem(
              context,
              icon: latest.status == StudentStatus.present
                  ? Icons.check_circle_outline
                  : Icons.event_busy_outlined,
              iconColor: latest.status == StudentStatus.present
                  ? AppColors.success(context)
                  : AppColors.warning(context),
              title: 'Attendance',
              subtitle: '${student.name.split(' ').first} $statusLabel',
              time: DateFormat('d MMM').format(latest.date),
            ),
          );
        }

        if (state.academicRecords.isNotEmpty) {
          final record = state.academicRecords.first;
          items.add(
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildActivityItem(
                context,
                icon: Icons.assignment_outlined,
                iconColor: AppColors.secondary(context),
                title: 'Marks Posted',
                subtitle: '${record.subject}: ${record.score.round()}%',
                time: '${record.term} ${record.year}',
              ),
            ),
          );
        }

        return Column(children: items);
      },
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
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
