import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffShell extends StatelessWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  bool _isAdmin(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return UserRoleDisplay.adminRoles.contains(state.user.role);
    }
    return false;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final isAdmin = _isAdmin(context);

    if (isAdmin) {
      if (location.startsWith('/staff/admin') && !location.contains('users')) return 0;
      if (location.contains('users')) return 1;
      if (location.startsWith('/staff/messages')) return 2;
      if (location.startsWith('/staff/more')) return 3;
    } else {
      if (location.startsWith('/staff/dashboard')) return 0;
      if (location.startsWith('/staff/attendance')) return 1;
      if (location.startsWith('/staff/marks')) return 2;
      if (location.startsWith('/staff/messages')) return 3;
      if (location.startsWith('/staff/more')) return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final isAdmin = _isAdmin(context);
    if (isAdmin) {
      switch (index) {
        case 0: context.go('/staff/admin'); break;
        case 1: context.go('/staff/admin/users'); break;
        case 2: context.go('/staff/messages'); break;
        case 3: context.go('/staff/more'); break;
      }
    } else {
      switch (index) {
        case 0: context.go('/staff/dashboard'); break;
        case 1: context.go('/staff/attendance'); break;
        case 2: context.go('/staff/marks'); break;
        case 3: context.go('/staff/messages'); break;
        case 4: context.go('/staff/more'); break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isAdmin = _isAdmin(context);

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

    final destinations = isAdmin ? adminDestinations : teacherDestinations;

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
                child: Image.asset('assets/logo.png', height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.bolt, color: Colors.blue, size: 32)),
              ),
              destinations: destinations.map((d) => NavigationRailDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              )).toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
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
