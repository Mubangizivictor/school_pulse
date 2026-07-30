import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/theme_provider.dart';
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

  /// Only classroom teachers have an "Attendance"/"Marks" tab - every other
  /// operational role (bursar, nurse, HR, discipline, etc.) gets a simpler
  /// Home/Messages/More nav instead of screens that don't apply to them.
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

  /// The signed-in user's own dashboard, so a bursar's Home tab doesn't land
  /// on the teacher dashboard. Staff holding more than one role go to the
  /// role hub instead of any single role's dashboard.
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isAdmin = _isAdmin(context);
    final isTeacher = _isTeacher(context);

    final List<NavigationDestination> teacherDestinations = const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.how_to_reg_outlined), selectedIcon: Icon(Icons.how_to_reg), label: 'Attendance'),
      NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Marks'),
      NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
      NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
    ];

    final List<NavigationDestination> adminDestinations = const [
      NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.manage_accounts_outlined), selectedIcon: Icon(Icons.manage_accounts), label: 'Users'),
      NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    ];

    final List<NavigationDestination> operationalDestinations = const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
      NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
    ];

    final destinations = isAdmin
        ? adminDestinations
        : (isTeacher ? teacherDestinations : operationalDestinations);

    final config = context.watch<ThemeProvider>().config;
    final logoUrl = config?.schoolLogoUrl;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 1200,
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.none,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.bolt, color: Colors.blue, size: 32),
                      )
                    : const Icon(Icons.bolt, color: Colors.blue, size: 32),
              ),
              destinations: destinations.map((d) => NavigationRailDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              )).toList(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      onPressed: () => _handleLogout(context),
                      tooltip: 'Logout',
                    ),
                  ),
                ),
              ),
            ),
          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              destinations: destinations,
            )
          : null,
    );
  }
}
