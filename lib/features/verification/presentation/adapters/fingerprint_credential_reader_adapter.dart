import 'dart:async';

import 'package:school_pulse/features/biometrics/domain/repositories/biometric_device_service.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

/// Wraps the existing `BiometricDeviceService` (currently backed by
/// `MockBiometricDeviceService` - no real hardware integration exists in
/// this codebase yet). Fingerprint only ever confirms an already-claimed
/// identity (see `FingerprintScanCredential`) - callers must know who
/// they expect before calling [captureForClaimedIdentity].
///
/// Not wired into the Security/Gate UI in Phase 1: today's gate flow has
/// no "claim an identity first" step for fingerprint, so the existing
/// "not available on this device yet" stub is left unchanged. This
/// adapter exists so a later phase (where a module already knows who
/// it's checking, e.g. confirming a specific student) can use it without
/// inventing a second fingerprint integration.
class FingerprintCredentialReaderAdapter implements CredentialReaderAdapter {
  final BiometricDeviceService deviceService;
  final _controller = StreamController<ScanCredential>.broadcast();

  FingerprintCredentialReaderAdapter(this.deviceService);

  @override
  ScanCredentialKind get kind => ScanCredentialKind.fingerprint;

  @override
  Stream<ScanCredential> get credentials => _controller.stream;

  @override
  Future<bool> isAvailable() async => deviceService.isConnected;

  @override
  Future<void> start(VerificationContext context) async {
    await deviceService.initialize();
  }

  @override
  Future<void> stop() async {
    await deviceService.disconnect();
  }

  Future<void> captureForClaimedIdentity({
    required String claimedIdentityId,
    required String claimedIdentityType,
    required String deviceId,
  }) async {
    _controller.add(
      FingerprintScanCredential(
        claimedIdentityId: claimedIdentityId,
        claimedIdentityType: claimedIdentityType,
        deviceId: deviceId,
        capturedAt: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
