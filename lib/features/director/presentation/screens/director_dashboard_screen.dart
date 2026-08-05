import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/director/domain/entities/director_dashboard_stats.dart';

class DirectorDashboardScreen extends StatelessWidget {
  const DirectorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actionBg = Theme.of(context).colorScheme.surfaceContainer;
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          NotificationBellButton(backgroundColor: actionBg),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 24),
                  _buildOverviewGrid(context),
                  const SizedBox(height: 24),
                  _buildFinancialPulse(context),
                  const SizedBox(height: 24),
                  _buildAcademicPulse(context),
                  const SizedBox(height: 24),
                  _buildActionCenter(context),
                  const SizedBox(height: 24),
                  _buildOperationalQuality(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = (state is AuthAuthenticated)
            ? state.user.name
            : 'Director';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            BlocBuilder<DirectorBloc, DirectorState>(
              builder: (context, state) {
                if (state is DirectorDashboardLoaded) {
                  return Text(
                    'Institution Oversight • ${state.stats.activeAcademicYear} • ${state.stats.currentTerm}',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  );
                }
                return const Text('Loading school oversight data...');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewGrid(BuildContext context) {
    return BlocBuilder<DirectorBloc, DirectorState>(
      builder: (context, state) {
        if (state is DirectorDashboardLoaded) {
          final stats = state.stats;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _OverviewCard(
                label: 'Total Students',
                value: stats.totalStudents.toString(),
                trend: '+${stats.schoolGrowthPercentage}%',
                icon: Icons.people_alt,
                color: Colors.blue,
              ),
              _OverviewCard(
                label: 'Total Staff',
                value: stats.totalStaff.toString(),
                trend: 'Active',
                icon: Icons.badge,
                color: Colors.purple,
              ),
              _OverviewCard(
                label: 'Departments',
                value: stats.totalDepartments.toString(),
                trend: 'Operational',
                icon: Icons.account_tree,
                color: Colors.teal,
              ),
              _OverviewCard(
                label: 'Pending Approvals',
                value: stats.pendingFinancialApprovals.toString(),
                trend: 'Action Required',
                icon: Icons.assignment_late,
                color: Colors.orange,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
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
              const SizedBox(height: 12),
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
              const SectionHeader(title: 'Academic Performance'),
              const SizedBox(height: 12),
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
                  const SizedBox(width: 12),
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
              const SizedBox(height: 12),
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
                  const SizedBox(width: 12),
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
        'route': '/director/approvals',
      },
      {
        'icon': Icons.insights,
        'label': 'Strategic Reports',
        'color': Colors.purple,
        'route': '/director/reports',
      },
      {
        'icon': Icons.track_changes,
        'label': 'School Goals',
        'color': Colors.orange,
        'route': '/director/goals',
      },
      {
        'icon': Icons.groups,
        'label': 'Management Meetings',
        'color': Colors.teal,
        'route': '/director/meetings',
      },
      {
        'icon': Icons.campaign,
        'label': 'Announcements',
        'color': Colors.red,
        'route': '/director/announcements',
      },
      {
        'icon': Icons.domain,
        'label': 'Campus Monitor',
        'color': Colors.indigo,
        'route': '/director/campuses',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Director Command Center'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 6 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return AppCard(
                  onTap: () {
                    if (action['route'] != null) {
                      context.push(action['route'] as String);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
              const SizedBox(height: 12),
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

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 2;
    return Container(
      width: width > 220 ? 220 : width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                trend,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
