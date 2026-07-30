import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffShell extends StatelessWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  bool _isAdmin(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.any(UserRoleDisplay.adminConsoleRoles.contains);
    }
    return false;
  }

  static const List<UserRole> _teacherRoles = [UserRole.classTeacher, UserRole.subjectTeacher];

  bool _isTeacher(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.any(_teacherRoles.contains);
    }
    return false;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (_isAdmin(context)) {
      if (location.contains('users')) return 1;
      if (location.startsWith('/staff/messages')) return 2;
      if (location.contains('config')) return 3;
      if (location.startsWith('/staff/admin')) return 0;
      return 0;
    }

    if (_isTeacher(context)) {
      if (location.startsWith('/staff/dashboard')) return 0;
      if (location.startsWith('/staff/attendance')) return 1;
      if (location.startsWith('/staff/marks')) return 2;
      if (location.startsWith('/staff/messages')) return 3;
      if (location.startsWith('/staff/more')) return 4;
      return 0;
    }

    if (location.startsWith('/staff/messages')) return 1;
    if (location.startsWith('/staff/more')) return 2;
    return 0;
  }

  String _homePath(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      if (state.user.roles.length > 1) return '/staff/hub';
      return UserRoleRouting.dashboardPath(state.user.role);
    }
    return '/staff/dashboard';
  }

  void _onItemTapped(int index, BuildContext context) {
    if (_isAdmin(context)) {
      switch (index) {
        case 0: context.go('/staff/admin'); break;
        case 1: context.go('/staff/admin/users'); break;
        case 2: context.go('/staff/messages'); break;
        case 3: context.go('/staff/admin/config'); break;
      }
      return;
    }

    if (_isTeacher(context)) {
      switch (index) {
        case 0: context.go(_homePath(context)); break;
        case 1: context.go('/staff/attendance'); break;
        case 2: context.go('/staff/marks'); break;
        case 3: context.go('/staff/messages'); break;
        case 4: context.go('/staff/more'); break;
      }
      return;
    }

    switch (index) {
      case 0: context.go(_homePath(context)); break;
      case 1: context.go('/staff/messages'); break;
      case 2: context.go('/staff/more'); break;
    }
  }

  void _handleLogout(BuildContext context) async {
    // Note: confirmActionDialog was previously imported from app_components.dart
    // For now, using standard showDialog until PulseDialogs are implemented
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.deepOrange)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isAdmin = _isAdmin(context);
    final isTeacher = _isTeacher(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<NavigationDestination> teacherDestinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.how_to_reg_outlined, size: 24),
        selectedIcon: Icon(Icons.how_to_reg_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Attendance',
      ),
      NavigationDestination(
        icon: Icon(Icons.edit_note_outlined, size: 24),
        selectedIcon: Icon(Icons.edit_note_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Marks',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.chat_bubble_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Messages',
      ),
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24, color: AppColors.royalBlue),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> adminDestinations = const [
      NavigationDestination(
        icon: Icon(Icons.analytics_outlined, size: 24),
        selectedIcon: Icon(Icons.analytics_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Insights',
      ),
      NavigationDestination(
        icon: Icon(Icons.people_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.people_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Users',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.chat_bubble_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Messages',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined, size: 24),
        selectedIcon: Icon(Icons.settings_rounded, size: 24, color: AppColors.royalBlue),
        label: 'System',
      ),
    ];

    final List<NavigationDestination> operationalDestinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.chat_bubble_rounded, size: 24, color: AppColors.royalBlue),
        label: 'Messages',
      ),
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24, color: AppColors.royalBlue),
        label: 'More',
      ),
    ];

    final destinations = isAdmin
        ? adminDestinations
        : (isTeacher ? teacherDestinations : operationalDestinations);

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: MediaQuery.of(context).size.width > 1200 ? 280 : 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 20,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4l),
                    child: PulseLogo(
                      size: 40,
                      variant: MediaQuery.of(context).size.width > 1200 
                          ? PulseLogoVariant.full 
                          : PulseLogoVariant.shield,
                    ),
                  ),
                  Expanded(
                    child: NavigationRail(
                      backgroundColor: Colors.transparent,
                      extended: MediaQuery.of(context).size.width > 1200,
                      selectedIndex: _calculateSelectedIndex(context),
                      onDestinationSelected: (idx) => _onItemTapped(idx, context),
                      minExtendedWidth: 280,
                      labelType: MediaQuery.of(context).size.width > 1200 
                          ? NavigationRailLabelType.none 
                          : NavigationRailLabelType.all,
                      unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.bold,
                      ),
                      destinations: destinations.map((d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                      )).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
                    child: _LogoutButton(onPressed: () => _handleLogout(context)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: AppColors.background(context),
              child: child,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: NavigationBar(
                height: 64,
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                indicatorColor: AppColors.electricBlue.withValues(alpha: 0.1),
                selectedIndex: _calculateSelectedIndex(context),
                onDestinationSelected: (idx) => _onItemTapped(idx, context),
                destinations: destinations,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
            )
          : null,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isExtended = MediaQuery.of(context).size.width > 1200;
    
    if (isExtended) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.logout_rounded, color: AppColors.deepOrange),
          label: Text(
            'Logout',
            style: AppTypography.labelLarge.copyWith(color: AppColors.deepOrange),
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: AppColors.deepOrange),
      onPressed: onPressed,
      tooltip: 'Logout',
    );
  }
}
