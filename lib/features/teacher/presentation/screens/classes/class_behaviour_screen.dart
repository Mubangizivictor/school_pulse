import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';

class ClassBehaviourScreen extends StatelessWidget {
  final String classId;
  const ClassBehaviourScreen({super.key, required this.classId});

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
              'Behaviour Records',
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
          _buildBehaviourSummary(isDark),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) => _buildLogItem(index, isDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: PulseButton(
              text: 'Log New Incident',
              icon: Icons.add_moderator,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviourSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('24', 'Merits', AppColors.successGreen, isDark),
          _buildSummaryItem('3', 'Demerits', AppColors.danger(null), isDark),
          _buildSummaryItem('A', 'Class Grade', AppColors.royalBlue, isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
      ],
    );
  }

  Widget _buildLogItem(int index, bool isDark) {
    final logs = [
      {'student': 'Abalo Peter', 'type': 'Merit', 'reason': 'Helped clean the classroom', 'date': 'Today, 10:30 AM', 'color': AppColors.successGreen},
      {'student': 'Adong Grace', 'type': 'Demerit', 'reason': 'Late for class (3rd time)', 'date': 'Yesterday', 'color': AppColors.errorRed},
      {'student': 'Anywar Doris', 'type': 'Merit', 'reason': 'Excellent math presentation', 'date': '14 May 2024', 'color': AppColors.successGreen},
      {'student': 'Atim Charles', 'type': 'Merit', 'reason': 'Organized library books', 'date': '12 May 2024', 'color': AppColors.successGreen},
      {'student': 'Bamuwamye Sarah', 'type': 'Demerit', 'reason': 'Disruptive behavior', 'date': '10 May 2024', 'color': AppColors.errorRed},
    ];
    final log = logs[index];

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: (log['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              log['type'] == 'Merit' ? Icons.add_circle : Icons.remove_circle,
              color: log['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['student'] as String,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  log['reason'] as String,
                  style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                Text(
                  log['date'] as String,
                  style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontSize: 10),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
        ],
      ),
    );
  }
}
