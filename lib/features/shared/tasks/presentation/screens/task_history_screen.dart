import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import '../../domain/entities/mock_tasks.dart';
import '../../domain/entities/task_entity.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';

class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedTasks = mockTasks
        .where((t) => t.status == TaskStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        title: const Text('Task History'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: completedTasks.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'No Completed Tasks',
              message: 'Tasks you complete will appear here for your records.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0 ||
                        _shouldShowDateHeader(completedTasks, index))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(
                          _formatDateHeader(task.completedAt ?? task.dueDate),
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    TaskCard(
                      task: task,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailsScreen(task: task),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  bool _shouldShowDateHeader(List<TaskEntity> tasks, int index) {
    final current = tasks[index].completedAt ?? tasks[index].dueDate;
    final previous = tasks[index - 1].completedAt ?? tasks[index - 1].dueDate;
    return current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    } else if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Yesterday';
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
