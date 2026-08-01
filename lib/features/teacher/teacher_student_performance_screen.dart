import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TeacherStudentPerformanceScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentPerformanceScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Performance',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _DropdownSelector(label: 'Term 2', isDark: isDark)),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: _DropdownSelector(label: '2024', isDark: isDark)),
              ],
            ),
            const SizedBox(height: AppSpacing.x2l),
            _buildAverageCircle(isDark),
            const SizedBox(height: AppSpacing.x2l),
            _buildStatsRow(isDark),
            const SizedBox(height: AppSpacing.x3l),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subject Performance',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            _buildSubjectBars(isDark),
            const SizedBox(height: AppSpacing.x3l),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/staff/students/$studentId/assessments'),
                icon: const Icon(Icons.list_alt, color: AppColors.royalBlue),
                label: const Text('View All Assessments', style: TextStyle(color: AppColors.royalBlue)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.royalBlue),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.m)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageCircle(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: 0.78,
            strokeWidth: 12,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
          ),
        ),
        Column(
          children: [
            Text('78%', style: AppTypography.headlineLarge.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
            Text('Average', style: AppTypography.labelMedium.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Class Rank', value: '5/32', isDark: isDark)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _StatBox(label: 'Total Marks', value: '780/1000', isDark: isDark)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _StatBox(label: 'Grade', value: 'B', isDark: isDark)),
      ],
    );
  }

  Widget _buildSubjectBars(bool isDark) {
    final subjects = [
      {'name': 'Mathematics', 'score': 0.85, 'label': '85%'},
      {'name': 'English', 'score': 0.72, 'label': '72%'},
      {'name': 'Social Studies', 'score': 0.75, 'label': '75%'},
      {'name': 'Science', 'score': 0.80, 'label': '80%'},
      {'name': 'ICT', 'score': 0.78, 'label': '78%'},
    ];

    return Column(
      children: subjects.map((s) => _SubjectProgressRow(
        name: s['name'] as String,
        score: s['score'] as double,
        label: s['label'] as String,
        isDark: isDark,
      )).toList(),
    );
  }
}

class _DropdownSelector extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DropdownSelector({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.s),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          Icon(Icons.keyboard_arrow_down, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatBox({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
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

  const _SubjectProgressRow({required this.name, required this.score, required this.label, required this.isDark});

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
              Text(name, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
              Text(label, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.royalBlue),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
