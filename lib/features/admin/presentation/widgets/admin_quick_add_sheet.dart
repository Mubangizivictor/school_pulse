import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Action sheet opened by the center "Add" nav button on the School Admin
/// bottom nav. Every entry routes to a screen that already exists - this
/// never creates anything itself, it just shortcuts to the real flows.
class AdminQuickAddSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _AdminQuickAddSheetContent(),
    );
  }
}

class _QuickAddAction {
  final String label;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onTap;

  /// True when this action should be omitted entirely for the given roles -
  /// used for "Add Staff", which is server-verified against
  /// [UserRoleDisplay.adminRoles] (director/headTeacher/schoolAdmin), a
  /// narrower set than the [UserRoleDisplay.adminConsoleRoles] that share
  /// this admin console UI (Deputy Head included). Without this, Deputy
  /// Head sees a working-looking shortcut into a wizard whose Confirm step
  /// the Cloud Function always rejects.
  final bool Function(List<UserRole> roles)? hiddenFor;

  const _QuickAddAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.hiddenFor,
  });
}

final _actions = [
  _QuickAddAction(
    label: 'Add Staff',
    icon: Icons.person_add_alt_1_rounded,
    color: Colors.black,
    onTap: (context) => context.push('/staff/admin/users/add-staff'),
    hiddenFor: (roles) => !roles.any(UserRoleDisplay.adminRoles.contains),
  ),
  _QuickAddAction(
    label: 'Add Student',
    icon: Icons.school_outlined,
    color: Colors.black,
    onTap: (context) {
      final auth = context.read<AuthBloc>().state;
      if (auth is AuthAuthenticated) {
        context.push('/staff/admin/admissions/new', extra: auth.user.schoolId);
      }
    },
  ),
  _QuickAddAction(
    label: 'Add Parent',
    icon: Icons.person_add_outlined,
    color: Colors.black,
    onTap: (context) => context.push('/staff/admin/parents'),
  ),
  _QuickAddAction(
    label: 'Create Announcement',
    icon: Icons.campaign_rounded,
    color: Colors.black,
    onTap: (context) => context.push('/staff/more/announcements/new'),
  ),
  _QuickAddAction(
    label: 'Create Appointment',
    icon: Icons.event_available_rounded,
    color: Colors.black,
    onTap: (context) => context.push('/staff/admin/appointments'),
  ),
];

class _AdminQuickAddSheetContent extends StatelessWidget {
  const _AdminQuickAddSheetContent();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final roles = authState is AuthAuthenticated
        ? authState.user.roles
        : const <UserRole>[];
    final visibleActions = _actions
        .where((action) => !(action.hiddenFor?.call(roles) ?? false))
        .toList();
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.l),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.extraLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Add',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.l),
            for (final action in visibleActions)
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: action.color,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(action.icon, color: action.color, size: 20),
                  ),
                  title: Text(
                    action.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    action.onTap(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
