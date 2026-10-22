import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/student/dashboard')) return 0;
    if (location.startsWith('/student/academics')) return 1;
    if (location.startsWith('/student/homework')) return 2;
    if (location.startsWith('/student/messages')) return 3;
    if (location.startsWith('/student/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/student/dashboard');
        break;
      case 1:
        context.go('/student/academics');
        break;
      case 2:
        context.go('/student/homework');
        break;
      case 3:
        context.go('/student/messages');
        break;
      case 4:
        context.go('/student/more');
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard, color: AppColors.royalBlue),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school, color: AppColors.royalBlue),
        label: 'Academics',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment, color: AppColors.royalBlue),
        label: 'Homework',
      ),
      const NavigationDestination(
        icon: MessagesNavIcon(icon: Icons.chat_bubble_outline_rounded),
        selectedIcon: MessagesNavIcon(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.royalBlue,
        ),
        label: 'Messages',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.royalBlue),
        label: 'More',
      ),
    ];

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
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
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
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x4l,
                    ),
                    child: MediaQuery.of(context).size.width > 1200
                        ? const PulseLogo(
                            size: 28,
                            variant: PulseLogoVariant.header,
                          )
                        : const PulseLogo(
                            size: 40,
                            variant: PulseLogoVariant.shield,
                          ),
                  ),
                  Expanded(
                    child: NavigationRail(
                      backgroundColor: AppColors.transparent,
                      extended: MediaQuery.of(context).size.width > 1200,
                      selectedIndex: _calculateSelectedIndex(context),
                      onDestinationSelected: (idx) =>
                          _onItemTapped(idx, context),
                      minExtendedWidth: 280,
                      labelType: MediaQuery.of(context).size.width > 1200
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      unselectedLabelTextStyle: AppTypography.labelMedium
                          .copyWith(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                      selectedLabelTextStyle: AppTypography.labelMedium
                          .copyWith(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.bold,
                          ),
                      destinations: destinations
                          .map(
                            (d) => NavigationRailDestination(
                              icon: d.icon,
                              selectedIcon: d.selectedIcon,
                              label: Text(d.label),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.m,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
                    child: _LogoutButton(
                      onPressed: () => _handleLogout(context),
                    ),
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
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                indicatorColor: AppColors.electricBlue,
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
          icon: const Icon(Icons.logout_rounded, color: AppColors.black),
          label: Text(
            'Logout',
            style: AppTypography.labelLarge.copyWith(color: AppColors.black),
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: AppColors.black),
      onPressed: onPressed,
      tooltip: 'Logout',
    );
  }
}
