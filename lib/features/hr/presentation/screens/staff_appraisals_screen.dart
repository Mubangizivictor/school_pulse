import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class StaffAppraisalsScreen extends StatelessWidget {
  const StaffAppraisalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Appraisals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Active Appraisal Cycle: 2024 Q4'),
          const SizedBox(height: 16),
          _AppraisalTile(
            name: 'Robert Okello',
            department: 'Mathematics',
            score: 0.85,
            status: 'Self-Assessment Done',
          ),
          _AppraisalTile(
            name: 'Jane Doe',
            department: 'English',
            score: 0.92,
            status: 'HOD Reviewed',
          ),
          _AppraisalTile(
            name: 'Mark Ssemwanga',
            department: 'Security',
            score: 0.0,
            status: 'Pending Start',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.analytics),
        label: const Text('Start New Cycle'),
      ),
    );
  }
}

class _AppraisalTile extends StatelessWidget {
  final String name;
  final String department;
  final double score;
  final String status;

  const _AppraisalTile({
    required this.name,
    required this.department,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
            Text(
              department,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: score,
                    backgroundColor: Colors.black,
                    color: score > 0.8 ? Colors.black : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(score * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
