import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../widgets/super_admin_logout_button.dart';
import 'audit_logs_screen.dart';
import 'subscription_plans_screen.dart';
import 'super_admin_placeholder_screen.dart';
import 'super_admin_settings_screen.dart';

/// Mobile "More" screen for the SaaS owner console. Lists the sections that
/// don't have a dedicated bottom-nav tab: Subscription Plans, Audit Logs,
/// and the honest Notifications/Settings placeholders, plus Logout.
class SuperAdminMoreScreen extends StatelessWidget {
  const SuperAdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        children: [
          _MoreTile(
            icon: Icons.subscriptions_outlined,
            title: 'Subscription Plans',
            subtitle: 'Manage plan pricing and billing cycles',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionPlansScreen(),
              ),
            ),
          ),
          _MoreTile(
            icon: Icons.history_outlined,
            title: 'Audit Logs',
            subtitle: 'Review platform activity history',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
            ),
          ),
          _MoreTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Platform notification settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SuperAdminPlaceholderScreen(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined,
                  message:
                      'Notification management is coming in a later phase.',
                ),
              ),
            ),
          ),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Account, billing and security',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SuperAdminSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _MoreTile(
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

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
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
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDestructive ? color : AppColors.textPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
