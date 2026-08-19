import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/today_operations.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Today's Operations — a KPI-grid snapshot of the school's live academic
/// day: lesson delivery, assessments, teacher absences and meetings.
class TodaysOperationsScreen extends StatelessWidget {
  const TodaysOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(TodaysOperationsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
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
    final cards = [
      DashboardStatCard(
        title: 'Lessons Scheduled',
        value: ops.lessonsScheduled.toDouble(),
        icon: Icons.event_note,
        color: AppColors.primary(context),
      ),
      DashboardStatCard(
        title: 'Lessons Completed',
        value: ops.lessonsCompleted.toDouble(),
        icon: Icons.check_circle_outline,
        color: AppColors.success(context),
      ),
      DashboardStatCard(
        title: 'In Progress',
        value: ops.lessonsInProgress.toDouble(),
        icon: Icons.play_circle_outline,
        color: AppColors.secondary(context),
      ),
      DashboardStatCard(
        title: 'Missed',
        value: ops.lessonsMissed.toDouble(),
        icon: Icons.cancel_outlined,
        color: AppColors.danger(context),
      ),
      DashboardStatCard(
        title: 'Assessments Today',
        value: ops.assessmentsToday.toDouble(),
        icon: Icons.fact_check_outlined,
        color: AppColors.primary(context),
      ),
      DashboardStatCard(
        title: 'Awaiting Confirmation',
        value: ops.awaitingConfirmation.toDouble(),
        icon: Icons.hourglass_empty,
        color: AppColors.warning(context),
      ),
      DashboardStatCard(
        title: 'Teacher Absences',
        value: ops.teacherAbsences.toDouble(),
        icon: Icons.person_off_outlined,
        color: AppColors.danger(context),
      ),
      DashboardStatCard(
        title: 'Substitute Lessons',
        value: ops.substituteLessons.toDouble(),
        icon: Icons.swap_horiz,
        color: AppColors.secondary(context),
      ),
      DashboardStatCard(
        title: 'Examinations Today',
        value: ops.examinationsToday.toDouble(),
        icon: Icons.school_outlined,
        color: AppColors.primary(context),
      ),
      DashboardStatCard(
        title: 'Meetings Today',
        value: ops.meetingsToday.toDouble(),
        icon: Icons.groups_outlined,
        color: AppColors.success(context),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SectionHeader(title: 'Live Snapshot'),
        const SizedBox(height: AppSpacing.l),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.l,
            mainAxisSpacing: AppSpacing.l,
            childAspectRatio: 1.5,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        ),
      ],
    );
  }
}
