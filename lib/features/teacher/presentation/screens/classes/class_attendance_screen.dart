import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';

class ClassAttendanceScreen extends StatelessWidget {
  final String classId;
  const ClassAttendanceScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

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
              'Class Attendance',
              style: AppTypography.titleLarge.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            Text(
              'P5 East • Today, 15 May 2024',
              style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(context, isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students (32)',
                  style: AppTypography.titleMedium.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark All', style: TextStyle(color: AppColors.successGreen)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: 10,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) => _buildAttendanceItem(index, isDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: PulseButton(
              label: 'Save Attendance',
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard('30', 'Present', '93.8%', AppColors.successGreen, isDark)),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: _buildSummaryCard('2', 'Absent', '6.2%', AppColors.danger(context), isDark)),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: _buildSummaryCard('0', 'Late', '0%', AppColors.goldenYellow, isDark)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String count, String label, String percentage, Color color, bool isDark) {
    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          Text(
            count,
            style: AppTypography.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(int index, bool isDark) {
    final names = ['Abalo Peter', 'Adong Grace', 'Aguti Brian', 'Anywar Doris', 'Atim Charles', 'Bamuwamye Sarah'];
    final name = names[index % names.length];
    final isPresent = index != 3; // Mocking one absent student

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.m),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=att_$index'),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'S1-2024-040$index',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildAttendanceAction(Icons.check_circle, isPresent ? AppColors.successGreen : AppColors.disabledDark, () {}),
              const SizedBox(width: AppSpacing.s),
              _buildAttendanceAction(Icons.cancel, !isPresent ? AppColors.errorRed : AppColors.disabledDark, () {}),
              const SizedBox(width: AppSpacing.s),
              _buildAttendanceAction(Icons.watch_later, AppColors.disabledDark, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
