import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class VisitorLogScreen extends StatelessWidget {
  const VisitorLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Visitor Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVisitorDialog(context),
            tooltip: 'Log New Visitor',
          ),
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildVisitorStats(context),
            const SizedBox(height: 24),
            _buildVisitorList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorStats(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: DashboardStatCard(title: 'Active Visitors', value: 8, icon: Icons.meeting_room, color: Colors.blue, trend: 'Currently on premises')),
        const SizedBox(width: 16),
        const Expanded(child: DashboardStatCard(title: 'Total Today', value: 24, icon: Icons.people_outline, color: Colors.green, trend: '+4 from yesterday')),
        const SizedBox(width: 16),
        const Expanded(child: DashboardStatCard(title: 'Avg. Stay', value: 45, suffix: ' min', icon: Icons.timer, color: Colors.orange, trend: 'Last 30 days')),
      ],
    );
  }

  Widget _buildVisitorList(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Visitor Entry/Exit History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name or purpose...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Visitor Name')),
              DataColumn(label: Text('Purpose')),
              DataColumn(label: Text('In Time')),
              DataColumn(label: Text('Out Time')),
              DataColumn(label: Text('Contact')),
              DataColumn(label: Text('Action')),
            ],
            rows: List.generate(8, (index) {
              final visitors = ['John Doe', 'Jane Smith', 'Alice Brown', 'Bob Johnson'];
              final purposes = ['Parent Meeting', 'Delivery', 'Interview', 'Maintenance'];
              final isActive = index < 3;
              
              return DataRow(cells: [
                DataCell(Text(visitors[index % 4], style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(purposes[index % 4])),
                DataCell(const Text('09:20 AM')),
                DataCell(isActive 
                  ? const StatusBadge(label: 'On Premises', color: Colors.blue) 
                  : const Text('10:45 AM')
                ),
                DataCell(Text('+256 701 234 5${index}6')),
                DataCell(
                  isActive 
                    ? TextButton(onPressed: () {}, child: const Text('Check Out'))
                    : const Icon(Icons.check_circle, color: Colors.green, size: 20)
                ),
              ]);
            }),
          ),
        ],
      ),
    );
  }

  void _showAddVisitorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Visitor Entry'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Full Name')),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Contact Number')),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Purpose of Visit')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Log Entry')),
        ],
      ),
    );
  }
}
