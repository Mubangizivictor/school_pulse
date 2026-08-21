import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/app_components.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_task.dart';
import '../../domain/policies/class_task_policy.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../bloc/class_attendance/class_attendance_bloc.dart';
import '../bloc/class_tasks/class_tasks_bloc.dart';
import '../bloc/class_teacher_context/class_teacher_context_bloc.dart';
import '../bloc/class_teacher_context/class_teacher_context_event.dart';
import '../bloc/class_teacher_context/class_teacher_context_state.dart';

enum _TaskViewStatus { pending, completed, overdue, upcoming }

/// A row the Tasks screen can render: either a real [ClassTask] or the
/// synthetic "Take attendance" entry derived from today's attendance
/// session. Both need the same status/label/icon surface, so the screen
/// works against this rather than branching on type everywhere.
class _TaskRow {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final _TaskViewStatus status;
  final DateTime? dueAt;
  final String? dueLabel;
  final ClassTask? task;
  final bool isAttendance;

  const _TaskRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.status,
    this.dueAt,
    this.dueLabel,
    this.task,
    this.isAttendance = false,
  });
}

class ClassTeacherTasksScreen extends StatefulWidget {
  const ClassTeacherTasksScreen({super.key});

  @override
  State<ClassTeacherTasksScreen> createState() =>
      _ClassTeacherTasksScreenState();
}

class _ClassTeacherTasksScreenState extends State<ClassTeacherTasksScreen> {
  int _tabIndex = 0;
  static const _tabs = [
    'All Tasks',
    'Today',
    'Upcoming',
    'Overdue',
    'Completed',
  ];

  Set<String> _categoryFilter = {};
  Set<ClassTaskPriority> _priorityFilter = {};

  ActiveResponsibilityContext? _lastContext;

  // Completed tasks older than this are swept automatically, so the list
  // does not fill up with things the teacher already finished.
  static const _completedRetention = Duration(hours: 24);
  final Set<String> _sweptTaskIds = {};

