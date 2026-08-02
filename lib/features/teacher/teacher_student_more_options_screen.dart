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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'More Options',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _OptionTile(
            icon: Icons.health_and_safety_outlined,
            label: 'Health Information',
            onTap: () => context.push('/staff/students/$studentId/health'),
          ),
          _OptionTile(
            icon: Icons.contact_phone_outlined,
            label: 'Contact Information',
          ),
          _OptionTile(
            icon: Icons.description_outlined,
            label: 'Documents',
          ),
          _OptionTile(
            icon: Icons.people_outline,
            label: 'Sibling Information',
          ),
          _OptionTile(
            icon: Icons.exit_to_app_outlined,
            label: 'Leave Applications',
            onTap: () => context.push('/staff/students/$studentId/leave-applications'),
          ),
          _OptionTile(
            icon: Icons.note_alt_outlined,
            label: 'Notes',
          ),
          _OptionTile(
            icon: Icons.chat_bubble_outline,
            label: 'Communications',
            onTap: () => context.push('/staff/students/$studentId/communications'),
          ),
          _OptionTile(
            icon: Icons.history_outlined,
            label: 'Timeline',
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _OptionTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary(context)),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
      ),
    );
  }
}
