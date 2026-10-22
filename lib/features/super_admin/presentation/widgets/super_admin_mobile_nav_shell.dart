import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Process-wide rapid-tap guard for owner-console navigation. Both the
/// dashboard sidebar and this bottom nav route through GoRouter; a
/// double/triple tap otherwise fires back-to-back `context.go`s that read
/// as a flash. Shared here (rather than per-widget state) because the
/// bottom nav is a StatelessWidget rebuilt on every section change.
DateTime _lastOwnerNavAt = DateTime.fromMillisecondsSinceEpoch(0);
const Duration _kOwnerNavDebounce = Duration(milliseconds: 350);

bool ownerNavThrottled() {
  final now = DateTime.now();
  if (now.difference(_lastOwnerNavAt) < _kOwnerNavDebounce) return true;
  _lastOwnerNavAt = now;
  return false;
}

@visibleForTesting
void debugResetOwnerNavThrottle() {
  _lastOwnerNavAt = DateTime.fromMillisecondsSinceEpoch(0);
}

/// Resolves a Super Admin URL to the owning console section. Keep this in
/// the shared navigation layer so full-page routes and dashboard tab routes
/// cannot drift apart.
int superAdminSectionForPath(String path) {
  if (path.startsWith('/super-admin/schools')) return 1;
  if (path.startsWith('/super-admin/payments') ||
      path.startsWith('/super-admin/plans') ||
      path.startsWith('/super-admin/subscriptions') ||
      path.startsWith('/super-admin/billing')) {
    return 2;
  }
  if (path.startsWith('/super-admin/audit-logs') ||
      path.startsWith('/super-admin/activity')) {
    return 3;
  }
  if (path.startsWith('/super-admin/settings')) {
    return 4;
  }
  // Notifications is reached from the Overview bell, not nested under
  // Settings, and is not a sixth destination - Overview stays highlighted
  // while it's open. Platform Health intentionally belongs to Overview too.
  return 0;
}

const _kSuperAdminSectionPaths = [
  '/super-admin',
  '/super-admin/schools',
  '/super-admin/payments',
  '/super-admin/audit-logs',
  '/super-admin/settings',
];

/// The one compact owner-console navigation control used by both the
/// dashboard and full-page Super Admin routes. It deliberately performs
/// real GoRouter navigation so browser/Android Back and iOS edge-back retain
/// their route history.
class SuperAdminBottomNavigation extends StatelessWidget {
  const SuperAdminBottomNavigation({
    super.key,
    required this.selectedIndex,
    this.onReselect,
  });

  final int selectedIndex;
  final VoidCallback? onReselect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.border(context))),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 18,
                offset: const Offset(0, -5),
              ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarTheme.of(context).copyWith(
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? (isDark ? AppColors.bgDark : AppColors.surfaceLight)
                    : AppColors.textMuted(context),
              ),
            ),
          ),
          child: NavigationBar(
            height: 72,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.information(context),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? AppColors.information(context)
                    : AppColors.textMuted(context),
                fontSize: 12,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              if (index == selectedIndex) {
                onReselect?.call();
                return;
              }
              if (ownerNavThrottled()) return;
              final target = _kSuperAdminSectionPaths[index];
              if (GoRouterState.of(context).uri.path == target) return;
              context.go(target);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Schools',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Billing',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the owner-console navigation available when a settings sub-route is
/// opened as a full GoRouter page rather than inside the dashboard tab stack.
class SuperAdminMobileNavShell extends StatelessWidget {
  const SuperAdminMobileNavShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    return superAdminSectionForPath(GoRouterState.of(context).uri.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Some owner settings screens use Navigator.push for their follow-up
      // pages. Keeping that Navigator inside this Scaffold means those pages
      // remain above the content, but below the persistent bottom navigation.
      body: Navigator(
        onGenerateRoute: (settings) => PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        ),
      ),
      bottomNavigationBar: SuperAdminBottomNavigation(
        selectedIndex: _selectedIndex(context),
        // A full-page sub-route has no dashboard tab Navigator to pop. Its
        // established reselect behavior is therefore to return to the real
        // parent section route.
        onReselect: () =>
            context.go(_kSuperAdminSectionPaths[_selectedIndex(context)]),
      ),
    );
  }
}
