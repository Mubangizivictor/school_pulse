import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/today_operations.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Today's Operations — a vertical list of the school's live academic
/// day metrics: lesson delivery, assessments, teacher absences and meetings.
class TodaysOperationsScreen extends StatelessWidget {
  const TodaysOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(TodaysOperationsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainer(context),
          title: Text("Today's Operations", style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is TodaysOperationsLoaded) {
              return _buildContent(context, state.operations);
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load operations',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodaysOperations ops) {
    final rows = [
      _OperationRowData(
        'Lessons Scheduled',
        ops.lessonsScheduled,
        Icons.event_note,
        AppColors.primary(context),
        onTap: () => Navigator.of(context).pushNamed('lessons'),
      ),
      _OperationRowData(
        'Lessons Completed',
        ops.lessonsCompleted,
        Icons.check_circle_outline,
        AppColors.success(context),
        onTap: () => Navigator.of(context).pushNamed('lessons'),
      ),
      _OperationRowData(
        'Lessons In Progress',
        ops.lessonsInProgress,
        Icons.play_circle_outline,
        AppColors.secondary(context),
        onTap: () => Navigator.of(context).pushNamed('lessons'),
      ),
      _OperationRowData(
        'Lessons Missed',
        ops.lessonsMissed,
        Icons.cancel_outlined,
        AppColors.danger(context),
        onTap: () => Navigator.of(context).pushNamed('missed-lessons'),
      ),
      _OperationRowData(
        'Awaiting Confirmation',
        ops.awaitingConfirmation,
        Icons.hourglass_empty,
        AppColors.warning(context),
        onTap: () => Navigator.of(context).pushNamed('lessons'),
      ),
      _OperationRowData(
        'Teacher Absences',
        ops.teacherAbsences,
        Icons.person_off_outlined,
        AppColors.danger(context),
      ),
      _OperationRowData(
        'Substitute Lessons',
        ops.substituteLessons,
        Icons.swap_horiz,
        AppColors.secondary(context),
      ),
      _OperationRowData(
        'Assessments Today',
        ops.assessmentsToday,
        Icons.fact_check_outlined,
        AppColors.primary(context),
      ),
      _OperationRowData(
        'Examinations Today',
        ops.examinationsToday,
        Icons.school_outlined,
        AppColors.primary(context),
      ),
      _OperationRowData(
        'Meetings Today',
        ops.meetingsToday,
        Icons.groups_outlined,
        AppColors.success(context),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _OperationRow(data: rows[i]),
                if (i != rows.length - 1)
                  Divider(height: 1, color: AppColors.border(context)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OperationRowData {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _OperationRowData(
    this.label,
    this.count,
    this.icon,
    this.color, {
    this.onTap,
  });
}

class _OperationRow extends StatelessWidget {
  final _OperationRowData data;

  const _OperationRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: Icon(data.icon, color: data.color, size: 18),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Text(
                data.label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              '${data.count}',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            if (data.onTap != null) ...[
              const SizedBox(width: AppSpacing.s),
              Icon(
                Icons.chevron_right,
                color: AppColors.textMuted(context),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
