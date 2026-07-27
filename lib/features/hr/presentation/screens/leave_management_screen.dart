import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';

class LeaveManagementScreen extends StatelessWidget {
  const LeaveManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Pending Requests'),
          const SizedBox(height: 12),
          _LeaveRequestTile(
            name: 'Sarah Johnson',
            type: 'Annual Leave',
            duration: 'Oct 25 - Oct 30 (5 days)',
            status: 'Pending',
            statusColor: semantic.warning,
          ),
          _LeaveRequestTile(
            name: 'John Mukasa',
            type: 'Sick Leave',
            duration: 'Oct 23 - Oct 24 (2 days)',
            status: 'Pending',
            statusColor: semantic.warning,
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Staff Leave Balances'),
          const SizedBox(height: 12),
          AppCard(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Staff Name')),
                DataColumn(label: Text('Annual')),
                DataColumn(label: Text('Sick')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Sarah Johnson')),
                  DataCell(Text('12/21')),
                  DataCell(Text('5/10')),
                ]),
                DataRow(cells: [
                  DataCell(Text('John Mukasa')),
                  DataCell(Text('18/21')),
                  DataCell(Text('2/10')),
                ]),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}

class _LeaveRequestTile extends StatelessWidget {
  final String name;
  final String type;
  final String duration;
  final String status;
  final Color statusColor;

  const _LeaveRequestTile({
    required this.name,
    required this.type,
    required this.duration,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$type • $duration'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
