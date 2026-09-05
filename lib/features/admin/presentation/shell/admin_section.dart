import 'package:flutter/material.dart';

/// The canonical list of School Admin console sections.
///
/// One source of truth shared by:
/// - the router (`/staff/admin/<slug>` root routes),
/// - [AdminWebShell] (sidebar + `IndexedStack`),
/// - the mobile bottom-nav shell (deep-link → tab, or push onto **More**),
/// - `AdminMoreScreen` (the mobile/desktop "More" list).
///
/// Modeled directly on `BursarSection` (lib/features/finance/presentation/
/// shell/bursar_section.dart) — same shape, same conventions.
///
/// `mobileTab` is the bottom-nav index for the four sections with a
/// dedicated tab (Home/Students/Attendance/More). Sections with a `null`
/// `mobileTab` are reached on mobile by opening **More** (index 3) and
/// pushing the section screen — so every desktop sidebar item also resolves
/// on a phone, exactly as Bursar's own non-tabbed sections do.
///
/// **Fees renders the real Bursar screens, embedded.** School Admin never
/// navigates to `/staff/bursar` or sees Bursar's own shell chrome — the
/// Fees section hosts `AdminFeesScreen`, which tabs between the exact same
/// widgets Bursar uses (overview, payroll, expenses, cash & bank, suppliers,
/// petty cash — same BLoCs, same repositories, same write callables), just
/// reached from inside [AdminShell]'s own sidebar/bottom-nav.
enum AdminSection {
  home(slug: 'home', label: 'Home', icon: Icons.home_outlined, mobileTab: 0),
  students(
    slug: 'students',
    label: 'Students',
    icon: Icons.people_outline,
    mobileTab: 1,
  ),
  staff(slug: 'staff', label: 'Staff', icon: Icons.badge_outlined),
  parents(
    slug: 'parents',
    label: 'Parents',
    icon: Icons.family_restroom_outlined,
  ),
  attendance(
    slug: 'attendance',
    label: 'Attendance',
    icon: Icons.event_available_outlined,
    mobileTab: 2,
  ),
  fees(slug: 'fees', label: 'Fees', icon: Icons.payments_outlined),
  approvals(
    slug: 'approvals',
    label: 'Approvals',
    icon: Icons.verified_outlined,
  ),
  appointments(
    slug: 'appointments',
    label: 'Appointments',
    icon: Icons.event_outlined,
  ),
  more(
    slug: 'more',
    label: 'More',
    icon: Icons.grid_view_outlined,
    mobileTab: 3,
  );

  const AdminSection({
    required this.slug,
    required this.label,
    required this.icon,
    this.mobileTab,
  });

  final String slug;
  final String label;
  final IconData icon;
  final int? mobileTab;

  /// The Admin bottom-nav "More" tab index — the fallback host for sections
  /// without their own tab.
  static const int moreTabIndex = 3;

  /// Resolve a section from a router path like `/staff/admin/parents` or
  /// `/staff/admin/students/abc123`. Returns [AdminSection.home] for the
  /// bare `/staff/admin` and [AdminSection.more] for every other admin
  /// destination (school-setup, structure/*, integrations, etc.) — the
  /// ~30 routes with no dedicated tab all resolve here, matching how they're
  /// only ever reached via the More tools list.
  static AdminSection fromLocation(String path) {
    if (path == '/staff/admin') return AdminSection.home;
    if (path == '/staff/admin/students' ||
        path.startsWith('/staff/admin/students/') ||
        path.startsWith('/staff/admin/admissions') ||
        path == '/staff/admin/student-id-card') {
      return AdminSection.students;
    }
    if (path == '/staff/admin/users' || path.startsWith('/staff/admin/users/')) {
      return AdminSection.staff;
    }
    if (path == '/staff/admin/parents') return AdminSection.parents;
    if (path == '/staff/admin/staff-attendance') return AdminSection.attendance;
    if (path == '/staff/admin/fees') return AdminSection.fees;
    if (path == '/staff/admin/approvals' ||
        path.startsWith('/staff/admin/approvals/')) {
      return AdminSection.approvals;
    }
    if (path == '/staff/admin/appointments') return AdminSection.appointments;
    return AdminSection.more;
  }
}
