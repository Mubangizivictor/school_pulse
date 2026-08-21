import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/widgets/role_switcher_sheet.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

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
    bool isDirector = false;
    bool isTeacher = false;

    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      role = UserRoleDisplay.name(authState.user.role);
      photoUrl = authState.user.photoUrl;
      isDirector = authState.user.roles.contains(UserRole.director);
      isTeacher = authState.user.roles.any(
        (r) => r == UserRole.classTeacher || r == UserRole.subjectTeacher,
      );
    }

    final className = isTeacher
        ? context.watch<ClassTeacherContextBloc>().state.active?.className
        : null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          children: [
            _MoreHeader(
              className: className,
              onClassTap: () => RoleSwitcherSheet.show(context),
              onSettingsTap: () => context.push('/staff/more/security-privacy'),
            ),
            const SizedBox(height: 10),
            _ProfileCard(
              name: name,
              role: role,
              photoUrl: photoUrl,
              onTap: () => context.push('/staff/more/edit-profile'),
            ),
            if (isTeacher) ...[const SizedBox(height: 10), _QuickAccessRow()],
            if (isDirector) ...[
              const SizedBox(height: 20),
              _MoreSection(
                title: 'DIRECTOR PORTAL',
                tiles: [
                  _MoreTileData(
                    icon: Icons.dashboard_rounded,
                    iconColor: AppColors.electricBlue,
                    title: 'Dashboard',
                    subtitle: 'Institution snapshot and performance',
                    onTap: () => context.push('/staff/director'),
                  ),
                  _MoreTileData(
                    icon: Icons.speed_rounded,
                    iconColor: AppColors.electricBlue,
                    title: 'Performance',
                    subtitle: 'School performance index and trends',
                    onTap: () => context.push('/staff/director/performance'),
                  ),
                  _MoreTileData(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.emeraldGreen,
                    title: 'Finance',
                    subtitle: 'Fee collection, revenue and expenses',
                    onTap: () => context.push('/staff/director/finance'),
                  ),
                  _MoreTileData(
                    icon: Icons.fact_check_rounded,
                    iconColor: AppColors.royalBlue,
                    title: 'Approvals',
                    subtitle: 'Review and decide pending requests',
                    onTap: () => context.push('/staff/director/approvals'),
                  ),
                  _MoreTileData(
                    icon: Icons.school_rounded,
                    iconColor: AppColors.electricBlue,
                    title: 'Academics',
                    subtitle: 'Class and subject performance',
                    onTap: () => context.push('/staff/director/academics'),
                  ),
                  _MoreTileData(
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.royalBlue,
                    title: 'Students',
                    subtitle: 'Enrollment and student analytics',
                    onTap: () => context.push('/staff/director/students'),
                  ),
                  _MoreTileData(
                    icon: Icons.badge_rounded,
                    iconColor: AppColors.deepOrange,
                    title: 'Staff',
                    subtitle: 'Workforce overview',
                    onTap: () => context.push('/staff/director/staff'),
                  ),
                  _MoreTileData(
                    icon: Icons.family_restroom_rounded,
                    iconColor: AppColors.goldenYellow,
                    title: 'Parents & Engagement',
                    subtitle: 'Portal usage and engagement',
                    onTap: () => context.push('/staff/director/parents'),
                  ),
                  _MoreTileData(
                    icon: Icons.corporate_fare_rounded,
                    iconColor: AppColors.emeraldGreen,
                    title: 'Departments',
                    subtitle: 'Department directory',
                    onTap: () => context.push('/staff/director/departments'),
                  ),
                  _MoreTileData(
                    icon: Icons.insights_rounded,
                    iconColor: AppColors.royalBlue,
                    title: 'Reports',
                    subtitle: 'Strategic reports',
                    onTap: () => context.push('/staff/director/reports'),
                  ),
                  _MoreTileData(
                    icon: Icons.track_changes_rounded,
                    iconColor: AppColors.deepOrange,
                    title: 'Goals & Targets',
                    subtitle: 'Strategic goals tracking',
                    onTap: () => context.push('/staff/director/goals'),
                  ),
                  _MoreTileData(
                    icon: Icons.groups_rounded,
                    iconColor: AppColors.electricBlue,
                    title: 'Meetings',
                    subtitle: 'Board and management meetings',
                    onTap: () => context.push('/staff/director/meetings'),
                  ),
                  _MoreTileData(
                    icon: Icons.report_gmailerrorred_rounded,
                    iconColor: Colors.red,
                    title: 'Incidents',
                    subtitle: 'Incident tracking',
                    onTap: () => context.push('/staff/director/incidents'),
                  ),
                  _MoreTileData(
                    icon: Icons.campaign_rounded,
                    iconColor: AppColors.royalBlue,
                    title: 'Communication',
                    subtitle: 'Announcements and messaging',
                    onTap: () => context.push('/staff/director/communication'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            _MoreSection(
              title: 'MAIN MENU',
              tiles: [
                _MoreTileData(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.electricBlue,
                  title: 'My Profile',
                  subtitle: 'View and update your profile',
                  onTap: () => context.push('/staff/more/personal-information'),
                ),
                if (isTeacher)
                  _MoreTileData(
                    icon: Icons.verified_user_outlined,
                    iconColor: AppColors.successGreen,
                    title: 'Attendance Settings',
                    subtitle: 'Manage attendance preferences',
                    onTap: () =>
                        context.push('/staff/more/attendance-settings'),
                  ),
                _MoreTileData(
                  icon: Icons.notifications_none_rounded,
                  iconColor: AppColors.electricBlue,
                  title: 'Notification Settings',
                  subtitle: 'Manage your notification preferences',
                  onTap: () =>
                      context.push('/staff/more/notification-preferences'),
                ),
                _MoreTileData(
                  icon: Icons.cloud_upload_outlined,
                  iconColor: AppColors.goldenYellow,
                  title: 'Offline Data',
                  subtitle: 'Manage offline sync and data',
                  onTap: () => context.push('/staff/more/offline-data'),
                ),
                _MoreTileData(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.electricBlue,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => context.push('/staff/more/help-center'),
                ),
                _MoreTileData(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.deepOrange,
                  title: 'About School Pulse',
                  subtitle: 'App version and information',
                  onTap: () => context.push('/about-school-pulse'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer(context),
                borderRadius: AppRadius.large,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: const ThemeSwitchTile(),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () => _handleLogout(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.red),
                    ],
                  ),
                ),
              ),
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
  final String? className;
  final VoidCallback onClassTap;
  final VoidCallback onSettingsTap;

  const _MoreHeader({
    required this.className,
    required this.onClassTap,
    required this.onSettingsTap,
  });

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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (className != null && className!.isNotEmpty)
                InkWell(
                  onTap: onClassTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        className!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primary(context),
                      ),
                    ],
                  ),
                )
              else
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
        const SizedBox(width: AppSpacing.s),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: AppRadius.large,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: const NotificationBellButton(),
        ),
        const SizedBox(width: AppSpacing.s),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: AppRadius.large,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: onSettingsTap,
          ),
        ),
      ],
    );
  }
}

