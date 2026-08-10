import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../widgets/super_admin_logout_button.dart';
import 'audit_logs_screen.dart';
import 'manual_payment_config_screen.dart';

/// Real (non-placeholder) Settings screen for the SaaS owner console,
/// scoped to what's honestly supportable right now: account identity,
/// a link to the manual payment configuration info screen, a link to
/// Audit Logs for security visibility, and logout. No fake toggles.
class SuperAdminSettingsScreen extends StatelessWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ownerName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'SaaS Owner';
    final ownerEmail = user?.email?.trim() ?? 'Not signed in';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        children: [
          _SettingsSectionLabel(label: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: ownerName,
            subtitle: ownerEmail,
            trailingLabel: 'Owner',
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsSectionLabel(label: 'Billing'),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Manual Payment Methods',
            subtitle: 'View how the manual payment configuration is managed',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManualPaymentConfigScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsSectionLabel(label: 'Security'),
          _SettingsTile(
            icon: Icons.history_outlined,
            title: 'Audit Logs',
            subtitle: 'Review platform activity and owner actions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () => handleSuperAdminLogout(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m, left: AppSpacing.s),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Same visual style as `super_admin_more_screen.dart`'s private `_MoreTile`,
/// with an optional static trailing label instead of a chevron for
/// non-navigating rows (e.g. the Account row).
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailingLabel,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? trailingLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? AppColors.deepOrange
        : AppColors.primary(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDestructive ? color : AppColors.textPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: trailingLabel != null
            ? Text(
                trailingLabel!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              )
            : (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      ),
    );
  }
}
