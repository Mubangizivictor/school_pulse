import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Lets a multi-role staff member switch which responsibility they are
/// currently acting as, without logging out. Only meaningful for a user
/// holding more than one UserRole - StaffShell only offers this sheet in
/// that case.
class RoleSwitcherSheet extends StatelessWidget {
  const RoleSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RoleSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;
    final activeRole = context.watch<AppRoleSessionCubit>().state;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Switch Responsibility'),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              itemCount: user.roles.length,
              itemBuilder: (context, index) {
                final role = user.roles[index];
                final isActive = role == activeRole;
                return ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(UserRoleDisplay.name(role)),
                  trailing: isActive
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: isActive
                      ? null
                      : () async {
                          await context.read<AppRoleSessionCubit>().switchTo(
                            user: user,
                            role: role,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          context.go(UserRoleRouting.dashboardPath(role));
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
