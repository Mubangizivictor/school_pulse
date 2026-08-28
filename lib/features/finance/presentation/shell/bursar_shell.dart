import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_home_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_student_lookup_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_cash_bank_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_more_screen.dart';

/// Bottom-navigation shell for the Bursar / Finance module.
///
/// 5 tabs, matching the locked reference screenshots exactly:
/// **Home | Students | Approvals | Cash & Bank | More**.
/// The active tab is black, inactive tabs grey. Each tab owns a nested
/// [Navigator] so screens pushed on top of a tab keep this bottom nav
/// visible (push-on-top-of-tab pattern). Receive Payment is reached from a
/// Home quick action or the student statement screen, not a tab.
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

  static const List<_TabSpec> _tabs = [
    _TabSpec(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabSpec(
      Icons.people_outline_rounded,
      Icons.people_alt_rounded,
      'Students',
    ),
    _TabSpec(Icons.verified_outlined, Icons.verified_rounded, 'Approvals'),
    _TabSpec(
      Icons.account_balance_outlined,
      Icons.account_balance_rounded,
      'Cash & Bank',
    ),
    _TabSpec(Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
  ];

  Widget _rootFor(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const BursarHomeScreen();
      case 1:
        return const BursarStudentLookupScreen();
      case 2:
        return const BursarApprovalsScreen();
      case 3:
        return const BursarCashBankScreen();
      case 4:
      default:
        return const BursarMoreScreen();
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) => MaterialPageRoute(
        builder: (_) => _rootFor(index),
        settings: routeSettings,
      ),
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
    final canPopInTab =
        _navigatorKeys[_selectedIndex].currentState?.canPop() ?? false;
    if (canPopInTab) {
      _navigatorKeys[_selectedIndex].currentState?.pop();
      return false;
    }
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final muted = AppColors.textMuted(context);

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
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border(context))),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.surfaceElevated(context),
              indicatorColor: AppColors.surfaceContainer(context),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: states.contains(WidgetState.selected)
                      ? primary
                      : muted,
                ),
              ),
            ),
            child: NavigationBar(
              height: 64,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final tab in _tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon, size: 24, color: muted),
                    selectedIcon: Icon(
                      tab.selectedIcon,
                      size: 24,
                      color: primary,
                    ),
                    label: tab.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _TabSpec(this.icon, this.selectedIcon, this.label);
}
