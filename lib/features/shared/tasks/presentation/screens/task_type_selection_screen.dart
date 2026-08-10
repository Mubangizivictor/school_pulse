import 'package:flutter/material.dart';

class TaskTypeSelectionScreen extends StatelessWidget {
  const TaskTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Type'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildCategoryItem(
            context,
            'Attendance & Roll Call',
            'Morning, Evening, or Special event attendance',
            Icons.fact_check_outlined,
            Colors.green,
          ),
          _buildCategoryItem(
            context,
            'Hygiene & Inspection',
            'Dormitory cleaning and sanitation checks',
            Icons.cleaning_services_outlined,
            Colors.purple,
          ),
          _buildCategoryItem(
            context,
            'Student Welfare',
            'Sick bay follow-ups and student needs',
            Icons.favorite_border,
            Colors.orange,
          ),
          _buildCategoryItem(
            context,
            'Academic Tasks',
            'Marking, lesson plans, and reports',
            Icons.menu_book_outlined,
            Colors.blue,
          ),
          _buildCategoryItem(
            context,
            'Administrative',
            'Meetings, inventory and system tasks',
            Icons.admin_panel_settings_outlined,
            Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      onTap: () => Navigator.pop(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
