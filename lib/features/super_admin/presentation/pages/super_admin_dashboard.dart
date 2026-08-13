import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import '../widgets/super_admin_tab_navigator.dart';
import 'audit_logs_screen.dart';
import 'billing_page.dart';
import 'school_management_screen.dart';
import 'subscription_plans_screen.dart';
import 'super_admin_notifications_screen.dart';
import 'super_admin_overview_screen.dart';
import 'super_admin_settings_screen.dart';

/// Section paths, in the same order as `_kSections` / the mobile bottom
/// nav — index N here is index N there. Each is a real child GoRoute of
/// `/super-admin` so the URL, browser refresh, and Back/Forward reflect
/// the active section instead of only living in local widget state.
const _kSectionPaths = [
  '', // Dashboard (the /super-admin index route itself)
  'schools',
  'payments',
  'plans',
  'notifications',
  'audit-logs',
  'settings',
];

/// Reads the active section index from the current route location, so a
/// direct/refreshed URL like `/super-admin/payments` opens on the right
/// section instead of always resetting to Dashboard (index 0).
int _sectionIndexForLocation(String location) {
  final path = location.startsWith('/super-admin')
      ? location.substring('/super-admin'.length)
      : '';
  final segment = path.startsWith('/') ? path.substring(1) : path;
  final top = segment.split('/').first;
  if (top.isEmpty) return 0;
  final index = _kSectionPaths.indexOf(top);
  return index == -1 ? 0 : index;
}