  @override
  void initState() {
    super.initState();
    // This screen can be the first one shown - e.g. the app restoring
    // straight to /staff/class-tasks - so it cannot assume the dashboard
    // already requested the responsibility context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final contextState = context.read<ClassTeacherContextBloc>().state;
      if (contextState.active != null) return;
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;
      context.read<ClassTeacherContextBloc>().add(
        ClassContextRequested(
          schoolId: authState.user.schoolId,
          userId: authState.user.id,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassTeacherContextBloc, ClassTeacherContextState>(
      listenWhen: (previous, current) =>
          previous.active?.roleAssignmentId != current.active?.roleAssignmentId,
      listener: (context, contextState) {
        final active = contextState.active;
        if (active == null) return;
        _lastContext = active;
        context.read<ClassTasksBloc>().add(ClassTasksRequested(active));
        context.read<ClassAttendanceBloc>().add(
          ClassAttendanceOpened(active, date: DateTime.now()),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: _TasksAppBar(
          activeFilterCount: _categoryFilter.length + _priorityFilter.length,
          onFilterTap: () => _openFilter(context),
        ),
        body: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
          builder: (context, contextState) {
            final active = contextState.active;
            if (contextState.isLoading || active == null) {
              return const _TasksSkeleton();
            }
            if (_lastContext?.roleAssignmentId != active.roleAssignmentId) {
              _lastContext = active;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.read<ClassTasksBloc>().add(ClassTasksRequested(active));
                context.read<ClassAttendanceBloc>().add(
                  ClassAttendanceOpened(active, date: DateTime.now()),
                );
              });
            }

            return BlocConsumer<ClassTasksBloc, ClassTasksState>(
              listenWhen: (p, c) =>
                  p.errorMessage != c.errorMessage ||
                  p.successMessage != c.successMessage,
              listener: (context, state) {
                final message = state.errorMessage ?? state.successMessage;
                if (message == null) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
                context.read<ClassTasksBloc>().add(
                  const ClassTasksFeedbackCleared(),
                );
              },
              builder: (context, tasksState) {
                if (tasksState.isLoading && tasksState.tasks.isEmpty) {
                  return const _TasksSkeleton();
                }

                _sweepStaleCompletedTasks(context, tasksState);

                return BlocBuilder<ClassAttendanceBloc, ClassAttendanceState>(
                  builder: (context, attendanceState) {
                    final rows = _buildRows(tasksState, attendanceState);
                    final counts = _counts(rows);
                    final filtered = _filter(rows, _tabIndex);

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ClassTasksBloc>().add(
                          ClassTasksRequested(active),
                        );
                        context.read<ClassAttendanceBloc>().add(
                          ClassAttendanceOpened(active, date: DateTime.now()),
                        );
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.l,
                          AppSpacing.xl,
                          AppSpacing.x4l,
                        ),
                        children: [
                          _HeroBanner(),
                          const SizedBox(height: AppSpacing.l),
                          _StatRow(
                            counts: counts,
                            selectedTab: _tabIndex,
                            onSelect: (i) => setState(() => _tabIndex = i),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          SegmentedTabControlScrollable(
                            labels: _tabs,
                            selectedIndex: _tabIndex,
                            onChanged: (i) => setState(() => _tabIndex = i),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tasks',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              TextButton.icon(
                                onPressed: () => _openAddTask(context, active),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Task'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.x3l,
                              ),
                              child: EmptyState(
                                icon: Icons.task_alt,
                                title: 'No tasks here',
                                message:
                                    'Nothing in this view right now. Try another tab or add a task.',
                              ),
                            )
                          else
                            ...filtered.map(
                              (row) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.m,
                                ),
                                child: _TaskCard(
                                  row: row,
                                  onTap: () =>
                                      _openTaskDetail(context, row, active),
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.l),
                          _TipsCard(onViewTips: () => _showTips(context)),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<_TaskRow> _buildRows(
    ClassTasksState tasksState,
    ClassAttendanceState attendanceState,
  ) {
    final rows = <_TaskRow>[];

    final attendanceRow = _attendanceRow(attendanceState);
    if (attendanceRow != null) rows.add(attendanceRow);

    for (final task in tasksState.tasks) {
      rows.add(_rowForTask(task));
    }

    return rows;
  }

  _TaskRow? _attendanceRow(ClassAttendanceState state) {
    if (state.isLoading || state.context == null) return null;
    final session = state.session;
    final now = DateTime.now();
    final dueAt = DateTime(now.year, now.month, now.day, 14, 0);

    final isSubmitted = state.isSubmitted;
    final status = isSubmitted
        ? _TaskViewStatus.completed
        : (now.isAfter(dueAt)
              ? _TaskViewStatus.overdue
              : _TaskViewStatus.pending);

    return _TaskRow(
      title: 'Take attendance',
      subtitle: state.context!.className?.isNotEmpty == true
          ? state.context!.className!
          : 'Class register',
      icon: Icons.people_alt_outlined,
      iconColor: AppColors.success(context),
      iconBg: AppColors.success(context).withValues(alpha: 0.12),
      status: status,
      dueAt: dueAt,
      dueLabel: isSubmitted
          ? 'Submitted${session?.submittedAt != null ? ' ${DateFormat.jm().format(session!.submittedAt!)}' : ''}'
          : 'Due today, ${DateFormat.jm().format(dueAt)}',
      isAttendance: true,
    );
  }

  _TaskRow _rowForTask(ClassTask task) {
    final status = task.isComplete
        ? _TaskViewStatus.completed
        : (task.isOverdue()
              ? _TaskViewStatus.overdue
              : (_isToday(task.dueAt)
                    ? _TaskViewStatus.pending
                    : _TaskViewStatus.upcoming));

    final icon = _iconForCategory(task.category, task.title);
    final color = _colorForCategory(context, task.category);

    final subtitleParts = [
      if (task.subjectName?.isNotEmpty == true) task.subjectName!,
      task.category,
    ];

    return _TaskRow(
      title: task.title,
      subtitle: subtitleParts.join(' • '),
      icon: icon,
      iconColor: color,
      iconBg: color.withValues(alpha: 0.12),
      status: status,
      dueAt: task.dueAt,
      dueLabel: _dueLabel(task),
      task: task,
    );
  }

  String _dueLabel(ClassTask task) {
    if (task.isComplete) {
      final at = task.completedAt;
      return at == null
          ? 'Completed'
          : 'Completed ${DateFormat.jm().format(at)}';
    }
    final now = DateTime.now();
    if (_isToday(task.dueAt)) {
      return 'Due today, ${DateFormat.jm().format(task.dueAt)}';
    }
    if (_isTomorrow(task.dueAt)) {
      return 'Due tomorrow';
    }
    if (task.dueAt.isBefore(now)) {
      return 'Due ${DateFormat.yMMMd().format(task.dueAt)}';
    }
    return 'Due ${DateFormat.yMMMd().format(task.dueAt)}';
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isTomorrow(DateTime d) {
    final t = DateTime.now().add(const Duration(days: 1));
    return d.year == t.year && d.month == t.month && d.day == t.day;
  }

  IconData _iconForCategory(String category, String title) {
    final lower = '$category $title'.toLowerCase();
    if (lower.contains('mark') || lower.contains('grad')) {
      return Icons.edit_note;
    }
    if (lower.contains('lesson')) return Icons.menu_book_outlined;
    if (lower.contains('attend')) return Icons.people_alt_outlined;
    if (lower.contains('upload') || lower.contains('resource')) {
      return Icons.description_outlined;
    }
    if (lower.contains('meeting')) return Icons.groups_outlined;
    if (lower.contains('exam')) return Icons.fact_check_outlined;
    if (lower.contains('homework')) return Icons.assignment_outlined;
    return Icons.checklist_outlined;
  }

  Color _colorForCategory(BuildContext context, String category) {
    switch (category) {
      case 'Academic':
      case 'Examinations':
        return AppColors.danger(context);
      case 'Lessons':
        return AppColors.warning(context);
      case 'Homework':
        return AppColors.information(context);
      case 'Meetings':
        return Colors.purple;
      default:
        return AppColors.primary(context);
    }
  }

  Map<_TaskViewStatus, int> _counts(List<_TaskRow> rows) {
    final counts = {for (final s in _TaskViewStatus.values) s: 0};
    for (final row in rows) {
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    return counts;
  }

  List<_TaskRow> _filter(List<_TaskRow> rows, int tabIndex) {
    List<_TaskRow> result;
    if (_categoryFilter.isNotEmpty) {
      rows = rows
          .where(
            (r) => r.task == null || _categoryFilter.contains(r.task!.category),
          )
          .toList();
    }
    if (_priorityFilter.isNotEmpty) {
      rows = rows
          .where(
            (r) => r.task == null || _priorityFilter.contains(r.task!.priority),
          )
          .toList();
    }
    switch (tabIndex) {
      case 1:
        result = rows
            .where((r) => r.dueAt != null && _isToday(r.dueAt!))
            .toList();
        break;
      case 2:
        result = rows
            .where((r) => r.status == _TaskViewStatus.upcoming)
            .toList();
        break;
      case 3:
        result = rows
            .where((r) => r.status == _TaskViewStatus.overdue)
            .toList();
        break;
      case 4:
        result = rows
            .where((r) => r.status == _TaskViewStatus.completed)
            .toList();
        break;
      default:
        result = rows;
    }
    result.sort((a, b) {
      final ad = a.dueAt ?? DateTime(2100);
      final bd = b.dueAt ?? DateTime(2100);
      return ad.compareTo(bd);
    });
    return result;
  }

  void _sweepStaleCompletedTasks(BuildContext context, ClassTasksState state) {
    final now = DateTime.now();
    final stale = state.tasks.where((task) {
      if (!task.isComplete || _sweptTaskIds.contains(task.id)) return false;
      final completedAt = task.completedAt;
      if (completedAt == null) return false;
      return now.difference(completedAt) >= _completedRetention;
    }).toList();
    if (stale.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<ClassTasksBloc>();
      for (final task in stale) {
        _sweptTaskIds.add(task.id);
        bloc.add(ClassTaskDeleted(task));
      }
    });
  }

  void _openAddTask(BuildContext context, ActiveResponsibilityContext active) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ClassTasksBloc>(),
        child: _AddTaskSheet(activeContext: active),
      ),
    );
  }

  void _openEditTask(
    BuildContext context,
    ClassTask task,
    ActiveResponsibilityContext active,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ClassTasksBloc>(),
        child: _AddTaskSheet(activeContext: active, editingTask: task),
      ),
    );
  }

  void _openTaskDetail(
    BuildContext context,
    _TaskRow row,
    ActiveResponsibilityContext active,
  ) {
    if (row.isAttendance) {
      context.go('/staff/roll-call');
      return;
    }
    final task = row.task;
    if (task == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ClassTasksBloc>(),
        child: _TaskDetailSheet(
          task: task,
          onEdit: () {
            Navigator.of(sheetContext).pop();
            _openEditTask(context, task, active);
          },
          onDelete: () => _confirmDelete(sheetContext, task),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ClassTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.danger(dialogContext)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<ClassTasksBloc>().add(ClassTaskDeleted(task));
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openFilter(BuildContext context) async {
    final result =
        await showModalBottomSheet<(Set<String>, Set<ClassTaskPriority>)>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _FilterSheet(
            categories: _categoryFilter,
            priorities: _priorityFilter,
          ),
        );
    if (result != null) {
      setState(() {
        _categoryFilter = result.$1;
        _priorityFilter = result.$2;
      });
    }
  }

  void _showTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TipsSheet(),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.primary(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on top of your responsibilities',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and manage all your teaching tasks and deadlines in one place.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final Map<_TaskViewStatus, int> counts;
  final int selectedTab;
  final ValueChanged<int> onSelect;

  const _StatRow({
    required this.counts,
    required this.selectedTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final items = [
      (
        'Total Tasks',
        total,
        Icons.assignment_outlined,
        AppColors.primary(context),
        0,
      ),
      (
        'Completed',
        counts[_TaskViewStatus.completed] ?? 0,
        Icons.check_circle,
        AppColors.success(context),
        4,
      ),
      (
        'Pending',
        counts[_TaskViewStatus.pending] ?? 0,
        Icons.access_time_filled,
        AppColors.warning(context),
        1,
      ),
      (
        'Overdue',
        counts[_TaskViewStatus.overdue] ?? 0,
        Icons.calendar_today,
        AppColors.danger(context),
        3,
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.s),
            Expanded(
              child: _StatTile(
                label: items[i].$1,
                value: items[i].$2,
                icon: items[i].$3,
                color: items[i].$4,
                selected: selectedTab == items[i].$5,
                onTap: () => onSelect(items[i].$5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? color : null,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.m,
        horizontal: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// [SegmentedTabControl] assumes its labels fit on one row; this screen has
/// five, so it needs to scroll rather than compress illegibly on narrow
/// phones.
class SegmentedTabControlScrollable extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabControlScrollable({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? colors.primary
                        : colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: i == selectedIndex
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final _TaskRow row;
  final VoidCallback onTap;

  const _TaskCard({required this.row, required this.onTap});

  (String, Color) _badge(BuildContext context) {
    switch (row.status) {
      case _TaskViewStatus.overdue:
        return ('Overdue', AppColors.danger(context));
      case _TaskViewStatus.pending:
        return ('Pending', AppColors.warning(context));
      case _TaskViewStatus.completed:
        return ('Completed', AppColors.success(context));
      case _TaskViewStatus.upcoming:
        return ('Upcoming', AppColors.information(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _badge(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: row.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(row.icon, color: row.iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  row.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                if (row.dueLabel != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: row.status == _TaskViewStatus.overdue
                            ? AppColors.danger(context)
                            : AppColors.textMuted(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        row.dueLabel!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: row.status == _TaskViewStatus.overdue
                              ? AppColors.danger(context)
                              : row.status == _TaskViewStatus.completed
                              ? AppColors.success(context)
                              : AppColors.textMuted(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          StatusBadge(label: label, color: color),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final VoidCallback onViewTips;

  const _TipsCard({required this.onViewTips});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.information(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help managing tasks?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Organize your work better and never miss a deadline.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          SecondaryButton(label: 'View Tips', onPressed: onViewTips),
        ],
      ),
    );
  }
}

class _TipsSheet extends StatelessWidget {
  const _TipsSheet();

  static const _tips = [
    (
      Icons.priority_high,
      'Set the right priority',
      'Mark urgent marking or reporting deadlines as high priority so they surface first.',
    ),
    (
      Icons.notifications_active_outlined,
      'Use reminders',
      'Add a reminder time on a task so you get nudged before it is due.',
    ),
    (
      Icons.repeat,
      'Recurring tasks',
      'Weekly lesson plans or daily attendance can repeat automatically instead of being re-added.',
    ),
    (
      Icons.check_circle_outline,
      'Complete as you go',
      'Marking a task complete as soon as it is done keeps your Pending count honest.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Managing your tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final tip in _tips)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(tip.$1, color: AppColors.primary(context)),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.$2,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tip.$3,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _Sheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.m,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.l),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  final ActiveResponsibilityContext activeContext;
  final ClassTask? editingTask;

  const _AddTaskSheet({required this.activeContext, this.editingTask});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late final _titleController = TextEditingController(
    text: widget.editingTask?.title ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.editingTask?.description ?? '',
  );
  late String _category =
      widget.editingTask?.category ?? TaskCategories.defaults.first;
  late ClassTaskPriority _priority =
      widget.editingTask?.priority ?? ClassTaskPriority.medium;
  late DateTime _dueDate =
      widget.editingTask?.dueAt ?? DateTime.now().add(const Duration(days: 1));
  late TimeOfDay _dueTime = widget.editingTask != null
      ? TimeOfDay.fromDateTime(widget.editingTask!.dueAt)
      : const TimeOfDay(hour: 17, minute: 0);
  String? _error;

  bool get _isEditing => widget.editingTask != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassTasksBloc, ClassTasksState>(
      // A successful save transitions from saving to idle. The previous
      // condition checked for the reverse transition, so this sheet never
      // received its success callback and remained open after saving.
      listenWhen: (previous, current) =>
          previous.isSaving &&
          !current.isSaving &&
          current.successMessage != null,
      listener: (context, state) {
        if (state.successMessage != null && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: _Sheet(
        title: _isEditing ? 'Edit Task' : 'Add Task',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: TaskCategories.defaults
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<ClassTaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: ClassTaskPriority.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p.name[0].toUpperCase() + p.name.substring(1),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _priority = v ?? _priority),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat.yMMMd().format(_dueDate)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(_dueTime.format(context)),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _dueTime,
                      );
                      if (picked != null) setState(() => _dueTime = picked);
                    },
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(_error!, style: TextStyle(color: AppColors.danger(context))),
            ],
            const SizedBox(height: AppSpacing.l),
            BlocBuilder<ClassTasksBloc, ClassTasksState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: _isEditing ? 'Save Changes' : 'Save Task',
                    isLoading: state.isSaving,
                    onPressed: () => _save(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    final dueAt = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final decision = ClassTaskPolicy.canSave(
      title: _titleController.text,
      dueAt: dueAt,
      remindAt: null,
      recurrence: TaskRecurrence.none,
    );

    if (!decision.isAllowed) {
      setState(() => _error = decision.message);
      return;
    }

    final active = widget.activeContext;
    final editing = widget.editingTask;
    final task = editing != null
        ? editing.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            priority: _priority,
            dueAt: dueAt,
          )
        : ClassTask(
            id: '',
            schoolId: active.schoolId,
            campusId: active.campusId,
            classId: active.classId,
            academicYearId: active.academicYearId,
            termId: active.termId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            priority: _priority,
            dueAt: dueAt,
            subjectName: active.subjectName,
            ownerUserId: active.userId,
            createdAt: DateTime.now(),
            roleAssignmentId: active.roleAssignmentId,
          );

    context.read<ClassTasksBloc>().add(ClassTaskSaved(task));
  }
}

class _TaskDetailSheet extends StatelessWidget {
  final ClassTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskDetailSheet({
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassTasksBloc, ClassTasksState>(
      listenWhen: (previous, current) =>
          previous.isSaving &&
          !current.isSaving &&
          current.successMessage != null,
      listener: (context, state) {
        if (state.successMessage != null && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: _Sheet(
        title: task.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.danger(context),
                    ),
                    label: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.danger(context)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            _DetailRow(icon: Icons.category_outlined, label: task.category),
            _DetailRow(
              icon: Icons.flag_outlined,
              label:
                  'Priority: ${task.priority.name[0].toUpperCase()}${task.priority.name.substring(1)}',
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Due ${DateFormat.yMMMd().add_jm().format(task.dueAt)}',
            ),
            if (task.subjectName?.isNotEmpty == true)
              _DetailRow(icon: Icons.book_outlined, label: task.subjectName!),
            const SizedBox(height: AppSpacing.l),
            if (!task.isComplete)
              BlocBuilder<ClassTasksBloc, ClassTasksState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Mark Complete',
                      isLoading: state.isSaving,
                      onPressed: () => context.read<ClassTasksBloc>().add(
                        ClassTaskCompleted(task),
                      ),
                    ),
                  );
                },
              )
            else
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success(context)),
                  const SizedBox(width: 8),
                  Text(
                    'Completed'
                    '${task.completedAt != null ? ' ${DateFormat.yMMMd().add_jm().format(task.completedAt!)}' : ''}',
                    style: TextStyle(
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted(context)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TasksSkeleton extends StatelessWidget {
  const _TasksSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.x4l,
      ),
      children: const [
        Skeleton(height: 96, borderRadius: 16),
        SizedBox(height: AppSpacing.l),
        Skeleton(height: 88, borderRadius: 16),
        SizedBox(height: AppSpacing.l),
        Skeleton(height: 44, borderRadius: 24),
        SizedBox(height: AppSpacing.l),
        Skeleton(height: 76, borderRadius: 16),
        SizedBox(height: AppSpacing.m),
        Skeleton(height: 76, borderRadius: 16),
        SizedBox(height: AppSpacing.m),
        Skeleton(height: 76, borderRadius: 16),
      ],
    );
  }
}

class _TasksAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int activeFilterCount;
  final VoidCallback onFilterTap;

  const _TasksAppBar({
    required this.activeFilterCount,
    required this.onFilterTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);

  @override
  Widget build(BuildContext context) {
    final className = context
        .watch<ClassTeacherContextBloc>()
        .state
        .active
        ?.className;
    return AppBar(
      backgroundColor: AppColors.background(context),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: kToolbarHeight + 12,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tasks',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (className != null && className.isNotEmpty)
            Text(
              className,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: onFilterTap,
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.background(context),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$activeFilterCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.s),
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final Set<String> categories;
  final Set<ClassTaskPriority> priorities;

  const _FilterSheet({required this.categories, required this.priorities});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _categories = {...widget.categories};
  late Set<ClassTaskPriority> _priorities = {...widget.priorities};

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Filter tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final category in TaskCategories.defaults)
                FilterChip(
                  label: Text(category),
                  selected: _categories.contains(category),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _categories.add(category);
                    } else {
                      _categories.remove(category);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Priority',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final priority in ClassTaskPriority.values)
                FilterChip(
                  label: Text(
                    priority.name[0].toUpperCase() + priority.name.substring(1),
                  ),
                  selected: _priorities.contains(priority),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _priorities.add(priority);
                    } else {
                      _priorities.remove(priority);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _categories = {};
                    _priorities = {};
                  }),
                  child: const Text('Clear all'),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, (_categories, _priorities)),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
