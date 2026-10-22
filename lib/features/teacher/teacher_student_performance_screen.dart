import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/components/circular_progress_gauge.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import 'presentation/bloc/class_performance/class_performance_bloc.dart';
import 'presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'presentation/widgets/teacher_student_detail_ui.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Performance'),
      body: BlocBuilder<ClassPerformanceBloc, ClassPerformanceState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return _MessageState(
              message: state.errorMessage!,
              onRetry: () {
                final active = context
                    .read<ClassTeacherContextBloc>()
                    .state
                    .active;
                if (active != null) {
                  context.read<ClassPerformanceBloc>().add(
                    ClassPerformanceRequested(active),
                  );
                }
              },
            );
          }

          final summary = state.summary;
          final student = summary?.students
              .where((s) => s.studentId == widget.studentId)
              .firstOrNull;

          if (summary == null || student == null) {
            return const _MessageState(
              message: 'No approved marks for this student yet.',
            );
          }

          final subjectNameOf = {
            for (final s in summary.subjects) s.subjectId: s.subjectName,
          };
          final ranked =
              summary.students.where((s) => s.average != null).toList()
                ..sort((a, b) => b.average!.compareTo(a.average!));
          final position = student.average == null
              ? null
              : ranked.indexWhere((s) => s.studentId == widget.studentId) + 1;

          return RefreshIndicator(
            onRefresh: () async {
              final active = context
                  .read<ClassTeacherContextBloc>()
                  .state
                  .active;
              if (active != null) {
                context.read<ClassPerformanceBloc>().add(
                  ClassPerformanceRequested(active),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 340;
                      final gauge = CircularProgressGauge(
                        value: (student.average ?? 0) / 100,
                        label: 'Average',
                        size: narrow ? 128 : 148,
                        overrideColor: AppColors.success(context),
                      );
                      final stats = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatBox(
                            label: 'Subjects Marked',
                            value:
                                '${student.subjectPercentages.length}/${summary.subjects.length}',
                          ),
                          const SizedBox(height: AppSpacing.m),
                          _StatBox(
                            label: 'Assessments',
                            value: student.missingSubjects == 0
                                ? 'Complete'
                                : '${student.missingSubjects} pending',
                          ),
                          const SizedBox(height: AppSpacing.m),
                          _StatBox(
                            label: 'Class Position',
                            value: position == null
                                ? '—'
                                : '$position${_ordinalSuffix(position)}',
                            caption: position == null
                                ? null
                                : 'Out of ${ranked.length}',
                          ),
                        ],
                      );

                      if (narrow) {
                        return Column(
                          children: [
                            gauge,
                            const SizedBox(height: AppSpacing.xl),
                            stats,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          gauge,
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: stats),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Subject Performance',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary(context),
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
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    )
                  else
                    for (final entry in student.subjectPercentages.entries)
                      _SubjectProgressRow(
                        name: subjectNameOf[entry.key] ?? entry.key,
                        subjectId: entry.key,
                        score: entry.value / 100,
                        label: '${entry.value.toStringAsFixed(0)}%',
                        onTap: () => context.push(
                          '/staff/students/${widget.studentId}/assessments'
                          '?subjectId=${entry.key}',
                        ),
                      ),
                  const SizedBox(height: AppSpacing.x3l),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/staff/students/${widget.studentId}/assessments',
                      ),
                      icon: Icon(
                        Icons.list_alt,
                        color: AppColors.primary(context),
                      ),
                      label: Text(
                        'View All Assessments',
                        style: TextStyle(color: AppColors.primary(context)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary(context)),
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
            ),
          );
        },
      ),
    );
  }

  static String _ordinalSuffix(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _MessageState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.l),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;

  const _StatBox({required this.label, required this.value, this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (caption != null)
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  final String name;
  final String subjectId;
  final double score;
  final String label;
  final VoidCallback onTap;

  const _SubjectProgressRow({
    required this.name,
    required this.subjectId,
    required this.score,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                    color: AppColors.textMuted(context),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textMuted(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: score.clamp(0, 1),
                backgroundColor: AppColors.surfaceElevated(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
