import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_home_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/fee_collection_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_student_lookup_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/financial_reports_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_more_screen.dart';

/// Bottom-navigation shell for the Bursar / Finance module.
///
/// 5 tabs: Home / Collections / Students / Reports / More.
/// Each tab owns a nested [Navigator] so that screens pushed on top of a
/// tab's root keep the [BursarShell]'s bottom nav visible (push-on-top-of-tab
/// pattern).
class BursarShell extends StatefulWidget {
  const BursarShell({super.key});

  @override
  State<BursarShell> createState() => _BursarShellState();
}

class _BursarShellState extends State<BursarShell> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined, size: 24),
      selectedIcon: Icon(
        Icons.home_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined, size: 24),
      selectedIcon: Icon(
        Icons.account_balance_wallet_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Collections',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline_rounded, size: 24),
      selectedIcon: Icon(
        Icons.people_alt_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Students',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined, size: 24),
      selectedIcon: Icon(
        Icons.bar_chart_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Reports',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined, size: 24),
      selectedIcon: Icon(
        Icons.grid_view_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'More',
    ),
  ];

  Widget Function(BuildContext) _routeBuilder(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return (_) => const BursarHomeScreen();
      case 1:
        return (_) => const FeeCollectionScreen();
      case 2:
        return (_) => const BursarStudentLookupScreen();
      case 3:
        return (_) => const FinancialReportsScreen();
      case 4:
      default:
        return (_) => const BursarMoreScreen();
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: _routeBuilder(index),
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
          children: List.generate(5, _buildTabNavigator),
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
            indicatorColor: AppColors.electricBlue,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: _destinations,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
