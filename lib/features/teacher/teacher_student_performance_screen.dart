import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_performance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class TeacherStudentPerformanceScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentPerformanceScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentPerformanceScreen> createState() =>
      _TeacherStudentPerformanceScreenState();
}

class _TeacherStudentPerformanceScreenState
    extends State<TeacherStudentPerformanceScreen> {
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
          'Performance',
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

          if (summary == null || student == null) {
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _buildAverageCircle(isDark, student.average),
                const SizedBox(height: AppSpacing.x2l),
                _buildStatsRow(isDark, student),
                const SizedBox(height: AppSpacing.x3l),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Subject Performance',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                if (student.subjectPercentages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.m,
                    ),
                    child: Text(
                      'No subject marks approved yet.',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  )
                else
                  for (final entry in student.subjectPercentages.entries)
                    _SubjectProgressRow(
                      name: subjectNameOf[entry.key] ?? entry.key,
                      score: entry.value / 100,
                      label: '${entry.value.toStringAsFixed(0)}%',
                      isDark: isDark,
                    ),
                const SizedBox(height: AppSpacing.x3l),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/staff/students/${widget.studentId}/assessments',
                    ),
                    icon: const Icon(
                      Icons.list_alt,
                      color: AppColors.royalBlue,
                    ),
                    label: const Text(
                      'View All Assessments',
                      style: TextStyle(color: AppColors.royalBlue),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.royalBlue),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.l,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.m),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAverageCircle(bool isDark, double? average) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: average == null ? 0 : average / 100,
            strokeWidth: 12,
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.successGreen,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              average == null ? '—' : '${average.toStringAsFixed(0)}%',
              style: AppTypography.headlineLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Average',
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDark, StudentPerformanceSummary student) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Attendance',
            value: student.attendanceRate == null
                ? '—'
                : '${student.attendanceRate!.toStringAsFixed(0)}%',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _StatBox(
            label: 'Subjects Marked',
            value: '${student.subjectPercentages.length}',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _StatBox(
            label: 'Open Follow-ups',
            value: '${student.openBehaviourFollowUps}',
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatBox({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  final String name;
  final double score;
  final String label;
  final bool isDark;

  const _SubjectProgressRow({
    required this.name,
    required this.score,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score.clamp(0, 1),
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.royalBlue,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
