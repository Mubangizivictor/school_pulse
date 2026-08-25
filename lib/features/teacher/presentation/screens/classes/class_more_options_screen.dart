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
    final primaryColor = AppColors.textPrimary(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildOptionItem(
            context,
            'Behaviour Records',
            Icons.gavel,
            AppColors.successGreen,
            isDark,
            () => context.push('/staff/classes/$classId/behaviour'),
          ),
          _buildOptionItem(
            context,
            'Class Resources',
            Icons.description,
            AppColors.royalBlue,
            isDark,
            () => context.push('/staff/classes/$classId/resources'),
          ),
          _buildOptionItem(
            context,
            'Lesson Plans',
            Icons.menu_book,
            AppColors.electricBlue,
            isDark,
            () => context.push('/staff/lesson-plans'),
          ),
          _buildOptionItem(
            context,
            'Photos & Media',
            Icons.photo_library,
            AppColors.brightOrange,
            isDark,
            // Photos and media live in the class resource area as images,
            // not a separate store - Resources already filters by kind.
            () => context.push('/staff/classes/$classId/resources'),
          ),
          _buildOptionItem(
            context,
            'Student Documents',
            Icons.folder_shared,
            AppColors.brightCyan,
            isDark,
            () => context.push('/staff/classes/$classId/resources'),
          ),
          _buildOptionItem(
            context,
            'Class Settings',
            Icons.settings,
            AppColors.textMutedDark,
            isDark,
            () => _showAdminOnlyNotice(context, 'Class Settings'),
          ),
          _buildOptionItem(
            context,
            'Archive Class',
            Icons.archive,
            AppColors.danger(context),
            isDark,
            () => _showAdminOnlyNotice(context, 'Archiving a class'),
          ),
        ],
      ),
    );
  }

  void _showAdminOnlyNotice(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Admin action required'),
        content: Text(
          '$action is managed by your school administrator, not from the '
          'Class Teacher panel. Contact your admin if you need this changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
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
                color: iconColor,
                borderRadius: BorderRadius.circular(AppSpacing.s),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }
}
