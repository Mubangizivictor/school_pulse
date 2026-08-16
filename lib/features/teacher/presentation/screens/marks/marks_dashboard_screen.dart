import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';

class MarksDashboardScreen extends StatefulWidget {
  const MarksDashboardScreen({super.key});

  @override
  State<MarksDashboardScreen> createState() => _MarksDashboardScreenState();
}

class _MarksDashboardScreenState extends State<MarksDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final active = context.read<SubjectTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<MarksBloc>().add(MarksRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      builder: (context, contextState) {
        final active = contextState.active;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: SafeArea(
            child: active == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'You are not currently assigned to teach a subject, '
                        'so there are no marks to enter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ),
                  )
                : BlocBuilder<MarksBloc, MarksState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildHeader(context, active),
                            const SizedBox(height: 24),
                            _buildSubjectCard(context, active, state),
                            const SizedBox(height: 24),
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActions(context),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Assessments',
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/staff/marks/history'),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: AppColors.primary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildAssessmentsList(context, state.assessments),
                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ActiveResponsibilityContext active) {
    return Row(
      children: [
        AvatarInitials(name: _initialsOf(active.staffId), size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marks',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              Text(
                active.subjectName ?? 'Subject',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                [
                  active.className,
                  active.streamName,
                ].where((e) => e != null && e.isNotEmpty).join(' '),
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initialsOf(String value) =>
      value.isEmpty ? '?' : value.substring(0, 1).toUpperCase();

  Widget _buildSubjectCard(
    BuildContext context,
    ActiveResponsibilityContext active,
    MarksState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = state.assessments.length;
    final pending = state.assessments
        .where((a) => a.status.acceptsEntry)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), AppColors.surfaceElevated(context)]
              : [
                  AppColors.primary(context).withValues(alpha: 0.1),
                  AppColors.surfaceElevated(context),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(context, '$total', 'Assessments'),
          _buildMetric(context, '${state.students.length}', 'Students'),
          _buildMetric(
            context,
            '$pending',
            'Open for entry',
            valueColor: AppColors.goldenYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String value,
    String label, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textMuted(context), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(
          context,
          'Enter Marks',
          Icons.edit_note,
          '/staff/marks/select-assessment',
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          context,
          'Import Marks',
          Icons.file_upload_outlined,
          '/staff/marks/import',
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          context,
          'Analytics',
          Icons.bar_chart,
          '/staff/marks/analytics',
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border(context).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary(context)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentsList(
    BuildContext context,
    List<SubjectAssessment> assessments,
  ) {
    if (assessments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No assessments have been set up for this subject yet.',
          style: TextStyle(color: AppColors.textMuted(context)),
        ),
      );
    }

    return Column(
      children: [
        for (final assessment in assessments.take(5))
          _buildAssessmentItem(context, assessment),
      ],
    );
  }

  Widget _buildAssessmentItem(
    BuildContext context,
    SubjectAssessment assessment,
  ) {
    final statusColor = switch (assessment.status) {
      AssessmentAvailability.approved ||
      AssessmentAvailability.published ||
      AssessmentAvailability.submitted => AppColors.success(context),
      AssessmentAvailability.locked ||
      AssessmentAvailability.archived => AppColors.textMuted(context),
      _ => AppColors.warning(context),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<MarksBloc>().add(MarksAssessmentSelected(assessment));
          context.push('/staff/marks/select-component');
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assessment.title.isEmpty
                        ? assessment.assessmentTypeName
                        : assessment.title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    assessment.assessmentTypeName,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                assessment.status.label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
