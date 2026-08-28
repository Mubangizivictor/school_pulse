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
/// **Home | Students | Approvals | Cash & Bank | More**. The active tab is
/// black (icon + label), inactive tabs grey (icon + label) — the label is
/// always shown, active or not. Each tab owns a nested [Navigator] so
/// screens pushed on top of a tab keep this bottom nav visible
/// (push-on-top-of-tab pattern). Receive Payment is reached from a Home
/// quick action or the student statement screen, not a tab.
class BursarShell extends StatefulWidget {
  const BursarShell({super.key});

  /// Lets a descendant (e.g. a Home quick action) switch the visible tab
  /// instead of pushing a duplicate screen onto the Home navigator.
  /// Tab indices: 0 Home · 1 Students · 2 Approvals · 3 Cash & Bank · 4 More.
  static void goToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_BursarShellState>()?._selectTab(index);
  }

  @override
  State<BursarShell> createState() => _BursarShellState();
}

class _BursarShellState extends State<BursarShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    if (!mounted) return;
    _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
    setState(() => _selectedIndex = index);
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const List<_TabSpec> _tabs = [
    _TabSpec(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabSpec(Icons.people_outline_rounded, Icons.people_alt_rounded, 'Students'),
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
    final active = AppColors.primary(context);
    final inactive = AppColors.textMuted(context);

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
            color: AppColors.surfaceElevated(context),
            border: Border(top: BorderSide(color: AppColors.border(context))),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: _NavItem(
                        spec: _tabs[i],
                        selected: i == _selectedIndex,
                        activeColor: active,
                        inactiveColor: inactive,
                        onTap: () => _onDestinationSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabSpec spec;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.spec,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? spec.selectedIcon : spec.icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
