import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/domain/entities/director_dashboard_stats.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';

class DirectorDashboardScreen extends StatelessWidget {
  const DirectorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      appBar: staffDashboardAppBar(context, roleLabel: 'Director'),
      body: Builder(
        builder: (context) => RefreshIndicator(
          onRefresh: () async {
            context.read<DirectorBloc>().add(DirectorDashboardRequested());
            await context.read<DirectorBloc>().stream.firstWhere(
              (state) => state is! DirectorDashboardLoading,
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.l,
                    AppSpacing.xl,
                    AppSpacing.x3l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPerformanceIndex(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildFinancialPulse(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildAcademicPulse(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActionCenter(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildOperationalQuality(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, state) {
        final stats = state is DirectorDashboardLoaded ? state.stats : null;
        final label = stats != null
            ? '${stats.activeAcademicYear} • ${stats.currentTerm}'
            : null;
        return StaffHeroSummaryCard(
          greetingNameFallback: 'Director',
          periodLabel: label,
          kpis: stats == null
              ? null
              : [
                  StaffKpiData(
                    title: 'Total Students',
                    valueText: stats.totalStudents.toString(),
                    subtitle: '+${stats.schoolGrowthPercentage}%',
                    icon: Icons.people_alt,
                    color: AppColors.information(context),
                  ),
                  StaffKpiData(
                    title: 'Total Staff',
                    valueText: stats.totalStaff.toString(),
                    subtitle: 'Active',
                    icon: Icons.badge,
                    color: AppColors.success(context),
                  ),
                  StaffKpiData(
                    title: 'Departments',
                    valueText: stats.totalDepartments.toString(),
                    subtitle: 'Operational',
                    icon: Icons.account_tree,
                    color: AppColors.warning(context),
                  ),
                  StaffKpiData(
                    title: 'Pending Approvals',
                    valueText: stats.pendingFinancialApprovals.toString(),
                    subtitle: 'Action Required',
                    icon: Icons.assignment_late,
                    color: AppColors.danger(context),
                  ),
                ],
        );
      },
    );
  }

  Widget _buildPerformanceIndex(BuildContext context) {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, state) {
        if (state is! DirectorDashboardLoaded) return const SizedBox.shrink();
        final stats = state.stats;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'School Performance Index',
              actionLabel: 'View Details',
              onActionPressed: () => context.push('/staff/director/performance'),
            ),
            const SizedBox(height: AppSpacing.m),
            AppCard(
              child: Row(
                children: [
                  CircularPercentGauge(
                    percent: (stats.overallSchoolAverage / 100).clamp(0, 1),
                    centerLabel: '${stats.overallSchoolAverage.round()}%',
                    subLabel: stats.overallSchoolAverage >= 80
                        ? 'Good'
                        : stats.overallSchoolAverage >= 60
                        ? 'Fair'
                        : 'Needs Attention',
                    size: 110,
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      children: [
                        LabeledProgressRow(
                          label: 'Academic',
                          percent: (stats.overallSchoolAverage / 100).clamp(0, 1),
                          trailingText: '${stats.overallSchoolAverage.round()}%',
                          color: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        LabeledProgressRow(
                          label: 'Financial',
                          percent: (stats.collectionPercentage / 100).clamp(0, 1),
                          trailingText: '${stats.collectionPercentage.round()}%',
                          color: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        LabeledProgressRow(
                          label: 'Operational',
                          percent: (stats.staffAttendanceRate / 100).clamp(0, 1),
                          trailingText: '${stats.staffAttendanceRate.round()}%',
                          color: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        LabeledProgressRow(
                          label: 'Engagement',
                          percent: (stats.parentPortalUsageRate / 100).clamp(0, 1),
                          trailingText: '${stats.parentPortalUsageRate.round()}%',
                          color: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFinancialPulse(BuildContext context) {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, state) {
        if (state is DirectorDashboardLoaded) {
          final stats = state.stats;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Financial Health'),
              const SizedBox(height: AppSpacing.m),
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _FinancialMetric(
                          label: 'Fee Collection',
                          value: '${stats.collectionPercentage}%',
                          subValue:
                              '${stats.collectedFees.toStringAsFixed(0)} / ${stats.expectedFees.toStringAsFixed(0)}',
                          isProgress: true,
                          percentage: stats.collectionPercentage / 100,
                          color: Colors.green,
                        ),
                        const VerticalDivider(),
                        _FinancialMetric(
                          label: 'Budget Utilization',
                          value: '${stats.budgetUtilization}%',
                          subValue:
                              'Exp: ${stats.totalExpenditure.toStringAsFixed(0)}',
                          isProgress: true,
                          percentage: stats.budgetUtilization / 100,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RevenueItem(
                          label: 'Monthly Rev',
                          value: stats.monthlyRevenue,
                        ),
                        _RevenueItem(
                          label: 'Term Rev',
                          value: stats.termRevenue,
                        ),
                        _RevenueItem(
                          label: 'Year Rev',
                          value: stats.yearRevenue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAcademicPulse(BuildContext context) {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, state) {
        if (state is DirectorDashboardLoaded) {
          final stats = state.stats;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Academic Performance',
                actionLabel: 'View Details',
                onActionPressed: () =>
                    context.push('/staff/director/performance'),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: _PerformanceCard(
                      label: 'School Average',
                      value: '${stats.overallSchoolAverage}%',
                      trend:
                          '${stats.improvementTrend > 0 ? "+" : ""}${stats.improvementTrend}%',
                      icon: Icons.analytics,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _PerformanceCard(
                      label: 'Pass Rate',
                      value: '${stats.passRate}%',
                      trend: 'Stable',
                      icon: Icons.verified_user,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top Performing Classes',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...stats.topClasses.map(
                            (c) => _ClassListTile(c: c, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Classes Requiring Intervention',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...stats.weakClasses.map(
                            (c) => _ClassListTile(c: c, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionCenter(BuildContext context) {
    final actions = [
      {
        'icon': Icons.fact_check,
        'label': 'Approval Center',
        'color': Colors.blue,
        'route': '/staff/director/approvals',
      },
      {
        'icon': Icons.insights,
        'label': 'Strategic Reports',
        'color': Colors.purple,
        'route': '/staff/director/reports',
      },
      {
        'icon': Icons.track_changes,
        'label': 'School Goals',
        'color': Colors.orange,
        'route': '/staff/director/goals',
      },
      {
        'icon': Icons.groups,
        'label': 'Management Meetings',
        'color': Colors.teal,
        'route': '/staff/director/meetings',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Director Command Center'),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            childAspectRatio: 2.05,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: 6,
              ),
              showShadow: false,
              onTap: () {
                if (action['route'] != null) {
                  context.push(action['route'] as String);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      action['label'] as String,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOperationalQuality(BuildContext context) {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, state) {
        if (state is DirectorDashboardLoaded) {
          final stats = state.stats;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Operational Quality Indicators'),
              const SizedBox(height: AppSpacing.m),
              AppCard(
                child: Column(
                  children: [
                    _QualityTile(
                      label: 'Staff Attendance',
                      value: '${stats.staffAttendanceRate}%',
                      icon: Icons.how_to_reg,
                      color: Colors.blue,
                    ),
                    const Divider(),
                    _QualityTile(
                      label: 'Parent Engagement',
                      value: '${stats.parentPortalUsageRate}% Usage',
                      icon: Icons.family_restroom,
                      color: Colors.purple,
                    ),
                    const Divider(),
                    _QualityTile(
                      label: 'Safety & Incidents',
                      value: '${stats.activeIncidents} Active',
                      icon: Icons.security,
                      color: stats.activeIncidents > 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final bool isProgress;
  final double percentage;
  final Color color;

  const _FinancialMetric({
    required this.label,
    required this.value,
    required this.subValue,
    this.isProgress = false,
    this.percentage = 0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (isProgress) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _RevenueItem extends StatelessWidget {
  final String label;
  final double value;

  const _RevenueItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
        ),
        Text(
          value.toStringAsFixed(0),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const _PerformanceCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassListTile extends StatelessWidget {
  final ClassPerformance c;
  final Color color;

  const _ClassListTile({required this.c, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        c.className,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${c.average}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Icon(
            c.trend > 0 ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _QualityTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QualityTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      dense: true,
    );
  }
}
