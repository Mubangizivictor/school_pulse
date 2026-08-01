import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TeacherStudentMoreOptionsScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentMoreOptionsScreen({super.key, required this.studentId});

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
          'More Options',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _OptionTile(
            icon: Icons.health_and_safety_outlined,
            label: 'Health Information',
            isDark: isDark,
            onTap: () => context.push('/staff/students/$studentId/health'),
          ),
          _OptionTile(
            icon: Icons.contact_phone_outlined,
            label: 'Contact Information',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.description_outlined,
            label: 'Documents',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.people_outline,
            label: 'Sibling Information',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.exit_to_app_outlined,
            label: 'Leave Applications',
            isDark: isDark,
            onTap: () => context.push('/staff/students/$studentId/leave-applications'),
          ),
          _OptionTile(
            icon: Icons.note_alt_outlined,
            label: 'Notes',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.chat_bubble_outline,
            label: 'Communications',
            isDark: isDark,
            onTap: () => context.push('/staff/students/$studentId/communications'),
          ),
          _OptionTile(
            icon: Icons.history_outlined,
            label: 'Timeline',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;

  const _OptionTile({required this.icon, required this.label, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.royalBlue),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
      ),
    );
  }
}
