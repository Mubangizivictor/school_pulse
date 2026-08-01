import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'task_type_selection_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _priority = 'High';
  String _category = 'Hygiene Inspection';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Task Details'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'e.g. Inspect Sunset House',
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskTypeSelectionScreen()),
                );
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Task Type / Category',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_category),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Provide details about this task...',
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Assignment & Priority'),
            const SizedBox(height: 12),
            _buildDropdownField('Assigned to', 'Mrs. Akello Mary'),
            const SizedBox(height: 16),
            _buildDropdownField('Priority', _priority),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Schedule'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDatePicker('Due Date', 'May 20, 2024')),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker('Due Time', '9:00 AM')),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Checklist'),
            const SizedBox(height: 12),
            _buildChecklistItem('Bedrooms Cleanliness'),
            _buildChecklistItem('Bathroom Sanitation'),
            _buildChecklistItem('Common Areas'),
            _buildChecklistItem('Waste Management'),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PrimaryButton(
          label: 'Create Task',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, size: 20),
      ),
      child: Text(value),
    );
  }

  Widget _buildTimePicker(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time, size: 20),
      ),
      child: Text(value),
    );
  }

  Widget _buildChecklistItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, size: 20),
          const SizedBox(width: 8),
          const Icon(Icons.radio_button_unchecked, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {}),
        ],
      ),
    );
  }
}
