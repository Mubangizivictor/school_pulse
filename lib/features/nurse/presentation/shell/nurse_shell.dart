import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_records_hub_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_home_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/messages_list_screen.dart';
import 'package:school_pulse/features/nurse/presentation/screens/nurse_more_screen.dart';

/// Bottom-navigation shell for the Nurse / Health Center module.
///
/// 4 tabs: Home / Records / Messages / More. Each tab owns a nested
/// [Navigator] so screens pushed on top of a tab's root keep the
/// [NurseShell]'s bottom nav visible (push-on-top-of-tab pattern).
class NurseShell extends StatefulWidget {
  const NurseShell({super.key});

  @override
  State<NurseShell> createState() => _NurseShellState();
}

class _NurseShellState extends State<NurseShell> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  List<NavigationDestination> _destinations(BuildContext context) {
    final primary = AppColors.primary(context);
    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24, color: primary),
        label: 'Home',
      ),
      NavigationDestination(
        icon: const Icon(Icons.assignment_outlined, size: 24),
        selectedIcon: Icon(Icons.assignment_rounded, size: 24, color: primary),
        label: 'Records',
      ),
      NavigationDestination(
        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.chat_bubble_rounded, size: 24, color: primary),
        label: 'Messages',
      ),
      NavigationDestination(
        icon: const Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24, color: primary),
        label: 'More',
      ),
    ];
  }

  Widget _tabRoot(int index) {
    switch (index) {
      case 0:
        return const NurseHomeScreen();
      case 1:
        return const NurseRecordsHubScreen();
      case 2:
        return const MessagesListScreen();
      case 3:
      default:
        return const NurseMoreScreen();
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (_) => _tabRoot(index),
          settings: routeSettings,
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
        !(_navigatorKeys[_selectedIndex].currentState?.canPop() ?? false);
    if (isFirstRouteInCurrentTab) {
      return true;
    }
    _navigatorKeys[_selectedIndex].currentState?.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(4, _buildTabNavigator),
        ),
        bottomNavigationBar: Container(
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
            indicatorColor: AppColors.primary(context),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: _destinations(context),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
