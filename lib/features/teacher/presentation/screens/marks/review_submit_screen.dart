import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/domain/policies/marks_entry_policy.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class ReviewSubmitScreen extends StatelessWidget {
  const ReviewSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<MarksBloc, MarksState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success(context),
            ),
          );
          context.go('/staff/marks');
          return;
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final assessment = state.selectedAssessment;
        final component = state.selectedComponent;
        final review = state.review;

        if (assessment == null || component == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(title: const Text('Review & Submit')),
            body: const Center(child: Text('Nothing to review.')),
          );
        }

        final entries = state.entries.values.toList();
        final named = [
          for (final entry in entries)
            (
              name: state.students
                      .where((s) => s.studentId == entry.studentId)
                      .firstOrNull
                      ?.name ??
                  'Unknown',
              entry: entry,
            ),
        ]..sort((a, b) => a.name.compareTo(b.name));

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
            ),
            title: Column(
              children: [
                Text(
                  'Review & Submit',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${assessment.title.isEmpty ? assessment.assessmentTypeName : assessment.title} • ${component.name}',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: state.isSaving && review == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        theme,
                        'Total Students',
                        '${review?.totalStudents ?? state.students.length}',
                      ),
                      _buildSummaryRow(
                        theme,
                        'Marks Entered',
                        '${review?.entered ?? state.enteredCount}',
                      ),
                      _buildSummaryRow(
                        theme,
                        'Marks Pending',
                        '${review?.pending ?? 0}',
                        valueColor: AppColors.warning(context),
                      ),
                      _buildSummaryRow(
                        theme,
                        'Maximum Mark',
                        component.maximumMark.toStringAsFixed(0),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Quick Preview',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final row in named.take(3))
                        _buildPreviewItem(
                          theme,
                          named.indexOf(row) + 1,
                          row.name,
                          row.entry,
                          component,
                        ),
                      if (named.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 8),
                          child: Text(
                            '... and ${named.length - 3} more students',
                            style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      if (review?.refusal != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.danger(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.danger(context).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline, color: AppColors.danger(context), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _refusalMessage(review!.refusal!),
                                  style: TextStyle(
                                    color: AppColors.danger(context),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  assessment.requiresApproval
                                      ? 'Once submitted, marks go to the '
                                            'academic office for approval.'
                                      : 'Once submitted, marks will be '
                                            'locked for editing.',
                                  style: TextStyle(
                                    color: theme.hintColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (review?.canSubmit ?? false) && !state.isSaving
                              ? () => context.read<MarksBloc>().add(
                                  const MarksSubmitted(),
                                )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit Marks',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  static String _refusalMessage(SubmissionRefusal refusal) => switch (refusal) {
    SubmissionRefusal.noPermission =>
      'You do not have permission to submit marks for this assessment.',
    SubmissionRefusal.outsideScope =>
      'This assessment is outside your current teaching assignment.',
    SubmissionRefusal.assessmentNotOpen =>
      'This assessment is not open for entry yet.',
    SubmissionRefusal.assessmentLocked =>
      'This assessment has been locked and can no longer accept marks.',
    SubmissionRefusal.entryNotOpenYet =>
      'Entry for this component has not opened yet.',
    SubmissionRefusal.missingMarks =>
      'Some students still need a mark or a status before you can submit.',
    SubmissionRefusal.invalidMarks =>
      'One or more marks are outside the valid range for this component.',
    SubmissionRefusal.noStudents =>
      'There are no students to submit marks for.',
  };

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
    ThemeData theme,
    int rank,
    String name,
    StudentMarkEntry entry,
    AssessmentComponent component,
  ) {
    final score = entry.status == MarkEntryStatus.scored
        ? '${entry.score?.toStringAsFixed(0) ?? '--'}/${component.maximumMark.toStringAsFixed(0)}'
        : entry.status.label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$rank.', style: TextStyle(color: theme.hintColor, fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
