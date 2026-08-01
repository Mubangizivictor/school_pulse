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
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

/// Boys' boarding dashboard. Mirrors the Matron (girls) dashboard exactly -
/// the only difference is the gender the data source scopes every query to.
class PatronDashboard extends StatefulWidget {
  const PatronDashboard({super.key});

  @override
  State<PatronDashboard> createState() => _PatronDashboardState();
}

class _PatronDashboardState extends State<PatronDashboard> {
  String? _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : null;
  }

  void _loadData() {
    final schoolId = _schoolId(context);
    if (schoolId != null) {
      context.read<PatronBloc>().add(WatchDashboardOverview(schoolId));
    }
    context.read<PatronBloc>().add(WatchDormitories());
    context.read<PatronBloc>().add(WatchAnnouncements());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // PatronBloc is provided once at the app root (see main.dart), so this
  // screen's State - and its original stream subscriptions - survive
  // Navigator.push/pop instead of being recreated. Without this,
  // navigating to another patron screen and back leaves the dashboard
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
              roleLabel: UserRoleDisplay.name(UserRole.boardingPatron),
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
            BlocBuilder<PatronBloc, PatronState>(
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
              onViewAll: () => _openSection('/staff/patron/reports'),
            ),
            const SizedBox(height: AppSpacing.l),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.x3l),

            // 3. Today's Tasks
            BlocBuilder<PatronBloc, PatronState>(
              buildWhen: (previous, current) => current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded ? state.overview : null;
                if (overview == null) {
                  return const Skeleton(height: 220, borderRadius: 16);
                }
                return BoardingTasksCard(
                  tasks: _buildTasks(overview, semanticColors),
                  onViewAll: () => _openSection('/staff/patron/reports'),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x3l),

            // 4. Urgent Alerts
            BlocBuilder<PatronBloc, PatronState>(
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
                  onViewAll: () => _openSection('/staff/patron/reports'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<BoardingMetric> _buildMetrics(
    PatronDashboardOverview? data,
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
        onTap: () => _openSection('/staff/patron/dorms'),
      ),
      BoardingMetric(
        label: 'Present',
        icon: Icons.check_circle_outline,
        color: semanticColors.success,
        value: data?.studentsPresent ?? 0,
        caption: share(data?.studentsPresent ?? 0),
        onTap: () => _openSection('/staff/patron/attendance'),
      ),
      BoardingMetric(
        label: 'Absent',
        icon: Icons.person_off_outlined,
        color: semanticColors.error,
        value: data?.studentsAbsent ?? 0,
        caption: share(data?.studentsAbsent ?? 0),
        onTap: () => _openSection('/staff/patron/attendance'),
      ),
      BoardingMetric(
        label: 'On Leave',
        icon: Icons.work_outline,
        color: Colors.orange,
        value: data?.studentsOnLeave ?? 0,
        onTap: () => _openSection('/staff/patron/leave'),
      ),
    ];
  }

  /// Today's tasks are derived from the live overview counts rather than a
  /// hand-maintained checklist, so a task disappears once the work behind it
  /// is actually cleared.
  List<BoardingTask> _buildTasks(
    PatronDashboardOverview data,
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
      onTap: () => _openSection('/staff/patron/attendance'),
    ));

    tasks.add(BoardingTask(
      title: 'Dorm Inspection',
      timeLabel: '${data.occupiedBeds} / ${data.totalBeds} beds occupied',
      icon: Icons.shield_outlined,
      color: Theme.of(context).colorScheme.primary,
      onTap: () => _openSection('/staff/patron/dorms'),
    ));

    if (data.pendingWelfareConcerns > 0) {
      tasks.add(BoardingTask(
        title: 'Follow up welfare concerns',
        timeLabel: '${data.pendingWelfareConcerns} open concern(s)',
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        onTap: () => _openSection('/staff/patron/welfare'),
      ));
    }

    if (data.pendingLeaveRequests > 0) {
      tasks.add(BoardingTask(
        title: 'Review ${data.pendingLeaveRequests} Leave Request(s)',
        timeLabel: 'Awaiting your approval',
        icon: Icons.exit_to_app,
        color: Colors.deepOrange,
        onTap: () => _openSection('/staff/patron/leave'),
      ));
    }

    if (data.openDisciplineCases > 0) {
      tasks.add(BoardingTask(
        title: 'Open discipline cases',
        timeLabel: '${data.openDisciplineCases} awaiting action',
        icon: Icons.gavel_outlined,
        color: semanticColors.error,
        onTap: () => _openSection('/staff/patron/discipline'),
      ));
    }

    return tasks;
  }

  /// Alerts are derived from the live overview counts, so each one clears
  /// itself once the underlying situation is resolved.
  List<BoardingAlert> _buildAlerts(
    PatronDashboardOverview data,
    SemanticColors semanticColors,
  ) {
    final alerts = <BoardingAlert>[];

    if (data.missingStudentCount > 0) {
      alerts.add(BoardingAlert(
        title: 'Unaccounted',
        detail: '${data.missingStudentCount} boarder(s) missing at roll call',
        icon: Icons.person_search_outlined,
        color: semanticColors.error,
        onTap: () => _openSection('/staff/patron/attendance'),
      ));
    }
    if (data.overdueLeaveCount > 0) {
      alerts.add(BoardingAlert(
        title: 'Leave Expiry',
        detail: '${data.overdueLeaveCount} student(s) overdue from leave',
        icon: Icons.watch_later_outlined,
        color: semanticColors.warning,
        onTap: () => _openSection('/staff/patron/leave'),
      ));
    }
    if (data.studentsInClinic > 0) {
      alerts.add(BoardingAlert(
        title: 'Clinic Review',
        detail: '${data.studentsInClinic} boarder(s) in the clinic today',
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        onTap: () => _openSection('/staff/patron/welfare'),
      ));
    }
    if (data.pendingWelfareConcerns > 0) {
      alerts.add(BoardingAlert(
        title: 'Welfare',
        detail: '${data.pendingWelfareConcerns} open concern(s)',
        icon: Icons.favorite_outline,
        color: Colors.pink,
        onTap: () => _openSection('/staff/patron/welfare'),
      ));
    }
    if (data.openDisciplineCases > 0) {
      alerts.add(BoardingAlert(
        title: 'Discipline',
        detail: '${data.openDisciplineCases} case(s) awaiting action',
        icon: Icons.gavel_outlined,
        color: semanticColors.error,
        onTap: () => _openSection('/staff/patron/discipline'),
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
          onTap: () => _openSection('/staff/patron/attendance'),
        ),
        BoardingQuickAction(
          label: 'Dorm Check',
          icon: Icons.house_outlined,
          color: Colors.green,
          onTap: () => _openSection('/staff/patron/dorms'),
        ),
        BoardingQuickAction(
          label: 'Welfare',
          icon: Icons.favorite_outline,
          color: Colors.purple,
          onTap: () => _openSection('/staff/patron/welfare'),
        ),
        BoardingQuickAction(
          label: 'Leave Requests',
          icon: Icons.exit_to_app,
          color: Colors.deepOrange,
          onTap: () => _openSection('/staff/patron/leave'),
        ),
        BoardingQuickAction(
          label: 'Announcements',
          icon: Icons.campaign_outlined,
          color: Colors.teal,
          onTap: () => _openSection('/staff/patron/communication'),
        ),
        BoardingQuickAction(
          label: 'Reports',
          icon: Icons.bar_chart_outlined,
          color: Colors.purple,
          onTap: () => _openSection('/staff/patron/reports'),
        ),
      ],
    );
  }
}

