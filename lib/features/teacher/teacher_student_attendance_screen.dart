import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TeacherStudentAttendanceScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentAttendanceScreen({super.key, required this.studentId});

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
          'Attendance',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(isDark),
                  const SizedBox(height: AppSpacing.x2l),
                  Text(
                    'This Term',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _buildMonthlyList(isDark),
                  const SizedBox(height: AppSpacing.x2l),
                  Text(
                    'Recent Records',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _buildRecentRecords(isDark),
                ],
              ),
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
          _TabItem(label: 'Overview', isSelected: true, isDark: isDark),
          const SizedBox(width: AppSpacing.xl),
          _TabItem(label: 'By Subject', isSelected: false, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return Row(
      children: [
        Expanded(child: _SummaryCard(label: 'Present', value: '28', percentage: '87.5%', color: AppColors.successGreen, isDark: isDark)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _SummaryCard(label: 'Absent', value: '4', percentage: '12.5%', color: AppColors.errorRed, isDark: isDark)),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _SummaryCard(label: 'Late', value: '1', percentage: '3.1%', color: AppColors.royalBlue, isDark: isDark)),
      ],
    );
  }

  Widget _buildMonthlyList(bool isDark) {
    final months = [
      {'name': 'May 2024', 'value': '90.0%'},
      {'name': 'Apr 2024', 'value': '86.7%'},
      {'name': 'Mar 2024', 'value': '88.0%'},
      {'name': 'Feb 2024', 'value': '85.0%'},
      {'name': 'Jan 2024', 'value': '92.0%'},
    ];

    return Column(
      children: months.map((m) => _MonthlyRow(name: m['name']!, value: m['value']!, isDark: isDark)).toList(),
    );
  }

  Widget _buildRecentRecords(bool isDark) {
    final records = [
      {'date': '31 May 2024', 'status': 'Present', 'color': AppColors.successGreen},
      {'date': '30 May 2024', 'status': 'Present', 'color': AppColors.successGreen},
      {'date': '29 May 2024', 'status': 'Absent', 'color': AppColors.errorRed},
    ];

    return Column(
      children: records.map((r) => _RecentRecordRow(date: r['date'] as String, status: r['status'] as String, color: r['color'] as Color, isDark: isDark)).toList(),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;

  const _TabItem({required this.label, required this.isSelected, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            width: 40,
            color: AppColors.royalBlue,
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final bool isDark;

  const _SummaryCard({required this.label, required this.value, required this.percentage, required this.color, required this.isDark});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headlineSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
          Text(percentage, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  final String name;
  final String value;
  final bool isDark;

  const _MonthlyRow({required this.name, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: AppTypography.bodyMedium.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColors.successGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RecentRecordRow extends StatelessWidget {
  final String date;
  final String status;
  final Color color;
  final bool isDark;

  const _RecentRecordRow({required this.date, required this.status, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: AppTypography.bodyMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Text(status, style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
