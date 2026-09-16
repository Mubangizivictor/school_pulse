import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/attendance_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/exam_factory/domain/repositories/exam_factory_repository.dart';
import 'package:school_pulse/features/exam_factory/domain/services/exam_factory_offline_queue_service.dart';
import 'package:school_pulse/features/exam_factory/domain/services/exam_factory_queue_replay.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/admin/domain/services/staff_attendance_offline_queue_service.dart';
import 'package:school_pulse/features/admin/domain/services/staff_attendance_queue_replay.dart';
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Drains the locally-queued attendance sync on app resume and on
/// connectivity restoration - the two lifecycle moments the app-root
/// `AuthBloc` listener in `main.dart` cannot cover on its own, since that
/// listener only fires on sign-in/sign-out transitions, not on a teacher
/// backgrounding School Pulse mid-session or regaining signal later while
/// already signed in.
///
/// Mounted in `MaterialApp.router`'s `builder:` alongside `OwnerAppLockGate`
/// / `SubscriptionAccessGate` (see `main.dart`) - same
/// `WidgetsBindingObserver` pattern as `OwnerAppLockGate`, scoped to every
/// signed-in role rather than one console, since attendance queueing is not
/// role-specific.
///
/// No `connectivity_plus` dependency: the project has no reconnect-stream
/// package today, and adding one is a heavier, cross-cutting change than
/// this task's scope. A short foreground poll of the existing
/// [NetworkInfo.isConnected] one-shot check is a lower-risk way to detect
/// "internet came back" without touching build config on either platform -
/// `syncPendingAttendance` itself is a no-op when there is nothing pending,
/// so a slightly delayed detection costs nothing beyond that poll.
class AttendanceSyncLifecycleGate extends StatefulWidget {
  final Widget child;

  const AttendanceSyncLifecycleGate({required this.child, super.key});

  @override
  State<AttendanceSyncLifecycleGate> createState() =>
      _AttendanceSyncLifecycleGateState();
}

class _AttendanceSyncLifecycleGateState
    extends State<AttendanceSyncLifecycleGate>
    with WidgetsBindingObserver {
  Timer? _connectivityPoll;
  bool _wasConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startConnectivityPoll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivityPoll?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSync();
    }
  }

  // A short interval keeps "internet came back" detection close to
  // immediate for a teacher waiting on DONE, without the overhead of a
  // platform connectivity-stream dependency this project doesn't have yet.
  void _startConnectivityPoll() {
    _connectivityPoll = Timer.periodic(const Duration(seconds: 15), (_) async {
      final connected = await di.sl<NetworkInfo>().isConnected;
      if (connected && !_wasConnected) {
        _triggerSync();
      }
      _wasConnected = connected;
    });
  }

  void _triggerSync() {
    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    // Fire-and-forget: syncPendingAttendance never throws for an offline
    // device or an empty queue, and this gate must never block a frame on
    // network I/O.
    unawaited(
      di.sl<AttendanceRepository>().syncPendingAttendance(
        authState.user.schoolId,
      ),
    );

    // Boarding roll call (Patron/Matron) has its own offline queue over the
    // same lifecycle triggers - see BoardingAttendanceLocalDataSource. Only
    // the role actually in effect is drained, since PatronBloc/MatronBloc
    // exist for every signed-in user regardless of role via the DI graph.
    if (authState.user.roles.contains(UserRole.boardingPatron)) {
      unawaited(
        di.sl<PatronRepository>().syncPendingBoardingAttendance(
          authState.user.schoolId,
        ),
      );
    }
    if (authState.user.roles.contains(UserRole.boardingMatron)) {
      unawaited(
        di.sl<MatronRepository>().syncPendingBoardingAttendance(
          authState.user.schoolId,
        ),
      );
    }

    // Exam Factory's offline queue (question drafts, moderation comments,
    // mark entry, attendance, incidents) shares these same lifecycle
    // triggers rather than adding its own observer/poll - see
    // ExamFactoryOfflineQueueService doc for what is and is not safe to
    // queue. Guarded by isRegistered so test setups that stub only the
    // attendance/boarding DI surface (this gate predates Exam Factory)
    // are not forced to also register it.
    if (di.sl.isRegistered<ExamFactoryOfflineQueueService>() &&
        di.sl.isRegistered<ExamFactoryRepository>()) {
      unawaited(
        di.sl<ExamFactoryOfflineQueueService>().syncPending(
          institutionId: authState.user.schoolId,
          actorId: authState.user.id,
          send: ExamFactoryQueueReplay(
            repository: di.sl<ExamFactoryRepository>(),
          ).replay,
        ),
      );
    }

    // Staff attendance's offline queue (same-day clock-in, correction)
    // shares these same lifecycle triggers - see
    // StaffAttendanceOfflineQueueService doc for what is and is not safe to
    // queue.
    if (di.sl.isRegistered<StaffAttendanceOfflineQueueService>() &&
        di.sl.isRegistered<StaffAttendanceRepository>()) {
      unawaited(
        di.sl<StaffAttendanceOfflineQueueService>().syncPending(
          institutionId: authState.user.schoolId,
          actorId: authState.user.id,
          send: StaffAttendanceQueueReplay(
            repository: di.sl<StaffAttendanceRepository>(),
          ).replay,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
