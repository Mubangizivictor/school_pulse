import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../data/repositories/director_governance_repository.dart';
import '../../domain/entities/strategic_goal.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/director_drawer.dart';

class StrategicGoalsScreen extends StatefulWidget {
  const StrategicGoalsScreen({super.key});
  @override
  State<StrategicGoalsScreen> createState() => _StrategicGoalsScreenState();
}

class _StrategicGoalsScreenState extends State<StrategicGoalsScreen> {
  final _repository = DirectorGovernanceRepository();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view goals.')),
      );
    }
    final schoolId = auth.user.schoolId;
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(
        title: const Text('Strategic Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New goal',
            onPressed: () => _openGoalEditor(context, schoolId),
          ),
        ],
      ),
      body: StreamBuilder<List<StrategicGoal>>(
        stream: _repository.watchGoals(schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load goals: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final goals = snapshot.data!;
          if (goals.isEmpty) {
            return const Center(
              child: Text('No strategic goals yet. Tap + to add one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _GoalCard(
              goal: goals[i],
              onTap: () => _openGoalEditor(context, schoolId, goal: goals[i]),
              onUpdateProgress: () =>
                  _openProgressEditor(context, schoolId, goals[i]),
              onDelete: () => _repository.deleteGoal(schoolId, goals[i].goalId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openGoalEditor(
    BuildContext context,
    String schoolId, {
    StrategicGoal? goal,
  }) async {
    final titleController = TextEditingController(text: goal?.title);
    final descController = TextEditingController(text: goal?.description);
    final deptController = TextEditingController(
      text: goal?.responsibleDepartment,
    );
    final targetController = TextEditingController(
      text: goal?.targetValue.toString() ?? '',
    );
    final unitController = TextEditingController(text: goal?.unit ?? '%');
    DateTime deadline =
        goal?.deadline ?? DateTime.now().add(const Duration(days: 90));

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(goal == null ? 'New strategic goal' : 'Edit goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(
                    labelText: 'Responsible department',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target value',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline'),
                  subtitle: Text(DateFormat.yMMMd().format(deadline)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 3),
                      ),
                    );
                    if (picked != null) setState(() => deadline = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !context.mounted) return;
    if (titleController.text.trim().isEmpty) return;

    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    await _repository.saveGoal(
      schoolId,
      StrategicGoal(
        goalId: goal?.goalId ?? '',
        institutionId: schoolId,
        title: titleController.text.trim(),
        description: descController.text.trim(),
        responsibleDepartment: deptController.text.trim(),
        targetValue: double.tryParse(targetController.text.trim()) ?? 0,
        currentValue: goal?.currentValue ?? 0,
        unit: unitController.text.trim(),
        status: goal?.status ?? GoalStatus.onTrack,
        deadline: deadline,
        createdAt: goal?.createdAt ?? DateTime.now(),
        createdBy: goal?.createdBy ?? auth.user.id,
      ),
    );
  }

  Future<void> _openProgressEditor(
    BuildContext context,
    String schoolId,
    StrategicGoal goal,
  ) async {
    final valueController = TextEditingController(
      text: goal.currentValue.toString(),
    );
    var status = goal.status;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Update: ${goal.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current value (${goal.unit})',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GoalStatus>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: GoalStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => status = v ?? status),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    await _repository.updateGoalProgress(
      schoolId,
      goal.goalId,
      currentValue:
          double.tryParse(valueController.text.trim()) ?? goal.currentValue,
      status: status,
    );
  }
}

class _GoalCard extends StatelessWidget {
  final StrategicGoal goal;
  final VoidCallback onTap, onUpdateProgress, onDelete;
  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onUpdateProgress,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (goal.status) {
      case GoalStatus.onTrack:
        return Colors.black;
      case GoalStatus.atRisk:
        return Colors.black;
      case GoalStatus.behind:
        return Colors.black;
      case GoalStatus.achieved:
        return Colors.black;
      case GoalStatus.abandoned:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.status.name.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              goal.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal.progressPercentage / 100,
            backgroundColor: color,
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.currentValue.toStringAsFixed(0)} / ${goal.targetValue.toStringAsFixed(0)} ${goal.unit}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Due ${DateFormat.yMMMd().format(goal.deadline)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          if (goal.responsibleDepartment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              goal.responsibleDepartment,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onUpdateProgress,
                child: const Text('Update progress'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
