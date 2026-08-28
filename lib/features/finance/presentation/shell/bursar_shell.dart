import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_home_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_student_lookup_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_cash_bank_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_more_screen.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_web_shell.dart';

/// Width-adaptive shell for the Bursar / Finance module.
///
/// - `< 600` (mobile): the 5-tab bottom-navigation shell
///   (**Home | Students | Approvals | Cash & Bank | More**) — unchanged.
/// - `600–1023` (tablet): the desktop console with a collapsed icon rail.
/// - `>= 1024` (desktop): the full [BursarWebShell] — sidebar + top bar +
///   11 URL-addressable sections.
///
/// Mobile keeps per-tab nested [Navigator]s (push-on-top-of-tab). Receive
/// Payment is reached from a Home quick action or the student statement
/// screen, not a tab.
class BursarShell extends StatelessWidget {
  /// The tab that opens for a direct mobile route into this module.
  final int initialTab;

  /// A student statement opened through a deep link. It is deliberately
  /// rendered inside the Students tab navigator so the mobile bottom nav is
  /// still present, just as it is for statements opened from the list.
  final Widget? studentDetail;

  const BursarShell({super.key, this.initialTab = 0, this.studentDetail});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        switch (layout) {
          case ResponsiveLayout.desktop:
            return BursarWebShell(studentDetail: studentDetail);
          case ResponsiveLayout.tablet:
            return BursarWebShell(compact: true, studentDetail: studentDetail);
          case ResponsiveLayout.mobile:
            return _BursarMobileShell(
              initialTab: initialTab,
              studentDetail: studentDetail,
            );
        }
      },
    );
  }
}

/// The original mobile bottom-navigation shell.
class _BursarMobileShell extends StatefulWidget {
  final int initialTab;
  final Widget? studentDetail;

  const _BursarMobileShell({required this.initialTab, this.studentDetail});

  @override
  State<_BursarMobileShell> createState() => _BursarMobileShellState();
}

/// Lets a descendant (e.g. a Home quick action) switch the visible mobile
/// tab instead of pushing a duplicate screen onto the Home navigator; a
/// no-op on the desktop console (which routes by URL). Tab indices:
/// 0 Home · 1 Students · 2 Approvals · 3 Cash & Bank · 4 More.
class BursarShellNav {
  const BursarShellNav._();
  static void goToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_BursarMobileShellState>()?._selectTab(
      index,
    );
  }
}

class _BursarMobileShellState extends State<_BursarMobileShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.studentDetail == null ? widget.initialTab : 1;
  }

  @override
  void didUpdateWidget(covariant _BursarMobileShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studentDetail != oldWidget.studentDetail ||
        widget.initialTab != oldWidget.initialTab) {
      _selectedIndex = widget.studentDetail == null ? widget.initialTab : 1;
    }
  }

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
        return widget.studentDetail ?? const BursarStudentLookupScreen();
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
          Icon(
            selected ? spec.selectedIcon : spec.icon,
            size: 24,
            color: color,
          ),
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
