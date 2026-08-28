import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_home_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_student_lookup_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_cash_bank_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_more_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/budget_details_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/expenditure_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_suppliers_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_petty_cash_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_payroll_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/financial_reports_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_audit_trail_screen.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_section.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_web_shell.dart';

/// Width-adaptive shell for the Bursar / Finance module.
///
/// - `< 600` (mobile): the 5-tab bottom-navigation shell
///   (**Home | Students | Approvals | Cash & Bank | More**). Sections
///   without their own tab open on **More** with the section screen pushed.
/// - `600–1023` (tablet): the two-column console with an icon rail.
/// - `>= 1024` (desktop): the full [BursarWebShell] — sidebar + top bar +
///   11 URL-addressable sections.
///
/// [section] is the section a router deep link resolved to. It drives the
/// desktop `IndexedStack` and the mobile tab / More-push, so every
/// `/staff/bursar/<slug>` URL renders the right thing at every width and
/// survives a browser refresh.
class BursarShell extends StatelessWidget {
  /// The section this route targets. `null` == Finance overview.
  final BursarSection? section;

  /// A student statement opened through a deep link. Rendered inside the
  /// Students section so the finance chrome stays put.
  final Widget? studentDetail;

  const BursarShell({super.key, this.section, this.studentDetail});

  BursarSection get _section => section ?? BursarSection.overview;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        switch (layout) {
          case ResponsiveLayout.desktop:
            return BursarWebShell(
              initialSection: _section,
              studentDetail: studentDetail,
            );
          case ResponsiveLayout.tablet:
            return BursarWebShell(
              compact: true,
              initialSection: _section,
              studentDetail: studentDetail,
            );
          case ResponsiveLayout.mobile:
            return _BursarMobileShell(
              section: _section,
              studentDetail: studentDetail,
            );
        }
      },
    );
  }
}

/// The original mobile bottom-navigation shell.
class _BursarMobileShell extends StatefulWidget {
  final BursarSection section;
  final Widget? studentDetail;

  const _BursarMobileShell({required this.section, this.studentDetail});

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

/// Section screen for the mobile **More** stack (deep links to sections
/// that have no dedicated bottom-nav tab).
Widget _mobileSectionScreen(BursarSection s) {
  switch (s) {
    case BursarSection.budget:
      return const BudgetDetailsScreen();
    case BursarSection.expenses:
      return const ExpenditureScreen();
    case BursarSection.suppliers:
      return const BursarSuppliersScreen();
    case BursarSection.pettyCash:
      return const BursarPettyCashScreen();
    case BursarSection.payroll:
      return const BursarPayrollScreen();
    case BursarSection.reports:
      return const FinancialReportsScreen();
    case BursarSection.audit:
      return const BursarAuditTrailScreen();
    case BursarSection.overview:
    case BursarSection.students:
    case BursarSection.approvals:
    case BursarSection.cashBank:
      return const BursarMoreScreen();
  }
}

class _BursarMobileShellState extends State<_BursarMobileShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _tabForSection();
    _scheduleSectionPush(widget.section);
  }

  @override
  void didUpdateWidget(covariant _BursarMobileShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section != oldWidget.section ||
        widget.studentDetail != oldWidget.studentDetail) {
      setState(() => _selectedIndex = _tabForSection());
      _scheduleSectionPush(widget.section);
    }
  }

  int _tabForSection() {
    if (widget.studentDetail != null) return 1;
    return widget.section.mobileTab ?? BursarSection.moreTabIndex;
  }

  /// For a section with no own tab, land on **More** and push its screen so
  /// a phone deep link (`/staff/bursar/payroll`) shows payroll, not the
  /// More list.
  void _scheduleSectionPush(BursarSection s) {
    if (s.mobileTab != null || widget.studentDetail != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final nav = _navigatorKeys[BursarSection.moreTabIndex].currentState;
      nav?.popUntil((r) => r.isFirst);
      nav?.push(
        MaterialPageRoute(
          builder: (_) => _mobileSectionScreen(s),
          settings: RouteSettings(name: 'bursar-section-${s.slug}'),
        ),
      );
    });
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
