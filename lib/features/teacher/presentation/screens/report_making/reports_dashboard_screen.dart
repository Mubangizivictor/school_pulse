import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REPORTS DASHBOARD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            Text('Manage Class Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Term',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      StatusBadge(label: 'In Progress', color: semantic.info),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Term 2, 2024/2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Students',
                          value: '32',
                          icon: Icons.people_outline,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Completed',
                          value: '0',
                          icon: Icons.check_circle_outline,
                          color: semantic.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Pending',
                          value: '32',
                          icon: Icons.pending_actions,
                          color: semantic.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Start Report Entry',
                    onPressed: () => context.push('/teacher/reports/select-class'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Previous Terms'),
            const SizedBox(height: 12),
            _TermHistoryCard(
              term: 'Term 1, 2024/2025',
              status: 'Completed',
              statusColor: semantic.success,
              date: 'Sep - Dec 2024',
            ),
            const SizedBox(height: 12),
            _TermHistoryCard(
              term: 'Term 3, 2023/2024',
              status: 'Completed',
              statusColor: semantic.success,
              date: 'May - Aug 2024',
            ),
            const SizedBox(height: 12),
            _TermHistoryCard(
              term: 'Term 2, 2023/2024',
              status: 'Completed',
              statusColor: semantic.success,
              date: 'Jan - Apr 2024',
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
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

  const _TermHistoryCard({
    required this.term,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
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
                Text(term, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          StatusBadge(label: status, color: statusColor),
        ],
      ),
    );
  }
}
