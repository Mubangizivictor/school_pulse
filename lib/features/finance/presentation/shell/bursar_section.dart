import 'package:flutter/material.dart';

/// The canonical list of Bursar console sections.
///
/// One source of truth shared by:
/// - the router (`/staff/bursar/<slug>` sub-routes),
/// - [BursarWebShell] (sidebar + `IndexedStack`),
/// - the mobile bottom-nav shell (deep-link → tab, or push onto **More**),
/// - `BursarMoreScreen` (the mobile "More" list).
///
/// `mobileTab` is the bottom-nav index for the four sections that have a
/// dedicated tab (Home/Students/Approvals/Cash & Bank). Sections with a
/// `null` `mobileTab` are reached on mobile by opening the **More** tab
/// (index 4) and pushing the section screen — so every desktop deep link
/// also resolves on a phone.
enum BursarSection {
  overview(
    slug: 'overview',
    label: 'Finance overview',
    icon: Icons.pie_chart_outline_rounded,
    mobileTab: 0,
  ),
  students(
    slug: 'students',
    label: 'Students & fees',
    icon: Icons.people_outline_rounded,
    mobileTab: 1,
  ),
  approvals(
    slug: 'approvals',
    label: 'Approvals',
    icon: Icons.verified_outlined,
    mobileTab: 2,
  ),
  cashBank(
    slug: 'cash-bank',
    label: 'Cash & bank',
    icon: Icons.account_balance_outlined,
    mobileTab: 3,
  ),
  budget(slug: 'budget', label: 'Budget', icon: Icons.bar_chart_rounded),
  expenses(
    slug: 'expenses',
    label: 'Expenses',
    icon: Icons.description_outlined,
  ),
  suppliers(
    slug: 'suppliers',
    label: 'Suppliers',
    icon: Icons.local_shipping_outlined,
  ),
  pettyCash(
    slug: 'petty-cash',
    label: 'Petty cash',
    icon: Icons.account_balance_wallet_outlined,
  ),
  payroll(
    slug: 'payroll',
    label: 'Payroll & compliance',
    icon: Icons.badge_outlined,
  ),
  reports(slug: 'reports', label: 'Reports', icon: Icons.assessment_outlined),
  reportRelease(
    slug: 'report-release',
    label: 'Report releases',
    icon: Icons.lock_open_outlined,
  ),
  entitlements(
    slug: 'entitlements',
    label: 'Financial entitlements',
    icon: Icons.verified_user_outlined,
  ),
  audit(slug: 'audit', label: 'Audit trail', icon: Icons.fact_check_outlined);

  const BursarSection({
    required this.slug,
    required this.label,
    required this.icon,
    this.mobileTab,
  });

  final String slug;
  final String label;
  final IconData icon;
  final int? mobileTab;

  /// The Bursar bottom-nav "More" tab index — the fallback host for
  /// sections without their own tab.
  static const int moreTabIndex = 4;

  /// Resolve a section from a router path like `/staff/bursar/petty-cash`
  /// or `/staff/bursar/student/abc/bills`. Returns [BursarSection.overview]
  /// for the bare `/staff/bursar` and anything unrecognised.
  static BursarSection fromLocation(String path) {
    for (final s in BursarSection.values) {
      if (path == '/staff/bursar/${s.slug}' ||
          path.startsWith('/staff/bursar/${s.slug}/')) {
        return s;
      }
    }
    if (path.startsWith('/staff/bursar/student/')) {
      return BursarSection.students;
    }
    if (path.startsWith('/staff/bursar/lookup')) {
      return BursarSection.students;
    }
    return BursarSection.overview;
  }
}
