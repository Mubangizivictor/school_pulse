import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class ClassMarksSummaryScreen extends StatelessWidget {
  const ClassMarksSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarksBloc, MarksState>(
      builder: (context, state) {
        final assessment = state.selectedAssessment;
        final component = state.selectedComponent;

        if (assessment == null || component == null) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: AppBar(title: const Text('Class Marks Summary')),
            body: const Center(child: Text('No assessment selected.')),
          );
        }

        final scored = <(String, double)>[
          for (final entry in state.entries.values)
            if (entry.status == MarkEntryStatus.scored && entry.score != null)
              (
                state.students
                        .where((s) => s.studentId == entry.studentId)
                        .firstOrNull
                        ?.name ??
                    'Unknown',
                entry.score!,
              ),
        ]..sort((a, b) => b.$2.compareTo(a.$2));

        final average = scored.isEmpty
            ? null
            : scored.map((e) => e.$2).reduce((a, b) => a + b) / scored.length;
        final highest = scored.isEmpty ? null : scored.first.$2;
        final lowest = scored.isEmpty ? null : scored.last.$2;

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
              'Class Marks Summary',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                        assessment.title.isEmpty
                            ? assessment.assessmentTypeName
                            : assessment.title,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        component.name,
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildSummaryBox(
                      context,
                      'Class Average',
                      average == null
                          ? '—'
                          : '${(average / component.maximumMark * 100).toStringAsFixed(0)}%',
                      AppColors.success(context),
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryBox(
                      context,
                      'Highest Score',
                      highest == null
                          ? '—'
                          : '${highest.toStringAsFixed(0)}/${component.maximumMark.toStringAsFixed(0)}',
                      AppColors.textPrimary(context),
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryBox(
                      context,
                      'Lowest Score',
                      lowest == null
                          ? '—'
                          : '${lowest.toStringAsFixed(0)}/${component.maximumMark.toStringAsFixed(0)}',
                      AppColors.textPrimary(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Student Performance',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (scored.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No marks entered yet.',
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                  )
                else
                  for (final row in scored)
                    _buildPerformanceItem(
                      context,
                      row.$1,
                      row.$2,
                      component.maximumMark,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryBox(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Expanded(
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
            Text(
              label,
              style: TextStyle(color: AppColors.textMuted(context), fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context,
    String name,
    double score,
    double maxMark,
  ) {
    final percentage = maxMark <= 0 ? 0 : score / maxMark * 100;
    final color = percentage >= 70
        ? AppColors.success(context)
        : percentage >= 50
        ? AppColors.warning(context)
        : AppColors.danger(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: AppColors.disabled(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
            ),
          ),
          Text(
            '${score.toStringAsFixed(0)}/${maxMark.toStringAsFixed(0)}',
            style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
          ),
          const SizedBox(width: 24),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
