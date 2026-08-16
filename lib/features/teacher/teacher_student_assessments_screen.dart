import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

/// Approved subject marks for this student. The performance repository joins
/// marks per subject, not per individual assessment, so this is the subject
/// breakdown - the same numbers the Performance tab shows, listed out.
class TeacherStudentAssessmentsScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentAssessmentsScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentAssessmentsScreen> createState() =>
      _TeacherStudentAssessmentsScreenState();
}

class _TeacherStudentAssessmentsScreenState
    extends State<TeacherStudentAssessmentsScreen> {
  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassPerformanceBloc>().add(
        ClassPerformanceRequested(active),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Assessments',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: BlocBuilder<ClassPerformanceBloc, ClassPerformanceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = state.summary;
          final student = summary?.students
              .where((s) => s.studentId == widget.studentId)
              .firstOrNull;

          if (summary == null ||
              student == null ||
              student.subjectPercentages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No approved marks for this student yet.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ),
            );
          }

          final subjectNameOf = {
            for (final s in summary.subjects) s.subjectId: s.subjectName,
          };
          final subjectIds = student.subjectPercentages.keys.toList()
            ..sort(
              (a, b) => (subjectNameOf[a] ?? a).compareTo(
                subjectNameOf[b] ?? b,
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: subjectIds.length,
            itemBuilder: (context, index) {
              final subjectId = subjectIds[index];
              final percentage = student.subjectPercentages[subjectId]!;
              return _AssessmentTile(
                subjectName: subjectNameOf[subjectId] ?? subjectId,
                percentage: percentage,
                passMark: summary.passMark,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  final String subjectName;
  final double percentage;
  final double passMark;
  final bool isDark;

  const _AssessmentTile({
    required this.subjectName,
    required this.percentage,
    required this.passMark,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final passed = percentage >= passMark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  passed ? 'Passing' : 'Below pass mark',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: AppTypography.titleMedium.copyWith(
              color: passed ? AppColors.successGreen : AppColors.errorRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
