import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class MarksAnalyticsScreen extends StatelessWidget {
  const MarksAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Performance Analytics',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<MarksBloc, MarksState>(
        builder: (context, state) {
          final component = state.selectedComponent;
          final assessment = state.selectedAssessment;

          if (component == null || assessment == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select an assessment from Marks History to see its '
                  'analytics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
              ),
            );
          }

          final named = [
            for (final entry in state.entries.values)
              if (entry.status == MarkEntryStatus.scored && entry.score != null)
                (
                  name: state.students
                          .where((s) => s.studentId == entry.studentId)
                          .firstOrNull
                          ?.name ??
                      'Unknown',
                  percentage: entry.score! / component.maximumMark * 100,
                ),
          ]..sort((a, b) => b.percentage.compareTo(a.percentage));

          if (named.isEmpty) {
            return Center(
              child: Text(
                'No marks entered yet for this assessment.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            );
          }

          final avg = named.map((e) => e.percentage).reduce((a, b) => a + b) /
              named.length;
          final passMark = assessment.passMark ?? 50;
          final passCount = named.where((e) => e.percentage >= passMark).length;
          final passRate = passCount / named.length * 100;
          final highest = named.first.percentage;

          final buckets = <String, int>{
            'A (80-100%)': 0,
            'B (60-79%)': 0,
            'C (40-59%)': 0,
            'D (0-39%)': 0,
          };
          for (final row in named) {
            if (row.percentage >= 80) {
              buckets['A (80-100%)'] = buckets['A (80-100%)']! + 1;
            } else if (row.percentage >= 60) {
              buckets['B (60-79%)'] = buckets['B (60-79%)']! + 1;
            } else if (row.percentage >= 40) {
              buckets['C (40-59%)'] = buckets['C (40-59%)']! + 1;
            } else {
              buckets['D (0-39%)'] = buckets['D (0-39%)']! + 1;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(context, avg, passRate, highest),
                const SizedBox(height: 24),
                Text(
                  'Grade Distribution',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGradeDistribution(context, buckets, named.length),
                const SizedBox(height: 24),
                Text(
                  'Top Performing Students',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTopStudents(context, named.take(5).toList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    double avg,
    double passRate,
    double highest,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat(
            context,
            'Avg Score',
            '${avg.toStringAsFixed(0)}%',
            AppColors.primary(context),
          ),
          _buildStat(
            context,
            'Pass Rate',
            '${passRate.toStringAsFixed(0)}%',
            AppColors.success(context),
          ),
          _buildStat(
            context,
            'Highest',
            '${highest.toStringAsFixed(0)}%',
            AppColors.secondary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDistribution(
    BuildContext context,
    Map<String, int> buckets,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          for (final entry in buckets.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : entry.value / total,
                      backgroundColor: AppColors.border(context).withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value}',
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopStudents(
    BuildContext context,
    List<({String name, double percentage})> rows,
  ) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border(context).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary(
                    context,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(color: AppColors.primary(context)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rows[i].name,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${rows[i].percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.success(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
