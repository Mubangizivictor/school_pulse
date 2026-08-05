import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class DirectorReportsScreen extends StatelessWidget {
  const DirectorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategic Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportSection(context, 'Financial Reports', [
            _ReportItem(
              title: 'Annual Budget Performance',
              icon: Icons.account_balance,
            ),
            _ReportItem(title: 'Fee Collection Analysis', icon: Icons.payments),
            _ReportItem(
              title: 'Expenditure by Department',
              icon: Icons.pie_chart,
            ),
          ]),
          const SizedBox(height: 24),
          _buildReportSection(context, 'Academic Reports', [
            _ReportItem(
              title: 'School-wide Performance Trend',
              icon: Icons.trending_up,
            ),
            _ReportItem(
              title: 'Subject Performance Comparison',
              icon: Icons.bar_chart,
            ),
            _ReportItem(
              title: 'Teacher Delivery Metrics',
              icon: Icons.person_search,
            ),
          ]),
          const SizedBox(height: 24),
          _buildReportSection(context, 'Operational Reports', [
            _ReportItem(
              title: 'Staff Attendance Summary',
              icon: Icons.assignment_ind,
            ),
            _ReportItem(
              title: 'Inventory & Asset Audit',
              icon: Icons.inventory,
            ),
            _ReportItem(title: 'Incident & Discipline Log', icon: Icons.gavel),
          ]),
        ],
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
        const SizedBox(height: 12),
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
      leading: Icon(item.icon, color: Theme.of(context).primaryColor),
      title: Text(item.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Implement report generation/viewing
      },
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;

  _ReportItem({required this.title, required this.icon});
}
