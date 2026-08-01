import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';

class ClassDetailsScreen extends StatelessWidget {
  final String classId;
  const ClassDetailsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Class Details',
          style: AppTypography.headlineSmall.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassHeader(context, isDark),
            const SizedBox(height: AppSpacing.xl),
            _buildTabs(context, isDark),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Class Overview',
              style: AppTypography.titleLarge.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(child: _buildStatCard('32', 'Total Students', AppColors.royalBlue, isDark)),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: _buildStatCard('30', 'Present Today', AppColors.successGreen, isDark)),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: _buildStatCard('2', 'Absent Today', AppColors.danger(context), isDark)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PulseCard(
              child: Column(
                children: [
                  _buildTeacherInfo(isDark),
                  const Divider(height: AppSpacing.x3l),
                  _buildDetailRow('Room', 'Room 12', isDark),
                  _buildDetailRow('Stream / Section', 'East', isDark),
                  _buildDetailRow('Subjects Taught', 'Mathematics, Social Studies', isDark),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class Timetable',
                  style: AppTypography.titleMedium.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/staff/classes/$classId/timetable'),
                  child: Text('View Timetable', style: TextStyle(color: AppColors.royalBlue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.royalBlue,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.m),
            ),
            child: const Icon(Icons.groups, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P5 East',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Primary Five • 2024',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                Text(
                  '32 Students • 18 Boys, 14 Girls',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(AppSpacing.s),
            ),
            child: Text(
              'Active',
              style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabItem('Overview', true, isDark, () {}),
          _buildTabItem('Students', false, isDark, () => context.push('/staff/classes/$classId/students')),
          _buildTabItem('Attendance', false, isDark, () => context.push('/staff/classes/$classId/attendance')),
          _buildTabItem('Performance', false, isDark, () => context.push('/staff/classes/$classId/performance')),
          _buildTabItem('More', false, isDark, () => context.push('/staff/classes/$classId/more')),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.m),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.m),
          border: isSelected ? null : Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, bool isDark) {
    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherInfo(bool isDark) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=teacher'),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class Teacher',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              Text(
                'Mrs. Achieng Mary',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
