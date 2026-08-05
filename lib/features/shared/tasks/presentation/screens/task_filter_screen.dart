import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class TaskFilterScreen extends StatefulWidget {
  const TaskFilterScreen({super.key});

  @override
  State<TaskFilterScreen> createState() => _TaskFilterScreenState();
}

class _TaskFilterScreenState extends State<TaskFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [TextButton(onPressed: () {}, child: const Text('Reset'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Status'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Pending', false),
                _buildFilterChip('In Progress', false),
                _buildFilterChip('Completed', false),
                _buildFilterChip('Overdue', false),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Priority'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('High', false),
                _buildFilterChip('Medium', false),
                _buildFilterChip('Low', false),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Category'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Attendance', false),
                _buildFilterChip('Hygiene', false),
                _buildFilterChip('Welfare', false),
                _buildFilterChip('Admin', false),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Due Date'),
            const SizedBox(height: 12),
            _buildDateOption('Today'),
            _buildDateOption('This Week'),
            _buildDateOption('This Month'),
            _buildDateOption('Custom Range'),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PrimaryButton(
          label: 'Apply Filters',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {},
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildDateOption(String label) {
    return RadioListTile(
      value: label,
      groupValue: 'Today',
      onChanged: (val) {},
      title: Text(label),
      contentPadding: EdgeInsets.zero,
    );
  }
}
