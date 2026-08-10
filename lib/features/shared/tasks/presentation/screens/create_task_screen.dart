import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'task_type_selection_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedPriority = 'High';
  final String _category = 'Hygiene Inspection';

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
            const Text(
              'Task Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
                  MaterialPageRoute(
                    builder: (_) => const TaskTypeSelectionScreen(),
                  ),
                );
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Task Type / Category',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(_category), const Icon(Icons.chevron_right)],
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
            const Text(
              'Assignment & Priority',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildDropdownField('Assigned to', 'Mrs. Akello Mary'),
            const SizedBox(height: 16),
            const Text(
              'Priority',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip('Low', Colors.green),
                const SizedBox(width: 8),
                _buildPriorityChip('Medium', Colors.orange),
                const SizedBox(width: 8),
                _buildPriorityChip('High', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Schedule',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDatePicker('Due Date', 'May 20, 2024')),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePicker('Due Time', '9:00 AM')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checklist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildChecklistItem('Bedrooms Cleanliness'),
            _buildChecklistItem('Bathroom Sanitation'),
            _buildChecklistItem('Common Areas'),
            _buildChecklistItem('Waste Management'),
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

  Widget _buildPriorityChip(String label, Color color) {
    final isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), const Icon(Icons.arrow_drop_down)],
      ),
    );
  }

  Widget _buildDatePicker(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      child: Text(value, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildTimePicker(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time, size: 18),
      ),
      child: Text(value, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildChecklistItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Icon(
              Icons.radio_button_unchecked,
              size: 20,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.close, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