class _QuickAccessTileData {
  final IconData icon;
  final Color color;
  final String label;
  final String route;

  const _QuickAccessTileData({
    required this.icon,
    required this.color,
    required this.label,
    required this.route,
  });
}

class _QuickAccessRow extends StatelessWidget {
  static const _tiles = [
    _QuickAccessTileData(
      icon: Icons.calendar_today_rounded,
      color: AppColors.successGreen,
      label: 'Calendar',
      route: '/staff/calendar',
    ),
    _QuickAccessTileData(
      icon: Icons.chat_bubble_outline_rounded,
      color: Colors.purple,
      label: 'Messages',
      route: '/staff/messages',
    ),
    _QuickAccessTileData(
      icon: Icons.campaign_rounded,
      color: AppColors.goldenYellow,
      label: 'News',
      route: '/staff/more/announcements',
    ),
    _QuickAccessTileData(
      icon: Icons.folder_outlined,
      color: AppColors.electricBlue,
      label: 'Resources',
      route: '/staff/resources',
    ),
    _QuickAccessTileData(
      icon: Icons.menu_book_rounded,
      color: AppColors.deepOrange,
      label: 'Lessons',
      route: '/staff/lesson-plans',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(title: 'QUICK ACCESS'),
        const SizedBox(height: 8),
        AppCard(
          child: Row(
            children: [
              for (final tile in _tiles) ...[
                Expanded(
                  child: InkWell(
                    onTap: () => context.push(tile.route),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tile.color.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tile.icon, color: tile.color, size: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tile.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _Avatar(name: name, photoUrl: photoUrl, size: 56),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.elevatedSurfaceDark
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
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
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary(
                            context,
                          ).withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted(context),
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

  const _Avatar({
    required this.name,
    required this.photoUrl,
    required this.size,
  });

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
