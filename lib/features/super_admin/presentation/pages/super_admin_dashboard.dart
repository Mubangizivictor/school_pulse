import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_push_token_service.dart';

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

  // Rapid-tap guard shared with the mobile bottom nav (see
  // ownerNavThrottled in super_admin_mobile_nav_shell.dart) so a
  // double/triple tap - across either control - fires exactly one
  // navigation instead of stacking section switches that read as a flash.
  bool _navThrottled() => ownerNavThrottled();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The URL is the single source of truth for which section is active.
    // Nav taps only call `context.go` (see `_syncRouteToSection`); this
    // callback is what actually moves `_selectedIndex`, for taps, deep
    // links, browser refresh and Back/Forward alike. One code path, so the
    // sidebar/bottom-nav highlight can never disagree with the route.
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
  /// that section's own nested-Navigator stack. Deliberately does NOT touch
  /// `_selectedIndex` - `didChangeDependencies` does that once the route
  /// actually changes.
  void _syncRouteToSection(String sectionPath) {
    final target = sectionPath.isEmpty
        ? '/super-admin'
        : '/super-admin/$sectionPath';
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
    // Register this device in the dedicated owner FCM token store (data-only
    // owner push). Best-effort; safe to call on every owner-console entry.
    OwnerPushTokenService().registerCurrentDevice();
  }

  void _popToRoot(GlobalKey<NavigatorState> key) {
    key.currentState?.popUntil((route) => route.isFirst);
  }

  void _goToBilling({ManualPaymentStatus? filter, int tab = 0}) {
    if (_navThrottled()) return;
    setState(() {
      _billingInitialFilter = filter;
      _billingInitialTab = tab;
      _billingPageKey++;
    });
    _syncRouteToSection(_kSectionPaths[2]);
    _popToRoot(_navigatorKeys[2]);
  }

  void _goToSchools({String? query}) {
    if (_navThrottled()) return;
    if (query != null) {
      setState(() => _schoolsSearchQuery = query);
    }
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

    // Fixed dark rail, per the console reference: near-black panel in both
    // themes, light-blue active pill, everything else white/grey on black.
    const rail = Color(0xFF0B0B0C);
    const railItemText = Color(0xFFBDBDBD);
    final accent = AppColors.information(context);

    return Container(
      width: 264,
      decoration: const BoxDecoration(
        color: rail,
        border: Border(right: BorderSide(color: Color(0xFF1E1E1F), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Padding(
            // Match the nav items' left edge: ListView padding (12) + each
            // item's own inner padding (12) = 24.
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _SidebarBrand(
              onTap: () {
                if (_selectedIndex == 0) {
                  _popToRoot(_navigatorKeys[0]);
                  return;
                }
                if (_navThrottled()) return;
                _syncRouteToSection(_kSectionPaths[0]);
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final (index, section) in _kSections.indexed)
                  _SidebarItem(
                    icon: section.icon,
                    selectedIcon: section.selectedIcon,
                    label: section.label,
                    isSelected: _selectedIndex == index,
                    accent: accent,
                    idleColor: railItemText,
                    onTap: () {
                      if (index == _selectedIndex) {
                        // Re-selecting the active section returns it to
                        // its root screen, matching the mobile tab bar.
                        // No route change and no transition.
                        _popToRoot(_navigatorKeys[index]);
                        return;
                      }
                      if (_navThrottled()) return;
                      // URL-only: didChangeDependencies moves _selectedIndex
                      // once the route actually changes. One state update,
                      // one navigation, highlight always matches the route.
                      _syncRouteToSection(_kSectionPaths[index]);
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E1E1F)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: .10),
                  child: Text(
                    _initialsOf(ownerLabel),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'SaaS Owner',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A9A9A),
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
            accent: accent,
            idleColor: railItemText,
            onTap: () => handleSuperAdminLogout(context),
            isDestructive: true,
          ),
          const SizedBox(height: 16),
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

/// Sidebar brand lockup: the wordless School Pulse icon (theme-aware PNG)
/// followed by the "School Pulse" wordmark. Replaces the packaged
/// `PulseLogo` so the console header uses the supplied brand icons.
class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // The rail is always dark; use the dark-mode brand icon in both themes.
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logos/icon_dark_mode.png',
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 12),
        const Flexible(
          child: Text(
            'School Pulse',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color accent;
  final Color idleColor;

  const _SidebarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accent,
    required this.idleColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFE5605F)
        : (isSelected ? Colors.white : idleColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected ? accent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  isSelected ? (selectedIcon ?? icon) : icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
