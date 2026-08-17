import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/admin/presentation/screens/access_codes_screen.dart';
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

  const _QuickAddAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

final _actions = [
  _QuickAddAction(
    label: 'Add Staff',
    icon: Icons.person_add_alt_1_rounded,
    color: Colors.indigo,
    onTap: (context) => context.push('/staff/admin/users/add-staff'),
  ),
  _QuickAddAction(
    label: 'Add Student',
    icon: Icons.school_outlined,
    color: Colors.teal,
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
    color: Colors.green,
    onTap: (context) => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccessCodesScreen())),
  ),
  _QuickAddAction(
    label: 'Create Announcement',
    icon: Icons.campaign_rounded,
    color: Colors.redAccent,
    onTap: (context) => context.push('/staff/more/announcements/new'),
  ),
  _QuickAddAction(
    label: 'Create Appointment',
    icon: Icons.event_available_rounded,
    color: Colors.lightBlue,
    onTap: (context) => context.push('/staff/admin/appointments'),
  ),
];

class _AdminQuickAddSheetContent extends StatelessWidget {
  const _AdminQuickAddSheetContent();

  @override
  Widget build(BuildContext context) {
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
            for (final action in _actions)
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.12),
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
