import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/features/admin/presentation/add_staff_wizard/add_staff_wizard_page.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_detail_screen.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_list_page.dart';
import 'package:school_pulse/features/admin/presentation/pages/user_management_page.dart';

/// Resolves the body [AdminShell]/[AdminWebShell] show for the **Staff**
/// section from the live URL, so `overview`, `add-staff`, and `:uid` all
/// render inside the canonical shell (persistent sidebar/bottom nav, Staff
/// highlighted) instead of escaping it as standalone full-screen routes.
///
/// Mirrors `AdminStudentsSectionBody` — same shell-embedding rationale, same
/// `GoRouterState.of(context).uri.path` resolution. Screens still navigate
/// between each other with ordinary `context.push`/`Navigator.pop`; only
/// *where* they render changes.
class AdminStaffSectionBody extends StatelessWidget {
  const AdminStaffSectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    if (path == '/staff/admin/users/overview') {
      return const UserManagementPage();
    }
    if (path == '/staff/admin/users/add-staff') {
      return const AddStaffWizardPage();
    }

    final uidMatch = RegExp(r'^/staff/admin/users/([^/]+)$').firstMatch(path);
    if (uidMatch != null) {
      return StaffDetailScreen(uid: uidMatch.group(1)!);
    }

    return const StaffListPage();
  }
}
