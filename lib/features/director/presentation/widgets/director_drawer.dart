import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Left navigation drawer shared by every Director screen.
///
/// Opened via `Scaffold(drawer: const DirectorDrawer())` and a leading
/// hamburger icon (`Scaffold.of(context).openDrawer()`) in each screen's
/// AppBar. Purely a navigation shell - no business logic, no data fetching
/// beyond reading the signed-in user's name/role off [AuthBloc].
class DirectorDrawer extends StatelessWidget {
  const DirectorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: '/staff/director',
                  ),
                  _DrawerItem(
                    icon: Icons.speed_rounded,
                    label: 'Performance',
                    route: '/staff/director/performance',
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Finance',
                    route: '/staff/director/finance',
                  ),
                  _DrawerItem(
                    icon: Icons.fact_check_rounded,
                    label: 'Approvals',
                    route: '/staff/director/approvals',
                    badgeCount: null,
                  ),
                  _DrawerItem(
                    icon: Icons.school_rounded,
                    label: 'Academics',
                    route: '/staff/director/academics',
                  ),
                  _DrawerItem(
                    icon: Icons.groups_rounded,
                    label: 'Students',
                    route: '/staff/director/students',
                  ),
                  _DrawerItem(
                    icon: Icons.badge_rounded,
                    label: 'Staff',
                    route: '/staff/director/staff',
                  ),
                  _DrawerItem(
                    icon: Icons.family_restroom_rounded,
                    label: 'Parents & Engagement',
                    route: '/staff/director/parents',
                  ),
                  _DrawerItem(
                    icon: Icons.account_tree_rounded,
                    label: 'Departments',
                    route: '/staff/director/departments',
                  ),
                  _DrawerItem(
                    icon: Icons.insights_rounded,
                    label: 'Reports',
                    route: '/staff/director/reports',
                  ),
                  _DrawerItem(
                    icon: Icons.track_changes_rounded,
                    label: 'Goals & Targets',
                    route: '/staff/director/goals',
                  ),
                  _DrawerItem(
                    icon: Icons.event_note_rounded,
                    label: 'Meetings',
                    route: '/staff/director/meetings',
                  ),
                  _DrawerItem(
                    icon: Icons.report_problem_rounded,
                    label: 'Incidents',
                    route: '/staff/director/incidents',
                  ),
                  _DrawerItem(
                    icon: Icons.campaign_rounded,
                    label: 'Communication',
                    route: '/staff/director/communication',
                  ),
                  _DrawerItem(
                    icon: Icons.corporate_fare_rounded,
                    label: 'Multi-Campus',
                    route: '/staff/director/multi-campus',
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: '/staff/director/settings',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // No app-wide sync-status mechanism exists yet (checked
            // core/services for a "last sync" signal - none found), so this
            // row intentionally shows a static "—" rather than a fabricated
            // timestamp. Wire this up once a real sync tracker exists.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sync Status — Last sync: —',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is AuthAuthenticated ? state.user.name : 'Director';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          color: colors.surfaceContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarInitials(name: name, size: 56),
              const SizedBox(height: 12),
              Text(
                'Director Portal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'School Director',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final int? badgeCount;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.path;
    final isSelected = location == route;

    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: colors.primary.withValues(alpha: 0.08),
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? colors.primary : colors.onSurface,
        ),
      ),
      trailing: badgeCount != null && badgeCount! > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        if (!isSelected) context.go(route);
      },
    );
  }
}

/// Small reusable AppBar leading hamburger button that opens the
/// [DirectorDrawer]. Screens that are not the top-level Dashboard show a
/// back chevron instead per the reference design, so this is only used
/// where a drawer trigger (not back navigation) is appropriate.
class DirectorMenuButton extends StatelessWidget {
  const DirectorMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      onPressed: () => Scaffold.of(context).openDrawer(),
      tooltip: 'Menu',
    );
  }
}
