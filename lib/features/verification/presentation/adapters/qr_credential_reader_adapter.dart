import 'dart:async';

import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

/// QR capture is a camera-driven full-screen UI (`QrScannerScreen`), not a
/// backgroundable hardware session like NFC - this adapter doesn't own
/// the camera itself, it's just the seam `VerificationScanScreen` feeds
/// scanned payloads through so `CredentialScanBloc` never has to know
/// whether a credential came from a camera, NFC, or anything else.
class QrCredentialReaderAdapter implements CredentialReaderAdapter {
  final _controller = StreamController<ScanCredential>.broadcast();
  bool _active = false;

  @override
  ScanCredentialKind get kind => ScanCredentialKind.qr;

  @override
  Stream<ScanCredential> get credentials => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> start(VerificationContext context) async {
    _active = true;
  }

  @override
  Future<void> stop() async {
    _active = false;
  }

  /// Called by the QR-capture UI (wrapping the existing `QrScannerScreen`)
  /// whenever `mobile_scanner` reports a raw payload.
  void submitRawPayload(String rawPayload) {
    if (!_active) return;
    _controller.add(QrScanCredential(rawPayload: rawPayload, scannedAt: DateTime.now()));
  }

  void dispose() {
    _controller.close();
  }
}