/// Top-level sections shown in the desktop sidebar. Schools also hosts
/// Applications internally (`SchoolManagementScreen`'s `_ApplicationList`),
/// so Applications is not broken out as its own top-level tab this phase —
/// it stays reachable via Schools, which keeps the sidebar from growing an
/// item that would just be a thin proxy to the same screen.
const _kSections = [
  (
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
  ),
  (icon: Icons.school_outlined, selectedIcon: Icons.school, label: 'Schools'),
  (
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: 'Payments & Billing',
  ),
  (
    icon: Icons.subscriptions_outlined,
    selectedIcon: Icons.subscriptions,
    label: 'Subscription Plans',
  ),
  (
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
    label: 'Notifications',
  ),
  (
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: 'Audit Logs',
  ),
  (
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  // Index into `_kSections` — drives the desktop sidebar / IndexedStack.
  // Kept in sync with the route (see `didChangeDependencies`) so a direct
  // URL or a browser refresh (e.g. `/super-admin/payments`) opens on the
  // matching section instead of always resetting to Dashboard.
  int _selectedIndex = 0;

  // Index into the 4-item mobile bottom nav (Home, Schools, Payments, More).
  // Settings (desktop section index 6) has no dedicated mobile tab, so it
  // clamps to the last one instead of pointing past the mobile array.
  int _mobileNavIndex = 0;

  String? _lastSyncedLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only react to *external* location changes (deep link, browser
    // refresh, Back/Forward) — sidebar/bottom-nav taps already update
    // `_selectedIndex` locally and push the matching route themselves, so
    // re-deriving it here too would just be redundant, not wrong.
    final location = GoRouterState.of(context).uri.path;
    if (location == _lastSyncedLocation) return;
    _lastSyncedLocation = location;
    final index = _sectionIndexForLocation(location);
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        // Mobile nav only has 5 destinations (Home, Schools, Payments,
        // Plans, Settings); Notifications/Audit Logs (desktop indices 4-5)
        // have no dedicated mobile tab, so land on the nearest one rather
        // than pointing the bottom nav's `selectedIndex` out of range.
        _mobileNavIndex = index == 6
            ? 4
            : index > 3
            ? 3
            : index;
      });
    }
  }

  /// Updates the URL to match `sectionPath` (a child of `/super-admin`,
  /// e.g. `'schools'`, or `''` for the Dashboard root) without disturbing
  /// that section's own nested-Navigator stack.
  void _syncRouteToSection(String sectionPath) {
    final target = sectionPath.isEmpty
        ? '/super-admin'
        : '/super-admin/$sectionPath';
    _lastSyncedLocation = target;
    if (GoRouterState.of(context).uri.path == target) return;
    context.go(target);
  }

  // Bumping this key forces BillingPage to rebuild with a fresh
  // `initialFilter` when navigated to from the Dashboard's
  // "Payments to Verify" shortcut.
  ManualPaymentStatus? _billingInitialFilter;
  int _billingPageKey = 0;

  // One nested Navigator per desktop sidebar section, so pushed screens
  // (School Details, Payment Review, Application Review, …) stay inside
  // that section instead of covering the sidebar.
  final List<GlobalKey<NavigatorState>> _desktopNavigatorKeys = List.generate(
    _kSections.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  // One nested Navigator per mobile bottom-nav destination (Home, Schools,
  // Payments, Plans, More), so the bottom bar stays visible on pushed
  // screens.
  final List<GlobalKey<NavigatorState>> _mobileNavigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  void initState() {
    super.initState();
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
  }

  void _popToRoot(GlobalKey<NavigatorState> key) {
    key.currentState?.popUntil((route) => route.isFirst);
  }

  void _goToBilling({ManualPaymentStatus? filter}) {
    setState(() {
      _billingInitialFilter = filter;
      _billingPageKey++;
      _selectedIndex = 2;
      _mobileNavIndex = 2;
    });
    _syncRouteToSection(_kSectionPaths[2]);
    _popToRoot(_desktopNavigatorKeys[2]);
    _popToRoot(_mobileNavigatorKeys[2]);
  }

  void _goToSchools({String? query}) {
    setState(() {
      _selectedIndex = 1;
      _mobileNavIndex = 1;
      if (query != null) _schoolsSearchQuery = query;
    });
    _syncRouteToSection(_kSectionPaths[1]);
    _popToRoot(_desktopNavigatorKeys[1]);
    _popToRoot(_mobileNavigatorKeys[1]);
  }

  // Backs the top bar's global search: since Schools/Applications are the
  // only owner-searchable dataset today, a submitted query jumps there and
  // pre-fills its search field rather than pretending to search everything.
  String? _schoolsSearchQuery;

  @override
  Widget build(BuildContext context) {
    final desktopBranches = [
      SuperAdminOverviewScreen(
        onOpenBilling: () =>
            _goToBilling(filter: ManualPaymentStatus.pendingVerification),
        onOpenSchools: _goToSchools,
        onSearchSchools: (query) => _goToSchools(query: query),
      ),
      SchoolManagementScreen(initialQuery: _schoolsSearchQuery),
      BillingPage(
        key: ValueKey(_billingPageKey),
        initialFilter: _billingInitialFilter,
      ),
      const SubscriptionPlansScreen(),
      const SuperAdminNotificationsScreen(),
      const AuditLogsScreen(),
      const SuperAdminSettingsScreen(),
    ];

    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        for (final (index, branch) in desktopBranches.indexed)
          SuperAdminTabNavigator(
            navigatorKey: _desktopNavigatorKeys[index],
            child: branch,
          ),
      ],
    );

    if (isSuperAdminWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(child: content),
          ],
        ),
      );
    }

    final mobileBranches = [
      SuperAdminOverviewScreen(
        onOpenBilling: () =>
            _goToBilling(filter: ManualPaymentStatus.pendingVerification),
        onOpenSchools: _goToSchools,
      ),
      const SchoolManagementScreen(),
      BillingPage(
        key: ValueKey('mobile-$_billingPageKey'),
        initialFilter: _billingInitialFilter,
      ),
      const SubscriptionPlansScreen(),
      const SuperAdminSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _mobileNavIndex,
        children: [
          for (final (index, branch) in mobileBranches.indexed)
            SuperAdminTabNavigator(
              navigatorKey: _mobileNavigatorKeys[index],
              child: branch,
            ),
        ],
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
          indicatorColor: AppColors.primary(context).withValues(alpha: 0.14),
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
          selectedIndex: _mobileNavIndex,
          onDestinationSelected: (index) {
            if (index == _mobileNavIndex) {
              // Re-tapping the active tab returns it to its root screen,
              // matching standard tab-bar behavior.
              _popToRoot(_mobileNavigatorKeys[index]);
              return;
            }
            // Mobile nav index 4 is Settings, which is desktop section
            // index 6 (Notifications and Audit Logs have no mobile tab of
            // their own) — every other index lines up 1:1 with a desktop
            // section and a `_kSectionPaths` entry.
            final sectionIndex = index == 4 ? 6 : index;
            setState(() {
              _mobileNavIndex = index;
              _selectedIndex = sectionIndex;
            });
            _syncRouteToSection(_kSectionPaths[sectionIndex]);
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

  Widget _buildSidebar() {
    final user = FirebaseAuth.instance.currentUser;
    final ownerLabel = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email?.trim().isNotEmpty ?? false)
        ? user!.email!.trim()
        : 'SaaS Owner';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(
          right: BorderSide(color: AppColors.border(context), width: 1),
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
          const SizedBox(height: AppSpacing.x4l),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: PulseLogo(variant: PulseLogoVariant.full, size: 40),
          ),
          const SizedBox(height: AppSpacing.x4l),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              children: [
                for (final (index, section) in _kSections.indexed)
                  _SidebarItem(
                    icon: section.icon,
                    selectedIcon: section.selectedIcon,
                    label: section.label,
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      if (index == _selectedIndex) {
                        // Re-selecting the active section returns it to
                        // its root screen, matching the mobile tab bar.
                        _popToRoot(_desktopNavigatorKeys[index]);
                        return;
                      }
                      setState(() {
                        _selectedIndex = index;
                        _mobileNavIndex = index == 6
                            ? 4
                            : index > 3
                            ? 3
                            : index;
                      });
                      _syncRouteToSection(_kSectionPaths[index]);
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary(context),
                  child: Text(
                    _initialsOf(ownerLabel),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          ownerLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      Text(
                        'SaaS Owner',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            isSelected: false,
            onTap: () => handleSuperAdminLogout(context),
            isDestructive: true,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _initialsOf(String label) {
    final parts = label
        .split(RegExp(r'[\s@.]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SO';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SidebarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.danger(context)
        : (isSelected
              ? AppColors.primary(context)
              : AppColors.textSecondary(context));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? AppColors.primary(context).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            isSelected ? (selectedIcon ?? icon) : icon,
            color: color,
            size: 22,
          ),
          title: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
