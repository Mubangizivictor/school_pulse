import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';

enum ScanCredentialKind { qr, nfc, fingerprint, manualCode }

/// A physical or virtual credential reader (NFC hardware, camera-driven QR
/// scan, an external fingerprint device). All adapters emit [ScanCredential]s
/// through the same shape so `CredentialScanBloc` never needs to know which
/// reader produced a given scan.
abstract class CredentialReaderAdapter {
  ScanCredentialKind get kind;

  Stream<ScanCredential> get credentials;

  Future<bool> isAvailable();

  Future<void> start(VerificationContext context);

  Future<void> stop();
}
