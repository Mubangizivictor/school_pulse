import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';

class ClassMoreOptionsScreen extends StatelessWidget {
  final String classId;
  const ClassMoreOptionsScreen({super.key, required this.classId});

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
              'More Options',
              style: AppTypography.titleLarge.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            Text(
              'P5 East',
              style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildOptionItem(context, 'Behaviour Records', Icons.gavel, AppColors.successGreen, isDark, () {}),
          _buildOptionItem(context, 'Class Notes', Icons.description, AppColors.royalBlue, isDark, () {}),
          _buildOptionItem(context, 'Lesson Plans', Icons.menu_book, AppColors.electricBlue, isDark, () {}),
          _buildOptionItem(context, 'Photos & Media', Icons.photo_library, AppColors.brightOrange, isDark, () {}),
          _buildOptionItem(context, 'Student Documents', Icons.folder_shared, AppColors.brightCyan, isDark, () {}),
          _buildOptionItem(context, 'Class Settings', Icons.settings, AppColors.textMutedDark, isDark, () {}),
          _buildOptionItem(context, 'Archive Class', Icons.archive, AppColors.danger(context), isDark, () {}),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: PulseCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.s),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }
}
