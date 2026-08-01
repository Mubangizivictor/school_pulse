import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';

class ClassTimetableScreen extends StatelessWidget {
  final String classId;
  const ClassTimetableScreen({super.key, required this.classId});

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
              'Timetable',
              style: AppTypography.titleLarge.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            Text(
              'P5 East',
              style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDaySelector(isDark),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: 6,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) => _buildTimetableItem(index, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(bool isDark) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.m),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.royalBlue : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  days[index],
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.royalBlue : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimetableItem(int index, bool isDark) {
    final periods = [
      {'time': '08:00 - 09:00', 'subject': 'Mathematics', 'room': 'Room 12', 'color': Colors.blue},
      {'time': '09:00 - 10:20', 'subject': 'English', 'room': 'Room 12', 'color': Colors.orange},
      {'time': '10:20 - 10:50', 'subject': 'Break', 'room': 'Playground', 'color': Colors.green},
      {'time': '10:50 - 11:50', 'subject': 'Science', 'room': 'Lab 1', 'color': Colors.purple},
      {'time': '11:50 - 12:50', 'subject': 'Social Studies', 'room': 'Room 12', 'color': Colors.red},
      {'time': '12:50 - 14:00', 'subject': 'Lunch', 'room': 'Dining Hall', 'color': Colors.teal},
    ];

    final period = periods[index];

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: period['color'] as Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period['time'] as String,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                Text(
                  period['subject'] as String,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            period['room'] as String,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Icon(Icons.chevron_right, size: 16, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
        ],
      ),
    );
  }
}
