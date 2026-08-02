import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceElevated(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REPORTS DASHBOARD',
                style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            Text('Manage Class Reports',
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary(context)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border(context).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              color: AppColors.primary(context).withValues(alpha: 0.05),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Term',
                        style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
                      ),
                      StatusBadge(label: 'In Progress', color: AppColors.information(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Term 2, 2024/2025',
                    style: TextStyle(
                        color: AppColors.textPrimary(context), fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Students',
                          value: '32',
                          icon: Icons.people_outline,
                          color: AppColors.primary(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Completed',
                          value: '0',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Pending',
                          value: '32',
                          icon: Icons.pending_actions,
                          color: AppColors.warning(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Start Report Entry',
                    onPressed: () => context.push('/staff/reports/select-class'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Previous Terms', color: AppColors.textPrimary(context)),
            const SizedBox(height: 12),
            _TermHistoryCard(
              term: 'Term 1, 2024/2025',
              status: 'Completed',
              statusColor: AppColors.success(context),
              date: 'Sep - Dec 2024',
              onTap: () => context.push('/staff/reports/select-class'),
            ),
            const SizedBox(height: 12),
            _TermHistoryCard(
              term: 'Term 3, 2023/2024',
              status: 'Completed',
              statusColor: AppColors.success(context),
              date: 'May - Aug 2024',
              onTap: () => context.push('/staff/reports/select-class'),
            ),
            const SizedBox(height: 12),
            _TermHistoryCard(
              term: 'Term 2, 2023/2024',
              status: 'Completed',
              statusColor: AppColors.success(context),
              date: 'Jan - Apr 2024',
              onTap: () => context.push('/staff/reports/select-class'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}

class _TermHistoryCard extends StatelessWidget {
  final String term;
  final String status;
  final Color statusColor;
  final String date;
  final VoidCallback onTap;

  const _TermHistoryCard({
    required this.term,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.assignment_turned_in_outlined, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(term,
                    style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold)),
                Text(date, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          StatusBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}

