import 'package:school_pulse/core/user_roles.dart';

/// The notification list route for [role]'s own navigation shell.
///
/// Every shell (`/parent`, `/student`, `/staff`) mounts an identical copy of
/// the notification screens at its own prefix. Falling back to a bare
/// `/staff/notifications` regardless of role - easy to do by accident, since
/// most roles are staff - lands a parent or student notification tap in the
/// wrong shell instead of their own.
String notificationShellBasePath(UserRole role) => switch (role) {
  UserRole.parent => '/parent/notifications',
  UserRole.student => '/student/notifications',
  _ => '/staff/notifications',
};
