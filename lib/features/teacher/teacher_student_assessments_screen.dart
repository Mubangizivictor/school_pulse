import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TeacherStudentAssessmentsScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentAssessmentsScreen({super.key, required this.studentId});

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
          'Assessments',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(child: _DropdownSelector(label: 'All Subjects', isDark: isDark)),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: _DropdownSelector(label: 'Term 2', isDark: isDark)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _AssessmentTile(isDark: isDark);
              },
            ),
          ),
        ],
      ),
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
          Icon(Icons.keyboard_arrow_down, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, size: 20),
        ],
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  final bool isDark;

  const _AssessmentTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mathematics',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.royalBlue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'End of Term Test',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '15 May 2024',
                  style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '85/100',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '85%',
                style: AppTypography.labelSmall.copyWith(color: AppColors.successGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
