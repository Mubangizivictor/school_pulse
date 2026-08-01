import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/shared/boarding/boarding_dashboard_widgets.dart';
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

/// Girls' boarding dashboard. Mirrors the Patron (boys) dashboard exactly -
/// the only difference is the gender the data source scopes every query to.
class MatronDashboardScreen extends StatefulWidget {
  const MatronDashboardScreen({super.key});

  @override
  State<MatronDashboardScreen> createState() => _MatronDashboardScreenState();
}

class _MatronDashboardScreenState extends State<MatronDashboardScreen> {
  String? _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : null;
  }

  void _loadData() {
    final schoolId = _schoolId(context);
    if (schoolId != null) {
      context.read<MatronBloc>().add(WatchDashboardOverview(schoolId));
    }
    context.read<MatronBloc>().add(WatchDormitories());
    context.read<MatronBloc>().add(WatchAnnouncements());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // MatronBloc is provided once at the app root (see main.dart), so this
  // screen's State - and its original stream subscriptions - survive
  // Navigator.push/pop instead of being recreated. Without this,
  // navigating to another matron screen and back leaves the dashboard
  // showing whatever it last rendered before the push, since initState()
  // never runs again. Re-running _loadData() on return keeps it fresh.
  void _openSection(String location) {
    context.push(location).then((_) {
      if (mounted) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.x8l,
            AppSpacing.xl,
            AppSpacing.x4l,
          ),
          children: [
            BoardingDashboardHeader(
              userName: user?.name ?? 'User',
              roleLabel: UserRoleDisplay.name(UserRole.boardingMatron),
              schoolName: user?.schoolName,
              photoUrl: user?.photoUrl,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    tooltip: 'Messages',
                    onPressed: () => context.push('/staff/messages'),
                  ),
                  const NotificationBellButton(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            // 1. Boarding overview strip
            BlocBuilder<MatronBloc, MatronState>(
              buildWhen: (previous, current) => current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded ? state.overview : null;
                return BoardingOverviewCard(
                  isLoading: overview == null,
                  metrics: _buildMetrics(overview, semanticColors),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x3l),

            // 2. Quick Actions
            BoardingSectionHeading(
              title: 'Quick Actions',
              onViewAll: () => _openSection('/staff/matron/reports'),
            ),
            const SizedBox(height: AppSpacing.l),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.x3l),

            // 3. Today's Tasks
            BlocBuilder<MatronBloc, MatronState>(
              buildWhen: (previous, current) => current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded ? state.overview : null;
                if (overview == null) {
                  return const Skeleton(height: 220, borderRadius: 16);
                }
                return BoardingTasksCard(
                  tasks: _buildTasks(overview, semanticColors),
                  onViewAll: () => _openSection('/staff/matron/reports'),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x3l),

            // 4. Urgent Alerts
            BlocBuilder<MatronBloc, MatronState>(
              buildWhen: (previous, current) => current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded ? state.overview : null;
                if (overview == null) {
                  return const Skeleton(height: 140, borderRadius: 16);
                }
                final alerts = _buildAlerts(overview, semanticColors);
                if (alerts.isEmpty) return const SizedBox.shrink();
                return BoardingAlertsCard(
                  alerts: alerts,
                  onViewAll: () => _openSection('/staff/matron/reports'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<BoardingMetric> _buildMetrics(
    MatronDashboardOverview? data,
    SemanticColors semanticColors,
  ) {
    final total = data?.totalStudents ?? 0;

    /// Each state is shown as a share of the roll, as in the reference.
    String? share(int value) {
      if (total == 0) return null;
      return '${(value / total * 100).toStringAsFixed(1)}%';
    }

    return [
      BoardingMetric(
        label: 'Residents',
        icon: Icons.groups_outlined,
        color: Theme.of(context).colorScheme.primary,
        value: total,
        caption: 'Total',
        captionUsesColor: false,
        onTap: () => _openSection('/staff/matron/dorms'),
      ),
      BoardingMetric(
        label: 'Present',
        icon: Icons.check_circle_outline,
        color: semanticColors.success,
        value: data?.studentsPresent ?? 0,
        caption: share(data?.studentsPresent ?? 0),
        onTap: () => _openSection('/staff/matron/attendance'),
      ),
      BoardingMetric(
        label: 'Absent',
        icon: Icons.person_off_outlined,
        color: semanticColors.error,
        value: data?.studentsAbsent ?? 0,
        caption: share(data?.studentsAbsent ?? 0),
        onTap: () => _openSection('/staff/matron/attendance'),
      ),
      BoardingMetric(
        label: 'On Leave',
        icon: Icons.work_outline,
        color: Colors.orange,
        value: data?.studentsOnLeave ?? 0,
        onTap: () => _openSection('/staff/matron/leave'),
      ),
    ];
  }

  /// Today's tasks are derived from the live overview counts rather than a
  /// hand-maintained checklist, so a task disappears once the work behind it
  /// is actually cleared.
  List<BoardingTask> _buildTasks(
    MatronDashboardOverview data,
    SemanticColors semanticColors,
  ) {
    final tasks = <BoardingTask>[];

    tasks.add(BoardingTask(
      title: 'Morning Roll Call',
      timeLabel: data.studentsPresent >= data.totalStudents && data.totalStudents > 0
          ? 'All ${data.totalStudents} boarders accounted for'
          : '${data.totalStudents - data.studentsPresent} still to confirm',
      icon: Icons.how_to_reg_outlined,
      color: semanticColors.success,
      isDone: data.totalStudents > 0 && data.studentsPresent >= data.totalStudents,
      onTap: () => _openSection('/staff/matron/attendance'),
    ));

    tasks.add(BoardingTask(
      title: 'Dorm Inspection',
      timeLabel: '${data.occupiedBeds} / ${data.totalBeds} beds occupied',
      icon: Icons.shield_outlined,
      color: Theme.of(context).colorScheme.primary,
      onTap: () => _openSection('/staff/matron/dorms'),
    ));

    if (data.pendingWelfareConcerns > 0) {
      tasks.add(BoardingTask(
        title: 'Follow up welfare concerns',
        timeLabel: '${data.pendingWelfareConcerns} open concern(s)',
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        onTap: () => _openSection('/staff/matron/welfare'),
      ));
    }

    if (data.pendingLeaveRequests > 0) {
      tasks.add(BoardingTask(
        title: 'Review ${data.pendingLeaveRequests} Leave Request(s)',
        timeLabel: 'Awaiting your approval',
        icon: Icons.exit_to_app,
        color: Colors.deepOrange,
        onTap: () => _openSection('/staff/matron/leave'),
      ));
    }

    if (data.openDisciplineCases > 0) {
      tasks.add(BoardingTask(
        title: 'Open discipline cases',
        timeLabel: '${data.openDisciplineCases} awaiting action',
        icon: Icons.gavel_outlined,
        color: semanticColors.error,
        onTap: () => _openSection('/staff/matron/discipline'),
      ));
    }

    return tasks;
  }

  /// Alerts are derived from the live overview counts, so each one clears
  /// itself once the underlying situation is resolved.
  List<BoardingAlert> _buildAlerts(
    MatronDashboardOverview data,
    SemanticColors semanticColors,
  ) {
    final alerts = <BoardingAlert>[];

    if (data.missingStudentCount > 0) {
      alerts.add(BoardingAlert(
        title: 'Unaccounted',
        detail: '${data.missingStudentCount} boarder(s) missing at roll call',
        icon: Icons.person_search_outlined,
        color: semanticColors.error,
        onTap: () => _openSection('/staff/matron/attendance'),
      ));
    }
    if (data.overdueLeaveCount > 0) {
      alerts.add(BoardingAlert(
        title: 'Leave Expiry',
        detail: '${data.overdueLeaveCount} student(s) overdue from leave',
        icon: Icons.watch_later_outlined,
        color: semanticColors.warning,
        onTap: () => _openSection('/staff/matron/leave'),
      ));
    }
    if (data.studentsInClinic > 0) {
      alerts.add(BoardingAlert(
        title: 'Clinic Review',
        detail: '${data.studentsInClinic} boarder(s) in the clinic today',
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        onTap: () => _openSection('/staff/matron/welfare'),
      ));
    }
    if (data.pendingWelfareConcerns > 0) {
      alerts.add(BoardingAlert(
        title: 'Welfare',
        detail: '${data.pendingWelfareConcerns} open concern(s)',
        icon: Icons.favorite_outline,
        color: Colors.pink,
        onTap: () => _openSection('/staff/matron/welfare'),
      ));
    }
    if (data.openDisciplineCases > 0) {
      alerts.add(BoardingAlert(
        title: 'Discipline',
        detail: '${data.openDisciplineCases} case(s) awaiting action',
        icon: Icons.gavel_outlined,
        color: semanticColors.error,
        onTap: () => _openSection('/staff/matron/discipline'),
      ));
    }
    return alerts;
  }

  Widget _buildQuickActions(BuildContext context) {
    return BoardingQuickActionGrid(
      actions: [
        BoardingQuickAction(
          label: 'Roll Call',
          icon: Icons.assignment_ind_outlined,
          color: Colors.blue,
          onTap: () => _openSection('/staff/matron/attendance'),
        ),
        BoardingQuickAction(
          label: 'Dorm Check',
          icon: Icons.house_outlined,
          color: Colors.green,
          onTap: () => _openSection('/staff/matron/dorms'),
        ),
        BoardingQuickAction(
          label: 'Welfare',
          icon: Icons.favorite_outline,
          color: Colors.purple,
          onTap: () => _openSection('/staff/matron/welfare'),
        ),
        BoardingQuickAction(
          label: 'Leave Requests',
          icon: Icons.exit_to_app,
          color: Colors.deepOrange,
          onTap: () => _openSection('/staff/matron/leave'),
        ),
        BoardingQuickAction(
          label: 'Announcements',
          icon: Icons.campaign_outlined,
          color: Colors.teal,
          onTap: () => _openSection('/staff/matron/communication'),
        ),
        BoardingQuickAction(
          label: 'Reports',
          icon: Icons.bar_chart_outlined,
          color: Colors.purple,
          onTap: () => _openSection('/staff/matron/reports'),
        ),
      ],
    );
  }
}

