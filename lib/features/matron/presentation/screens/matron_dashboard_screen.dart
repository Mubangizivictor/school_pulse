import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_dashboard_widgets.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
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
    return Scaffold(
      appBar: staffDashboardAppBar(context, roleLabel: 'Matron'),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.l,
            AppSpacing.xl,
            AppSpacing.x4l,
          ),
          children: [
            // 1. Boarding overview hero
            BlocBuilder<MatronBloc, MatronState>(
              buildWhen: (previous, current) =>
                  current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded
                    ? state.overview
                    : null;
                return StaffHeroSummaryCard(
                  greetingNameFallback: 'Matron',
                  kpis: overview == null
                      ? null
                      : [
                          StaffKpiData(
                            title: 'Residents',
                            valueText: '${overview.totalStudents}',
                            subtitle: 'Total',
                            icon: Icons.groups_outlined,
                            color: AppColors.information(context),
                          ),
                          StaffKpiData(
                            title: 'Present',
                            valueText: '${overview.studentsPresent}',
                            subtitle: 'Checked in',
                            icon: Icons.check_circle_outline,
                            color: AppColors.success(context),
                          ),
                          StaffKpiData(
                            title: 'Absent',
                            valueText: '${overview.studentsAbsent}',
                            subtitle: 'Needs review',
                            icon: Icons.person_off_outlined,
                            color: AppColors.danger(context),
                          ),
                          StaffKpiData(
                            title: 'On Leave',
                            valueText: '${overview.studentsOnLeave}',
                            subtitle: 'Away',
                            icon: Icons.work_outline,
                            color: AppColors.warning(context),
                          ),
                        ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.x3l),

            // 2. Secondary metrics: dorms / occupancy / discipline / welfare
            BlocBuilder<MatronBloc, MatronState>(
              buildWhen: (previous, current) =>
                  current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded
                    ? state.overview
                    : null;
                return BoardingSecondaryMetricsRow(
                  isLoading: overview == null,
                  metrics: overview == null
                      ? const []
                      : _buildSecondaryMetrics(overview),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x3l),

            // 3. Today's Schedule
            BoardingScheduleCard(items: _buildScheduleItems(context)),
            const SizedBox(height: AppSpacing.x3l),

            // 4. Urgent Alerts
            BlocBuilder<MatronBloc, MatronState>(
              buildWhen: (previous, current) =>
                  current is DashboardOverviewLoaded,
              builder: (context, state) {
                final overview = state is DashboardOverviewLoaded
                    ? state.overview
                    : null;
                if (overview == null) {
                  return const Skeleton(height: 140, borderRadius: 16);
                }
                final alerts = _buildAlerts(
                  overview,
                  Theme.of(context).extension<SemanticColors>()!,
                );
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

  /// Dormitories assigned / Occupancy % / Open Discipline Cases / Welfare
  /// Concerns - all sourced from the live dashboard overview.
  List<BoardingSecondaryMetric> _buildSecondaryMetrics(
    MatronDashboardOverview data,
  ) {
    final occupancyPercent = data.totalBeds == 0
        ? 0
        : (data.occupiedBeds / data.totalBeds * 100).round();
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return [
      BoardingSecondaryMetric(
        label: 'Dormitories',
        icon: Icons.home_outlined,
        color: theme.colorScheme.primary,
        value: '${data.occupiedBeds}/${data.totalBeds} beds',
        onTap: () => _openSection('/staff/matron/dorms'),
      ),
      BoardingSecondaryMetric(
        label: 'Occupancy',
        icon: Icons.pie_chart_outline,
        color: Colors.black,
        value: '$occupancyPercent%',
        onTap: () => _openSection('/staff/matron/dorms'),
      ),
      BoardingSecondaryMetric(
        label: 'Open Discipline Cases',
        icon: Icons.gavel_outlined,
        color: semanticColors.error,
        value: '${data.openDisciplineCases}',
        onTap: () => _openSection('/staff/matron/discipline'),
      ),
      BoardingSecondaryMetric(
        label: 'Welfare Concerns',
        icon: Icons.favorite_outline,
        color: Colors.black,
        value: '${data.pendingWelfareConcerns}',
        onTap: () => _openSection('/staff/matron/welfare'),
      ),
    ];
  }

  /// Today's Schedule shows only Morning/Evening Roll Call - there is no
  /// backend concept of a "Dorm Inspection" schedule entry, so it is not
  /// shown here. No repository method currently distinguishes a completed
  /// morning session from an evening one, so these rows carry only their
  /// time label - no fabricated "completed" status.
  List<BoardingScheduleItem> _buildScheduleItems(BuildContext context) {
    final theme = Theme.of(context);
    return [
      BoardingScheduleItem(
        title: 'Morning Roll Call',
        timeLabel: '6:30 AM',
        icon: Icons.how_to_reg_outlined,
        color: theme.colorScheme.primary,
        onTap: () => _openSection('/staff/matron/roll-call'),
      ),
      BoardingScheduleItem(
        title: 'Evening Roll Call',
        timeLabel: '8:00 PM',
        icon: Icons.nightlight_outlined,
        color: theme.colorScheme.primary,
        onTap: () => _openSection('/staff/matron/roll-call'),
      ),
    ];
  }

  /// Alerts are derived from the live overview counts, so each one clears
  /// itself once the underlying situation is resolved.
  List<BoardingAlert> _buildAlerts(
    MatronDashboardOverview data,
    SemanticColors semanticColors,
  ) {
    final alerts = <BoardingAlert>[];

    if (data.missingStudentCount > 0) {
      alerts.add(
        BoardingAlert(
          title: 'Unaccounted',
          detail: '${data.missingStudentCount} boarder(s) missing at roll call',
          icon: Icons.person_search_outlined,
          color: semanticColors.error,
          onTap: () => _openSection('/staff/matron/dorms'),
        ),
      );
    }
    if (data.overdueLeaveCount > 0) {
      alerts.add(
        BoardingAlert(
          title: 'Leave Expiry',
          detail: '${data.overdueLeaveCount} student(s) overdue from leave',
          icon: Icons.watch_later_outlined,
          color: semanticColors.warning,
          onTap: () => _openSection('/staff/matron/leave'),
        ),
      );
    }
    if (data.studentsInClinic > 0) {
      alerts.add(
        BoardingAlert(
          title: 'Clinic Review',
          detail: '${data.studentsInClinic} boarder(s) in the clinic today',
          icon: Icons.medical_services_outlined,
          color: Colors.black,
          onTap: () => _openSection('/staff/matron/welfare'),
        ),
      );
    }
    if (data.pendingWelfareConcerns > 0) {
      alerts.add(
        BoardingAlert(
          title: 'Welfare',
          detail: '${data.pendingWelfareConcerns} open concern(s)',
          icon: Icons.favorite_outline,
          color: Colors.black,
          onTap: () => _openSection('/staff/matron/welfare'),
        ),
      );
    }
    if (data.openDisciplineCases > 0) {
      alerts.add(
        BoardingAlert(
          title: 'Discipline',
          detail: '${data.openDisciplineCases} case(s) awaiting action',
          icon: Icons.gavel_outlined,
          color: semanticColors.error,
          onTap: () => _openSection('/staff/matron/discipline'),
        ),
      );
    }
    return alerts;
  }
}
