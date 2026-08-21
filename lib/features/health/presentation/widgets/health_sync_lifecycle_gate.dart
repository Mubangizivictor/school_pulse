import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/repositories/health_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Drains the locally-queued clinic-visit sync on app resume and on
/// connectivity restoration - the same lifecycle moments
/// [AttendanceSyncLifecycleGate] and [MessageSyncLifecycleGate] cover for
/// their own features. See those for the pattern this mirrors.
class HealthSyncLifecycleGate extends StatefulWidget {
  final Widget child;

  const HealthSyncLifecycleGate({required this.child, super.key});

  @override
  State<HealthSyncLifecycleGate> createState() =>
      _HealthSyncLifecycleGateState();
}

class _HealthSyncLifecycleGateState extends State<HealthSyncLifecycleGate>
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

  void _startConnectivityPoll() {
    _connectivityPoll = Timer.periodic(const Duration(seconds: 15), (
      _,
    ) async {
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
    // Fire-and-forget: syncPendingClinicVisits never throws for an offline
    // device or an empty queue, and this gate must never block a frame on
    // network I/O.
    unawaited(
      di.sl<HealthRepository>().syncPendingClinicVisits(
        authState.user.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
