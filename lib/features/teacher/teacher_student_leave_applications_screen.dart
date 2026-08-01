import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TeacherStudentLeaveApplicationsScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentLeaveApplicationsScreen({super.key, required this.studentId});

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
          'Leave Applications',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterTabs(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _LeaveApplicationTile(
                  reason: 'Sick Leave',
                  dateRange: '12 - 14 May 2024',
                  status: 'Pending',
                  statusColor: AppColors.warningOrange,
                  isDark: isDark,
                ),
                _LeaveApplicationTile(
                  reason: 'Family Function',
                  dateRange: '2 May 2024',
                  status: 'Approved',
                  statusColor: AppColors.successGreen,
                  isDark: isDark,
                ),
                _LeaveApplicationTile(
                  reason: 'Visiting Doctor',
                  dateRange: '20 Apr 2024',
                  status: 'Approved',
                  statusColor: AppColors.successGreen,
                  isDark: isDark,
                ),
                _LeaveApplicationTile(
                  reason: 'Not Feeling Well',
                  dateRange: '5 Apr 2024',
                  status: 'Declined',
                  statusColor: AppColors.errorRed,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('New Leave Request', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.m)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          _FilterTabItem(label: 'All', isSelected: true, isDark: isDark),
          _FilterTabItem(label: 'Pending', isSelected: false, isDark: isDark),
          _FilterTabItem(label: 'Approved', isSelected: false, isDark: isDark),
          _FilterTabItem(label: 'Declined', isSelected: false, isDark: isDark),
        ],
      ),
    );
  }
}

class _FilterTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;

  const _FilterTabItem({required this.label, required this.isSelected, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isSelected ? AppColors.royalBlue : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: AppColors.royalBlue,
            ),
        ],
      ),
    );
  }
}

class _LeaveApplicationTile extends StatelessWidget {
  final String reason;
  final String dateRange;
  final String status;
  final Color statusColor;
  final bool isDark;

  const _LeaveApplicationTile({
    required this.reason,
    required this.dateRange,
    required this.status,
    required this.statusColor,
    required this.isDark,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reason,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateRange,
                style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.s),
            ),
            child: Text(
              status,
              style: AppTypography.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
