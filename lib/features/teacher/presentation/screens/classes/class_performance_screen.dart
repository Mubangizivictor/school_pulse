import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_performance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class ClassPerformanceScreen extends StatefulWidget {
  final String classId;
  const ClassPerformanceScreen({super.key, required this.classId});

  @override
  State<ClassPerformanceScreen> createState() => _ClassPerformanceScreenState();
}

class _ClassPerformanceScreenState extends State<ClassPerformanceScreen> {
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
    final primaryColor = AppColors.textPrimary(context);

    return BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
      builder: (context, contextState) {
        final active = contextState.active;
        final subtitle = active == null
            ? 'No class assigned'
            : [
                [
                  active.className,
                  active.streamName,
                ].where((e) => e != null && e.isNotEmpty).join(' '),
                [
                  active.termName,
                  active.academicYearName,
                ].where((e) => e.isNotEmpty).join(', '),
              ].where((e) => e.isNotEmpty).join(' • ');

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Performance',
                  style: AppTypography.titleLarge.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          body: active == null
              ? _message(
                  isDark,
                  'You are not currently the Class Teacher for any class.',
                )
              : BlocBuilder<ClassPerformanceBloc, ClassPerformanceState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: const SchoolPulseLoader());
                    }

                    if (!state.hasSummary) {
                      return _message(
                        isDark,
                        state.errorMessage ??
                            'No performance data for your class yet.',
                      );
                    }

                    final summary = state.summary!;

                    if (summary.students.isEmpty) {
                      return _message(
                        isDark,
                        'No students have been placed in your class for this '
                        'academic year.',
                      );
                    }

                    if (state.awaitingMarks) {
                      // Approved marks are what this screen measures; saying
                      // so beats showing a page of dashes.
                      return _message(
                        isDark,
                        'No approved marks for your class this term yet. '
                        'Figures appear once subject teachers submit and the '
                        'academic office approves them.',
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeadline(context, summary, isDark),
                          const SizedBox(height: AppSpacing.x3l),
                          PulseCard(
                            child: Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < summary.subjects.length;
                                  i++
                                ) ...[
                                  if (i > 0)
                                    const Divider(height: AppSpacing.x3l),
                                  _buildSubjectPerformance(
                                    summary.subjects[i],
                                    _colorFor(i),
                                    isDark,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (summary.needingAttention.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.x3l),
                            Text(
                              'Needs your attention',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            for (final flagged in summary.needingAttention)
                              _buildAttentionRow(context, flagged, isDark),
                          ],
                          const SizedBox(height: AppSpacing.x3l),
                          PulseButton(
                            label: 'View Detailed Analysis',
                            onPressed: () =>
                                context.push('/staff/class-analytics'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _message(bool isDark, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(
    BuildContext context,
    ClassPerformanceSummary summary,
    bool isDark,
  ) {
    final average = summary.classAverage;
    final passRate = summary.passRate;

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(
            average == null ? '—' : '${average.toStringAsFixed(1)}%',
            'Class average',
            AppColors.royalBlue,
            isDark,
          ),
          _stat(
            passRate == null ? '—' : '${passRate.toStringAsFixed(0)}%',
            'Pass rate',
            AppColors.successGreen,
            isDark,
          ),
          // Named rather than hidden: an average over two thirds of the class
          // is not the class's average, and the teacher should see the gap.
          _stat(
            '${summary.studentsAwaitingMarks}',
            'Awaiting marks',
            AppColors.goldenYellow,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAttentionRow(
    BuildContext context,
    StudentNeedingAttention flagged,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: PulseCard(
        padding: const EdgeInsets.all(AppSpacing.l),
        onTap: () =>
            context.push('/staff/students/${flagged.student.studentId}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flagged.student.studentName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Situations, not labels: each of these can be resolved, and
                  // none of them is a description of the child.
                  Text(
                    flagged.reasons.map((r) => r.label).join(' • '),
                    style: AppTypography.labelSmall.copyWith(
                      color: flagged.isDataOnly
                          ? AppColors.textMutedLight
                          : AppColors.danger(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              flagged.student.average == null
                  ? '—'
                  : '${flagged.student.average!.toStringAsFixed(0)}%',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorFor(int index) {
    const palette = [
      AppColors.royalBlue,
      AppColors.electricBlue,
      AppColors.successGreen,
      AppColors.brightCyan,
      AppColors.goldenYellow,
    ];
    return palette[index % palette.length];
  }

  Widget _buildSubjectPerformance(
    SubjectPerformanceSummary subject,
    Color color,
    bool isDark,
  ) {
    final average = subject.average;
    final coverage = subject.coverage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                subject.subjectName,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  average == null ? '—' : '${average.toStringAsFixed(0)}%',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.elevatedSurfaceDark
                        : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  // How much of the class this average actually covers -
                  // grading is the Report Card Engine's, not this screen's.
                  child: Text(
                    '${subject.studentsWithMarks}/${subject.studentsExpected}',
                    style: AppTypography.labelSmall.copyWith(
                      color: subject.isComplete
                          ? (AppColors.textPrimary(context))
                          : AppColors.goldenYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (average ?? 0) / 100,
            backgroundColor: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              // Faded while the marks are still coming in, so a partial
              // average does not read as a settled one.
              (coverage ?? 1) < 1 ? color : color,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
