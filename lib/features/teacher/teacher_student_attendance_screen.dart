import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_history_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class TeacherStudentAttendanceScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentAttendanceScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentAttendanceScreen> createState() =>
      _TeacherStudentAttendanceScreenState();
}

class _TeacherStudentAttendanceScreenState
    extends State<TeacherStudentAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassAttendanceHistoryBloc>().add(
        ClassAttendanceHistoryRequested(active, range: HistoryRange.term),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Attendance',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body:
          BlocBuilder<ClassAttendanceHistoryBloc, ClassAttendanceHistoryState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = <(DateTime, ClassAttendanceEntry)>[];
              for (final session in state.sessions) {
                final entry = session.entries
                    .where((e) => e.studentId == widget.studentId)
                    .firstOrNull;
                if (entry != null) entries.add((session.date, entry));
              }
              entries.sort((a, b) => b.$1.compareTo(a.$1));

              final optionByCode = {for (final o in state.options) o.code: o};
              int present = 0, authorisedAbsent = 0, unauthorisedAbsent = 0;
              for (final (_, entry) in entries) {
                final option = optionByCode[entry.statusCode];
                if (option == null) continue;
                if (option.countsAsPresent) {
                  present++;
                } else if (option.isAuthorisedAbsence) {
                  authorisedAbsent++;
                } else {
                  unauthorisedAbsent++;
                }
              }
              final total = entries.length;

              if (total == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'No attendance has been recorded for this student yet.',
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(
                      isDark,
                      present,
                      authorisedAbsent + unauthorisedAbsent,
                      total,
                    ),
                    const SizedBox(height: AppSpacing.x2l),
                    Text(
                      'Recent Records',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    for (final (date, entry) in entries.take(20))
                      _RecentRecordRow(
                        date: _formatDate(date),
                        option: optionByCode[entry.statusCode],
                        isDark: isDark,
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildSummaryCards(bool isDark, int present, int absent, int total) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Present',
            value: '$present',
            percentage: total == 0
                ? '—'
                : '${(present / total * 100).toStringAsFixed(0)}%',
            color: AppColors.successGreen,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _SummaryCard(
            label: 'Absent',
            value: '$absent',
            percentage: total == 0
                ? '—'
                : '${(absent / total * 100).toStringAsFixed(0)}%',
            color: AppColors.errorRed,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _SummaryCard(
            label: 'Days Recorded',
            value: '$total',
            percentage: 'This term',
            color: AppColors.royalBlue,
            isDark: isDark,
          ),
        ),
      ],
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            percentage,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordRow extends StatelessWidget {
  final String date;
  final ClassAttendanceOption? option;
  final bool isDark;

  const _RecentRecordRow({
    required this.date,
    required this.option,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = option == null
        ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
        : option!.countsAsPresent
        ? AppColors.successGreen
        : option!.isAuthorisedAbsence
        ? AppColors.warning(context)
        : AppColors.errorRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Text(
                option?.label ?? 'Unknown',
                style: AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
