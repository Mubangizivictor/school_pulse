import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/domain/services/message_outbox_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Drains the messaging offline outbox on app resume and on connectivity
/// restoration - same shape and same reasoning as
/// `AttendanceSyncLifecycleGate`: a short foreground poll of
/// [NetworkInfo.isConnected] rather than a `connectivity_plus` dependency
/// this project doesn't otherwise have, since [MessageOutboxService.drain]
/// is already a no-op when there is nothing queued or the device is still
/// offline.
///
/// No-op on web ([MessageOutboxService] isn't registered there - see
/// injection_container.dart's `if (!kIsWeb)` guard around it).
class MessageSyncLifecycleGate extends StatefulWidget {
  final Widget child;

  const MessageSyncLifecycleGate({required this.child, super.key});

  @override
  State<MessageSyncLifecycleGate> createState() =>
      _MessageSyncLifecycleGateState();
}

class _MessageSyncLifecycleGateState extends State<MessageSyncLifecycleGate>
    with WidgetsBindingObserver {
  Timer? _connectivityPoll;
  bool _wasConnected = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    WidgetsBinding.instance.addObserver(this);
    _startConnectivityPoll();
  }

  @override
  void dispose() {
    if (!kIsWeb) WidgetsBinding.instance.removeObserver(this);
    _connectivityPoll?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _triggerSync();
  }

  void _startConnectivityPoll() {
    _connectivityPoll = Timer.periodic(const Duration(seconds: 15), (
      _,
    ) async {
      final connected = await di.sl<NetworkInfo>().isConnected;
      if (connected && !_wasConnected) _triggerSync();
      _wasConnected = connected;
    });
  }

  void _triggerSync() {
    if (!mounted || kIsWeb) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    unawaited(di.sl<MessageOutboxService>().drain());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
