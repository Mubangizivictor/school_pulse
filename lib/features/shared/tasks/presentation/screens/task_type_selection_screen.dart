import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class TaskTypeSelectionScreen extends StatelessWidget {
  const TaskTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Task Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTypeSection(context, 'Attendance', [
            'Morning Roll Call',
            'Evening Roll Call',
            'Meal Attendance',
            'Church/Assembly Attendance',
          ]),
          const SizedBox(height: 24),
          _buildTypeSection(context, 'Hygiene & Environment', [
            'General Cleaning',
            'Dormitory Inspection',
            'Compound Maintenance',
            'Sanitation Check',
          ]),
          const SizedBox(height: 24),
          _buildTypeSection(context, 'Student Welfare', [
            'Sick Student Follow-up',
            'Disciplinary Action',
            'Pocket Money Distribution',
            'Counseling Session',
          ]),
          const SizedBox(height: 24),
          _buildTypeSection(context, 'Administrative', [
            'Staff Meeting',
            'Report Submission',
            'Inventory Check',
            'Leave Request Approval',
          ]),
        ],
      ),
    );
  }

  Widget _buildTypeSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildTypeChip(context, item)).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String label) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
