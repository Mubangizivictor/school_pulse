import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/assessment_moderation.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Assessments Overview — root of the Assessments tab. Lists every
/// [AssessmentModeration] with a status badge; tapping it can push
/// Marks Completion Matrix / Interventions (handled by the shell's tab
/// navigator per the plan's tab mapping).
class AssessmentsOverviewScreen extends StatelessWidget {
  const AssessmentsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(AssessmentsOverviewRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
          automaticallyImplyLeading: false,
          title: Text('Assessments Overview', style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is AssessmentsOverviewLoaded) {
              if (state.assessments.isEmpty) {
                return const EmptyState(
                  icon: Icons.fact_check_outlined,
                  title: 'No assessments',
                  message: 'No assessments have been submitted yet.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: state.assessments.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.l),
                itemBuilder: (context, index) =>
                    _AssessmentCard(assessment: state.assessments[index]),
              );
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load assessments',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final AssessmentModeration assessment;

  const _AssessmentCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assessment.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              StatusBadge(
                label: _statusLabel(assessment.status),
                color: _statusColor(context, assessment.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${assessment.subjectName} • ${assessment.className}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  assessment.teacherName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
              Text(
                '${assessment.submissionCount}/${assessment.totalStudents} submitted',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Average: ${assessment.averageScore.toStringAsFixed(1)}%',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (assessment.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Rejected: ${assessment.rejectionReason}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(ModerationStatus status) {
    switch (status) {
      case ModerationStatus.pending:
        return 'Pending';
      case ModerationStatus.approved:
        return 'Approved';
      case ModerationStatus.rejected:
        return 'Rejected';
    }
  }

  Color _statusColor(BuildContext context, ModerationStatus status) {
    switch (status) {
      case ModerationStatus.pending:
        return AppColors.warning(context);
      case ModerationStatus.approved:
        return AppColors.success(context);
      case ModerationStatus.rejected:
        return AppColors.danger(context);
    }
  }
}
