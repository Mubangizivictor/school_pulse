import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class AdminStaffAttendanceScreen extends StatelessWidget {
  const AdminStaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Staff Attendance Monitor'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAttendanceOverview(context),
            const SizedBox(height: 24),
            _buildStaffList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DashboardStatCard(title: 'Present Now', value: 42, icon: Icons.person_pin_circle, color: Colors.green, trend: 'Out of 48 total')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Late Arrivals', value: 3, icon: Icons.access_time_filled, color: Colors.orange, trend: 'Today')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'On Leave', value: 2, icon: Icons.event_busy, color: Colors.blue, trend: 'Approved')),
        const SizedBox(width: 16),
        Expanded(child: DashboardStatCard(title: 'Avg. Clock-in', value: 7, suffix: ':42 AM', icon: Icons.speed, color: Colors.purple, trend: 'Last 7 days')),
      ],
    );
  }

  Widget _buildStaffList(BuildContext context) {
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
                Text('Daily Attendance Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search staff name...',
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
              DataColumn(label: Text('Staff Member')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Clock In')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Location')),
            ],
            rows: List.generate(10, (index) {
              final names = ['Okello David', 'Namono Sarah', 'Mugisha Paul', 'Atwine Ritah'];
              final depts = ['Academic', 'Administration', 'Operations', 'Finance'];
              return DataRow(cells: [
                DataCell(Row(
                  children: [
                    AvatarInitials(name: names[index % 4], size: 32),
                    const SizedBox(width: 12),
                    Text(names[index % 4], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
                DataCell(Text(depts[index % 4])),
                DataCell(Text('07:${40 + index} AM')),
                DataCell(StatusBadge(
                  label: index == 2 ? 'Late' : 'On Time',
                  color: index == 2 ? Colors.orange : Colors.green,
                )),
                const DataCell(Text('Main Gate')),
              ]);
            }),
          ),
        ],
      ),
    );
  }
}
