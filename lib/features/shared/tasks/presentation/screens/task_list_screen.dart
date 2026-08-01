import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../../domain/entities/mock_tasks.dart';
import '../../domain/entities/task_entity.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'create_task_screen.dart';
import 'task_filter_screen.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final actionBg = Theme.of(context).colorScheme.surfaceContainer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: actionBg),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskFilterScreen()),
            ),
            style: IconButton.styleFrom(backgroundColor: actionBg),
          ),
          const SizedBox(width: 8),
          NotificationBellButton(backgroundColor: actionBg),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                _buildTab('Today', 0),
                const SizedBox(width: 8),
                _buildTab('Upcoming', 1),
                const SizedBox(width: 8),
                _buildTab('Overdue', 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionHeader('Priority Tasks', '2'),
                ...mockTasks.where((t) => t.priority == TaskPriority.high).map((task) => TaskCard(
                  task: task,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
                  ),
                )),
                const SizedBox(height: 16),
                _buildSectionHeader('General Tasks', '3'),
                ...mockTasks.where((t) => t.priority != TaskPriority.high).take(3).map((task) => TaskCard(
                  task: task,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
                  ),
                )),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Add New Task',
                  icon: Icons.add,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
