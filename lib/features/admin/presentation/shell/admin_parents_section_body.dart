import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/features/admin/parent_access_workspace/presentation/screens/parent_detail_screen.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/screens/parents_access_workspace_screen.dart';
import 'package:school_pulse/features/admin/presentation/link_parent_wizard/link_parent_wizard_page.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Resolves the body [AdminShell]/[AdminWebShell] shows for the **Parents**
/// section from the live URL, so the directory, the Link Parent flow
/// (`parents/link`), and the parent detail/access screen (`parents/:inviteId`)
/// all render inside the canonical shell — persistent sidebar on
/// desktop/tablet, the Parents bottom-nav tab on mobile — instead of
/// escaping it as standalone full-screen routes.
///
/// Mirrors [AdminStaffSectionBody] / `AdminStudentsSectionBody`: same
/// `GoRouterState.of(context).uri.path` resolution, same shell-embedding
/// rationale. Screens still navigate between each other with ordinary
/// `context.push` / `Navigator.pop`; only *where* they render changes.
class AdminParentsSectionBody extends StatelessWidget {
  const AdminParentsSectionBody({super.key});

  String _schoolId(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      return auth.user.schoolId;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    if (path == '/staff/admin/parents/link') {
      return LinkParentWizardPage(schoolId: _schoolId(context));
    }

    final idMatch = RegExp(r'^/staff/admin/parents/([^/]+)$').firstMatch(path);
    if (idMatch != null && idMatch.group(1) != 'link') {
      return ParentDetailScreen(inviteId: idMatch.group(1)!);
    }

    return const ParentsAccessWorkspaceScreen();
  }
}
