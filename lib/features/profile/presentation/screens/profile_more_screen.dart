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
    String? photoUrl;
    bool isAdmin = false;

    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      role = UserRoleDisplay.name(authState.user.role);
      photoUrl = authState.user.photoUrl;
      isAdmin = authState.user.roles.any(
        UserRoleDisplay.adminConsoleRoles.contains,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _MoreHeader(
              onSettingsTap: () =>
                  context.push('/staff/more/security-privacy'),
            ),
            const SizedBox(height: 20),
            _ProfileCard(
              name: name,
              role: role,
              photoUrl: photoUrl,
              onTap: () => context.push('/staff/more/edit-profile'),
            ),
            const SizedBox(height: 24),
            _MoreSection(
              title: 'ACCOUNT',
              tiles: [
                _MoreTileData(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.electricBlue,
                  title: 'Personal Information',
                  subtitle: 'Update your personal details',
                  onTap: () =>
                      context.push('/staff/more/personal-information'),
                ),
                _MoreTileData(
                  icon: Icons.notifications_none_rounded,
                  iconColor: AppColors.electricBlue,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () =>
                      context.push('/staff/more/notification-preferences'),
                ),
                _MoreTileData(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.electricBlue,
                  title: 'Security & Privacy',
                  subtitle: 'Password, 2FA and privacy settings',
                  onTap: () => context.push('/staff/more/security-privacy'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MoreSection(
              title: 'SCHOOL',
              tiles: [
                _MoreTileData(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.successGreen,
                  title: 'School Calendar',
                  subtitle: 'View academic calendar and events',
                  onTap: () => context.push('/staff/calendar'),
                ),
                _MoreTileData(
                  icon: Icons.campaign_rounded,
                  iconColor: AppColors.royalBlue,
                  title: 'Announcements',
                  subtitle: 'Stay updated with school news',
                  onTap: () => context.push('/staff/more/announcements'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MoreSection(
              title: 'DIRECTORY & INFORMATION',
              tiles: [
                _MoreTileData(
                  icon: Icons.info_rounded,
                  iconColor: AppColors.goldenYellow,
                  title: 'School Directory',
                  subtitle: 'View faculty, staff and student directory',
                  onTap: () => context.push('/staff/more/school-directory'),
                ),
              ],
            ),
            if (isAdmin) ...[
              const SizedBox(height: 20),
              _MoreSection(
                title: 'BILLING',
                tiles: [
                  _MoreTileData(
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.deepOrange,
                    title: 'Subscription & Billing',
                    subtitle: 'Manage subscription and payment methods',
                    onTap: () => context.push('/staff/admin/subscription'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _MoreSection(
              title: 'SUPPORT',
              tiles: [
                _MoreTileData(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.emeraldGreen,
                  title: 'Help Center',
                  subtitle: 'Get help and find answers',
                  onTap: () => context.push('/staff/more/help-center'),
                ),
                _MoreTileData(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.goldenYellow,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () => context.push('/staff/more/terms-of-service'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionLabel(title: 'APP SETTINGS'),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: const ThemeSwitchTile(),
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Logout',
              icon: Icons.logout_rounded,
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
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

class _MoreHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _MoreHeader({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your account and app preferences',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border(context).withValues(alpha: 0.4),
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 18,
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary(context),
            ),
            onPressed: onSettingsTap,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String? photoUrl;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      onTap: onTap,
      showShadow: false,
      color: isDark ? AppColors.elevatedSurfaceDark : null,
      padding: EdgeInsets.zero,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: _decorativeCircle(90, AppColors.electricBlue, 0.16),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _decorativeCircle(28, AppColors.brightCyan, 0.20),
          ),
          Positioned(
            top: 55,
            right: 60,
            child: _decorativeCircle(14, AppColors.brightCyan, 0.25),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(name: name, photoUrl: photoUrl, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.primary(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;

  const _Avatar({required this.name, required this.photoUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return AvatarInitials(name: name, size: size);
    }
    return ClipOval(
      child: Image.network(
        photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            AvatarInitials(name: name, size: size),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _MoreTileData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreTileData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _MoreSection extends StatelessWidget {
  final String title;
  final List<_MoreTileData> tiles;

  const _MoreSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: title),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                _MoreTile(data: tiles[i]),
                if (i != tiles.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 68,
                    color: AppColors.border(context).withValues(alpha: 0.4),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  final _MoreTileData data;

  const _MoreTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.iconColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, size: 18, color: data.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
