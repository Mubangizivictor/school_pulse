import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'task_type_selection_screen.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController(text: 'Inspect Sunset House');
  final _descController = TextEditingController(text: 'Routine weekly inspection for hygiene and maintenance.');
  String _selectedPriority = 'High';
  final String _category = 'Hygiene Inspection';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Edit Task',
          style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w900, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'General Information'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Task Title',
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
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
                decoration: InputDecoration(
                  labelText: 'Task Type / Category',
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_category, style: TextStyle(color: AppColors.textPrimary(context))),
                    Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Assignment & Priority'),
            const SizedBox(height: 12),
            _buildDropdownField(context, 'Assigned to', 'Mrs. Akello Mary'),
            const SizedBox(height: 16),
            Text(
              'Select Priority',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPriorityChip('Low', AppColors.successGreen),
                const SizedBox(width: 8),
                _buildPriorityChip('Medium', AppColors.goldenYellow),
                const SizedBox(width: 8),
                _buildPriorityChip('High', AppColors.deepOrange),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Schedule Details'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPickerField(context, 'Due Date', 'May 20, 2024', Icons.calendar_today)),
                const SizedBox(width: 12),
                Expanded(child: _buildPickerField(context, 'Due Time', '09:00 AM', Icons.access_time)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, 'Checklist'),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Item'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildChecklistItem(context, 'Bedrooms Cleanliness'),
            _buildChecklistItem(context, 'Bathroom Sanitation'),
            _buildChecklistItem(context, 'Common Areas'),
            _buildChecklistItem(context, 'Waste Management'),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        ),
        child: SafeArea(
          child: PrimaryButton(
            label: 'Save Changes',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildPriorityChip(String label, Color color) {
    final isSelected = _selectedPriority == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? AppColors.surfaceDark : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary(context),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(color: AppColors.textPrimary(context))),
          Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }

  Widget _buildPickerField(BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.electricBlue),
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      child: Text(value, style: TextStyle(fontSize: 13, color: AppColors.textPrimary(context))),
    );
  }

  Widget _buildChecklistItem(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderColor: isDark ? AppColors.borderDark : AppColors.borderLight,
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 20, color: AppColors.textMuted(context)),
            const SizedBox(width: 8),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.textMuted(context), width: 1.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary(context)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: AppColors.danger(context)),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
