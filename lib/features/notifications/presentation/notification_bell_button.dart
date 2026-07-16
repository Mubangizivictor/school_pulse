import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/data/models/staff_alert.dart';
import 'package:school_pulse/features/notifications/data/repositories/staff_alerts_repository.dart';

/// Bell icon with a live unread-count badge, shared by every staff
/// dashboard app bar. Tapping it opens the shared notification center.
class NotificationBellButton extends StatelessWidget {
  final Color? backgroundColor;

  const NotificationBellButton({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return IconButton(
        icon: const Icon(Icons.notifications_none_outlined),
        onPressed: () => context.push('/staff/notifications'),
        style: backgroundColor != null ? IconButton.styleFrom(backgroundColor: backgroundColor) : null,
      );
    }
    final uid = authState.user.id;
    final role = authState.user.role;
    final groups = NotificationGroups.forRole(role);
    final notificationRoute = role == UserRole.parent ? '/parent/notifications' : '/staff/notifications';

    return StreamBuilder<List<StaffAlert>>(
      stream: StaffAlertsRepository().watchAllForUser(uid: uid, groups: groups),
      builder: (context, snapshot) {
        final unread = (snapshot.data ?? const []).where((a) => !a.isReadBy(uid)).length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () => context.push(notificationRoute),
              style: backgroundColor != null ? IconButton.styleFrom(backgroundColor: backgroundColor) : null,
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
