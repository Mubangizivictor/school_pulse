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
import '../widgets/super_admin_mobile_nav_shell.dart';
import '../widgets/super_admin_tab_navigator.dart';
import 'audit_logs_screen.dart';
import 'billing_home_screen.dart';
import 'school_management_screen.dart';
import 'super_admin_overview_screen.dart';
import 'super_admin_settings_screen.dart';

/// Section paths, in the same order as `_kSections` — index N here is
/// index N there, and both match the approved five-item navigation
/// exactly: Overview | Schools | Billing | Activity | Settings. Each is a
/// real child GoRoute of `/super-admin` so the URL, browser refresh, and
/// Back/Forward reflect the active section instead of only living in
/// local widget state. Plans and Payment Methods are tabs inside Billing
/// (BillingHomeScreen), not separate destinations; Notifications is
/// reached from the top bar's bell icon, not a persistent nav item.
const _kSectionPaths = [
  '', // Overview (the /super-admin index route itself)
  'schools',
  'payments', // Billing - kept as the existing route segment
  'audit-logs', // Activity
  'settings',
];

/// Reads the active section index from the current route location, so a
/// direct/refreshed URL like `/super-admin/payments` opens on the right
/// section instead of always resetting to Overview (index 0). Legacy
/// `/super-admin/plans` and `/super-admin/notifications` deep links still
/// resolve to Billing and Overview respectively (see the fallback below)
/// so existing bookmarks/pushes keep working under the collapsed nav.
int _sectionIndexForLocation(String location) {
  return superAdminSectionForPath(location);
}

/// Top-level sections, shown identically in the desktop sidebar and the
/// mobile bottom nav: Overview | Schools | Billing | Activity | Settings.
/// Schools also hosts Applications internally
/// (`SchoolManagementScreen`'s Active/Applications/Suspended tabs), and
/// Billing hosts Payments/Plans/Payment Methods internally
/// (`BillingHomeScreen`), so neither grows the top-level nav.
const _kSections = [
  (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Overview'),
  (icon: Icons.school_outlined, selectedIcon: Icons.school, label: 'Schools'),
  (
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: 'Billing',
  ),
  (
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: 'Activity',
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
  // Index into `_kSections` — the same five destinations drive both the
  // desktop sidebar and the mobile bottom nav, so one index now serves
  // both (no separate mobile-index remapping needed since the nav
  // collapsed from seven sections to exactly five: Overview | Schools |
  // Billing | Activity | Settings).
  int _selectedIndex = 0;

  String? _lastSyncedLocation;
  int _billingInitialTab = 0;

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
      setState(() => _selectedIndex = index);
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

  // Bumping this key forces BillingHomeScreen to rebuild with a fresh
  // `initialFilter`/`initialTab` when navigated to from the Overview's
  // "Payments to Verify" shortcut.
  ManualPaymentStatus? _billingInitialFilter;
  int _billingPageKey = 0;

  // One nested Navigator per section, shared by the desktop sidebar and
  // mobile bottom nav (both render the same five branches), so pushed
  // screens (School Details, Payment Review, Application Review, …) stay
  // inside that section instead of covering the nav.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    _kSections.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  void initState() {
    super.initState();
    context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    // The overview timeline consumes this already-supported dashboard state.
    context.read<SuperAdminBloc>().add(const LoadAuditLogsEvent());
  }

  void _popToRoot(GlobalKey<NavigatorState> key) {
    key.currentState?.popUntil((route) => route.isFirst);
  }

  void _goToBilling({ManualPaymentStatus? filter, int tab = 0}) {
    setState(() {
      _billingInitialFilter = filter;
      _billingInitialTab = tab;
      _billingPageKey++;
      _selectedIndex = 2;
    });
    _syncRouteToSection(_kSectionPaths[2]);
    _popToRoot(_navigatorKeys[2]);
  }

  void _goToSchools({String? query}) {
    setState(() {
      _selectedIndex = 1;
      if (query != null) _schoolsSearchQuery = query;
    });
    _syncRouteToSection(_kSectionPaths[1]);
    _popToRoot(_navigatorKeys[1]);
  }

  // Backs the top bar's global search: since Schools/Applications are the
  // only owner-searchable dataset today, a submitted query jumps there and
  // pre-fills its search field rather than pretending to search everything.
  String? _schoolsSearchQuery;

  @override
  Widget build(BuildContext context) {
    final branches = [
      SuperAdminOverviewScreen(
        onOpenBilling: () =>
            _goToBilling(filter: ManualPaymentStatus.pendingVerification),
        onOpenSchools: _goToSchools,
        onSearchSchools: (query) => _goToSchools(query: query),
      ),
      SchoolManagementScreen(initialQuery: _schoolsSearchQuery),
      BillingHomeScreen(
        key: ValueKey(_billingPageKey),
        initialFilter: _billingInitialFilter,
        initialTab: _billingInitialTab,
      ),
      const AuditLogsScreen(),
      const SuperAdminSettingsScreen(),
    ];

    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        for (final (index, branch) in branches.indexed)
          SuperAdminTabNavigator(
            navigatorKey: _navigatorKeys[index],
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

    return Scaffold(
      body: content,
      bottomNavigationBar: SuperAdminBottomNavigation(
        selectedIndex: _selectedIndex,
        onReselect: () => _popToRoot(_navigatorKeys[_selectedIndex]),
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
                        _popToRoot(_navigatorKeys[index]);
                        return;
                      }
                      setState(() => _selectedIndex = index);
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
        color: isSelected ? AppColors.primary(context) : Colors.transparent,
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
