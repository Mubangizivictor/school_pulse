import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/admin/admin_dashboard_screen.dart';
import 'package:school_pulse/features/admin/admin_staff_attendance_screen.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_parents_section_body.dart';
import 'package:school_pulse/features/admin/presentation/screens/admin_more_screen.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_fees_screen.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_section.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_staff_section_body.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_center_screen.dart';
import 'package:school_pulse/features/appointments/presentation/screens/appointments_workspace_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';
import 'package:school_pulse/features/admin/presentation/shell/admin_students_section_body.dart';

/// The School Admin console for tablet-rail-and-up widths (used by
/// [AdminShell]'s `ResponsiveBuilder` branch at >= 600px; the tablet
/// 600-1023 branch uses the same widget with a narrower sidebar).
///
/// Structure mirrors `BursarWebShell`: a fixed left sidebar + an
/// `IndexedStack` of per-section nested `Navigator`s, with the active
/// section derived from the URL so every section is deep-linkable and
/// refresh-safe on web.
class AdminWebShell extends StatefulWidget {
  /// Tablet (600–1023): a narrower but still labelled sidebar. Desktop
  /// passes neither and gets the full-width sidebar.
  final bool compact;

  /// The section this route resolved to. Used as the active section when
  /// the nested-route URL can't be read (tests, or a transient build); the
  /// live URL still wins once available.
  final AdminSection? initialSection;

  const AdminWebShell({super.key, this.compact = false, this.initialSection});

  @override
  State<AdminWebShell> createState() => _AdminWebShellState();
}

typedef _Section = AdminSection;

/// In-shell sidebar sections.
const _mainNav = [
  AdminSection.home,
  AdminSection.students,
  AdminSection.staff,
  AdminSection.parents,
  AdminSection.attendance,
  AdminSection.fees,
  AdminSection.approvals,
  AdminSection.appointments,
];

class _AdminWebShellState extends State<AdminWebShell> {
  final _navKeys = {
    for (final s in AdminSection.values) s: GlobalKey<NavigatorState>(),
  };

  _Section _sectionForLocation(BuildContext context) {
    // The live URL is authoritative (survives refresh, back/forward, shared
    // links). `initialSection` is the fallback for the brief window before
    // GoRouterState is readable and for widget tests with no router.
    try {
      final path = GoRouterState.of(context).uri.path;
      if (path.startsWith('/staff/admin')) {
        return AdminSection.fromLocation(path);
      }
    } catch (_) {
      // No GoRouter in the tree (tests) — fall through.
    }
    return widget.initialSection ?? AdminSection.home;
  }

  Widget _screenFor(_Section s) {
    switch (s) {
      case _Section.home:
        return const AdminDashboardScreen();
      case _Section.students:
        return const AdminStudentsSectionBody();
      case _Section.staff:
        return const AdminStaffSectionBody();
      case _Section.parents:
        return const AdminParentsSectionBody();
      case _Section.attendance:
        return const AdminStaffAttendanceScreen();
      case _Section.fees:
        return const AdminFeesScreen();
      case _Section.approvals:
        return const ApprovalCenterScreen();
      case _Section.appointments:
        return const AppointmentsWorkspaceScreen();
      case _Section.more:
        return const AdminMoreScreen();
    }
  }

  void _go(_Section s) {
    final current = _sectionForLocation(context);
    if (current == s) {
      _navKeys[s]!.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    context.go(
      s == AdminSection.home
          ? '/staff/admin'
          : '/staff/admin/${s.routeSegment}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _sectionForLocation(context);
    // Tablet gets a real labelled rail (200px), not a 76px icon strip.
    final sidebarWidth = widget.compact ? 200.0 : 248.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sidebar(
            width: sidebarWidth,
            compact: widget.compact,
            active: active,
            onSelect: _go,
          ),
          Expanded(
            child: IndexedStack(
              index: _Section.values.indexOf(active),
              children: [
                for (final s in _Section.values)
                  Navigator(
                    key: _navKeys[s],
                    onGenerateRoute: (rs) => MaterialPageRoute(
                      builder: (_) => _screenFor(s),
                      settings: rs,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final double width;
  final bool compact;
  final _Section active;
  final ValueChanged<_Section> onSelect;

  const _Sidebar({
    required this.width,
    required this.compact,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(right: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 16, 18, 16, 16),
            child: _SchoolHeader(compact: compact),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
              children: [
                for (final s in _mainNav)
                  _Item(
                    icon: s.icon,
                    label: s.label,
                    compact: compact,
                    selected: s == active,
                    onTap: () => onSelect(s),
                  ),
                _Item(
                  icon: AdminSection.more.icon,
                  label: AdminSection.more.label,
                  compact: compact,
                  selected: active == AdminSection.more,
                  onTap: () => onSelect(AdminSection.more),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          _FooterRow(compact: compact),
        ],
      ),
    );
  }
}

/// School badge + name at the top of the sidebar, from the live
/// [BrandingBloc] (falls back to the auth user's `schoolName`).
class _SchoolHeader extends StatelessWidget {
  final bool compact;
  const _SchoolHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    final brandingState = context.watch<BrandingBloc>().state;
    final branding = brandingState is BrandingLoaded
        ? brandingState.branding
        : null;
    final auth = context.watch<AuthBloc>().state;
    final name = branding?.schoolName.isNotEmpty == true
        ? branding!.schoolName
        : (auth is AuthAuthenticated
              ? (auth.user.schoolName ?? 'School Pulse')
              : 'School Pulse');
    final badge = SchoolBadge(
      badgeUrl: branding?.badgeUrl ?? branding?.logoUrl,
      size: compact ? 34 : 30,
    );

    if (compact) return Center(child: badge);

    return Row(
      children: [
        badge,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? AppColors.background(context)
        : AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? AppColors.primary(context) : Colors.transparent,
        borderRadius: AppRadius.medium,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.medium,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: 9,
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  final bool compact;
  const _FooterRow({required this.compact});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated ? auth.user.name : 'Admin';
    final initials = name.trim().isEmpty
        ? 'A'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join();

    return InkWell(
      onTap: () => _confirmLogout(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 18,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary(context),
              ),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background(context),
                ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutPressed());
              context.go('/welcome');
            },
            child: Text(
              'Sign out',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }
}
