import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/dean/domain/entities/lesson_tracking.dart';
import 'package:school_pulse/features/dean/presentation/widgets/glass_icon_button.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';

class LessonMonitoringScreen extends StatefulWidget {
  const LessonMonitoringScreen({super.key});

  @override
  State<LessonMonitoringScreen> createState() => _LessonMonitoringScreenState();
}

class _LessonMonitoringScreenState extends State<LessonMonitoringScreen> {
  LessonStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(const LessonRecordsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Lesson Register'),
          actions: [
            GlassIconButton(
              icon: Icons.filter_list,
              tooltip: 'Filter',
              onPressed: () => _showFilterSheet(context),
            ),
            const SizedBox(width: AppSpacing.l),
          ],
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LessonRecordsLoaded) {
              final records = _statusFilter == null
                  ? state.records
                  : state.records
                        .where((r) => r.status == _statusFilter)
                        .toList();
              if (records.isEmpty) {
                return const EmptyState(
                  icon: Icons.history_edu,
                  title: 'No lesson records',
                  message: 'No lesson records found for the selected period.',
                );
              }
              return _buildLessonList(context, records);
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initialize monitoring...'));
          },
        ),
      ),
    );
  }

  Widget _buildLessonList(BuildContext context, List<LessonRecord> records) {
    final sorted = [...records]
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    final grouped = <String, List<LessonRecord>>{};
    for (final record in sorted) {
      final dateKey = DateFormat('d MMMM yyyy').format(record.scheduledAt);
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Text(
              entry.key,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          for (final record in entry.value)
            _LessonCard(record: record, statusIcon: _statusIcon(record.status)),
          const SizedBox(height: AppSpacing.l),
        ],
      ],
    );
  }

  static IconData _statusIcon(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return Icons.check_circle;
      case LessonStatus.missed:
        return Icons.error;
      case LessonStatus.planned:
        return Icons.schedule;
      case LessonStatus.rescheduled:
        return Icons.swap_horiz;
      case LessonStatus.substituted:
        return Icons.person_outline;
    }
  }

  static String _statusFilterLabel(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return 'Completed';
      case LessonStatus.missed:
        return 'Missed';
      case LessonStatus.planned:
        return 'In Progress';
      case LessonStatus.rescheduled:
        return 'Rescheduled';
      case LessonStatus.substituted:
        return 'Substituted';
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by Status', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.l),
              Wrap(
                spacing: AppSpacing.m,
                runSpacing: AppSpacing.m,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _statusFilter == null,
                    onSelected: (_) {
                      setState(() => _statusFilter = null);
                      setSheetState(() {});
                    },
                  ),
                  for (final status in LessonStatus.values)
                    ChoiceChip(
                      label: Text(_statusFilterLabel(status)),
                      selected: _statusFilter == status,
                      onSelected: (_) {
                        setState(() => _statusFilter = status);
                        setSheetState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonRecord record;
  final IconData statusIcon;

  const _LessonCard({required this.record, required this.statusIcon});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, record.status);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${record.className} - ${record.subjectName}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              StatusBadge(
                label: _statusLabel(record.status),
                color: color,
                icon: statusIcon,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Mr./Ms. ${record.teacherName}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('h:mm a').format(record.scheduledAt),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          if (record.topicCovered != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Topic: ${record.topicCovered}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return 'Completed';
      case LessonStatus.missed:
        return 'Missed';
      case LessonStatus.planned:
        return 'In Progress';
      case LessonStatus.rescheduled:
        return 'Rescheduled';
      case LessonStatus.substituted:
        return 'Substituted';
    }
  }

  Color _statusColor(BuildContext context, LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return AppColors.success(context);
      case LessonStatus.missed:
        return AppColors.danger(context);
      case LessonStatus.planned:
        return AppColors.information(context);
      case LessonStatus.rescheduled:
        return AppColors.warning(context);
      case LessonStatus.substituted:
        return AppColors.secondary(context);
    }
  }
}
