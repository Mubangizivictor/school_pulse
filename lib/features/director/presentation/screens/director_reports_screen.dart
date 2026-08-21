import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';
import 'package:school_pulse/features/director/presentation/screens/reports/report_detail_screen.dart';
import 'package:school_pulse/features/director/domain/entities/director_dashboard_stats.dart';

class DirectorReportsScreen extends StatelessWidget {
  const DirectorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Strategic Reports')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.l, AppSpacing.xl, AppSpacing.x3l),
        children: [
          _buildReportSection(context, 'Financial Reports', [
            _ReportItem(
              title: 'Annual Budget Performance',
              icon: Icons.account_balance,
              color: Colors.blue,
              open: (context) => _openReport(
                context,
                'Annual Budget Performance',
                (context, stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          ReportMetricRow(
                            label: 'Total Expenditure',
                            value: stats.totalExpenditure.toStringAsFixed(0),
                          ),
                          ReportMetricRow(
                            label: 'Budget Utilization',
                            value: '${stats.budgetUtilization}%',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    LabeledProgressRow(
                      label: 'Budget Utilization',
                      percent: (stats.budgetUtilization / 100).clamp(0, 1),
                      trailingText: '${stats.budgetUtilization}%',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            _ReportItem(
              title: 'Fee Collection Analysis',
              icon: Icons.payments,
              color: Colors.green,
              open: (context) => _openReport(
                context,
                'Fee Collection Analysis',
                (context, stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          ReportMetricRow(
                            label: 'Expected Fees',
                            value: stats.expectedFees.toStringAsFixed(0),
                          ),
                          ReportMetricRow(
                            label: 'Collected Fees',
                            value: stats.collectedFees.toStringAsFixed(0),
                          ),
                          ReportMetricRow(
                            label: 'Outstanding Fees',
                            value: stats.outstandingFees.toStringAsFixed(0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    LabeledProgressRow(
                      label: 'Collection Percentage',
                      percent: (stats.collectionPercentage / 100).clamp(0, 1),
                      trailingText: '${stats.collectionPercentage}%',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            _ReportItem(
              title: 'Expenditure by Department',
              icon: Icons.pie_chart,
              color: Colors.orange,
              open: (context) => _openReport(
                context,
                'Expenditure by Department',
                // TODO: Wire to a real per-department expenditure breakdown
                // once the finance module exposes department-level spend.
                (context, stats) => const ReportNotTrackedNote(
                  message:
                      'Per-department expenditure is not tracked yet. This '
                      'report currently only has a school-wide expenditure '
                      'total, available under Annual Budget Performance.',
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildReportSection(context, 'Academic Reports', [
            _ReportItem(
              title: 'School-wide Performance Trend',
              icon: Icons.trending_up,
              color: Colors.purple,
              open: (context) => _openReport(
                context,
                'School-wide Performance Trend',
                (context, stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stats.overallSchoolAverage}%',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          StatusBadge(
                            label:
                                '${stats.improvementTrend >= 0 ? "+" : ""}${stats.improvementTrend}% vs Last Term',
                            color: stats.improvementTrend >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          // TODO: Wire to a real term-over-term series once
                          // the director module stores historical snapshots.
                          const TrendLineChart(values: []),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ReportItem(
              title: 'Subject Performance Comparison',
              icon: Icons.bar_chart,
              color: Colors.teal,
              open: (context) => _openReport(
                context,
                'Subject Performance Comparison',
                // TODO: Wire to real per-subject averages once the director
                // module exposes subject-level academic data.
                (context, stats) => const ReportNotTrackedNote(
                  message: 'Per-subject performance comparison is not tracked yet.',
                ),
              ),
            ),
            _ReportItem(
              title: 'Teacher Delivery Metrics',
              icon: Icons.person_search,
              color: Colors.indigo,
              open: (context) => _openReport(
                context,
                'Teacher Delivery Metrics',
                // TODO: Wire to real lesson-delivery/coverage data once the
                // academics module exposes it to the director layer.
                (context, stats) => const ReportNotTrackedNote(
                  message: 'Teacher delivery metrics are not tracked yet.',
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildReportSection(context, 'Operational Reports', [
            _ReportItem(
              title: 'Staff Attendance Summary',
              icon: Icons.assignment_ind,
              color: Colors.cyan,
              open: (context) => _openReport(
                context,
                'Staff Attendance Summary',
                (context, stats) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.staffAttendanceRate}%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Staff attendance rate',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _ReportItem(
              title: 'Inventory & Asset Audit',
              icon: Icons.inventory,
              color: Colors.brown,
              open: (context) => _openReport(
                context,
                'Inventory & Asset Audit',
                // TODO: Wire to the Stores/Assets module's real inventory
                // data once it exposes an audit summary to the director.
                (context, stats) => const ReportNotTrackedNote(
                  message: 'Inventory and asset audit data is not tracked yet.',
                ),
              ),
            ),
            _ReportItem(
              title: 'Incident & Discipline Log',
              icon: Icons.gavel,
              color: Colors.red,
              open: (context) => _openReport(
                context,
                'Incident & Discipline Log',
                (context, stats) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.activeIncidents}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Active incidents',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  static void _openReport(
    BuildContext context,
    String title,
    Widget Function(BuildContext context, DirectorDashboardStats stats) builder,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(title: title, builder: builder),
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context,
    String title,
    List<_ReportItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          child: Column(
            children: items
                .map((item) => _buildReportTile(context, item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTile(BuildContext context, _ReportItem item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.color.withValues(alpha: 0.12),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () => item.open(context),
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) open;

  _ReportItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.open,
  });
}
