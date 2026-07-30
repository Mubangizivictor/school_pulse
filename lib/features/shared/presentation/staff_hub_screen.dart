import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Landing screen for a staff member holding more than one role (e.g. a
/// class teacher who is also a subject teacher and the discipline head).
/// Each assigned role gets its own card; tapping one opens that role's
/// existing dashboard unchanged - no dashboard needed to be rewritten to
/// support multiple roles.
class StaffHubScreen extends StatelessWidget {
  const StaffHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final roles = user?.roles ?? const <UserRole>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(user != null ? 'Welcome, ${user.name}' : 'My Roles'),
      ),
      body: roles.isEmpty
          ? const Center(child: Text('No roles assigned.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'You hold ${roles.length} roles at this school. Choose one to continue.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 16),
                ...roles.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      onTap: () => context.push(UserRoleRouting.dashboardPath(role)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(_iconForRole(role)),
                        ),
                        title: Text(UserRoleDisplay.name(role)),
                        subtitle: _subtitleForRole(role, user),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget? _subtitleForRole(UserRole role, UserEntity? user) {
    if (role == UserRole.classTeacher && user?.assignedClass != null) {
      return Text('Class Teacher - ${user!.assignedClass}');
    }
    if (role == UserRole.subjectTeacher && (user?.subjects?.isNotEmpty ?? false)) {
      final bySubject = <String, List<String>>{};
      for (final a in user!.subjects!) {
        bySubject.putIfAbsent(a.subjectName, () => []).add(a.className);
      }
      final summary = bySubject.entries.map((e) => '${e.key} - ${e.value.join(', ')}').join('; ');
      return Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    return null;
  }

  IconData _iconForRole(UserRole role) {
    switch (role) {
      case UserRole.director: return Icons.account_balance;
      case UserRole.headTeacher: return Icons.school;
      case UserRole.deputyHead: return Icons.school_outlined;
      case UserRole.deanOfStudies: return Icons.auto_stories;
      case UserRole.schoolAdmin: return Icons.admin_panel_settings;
      case UserRole.bursar: return Icons.payments;
      case UserRole.classTeacher: return Icons.assignment_ind;
      case UserRole.subjectTeacher: return Icons.book;
      case UserRole.librarian: return Icons.local_library;
      case UserRole.nurse: return Icons.medical_services;
      case UserRole.boardingMatron: return Icons.bed;
      case UserRole.boardingPatron: return Icons.bed;
      case UserRole.transportCoordinator: return Icons.directions_bus;
      case UserRole.guidanceDiscipline: return Icons.gavel;
      case UserRole.storeInventory: return Icons.inventory;
      case UserRole.gatekeeper: return Icons.security;
      case UserRole.securityHead: return Icons.admin_panel_settings;
      case UserRole.gamesMaster: return Icons.sports_soccer;
      case UserRole.cateringManager: return Icons.restaurant;
      case UserRole.religiousLeader: return Icons.church;
      case UserRole.receptionist: return Icons.support_agent;
      case UserRole.hrOfficer: return Icons.badge;
      case UserRole.parent: return Icons.person;
      case UserRole.superAdmin: return Icons.workspace_premium;
      case UserRole.student: return Icons.school;
    }
  }
}
