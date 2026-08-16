import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class StudentMarksDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentMarksDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarksBloc, MarksState>(
      builder: (context, state) {
        final student = state.students
            .where((s) => s.studentId == studentId)
            .firstOrNull;
        final assessment = state.selectedAssessment;

        if (student == null || assessment == null) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: AppBar(title: const Text('Student Marks Detail')),
            body: const Center(child: Text('No marks to show.')),
          );
        }

        final components = assessment.markableComponents;
        final entry = state.entries[studentId];
        final scored = entry?.status == MarkEntryStatus.scored
            ? entry!.score
            : null;
        final maxMark = components.isEmpty
            ? assessment.maximumMark
            : (state.selectedComponent?.maximumMark ?? assessment.maximumMark);
        final percentage = scored == null || maxMark <= 0
            ? null
            : (scored / maxMark * 100);

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Student Marks Detail',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
                      ? NetworkImage(student.photoUrl!)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  student.name,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  student.admissionNumber,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  student.className,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 32),
                _buildAssessmentSummary(
                  context,
                  assessment,
                  scored,
                  maxMark,
                  percentage,
                ),
                const SizedBox(height: 24),
                if (components.length > 1)
                  _buildComponentBreakdown(context, components, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentSummary(
    BuildContext context,
    SubjectAssessment assessment,
    double? scored,
    double maxMark,
    double? percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            assessment.title.isEmpty
                ? assessment.assessmentTypeName
                : assessment.title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: scored == null || maxMark <= 0
                          ? 0
                          : (scored / maxMark).clamp(0, 1),
                      strokeWidth: 8,
                      backgroundColor: AppColors.border(context),
                      color: AppColors.success(context),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scored?.toStringAsFixed(0) ?? '—',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/ ${maxMark.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem(
                    context,
                    'Percentage',
                    percentage == null
                        ? '—'
                        : '${percentage.toStringAsFixed(0)}%',
                    AppColors.success(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentBreakdown(
    BuildContext context,
    List<AssessmentComponent> components,
    MarksState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Component Breakdown',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        for (final component in components)
          _buildComponentItem(context, component, state),
      ],
    );
  }

  Widget _buildComponentItem(
    BuildContext context,
    AssessmentComponent component,
    MarksState state,
  ) {
    final isSelected = state.selectedComponent?.id == component.id;
    final entry = isSelected ? state.entries[studentId] : null;
    final scoreLabel = entry?.status == MarkEntryStatus.scored
        ? '${entry!.score?.toStringAsFixed(0) ?? '--'} / ${component.maximumMark.toStringAsFixed(0)}'
        : '-- / ${component.maximumMark.toStringAsFixed(0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            component.name,
            style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
          ),
          Text(
            scoreLabel,
            style: TextStyle(
              color: entry?.status == MarkEntryStatus.scored
                  ? AppColors.success(context)
                  : AppColors.textMuted(context),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
