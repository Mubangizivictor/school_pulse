import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';

class ClassAssignmentsScreen extends StatelessWidget {
  final String classId;
  const ClassAssignmentsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
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
              'Assignments',
              style: AppTypography.titleLarge.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'P5 East',
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabs(isDark),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: 4,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) =>
                  _buildAssignmentItem(index, isDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: PulseButton(
              label: 'Create Assignment',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          _buildTabItem('All', true, isDark),
          _buildTabItem('Homework', false, isDark),
          _buildTabItem('Classwork', false, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isSelected, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.royalBlue.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: isSelected ? Border.all(color: AppColors.royalBlue) : null,
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected
              ? AppColors.royalBlue
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAssignmentItem(int index, bool isDark) {
    final assignments = [
      {
        'title': 'Complete Exercise 5 - 10',
        'subject': 'Mathematics',
        'due': '15 May 2024',
        'status': 'Pending',
        'statusColor': AppColors.goldenYellow,
      },
      {
        'title': 'Read Chapter 3 and answer questions',
        'subject': 'English',
        'due': '16 May 2024',
        'status': 'Pending',
        'statusColor': AppColors.goldenYellow,
      },
      {
        'title': 'Map of East Africa',
        'subject': 'Social Studies',
        'due': '12 May 2024',
        'status': 'Completed',
        'statusColor': AppColors.successGreen,
      },
      {
        'title': 'Science Project Phase 1',
        'subject': 'Science',
        'due': '20 May 2024',
        'status': 'Pending',
        'statusColor': AppColors.goldenYellow,
      },
    ];

    final assignment = assignments[index];

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (assignment['statusColor'] as Color).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
                child: Text(
                  assignment['status'] as String,
                  style: AppTypography.labelSmall.copyWith(
                    color: assignment['statusColor'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                size: 20,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            assignment['title'] as String,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            assignment['subject'] as String,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              const SizedBox(width: 4),
              Text(
                'Due: ${assignment['due']}',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 14,
                    color: AppColors.royalBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '28/32 Submitted',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.royalBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
