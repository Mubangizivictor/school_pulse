import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store & Inventory'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Stock Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              DashboardStatCard(
                title: 'Low Stock Items',
                value: 8,
                icon: Icons.warning_amber_rounded,
                color: semanticColors.error,
              ),
              DashboardStatCard(
                title: 'Pending Requests',
                value: 14,
                icon: Icons.pending_actions,
                color: semanticColors.info,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Stock Movements'),
          const SizedBox(height: 12),
          _InventoryItem(
            name: 'Chalk Boxes (White)',
            status: 'Restocked',
            quantity: '+50',
            date: 'Today, 09:30 AM',
            color: semanticColors.success,
          ),
          _InventoryItem(
            name: 'Printing Paper (A4)',
            status: 'Issued',
            quantity: '-5 Reams',
            date: 'Today, 08:15 AM',
            color: semanticColors.warning,
          ),
          _InventoryItem(
            name: 'Textbooks (Math P.4)',
            status: 'Issued',
            quantity: '-12',
            date: 'Yesterday',
            color: semanticColors.warning,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickAction(
                label: 'Add Stock',
                icon: Icons.add_box_outlined,
                color: Theme.of(context).colorScheme.primary,
                onTap: () {},
              ),
              _QuickAction(
                label: 'Issue Item',
                icon: Icons.outbox_outlined,
                color: semanticColors.info,
                onTap: () {},
              ),
              _QuickAction(
                label: 'Inventory Audit',
                icon: Icons.assignment_turned_in_outlined,
                color: semanticColors.success,
                onTap: () {},
              ),
              _QuickAction(
                label: 'Reports',
                icon: Icons.bar_chart_outlined,
                color: Colors.purple,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final String name;
  final String status;
  final String quantity;
  final String date;
  final Color color;

  const _InventoryItem({
    required this.name,
    required this.status,
    required this.quantity,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'Restocked' ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$status • $date', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            quantity,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
