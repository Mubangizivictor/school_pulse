import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  Color _getCategoryColor(String category) {
    if (category.contains('Attendance')) return Colors.green;
    if (category.contains('Hygiene') || category.contains('Inspection'))
      return Colors.purple;
    if (category.contains('Welfare') || category.contains('Sarah'))
      return Colors.orange;
    return Colors.blue;
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Attendance')) return Icons.verified_user_outlined;
    if (category.contains('Hygiene') || category.contains('Inspection'))
      return Icons.cleaning_services_outlined;
    if (category.contains('Welfare') || category.contains('Sarah'))
      return Icons.favorite_border;
    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final color = _getCategoryColor(task.category);
    final isOverdue = task.status == TaskStatus.overdue;

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(task.category),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Overdue by ${DateTime.now().difference(task.dueDate).inDays} days',
                    style: TextStyle(
                      color: semantic.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${task.dueTime.hour.toString().padLeft(2, '0')}:${task.dueTime.minute.toString().padLeft(2, '0')} ${task.dueTime.period == DayPeriod.am ? 'AM' : 'PM'}',
                style: TextStyle(
                  color: isOverdue ? semantic.error : semantic.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              if (task.status == TaskStatus.completed)
                const Icon(Icons.check_box, color: Colors.blue, size: 22)
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isOverdue
                      ? Center(
                          child: Icon(
                            Icons.close,
                            color: semantic.error,
                            size: 14,
                          ),
                        )
                      : null,
                ),
              if (isOverdue) ...[
                const SizedBox(height: 4),
                Text(
                  'May 19',
                  style: TextStyle(color: semantic.error, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
