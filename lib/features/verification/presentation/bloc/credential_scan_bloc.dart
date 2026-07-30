import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_event.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_state.dart';

/// Owns which `CredentialReaderAdapter` is active at any moment (NFC / QR
/// / fingerprint), so exactly one reader session is ever open - e.g. an
/// NFC session gets stopped before a QR camera is opened for the same
/// scan attempt. Kept separate from `VerificationSessionBloc` so later
/// phases (attendance, meals, etc.) can reuse this reader-lifecycle
/// management unchanged while writing their own session bloc.
class CredentialScanBloc extends Bloc<CredentialScanEvent, CredentialScanState> {
  final Map<ScanCredentialKind, CredentialReaderAdapter> adapters;

  StreamSubscription<ScanCredential>? _subscription;
  CredentialReaderAdapter? _active;

  CredentialScanBloc({required this.adapters}) : super(const CredentialScanState.initial()) {
    on<StartCredentialScan>(_onStart);
    on<StopCredentialScan>(_onStop);
    on<CredentialCapturedByAdapter>(_onCaptured);
  }

  Future<void> _onStart(StartCredentialScan event, Emitter<CredentialScanState> emit) async {
    await _teardownActive();

    final adapter = adapters[event.kind];
    if (adapter == null) return;

    _active = adapter;
    _subscription = adapter.credentials.listen((credential) => add(CredentialCapturedByAdapter(credential)));
    await adapter.start(event.context);
    emit(state.copyWith(isScanning: true, activeKind: event.kind));
  }

  Future<void> _onStop(StopCredentialScan event, Emitter<CredentialScanState> emit) async {
    await _teardownActive();
    emit(state.copyWith(isScanning: false));
  }

  void _onCaptured(CredentialCapturedByAdapter event, Emitter<CredentialScanState> emit) {
    emit(state.copyWith(lastCredential: event.credential));
  }

  Future<void> _teardownActive() async {
    await _subscription?.cancel();
    _subscription = null;
    await _active?.stop();
    _active = null;
  }

  @override
  Future<void> close() async {
    await _teardownActive();
    return super.close();
  }
}
