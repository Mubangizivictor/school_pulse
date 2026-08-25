import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/institution/presentation/screens/institution_switcher_sheet.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_quick_add_sheet.dart';
import 'package:school_pulse/features/auth/presentation/widgets/role_switcher_sheet.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';

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

  static const List<UserRole> _teacherRoles = [
    UserRole.classTeacher,
    UserRole.subjectTeacher,
  ];

  bool _isTeacher(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.any(_teacherRoles.contains);
    }
    return false;
  }

  /// Class Teacher and Subject Teacher share one account but show different
  /// nav vocabularies - "Reports/Tasks" for class-level work vs
  /// "Lessons/Marks" for subject teaching. `StaffPanelHost` already decides
  /// which dashboard is on screen from the active responsibility; this reads
  /// the same source so the nav bar never disagrees with the panel it sits
  /// under. Class Teacher is the default (including while nothing has
  /// resolved yet), matching `StaffPanelHost`'s own fallback.
  bool _isSubjectTeacherActive(BuildContext context, {bool listen = true}) {
    final bloc = listen
        ? context.watch<SubjectTeacherContextBloc>()
        : context.read<SubjectTeacherContextBloc>();
    return bloc.state.active?.roleType ==
        StaffResponsibilityType.subjectTeacher;
  }

  static const List<UserRole> _boardingRoles = [
    UserRole.boardingMatron,
    UserRole.boardingPatron,
  ];

  bool _isBoarding(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.any(_boardingRoles.contains);
    }
    return false;
  }

  /// Matron and Patron run the same boarding workflow against different
  /// wings, so their nav destinations are identical and only the route
  /// prefix differs.
  String _boardingRoot(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated &&
        state.user.roles.contains(UserRole.boardingPatron)) {
      return '/staff/patron';
    }
    return '/staff/matron';
  }

  bool _hasMultipleRoles(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.length > 1;
    }
    return false;
  }

  bool _isNurse(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.contains(UserRole.nurse);
    }
    return false;
  }

  bool _isDirector(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.roles.contains(UserRole.director);
    }
    return false;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    bool isMoreSubRoute(String loc) {
      return loc.startsWith('/staff/more') ||
          loc.startsWith('/staff/profile') ||
          loc.startsWith('/staff/notifications') ||
          loc.startsWith('/staff/calendar') ||
          loc.startsWith('/staff/tasks');
    }

    if (_isDirector(context)) {
      if (location.startsWith('/staff/director/approvals')) return 1;
      if (location.startsWith('/staff/director/reports')) return 3;
      if (isMoreSubRoute(location)) return 4;
      return 0;
    }

    if (_isAdmin(context)) {
      if (location.contains('/staff/admin/structure')) return 1;
      if (isMoreSubRoute(location)) return 2;
      if (location.startsWith('/staff/admin')) return 0;
      return 0;
    }

    if (_isTeacher(context)) {
      if (location.startsWith('/staff/dashboard')) return 0;
      if (location.startsWith('/staff/students')) return 1;
      if (_isSubjectTeacherActive(context)) {
        if (location.startsWith('/staff/lessons')) return 2;
        if (location.startsWith('/staff/marks')) return 3;
      } else {
        if (location.startsWith('/staff/reports')) return 2;
        if (location.startsWith('/staff/class-tasks')) return 3;
      }
      if (isMoreSubRoute(location)) return 4;
      return 0;
    }

    if (_isBoarding(context)) {
      final root = _boardingRoot(context);
      if (location.startsWith('$root/more')) return 4;
      if (location.startsWith('/staff/tasks')) return 3;
      if (location.startsWith('$root/roll-call')) return 2;
      if (location.startsWith('$root/dorms')) return 1;
      if (isMoreSubRoute(location)) return 4;
      return 0;
    }

    if (_isNurse(context)) {
      if (location.startsWith('/staff/nurse/records') ||
          location.startsWith('/staff/nurse/visits') ||
          location.startsWith('/staff/nurse/medications')) {
        return 1;
      }
      if (location.startsWith('/staff/messages')) return 2;
      if (isMoreSubRoute(location)) return 3;
      return 0;
    }

    if (location.startsWith('/staff/messages')) return 2;
    if (location.startsWith('/staff/tasks')) return 1;
    if (isMoreSubRoute(location)) return 3;
    return 0;
  }

  String _homePath(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      if (state.user.roles.length > 1) return '/staff/hub';
      return UserRoleRouting.dashboardPath(state.user.role);
    }
    return '/staff/dashboard';
  }

  void _onItemTapped(int index, BuildContext context) {
    if (_isDirector(context)) {
      switch (index) {
        case 0:
          context.go(_homePath(context));
          break;
        case 1:
          context.go('/staff/director/approvals');
          break;
        case 2:
          context.push('/staff/director/approvals/submit');
          break;
        case 3:
          context.go('/staff/director/reports');
          break;
        case 4:
          context.go('/staff/more');
          break;
      }
      return;
    }

    if (_isAdmin(context)) {
      switch (index) {
        case 0:
          context.go(_homePath(context));
          break;
        case 1:
          context.go('/staff/admin/structure');
          break;
        case 2:
          context.go('/staff/more');
          break;
      }
      return;
    }

    if (_isTeacher(context)) {
      final subjectActive = _isSubjectTeacherActive(context, listen: false);
      switch (index) {
        case 0:
          context.go(_homePath(context));
          break;
        case 1:
          context.go('/staff/students');
          break;
        case 2:
          context.go(subjectActive ? '/staff/lessons' : '/staff/reports');
          break;
        case 3:
          context.go(subjectActive ? '/staff/marks' : '/staff/class-tasks');
          break;
        case 4:
          context.go('/staff/more');
          break;
      }
      return;
    }

    if (_isBoarding(context)) {
      final root = _boardingRoot(context);
      switch (index) {
        case 0:
          context.go(_homePath(context));
          break;
        case 1:
          context.go('$root/dorms');
          break;
        case 2:
          context.go('$root/roll-call');
          break;
        case 3:
          context.go('/staff/tasks');
          break;
        case 4:
          context.go('$root/more');
          break;
      }
      return;
    }

    if (_isNurse(context)) {
      switch (index) {
        case 0:
          context.go(_homePath(context));
          break;
        case 1:
          context.go('/staff/nurse/records');
          break;
        case 2:
          context.go('/staff/messages');
          break;
        case 3:
          context.go('/staff/more');
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        context.go(_homePath(context));
        break;
      case 1:
        context.go('/staff/tasks');
        break;
      case 2:
        context.go('/staff/messages');
        break;
      case 3:
        context.go('/staff/more');
        break;
    }
  }

  void _handleLogout(BuildContext context) async {
    // Note: confirmActionDialog was previously imported from app_components.dart
    // For now, using standard showDialog until PulseDialogs are implemented
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.deepOrange),
            ),
          ),
        ],
      ),
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
    final isBoarding = _isBoarding(context);
    // Dean of Studies, Bursar and Nurse own their own full-screen bottom nav
    // (DeanShell / BursarShell / NurseShell) - showing this shell's bar too
    // would stack two bottom navs on every screen in those sections.
    final isDeanSection = GoRouterState.of(
      context,
    ).uri.path.startsWith('/staff/dean');
    final isBursarSection = GoRouterState.of(
      context,
    ).uri.path.startsWith('/staff/bursar');
    final isNurseSection = GoRouterState.of(
      context,
    ).uri.path.startsWith('/staff/nurse');

    final List<NavigationDestination> subjectTeacherDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.people_rounded, size: 24),
        label: 'Students',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined, size: 24),
        selectedIcon: Icon(Icons.calendar_today_rounded, size: 24),
        label: 'Lessons',
      ),
      const NavigationDestination(
        icon: Icon(Icons.edit_document, size: 24),
        selectedIcon: Icon(Icons.edit_document, size: 24),
        label: 'Marks',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> classTeacherDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people_outline_rounded, size: 24),
        selectedIcon: Icon(Icons.people_rounded, size: 24),
        label: 'Students',
      ),
      const NavigationDestination(
        icon: Icon(Icons.insights_outlined, size: 24),
        selectedIcon: Icon(Icons.insights_rounded, size: 24),
        label: 'Report Cards',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined, size: 24),
        selectedIcon: Icon(Icons.assignment_rounded, size: 24),
        label: 'Tasks',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> adminDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_tree_outlined, size: 24),
        selectedIcon: Icon(Icons.account_tree_rounded, size: 24),
        label: 'Structure',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> boardingDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bed_outlined, size: 24),
        selectedIcon: Icon(Icons.bed_rounded, size: 24),
        label: 'Dorms',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_ind_outlined, size: 24),
        selectedIcon: Icon(Icons.assignment_ind_rounded, size: 24),
        label: 'Roll Call',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined, size: 24),
        selectedIcon: Icon(Icons.assignment_rounded, size: 24),
        label: 'Tasks',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> operationalDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined, size: 24),
        selectedIcon: Icon(Icons.assignment_rounded, size: 24),
        label: 'Tasks',
      ),
      const NavigationDestination(
        icon: MessagesNavIcon(icon: Icons.chat_bubble_outline_rounded),
        selectedIcon: MessagesNavIcon(icon: Icons.chat_bubble_rounded),
        label: 'Messages',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> directorDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.fact_check_outlined, size: 24),
        selectedIcon: Icon(Icons.fact_check_rounded, size: 24),
        label: 'Approvals',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_circle_rounded, size: 24),
        selectedIcon: Icon(Icons.add_circle_rounded, size: 24),
        label: 'Add',
      ),
      const NavigationDestination(
        icon: Icon(Icons.insights_outlined, size: 24),
        selectedIcon: Icon(Icons.insights_rounded, size: 24),
        label: 'Reports',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final List<NavigationDestination> nurseDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined, size: 24),
        selectedIcon: Icon(Icons.home_rounded, size: 24),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined, size: 24),
        selectedIcon: Icon(Icons.assignment_rounded, size: 24),
        label: 'Records',
      ),
      const NavigationDestination(
        icon: MessagesNavIcon(icon: Icons.chat_bubble_outline_rounded),
        selectedIcon: MessagesNavIcon(icon: Icons.chat_bubble_rounded),
        label: 'Messages',
      ),
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, size: 24),
        selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
        label: 'More',
      ),
    ];

    final isDirector = _isDirector(context);

    final destinations = isDirector
        ? directorDestinations
        : isAdmin
        ? adminDestinations
        : isTeacher
        ? (_isSubjectTeacherActive(context)
              ? subjectTeacherDestinations
              : classTeacherDestinations)
        : isBoarding
        ? boardingDestinations
        : _isNurse(context)
        ? nurseDestinations
        : operationalDestinations;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: MediaQuery.of(context).size.width > 1200 ? 280 : 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                border: Border(
                  right: BorderSide(color: AppColors.border(context), width: 1),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x4l,
                    ),
                    child: PulseLogo(
                      size: 40,
                      variant: MediaQuery.of(context).size.width > 1200
                          ? PulseLogoVariant.full
                          : PulseLogoVariant.shield,
                    ),
                  ),
                  Expanded(
                    child: NavigationRail(
                      backgroundColor: Colors.transparent,
                      extended: MediaQuery.of(context).size.width > 1200,
                      selectedIndex: _calculateSelectedIndex(context),
                      onDestinationSelected: (idx) =>
                          _onItemTapped(idx, context),
                      minExtendedWidth: 280,
                      labelType: MediaQuery.of(context).size.width > 1200
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      unselectedLabelTextStyle: AppTypography.labelMedium
                          .copyWith(color: AppColors.textMuted(context)),
                      selectedLabelTextStyle: AppTypography.labelMedium
                          .copyWith(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.bold,
                          ),
                      unselectedIconTheme: IconThemeData(
                        color: AppColors.textMuted(context),
                      ),
                      selectedIconTheme: IconThemeData(
                        color: AppColors.primary(context),
                      ),
                      destinations: destinations
                          .map(
                            (d) => NavigationRailDestination(
                              icon: d.icon,
                              selectedIcon: d.selectedIcon,
                              label: Text(d.label),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.m,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (_hasMultipleRoles(context))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: IconButton(
                        icon: const Icon(Icons.badge_outlined),
                        tooltip: 'Switch Role',
                        onPressed: () => RoleSwitcherSheet.show(context),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded),
                      tooltip: 'Switch Institution',
                      onPressed: () => InstitutionSwitcherSheet.show(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
                    child: _LogoutButton(
                      onPressed: () => _handleLogout(context),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: AppColors.background(context),
              child: Column(
                children: [
                  // _SupportModeBanner already wraps its own SafeArea
                  // internally when it has content to show, and collapses to
                  // a literal zero-height SizedBox otherwise - adding
                  // another SafeArea here would reserve the status-bar inset
                  // even while empty, stacking with the routed screen's own
                  // AppBar/SafeArea below and pushing it down for no reason.
                  const _SupportModeBanner(),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          (isMobile && !isDeanSection && !isBursarSection && !isNurseSection)
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border(context), width: 0.5),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTypography.labelSmall.copyWith(
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted(context),
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 64,
                  backgroundColor: AppColors.surfaceElevated(context),
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  selectedIndex: _calculateSelectedIndex(context),
                  onDestinationSelected: (idx) => _onItemTapped(idx, context),
                  destinations: destinations.map((d) {
                    final index = destinations.indexOf(d);
                    final isSelected =
                        index == _calculateSelectedIndex(context);
                    final isRaisedAddAction = isDirector && d.label == 'Add';
                    if (isRaisedAddAction) {
                      return NavigationDestination(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppColors.background(context),
                            size: 22,
                          ),
                        ),
                        label: '',
                      );
                    }
                    final rawIcon = isSelected ? d.selectedIcon : d.icon;
                    final tintColor = isSelected
                        ? AppColors.primary(context)
                        : AppColors.textMuted(context);
                    final themedIcon = rawIcon is MessagesNavIcon
                        ? MessagesNavIcon(
                            icon: rawIcon.icon,
                            color: tintColor,
                            size: 24,
                          )
                        : Icon(
                            (rawIcon as Icon).icon,
                            color: tintColor,
                            size: 24,
                          );
                    return NavigationDestination(
                      icon: isSelected
                          ? Container(
                              width: 36,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: rawIcon is MessagesNavIcon
                                  ? Icon(
                                      rawIcon.icon,
                                      color: AppColors.background(context),
                                      size: 21,
                                    )
                                  : Icon(
                                      (rawIcon as Icon).icon,
                                      color: AppColors.background(context),
                                      size: 21,
                                    ),
                            )
                          : themedIcon,
                      label: d.label,
                    );
                  }).toList(),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                ),
              ),
            )
          : null,
    );
  }
}

/// Persistent "acting as" banner shown while the platform owner is signed
/// in as a school admin via Owner Support Mode. Present at the top of every
/// staff-shelled screen so it can never be scrolled away or missed - the
/// owner must always know they're impersonating and be one tap from exiting.
class _SupportModeBanner extends StatelessWidget {
  const _SupportModeBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated || state.supportMode == null) {
          return const SizedBox.shrink();
        }
        final supportMode = state.supportMode!;
        final minutesLeft = supportMode.expiresAt
            .difference(DateTime.now())
            .inMinutes
            .clamp(0, 999);

        return Material(
          color: AppColors.background(context),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.m,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 20,
                    color: AppColors.warning(context),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Support Mode: acting as ${state.user.name} at '
                      '${supportMode.schoolName} · expires in ${minutesLeft}m',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(ExitSupportModePressed());
                      context.go('/welcome');
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isExtended = MediaQuery.of(context).size.width > 1200;

    if (isExtended) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.logout_rounded,
            color: AppColors.textPrimary(context),
          ),
          label: Text(
            'Logout',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(Icons.logout_rounded, color: AppColors.textPrimary(context)),
      onPressed: onPressed,
      tooltip: 'Logout',
    );
  }
}
