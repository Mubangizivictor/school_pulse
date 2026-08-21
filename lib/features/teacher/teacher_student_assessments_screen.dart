import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'domain/entities/class_performance.dart';
import 'presentation/bloc/class_performance/class_performance_bloc.dart';
import 'presentation/bloc/class_performance/student_assessment_results_bloc.dart';
import 'presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

/// Subjects the student sits, each expandable into its individual approved
/// assessment results - resolved on demand per subject rather than upfront,
/// since a class teacher only opens the subjects they came here to check.
class TeacherStudentAssessmentsScreen extends StatefulWidget {
  final String studentId;
  final String? initialSubjectId;

  const TeacherStudentAssessmentsScreen({
    super.key,
    required this.studentId,
    this.initialSubjectId,
  });

  @override
  State<TeacherStudentAssessmentsScreen> createState() =>
      _TeacherStudentAssessmentsScreenState();
}

class _TeacherStudentAssessmentsScreenState
    extends State<TeacherStudentAssessmentsScreen> {
  bool _openedInitial = false;

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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Assessments',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: BlocBuilder<ClassPerformanceBloc, ClassPerformanceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
            );
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
                    color: AppColors.textMuted(context),
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
              (a, b) =>
                  (subjectNameOf[a] ?? a).compareTo(subjectNameOf[b] ?? b),
            );

          if (!_openedInitial &&
              widget.initialSubjectId != null &&
              subjectIds.contains(widget.initialSubjectId)) {
            _openedInitial = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _openSubject(
                context,
                subjectId: widget.initialSubjectId!,
                subjectName:
                    subjectNameOf[widget.initialSubjectId!] ??
                    widget.initialSubjectId!,
                percentage:
                    student.subjectPercentages[widget.initialSubjectId!]!,
                passMark: summary.passMark,
              );
            });
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: subjectIds.length,
            itemBuilder: (context, index) {
              final subjectId = subjectIds[index];
              final percentage = student.subjectPercentages[subjectId]!;
              return _SubjectTile(
                subjectName: subjectNameOf[subjectId] ?? subjectId,
                percentage: percentage,
                passMark: summary.passMark,
                onTap: () => _openSubject(
                  context,
                  subjectId: subjectId,
                  subjectName: subjectNameOf[subjectId] ?? subjectId,
                  percentage: percentage,
                  passMark: summary.passMark,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openSubject(
    BuildContext context, {
    required String subjectId,
    required String subjectName,
    required double percentage,
    required double passMark,
  }) {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => di.sl<StudentAssessmentResultsBloc>()
          ..add(
            StudentAssessmentResultsRequested(
              context: active,
              studentId: widget.studentId,
              subjectId: subjectId,
            ),
          ),
        child: _SubjectAssessmentSheet(
          subjectName: subjectName,
          percentage: percentage,
          passMark: passMark,
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final String subjectName;
  final double percentage;
  final double passMark;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subjectName,
    required this.percentage,
    required this.passMark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final passed = percentage >= passMark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.l),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.l),
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(AppSpacing.l),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.m),
              ),
              child: Icon(Icons.menu_book, color: AppColors.primary(context)),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (passed
                                  ? AppColors.success(context)
                                  : AppColors.danger(context))
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.s),
                    ),
                    child: Text(
                      passed ? 'Passing' : 'Below pass mark',
                      style: AppTypography.labelSmall.copyWith(
                        color: passed
                            ? AppColors.success(context)
                            : AppColors.danger(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTypography.titleMedium.copyWith(
                color: passed
                    ? AppColors.success(context)
                    : AppColors.danger(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}

class _SubjectAssessmentSheet extends StatelessWidget {
  final String subjectName;
  final double percentage;
  final double passMark;

  const _SubjectAssessmentSheet({
    required this.subjectName,
    required this.percentage,
    required this.passMark,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.xl),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.m),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subjectName,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: AppTypography.titleLarge.copyWith(
                        color: percentage >= passMark
                            ? AppColors.success(context)
                            : AppColors.danger(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<
                      StudentAssessmentResultsBloc,
                      StudentAssessmentResultsState
                    >(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.errorMessage != null) {
                          return Center(
                            child: Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted(context),
                              ),
                            ),
                          );
                        }

                        final results = state.results ?? const [];
                        if (results.isEmpty) {
                          return Center(
                            child: Text(
                              'No individual assessment records found for this '
                              'subject.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted(context),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, index) =>
                              _AssessmentResultTile(result: results[index]),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssessmentResultTile extends StatelessWidget {
  final StudentAssessmentResult result;

  const _AssessmentResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.displayName.isEmpty
                      ? 'Assessment'
                      : result.displayName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (result.assessmentDate != null)
                  Text(
                    _formatDate(result.assessmentDate!),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${result.score.toStringAsFixed(0)}/${result.maximumMark.toStringAsFixed(0)}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
