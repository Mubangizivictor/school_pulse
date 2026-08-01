// dartz also exports `State`, which collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/failures/notification_failure.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notification_repository.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Loads a notification by id, then hands off to [NotificationDetailsScreen].
///
/// Needed because a notification tapped in the system tray arrives with only
/// an id - the in-app list can pass the whole object, but a cold launch from a
/// push cannot. Also covers the deleted, expired and wrong-tenant cases, which
/// the spec requires to show a professional fallback rather than a blank
/// screen or a crash.
class NotificationDetailsLoaderScreen extends StatefulWidget {
  final String notificationId;

  const NotificationDetailsLoaderScreen({
    super.key,
    required this.notificationId,
  });

  @override
  State<NotificationDetailsLoaderScreen> createState() =>
      _NotificationDetailsLoaderScreenState();
}

class _NotificationDetailsLoaderScreenState
    extends State<NotificationDetailsLoaderScreen> {
  late Future<Either<NotificationFailure, NotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Either<NotificationFailure, NotificationItem>> _load() async {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    if (user == null) {
      return const Left(NotificationAuthRequiredFailure());
    }
    if (widget.notificationId.isEmpty) {
      return const Left(NotificationNotFoundFailure());
    }

    return di.sl<NotificationRepository>().getById(
          schoolId: user.schoolId,
          notificationId: widget.notificationId,
          recipientUserId: user.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<NotificationFailure, NotificationItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoaderScaffold(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          );
        }

        final result = snapshot.data;
        if (result == null) {
          return const _FallbackScreen(
            message: 'This notification could not be opened.',
          );
        }

        return result.fold(
          (failure) => _FallbackScreen(message: failure.userMessage),
          (notification) =>
              NotificationDetailsScreen(notification: notification),
        );
      },
    );
  }
}

class _LoaderScaffold extends StatelessWidget {
  final Widget child;

  const _LoaderScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _popOrHome(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(child: child),
    );
  }
}

/// Shown when the notification is gone, expired, or not ours to read.
///
/// Deliberately does not distinguish "deleted" from "belongs to another
/// school" in its wording - the repository already collapses those, so a
/// crafted id cannot be used to probe whether a notification exists elsewhere.
class _FallbackScreen extends StatelessWidget {
  final String message;

  const _FallbackScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return _LoaderScaffold(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _popOrHome(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cold-launching from a push leaves nothing to pop back to, so fall through
/// to the notification centre instead of stranding the user on a dead end.
void _popOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/staff/notifications');
  }
}
