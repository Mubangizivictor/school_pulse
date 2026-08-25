import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../responsive.dart';

/// Keeps the owner-console navigation available when a settings sub-route is
/// opened as a full GoRouter page rather than inside the dashboard tab stack.
class SuperAdminMobileNavShell extends StatelessWidget {
  const SuperAdminMobileNavShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/super-admin/schools')) return 1;
    if (path.startsWith('/super-admin/payments')) return 2;
    if (path.startsWith('/super-admin/plans')) return 3;
    if (path.startsWith('/super-admin/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isSuperAdminWide(context)) return child;

    return Scaffold(
      // Some owner settings screens use Navigator.push for their follow-up
      // pages. Keeping that Navigator inside this Scaffold means those pages
      // remain above the content, but below the persistent bottom navigation.
      body: Navigator(
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => child, settings: settings),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 88,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary(context),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary(context)
                  : AppColors.textMuted(context),
              fontSize: 12.5,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
          selectedIndex: _selectedIndex(context),
          onDestinationSelected: (index) {
            const paths = [
              '/super-admin',
              '/super-admin/schools',
              '/super-admin/payments',
              '/super-admin/plans',
              '/super-admin/settings',
            ];
            context.go(paths[index]);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Schools',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Payments',
            ),
            NavigationDestination(
              icon: Icon(Icons.subscriptions_outlined),
              selectedIcon: Icon(Icons.subscriptions),
              label: 'Plans',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
