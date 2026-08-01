import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/data/models/staff_alert.dart';
import 'package:school_pulse/features/notifications/data/repositories/staff_alerts_repository.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';

/// Bell icon with a live unread-count badge, shared by every staff
/// dashboard app bar. Tapping it opens the shared notification center.
class NotificationBellButton extends StatefulWidget {
  final Color? backgroundColor;

  const NotificationBellButton({super.key, this.backgroundColor});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  /// Built once and reused.
  ///
  /// Previously this was constructed inside `build()`, which opened a fresh
  /// Firestore stream on every rebuild - a billed listener per rebuild, and a
  /// badge that flickered back to zero each time. It also threw outright when
  /// Firebase was unavailable (widget tests), taking the whole dashboard down
  /// with it.
  StaffAlertsRepository? _repository;
  bool _repositoryUnavailable = false;

  StaffAlertsRepository? get _alerts {
    if (_repositoryUnavailable) return null;
    try {
      return _repository ??= StaffAlertsRepository();
    } catch (_) {
      // No Firebase app - the bell still renders and still navigates, it just
      // cannot show a count.
      _repositoryUnavailable = true;
      return null;
    }
  }

  Color? get backgroundColor => widget.backgroundColor;

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
    // Parents also belong to a 'Class:<X>' group per child, which
    // NotificationGroups.forRole can't know about - match the groups the
    // actual Notifications screen queries by so the badge doesn't undercount.
    List<String> groups = NotificationGroups.forRole(role);
    if (role == UserRole.parent) {
      final studentsState = context.watch<StudentsBloc>().state;
      if (studentsState is StudentsLoaded) {
        groups = {
          'Parents',
          ...studentsState.students.map((s) => 'Class:${s.className}'),
        }.toList();
      }
    }
    final notificationRoute = role == UserRole.parent 
        ? '/parent/notifications' 
        : role == UserRole.student 
            ? '/student/notifications' 
            : '/staff/notifications';

    final repository = _alerts;
    if (repository == null) {
      // Firebase unavailable: a bell that navigates but shows no badge is far
      // better than an exception thrown mid-build.
      return IconButton(
        icon: const Icon(Icons.notifications_none_outlined),
        onPressed: () => context.push(notificationRoute),
        style: backgroundColor != null ? IconButton.styleFrom(backgroundColor: backgroundColor) : null,
      );
    }

    return StreamBuilder<List<StaffAlert>>(
      stream: repository.watchAllForUser(uid: uid, groups: groups),
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
