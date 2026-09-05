import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/admin_dashboard_screen.dart';
import 'package:school_pulse/features/admin/admin_staff_attendance_screen.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/screens/parents_access_workspace_screen.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_list_page.dart';
import 'package:school_pulse/features/admin/presentation/screens/admin_more_screen.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_section.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_fees_screen.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_web_shell.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_center_screen.dart';
import 'package:school_pulse/features/appointments/presentation/screens/appointments_workspace_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_directory_screen.dart';

/// Width-adaptive shell for the School Admin console.
///
/// - `< 600` (mobile): the 4-tab bottom-navigation shell
///   (**Home | Students | Attendance | More**). Sections without their own
///   tab (including Fees) open on **More** with the section screen pushed.
/// - `600–1023` (tablet): the two-column console with a labelled rail.
/// - `>= 1024` (desktop): the full [AdminWebShell] — sidebar + top bar +
///   8 in-shell sections (including Fees) + More.
///
/// Modeled directly on `BursarShell` (lib/features/finance/presentation/
/// shell/bursar_shell.dart).
class AdminShell extends StatelessWidget {
  /// The section this route targets.
  final AdminSection section;

  const AdminShell({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        switch (layout) {
          case ResponsiveLayout.desktop:
            return AdminWebShell(initialSection: section);
          case ResponsiveLayout.tablet:
            return AdminWebShell(compact: true, initialSection: section);
          case ResponsiveLayout.mobile:
            return _AdminMobileShell(section: section);
        }
      },
    );
  }
}

/// The mobile bottom-navigation shell.
class _AdminMobileShell extends StatefulWidget {
  final AdminSection section;

  const _AdminMobileShell({required this.section});

  @override
  State<_AdminMobileShell> createState() => _AdminMobileShellState();
}

/// Lets a descendant switch the visible mobile tab instead of pushing a
/// duplicate screen. Tab indices: 0 Home · 1 Students · 2 Attendance · 3 More.
class AdminShellNav {
  const AdminShellNav._();
  static void goToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_AdminMobileShellState>()?._selectTab(
      index,
    );
  }
}

/// Section screen for the mobile **More** stack (deep links to sections
/// that have no dedicated bottom-nav tab).
Widget _mobileSectionScreen(AdminSection s) {
  switch (s) {
    case AdminSection.staff:
      return const StaffListPage();
    case AdminSection.parents:
      return const ParentsAccessWorkspaceScreen();
    case AdminSection.approvals:
      return const ApprovalCenterScreen();
    case AdminSection.appointments:
      return const AppointmentsWorkspaceScreen();
    case AdminSection.fees:
      return const AdminFeesScreen();
    case AdminSection.home:
    case AdminSection.students:
    case AdminSection.attendance:
    case AdminSection.more:
      return const AdminMoreScreen();
  }
}

class _AdminMobileShellState extends State<_AdminMobileShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _tabForSection();
    _scheduleSectionPush(widget.section);
  }

  @override
  void didUpdateWidget(covariant _AdminMobileShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section != oldWidget.section) {
      setState(() => _selectedIndex = _tabForSection());
      _scheduleSectionPush(widget.section);
    }
  }

  int _tabForSection() => widget.section.mobileTab ?? AdminSection.moreTabIndex;

  /// For a section with no own tab, land on **More** and push its screen so
  /// a phone deep link (`/staff/admin/parents`) shows Parents, not the More
  /// list.
  void _scheduleSectionPush(AdminSection s) {
    if (s.mobileTab != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final nav = _navigatorKeys[AdminSection.moreTabIndex].currentState;
      nav?.popUntil((r) => r.isFirst);
      nav?.push(
        MaterialPageRoute(
          builder: (_) => _mobileSectionScreen(s),
          settings: RouteSettings(name: 'admin-section-${s.slug}'),
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
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const List<_TabSpec> _tabs = [
    _TabSpec(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabSpec(
      Icons.people_outline_rounded,
      Icons.people_alt_rounded,
      'Students',
    ),
    _TabSpec(
      Icons.event_available_outlined,
      Icons.event_available_rounded,
      'Attendance',
    ),
    _TabSpec(Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
  ];

  Widget _rootFor(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const AdminStudentDirectoryScreen();
      case 2:
        return const AdminStaffAttendanceScreen();
      case 3:
      default:
        return const AdminMoreScreen();
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
        backgroundColor: AppColors.background(context),
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(4, _buildTabNavigator),
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
