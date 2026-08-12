import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// New landing screen for the "More" tab - replaces StaffMoreScreen.
/// No Language tile per the locked-in product decision; dark mode uses
/// ThemeSwitchTile() (ThemeProvider-backed) verbatim.
class ProfileMoreScreen extends StatelessWidget {
  const ProfileMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String name = 'Staff Member';
    String role = 'Staff';
    bool isAdmin = false;

    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      role = UserRoleDisplay.name(authState.user.role);
      isAdmin = authState.user.roles.any(
        UserRoleDisplay.adminConsoleRoles.contains,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            onTap: () => context.push('/staff/more/edit-profile'),
            child: Row(
              children: [
                AvatarInitials(name: name, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'ACCOUNT'),
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () => context.push('/staff/more/personal-information'),
          ),
          _MenuTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () => context.push('/staff/more/notification-preferences'),
          ),
          _MenuTile(
            icon: Icons.security_outlined,
            title: 'Security & Privacy',
            onTap: () => context.push('/staff/more/security-privacy'),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'SCHOOL'),
          _MenuTile(
            icon: Icons.calendar_today_outlined,
            title: 'School Calendar',
            onTap: () => context.push('/staff/calendar'),
          ),
          _MenuTile(
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            onTap: () => context.push('/staff/more/announcements'),
          ),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'School Directory',
            onTap: () => context.push('/staff/more/school-directory'),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'BILLING'),
            _MenuTile(
              icon: Icons.payment_outlined,
              title: 'Subscription & Billing',
              onTap: () => context.push('/staff/admin/subscription'),
            ),
          ],
          const SizedBox(height: 24),
          const SectionHeader(title: 'SUPPORT'),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () => context.push('/staff/more/help-center'),
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => context.push('/staff/more/terms-of-service'),
          ),
          const SizedBox(height: 8),
          const AppCard(padding: EdgeInsets.zero, child: ThemeSwitchTile()),
          const SizedBox(height: 32),
          SecondaryButton(
            label: 'Logout',
            icon: Icons.logout,
            onPressed: () => _handleLogout(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Logout',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    }
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.primary(context)),
          title: Text(
            title,
            style: TextStyle(color: AppColors.textPrimary(context)),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textMuted(context),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
