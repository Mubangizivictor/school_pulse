import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskEntity task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late List<TaskChecklistItem> checklist;

  @override
  void initState() {
    super.initState();
    checklist = List.from(widget.task.checklist);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isInProgress = widget.task.status == TaskStatus.inProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.task.priority == TaskPriority.high)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: StatusBadge(
                  label: 'High Priority',
                  color: Colors.black,
                  icon: Icons.verified_user,
                ),
              ),
            if (isCompleted)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: StatusBadge(
                  label: 'Completed',
                  color: Colors.black,
                  icon: Icons.check_circle,
                ),
              )
            else if (isInProgress)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: StatusBadge(
                  label: 'In Progress',
                  color: semantic.warning,
                  icon: Icons.pending_actions,
                ),
              ),

            Text(
              widget.task.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.task.category,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Due Date',
              'May 20, 2024',
            ),
            _buildDetailRow(Icons.access_time, 'Due Time', '9:00 AM'),
            if (widget.task.dormitory != null)
              _buildDetailRow(
                Icons.home_outlined,
                'Dormitory',
                widget.task.dormitory!,
              ),
            if (widget.task.assignedTo != null)
              _buildDetailRow(
                Icons.person_outline,
                'Assigned To',
                widget.task.assignedTo!,
              ),

            if (isCompleted) ...[
              _buildDetailRow(
                Icons.event_available,
                'Completed On',
                'May 20, 2024 9:30 AM',
              ),
              _buildDetailRow(
                Icons.person_pin_outlined,
                'Completed By',
                'Mrs. Akello Mary',
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.description ?? 'No description provided.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            if (isInProgress) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Progress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${checklist.where((e) => e.isCompleted).length}/${checklist.length} completed',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: checklist.isEmpty
                    ? 0
                    : checklist.where((e) => e.isCompleted).length /
                          checklist.length,
                backgroundColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Checklist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isCompleted)
                  Text(
                    '${checklist.where((e) => e.isCompleted).length}/${checklist.length} completed',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...checklist.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  onTap: isCompleted
                      ? null
                      : () {
                          setState(() {
                            checklist[index] = TaskChecklistItem(
                              id: item.id,
                              title: item.title,
                              isCompleted: !item.isCompleted,
                            );
                          });
                        },
                  child: Row(
                    children: [
                      Icon(
                        item.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: item.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.title,
                        style: TextStyle(
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isCompleted
                              ? Theme.of(context).colorScheme.outline
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (isCompleted) ...[
              const SizedBox(height: 24),
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('All students accounted for.'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attachments',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All (2)'),
                  ),
                ],
              ),
              _buildAttachment('roll_call_may20.1.jpg', '1.2 MB'),
              _buildAttachment('attendance_sheet.pdf', '450 KB'),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: isCompleted
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: isInProgress ? 'Pause Task' : 'Work In Progress',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        label: isInProgress ? 'Continue' : 'Mark Completed',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(String name, String size) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  size,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
