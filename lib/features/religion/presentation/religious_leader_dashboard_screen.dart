import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class ReligiousLeaderDashboardScreen extends StatelessWidget {
  const ReligiousLeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Religious & Spiritual Life'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spiritual Oversight',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Service Attendance',
                    value: 85,
                    suffix: '%',
                    icon: Icons.people,
                    color: Colors.purple,
                    trend: 'Term Average',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Active Groups',
                    value: 6,
                    icon: Icons.group_work,
                    color: Colors.orange,
                    trend: 'Scripture Union, Muslim Students, etc.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Activities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text('Friday Juma Prayers'),
                    subtitle: Text('1:00 PM - School Mosque'),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text('Sunday Service'),
                    subtitle: Text('9:00 AM - Main Hall'),
                  ),
                  ListTile(
                    leading: Icon(Icons.event, color: Colors.blue),
                    title: Text('Inter-faith Dialogue'),
                    subtitle: Text('Wednesday, 25th Oct - Library Annex'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
