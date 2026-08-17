import 'dart:async';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

/// Wraps `nfc_manager` behind the shared `CredentialReaderAdapter`
/// contract. Card technology (MIFARE Classic/DESFire, NTAG, iOS MiFare,
/// ISO15693, etc) is abstracted away here - callers only ever see a
/// hex-encoded UID via [ScanCredential.nfc], never a tag-tech-specific
/// type, so business logic never depends on which card technology was
/// tapped.
class NfcCredentialReaderAdapter implements CredentialReaderAdapter {
  final _controller = StreamController<ScanCredential>.broadcast();
  bool _sessionActive = false;

  @override
  ScanCredentialKind get kind => ScanCredentialKind.nfc;

  @override
  Stream<ScanCredential> get credentials => _controller.stream;

  @override
  Future<bool> isAvailable() => NfcManager.instance.isAvailable();

  @override
  Future<void> start(VerificationContext context) async {
    if (_sessionActive) return;

    final available = await isAvailable();
    if (!available) {
      throw StateError(
        'NFC is not available on this device. iOS Simulator cannot scan NFC cards; use a physical NFC-capable iPhone.',
      );
    }

    _sessionActive = true;
    try {
      await NfcManager.instance.startSession(
        alertMessage: 'Hold the student card near the top edge of your iPhone.',
        onDiscovered: (tag) async {
          final uid = _extractUid(tag);
          if (uid == null) {
            if (!_controller.isClosed) {
              _controller.addError(
                StateError('The NFC tag was detected but its card UID could not be read.'),
              );
            }
            return;
          }
          if (!_controller.isClosed) {
            _controller.add(
              NfcScanCredential(cardUid: uid, scannedAt: DateTime.now()),
            );
          }
        },
        onError: (error) async {
          _sessionActive = false;
          if (!_controller.isClosed) {
            _controller.addError(
              StateError('iPhone NFC session failed: $error'),
            );
          }
        },
      );
    } catch (error) {
      _sessionActive = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (!_sessionActive) return;
    _sessionActive = false;
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {
      // The native session may already have been closed by iOS after a
      // successful read or native error. Cleanup must remain idempotent.
    }
  }

  void dispose() {
    _controller.close();
  }

  String? _extractUid(NfcTag tag) {
    final identifier =
        NfcA.from(tag)?.identifier ??
        MifareClassic.from(tag)?.identifier ??
        MifareUltralight.from(tag)?.identifier ??
        IsoDep.from(tag)?.identifier ??
        Iso15693.from(tag)?.identifier ??
        NfcB.from(tag)?.identifier ??
        NfcF.from(tag)?.identifier ??
        NfcV.from(tag)?.identifier ??
        MiFare.from(tag)?.identifier;
    if (identifier == null || identifier.isEmpty) return null;
    return _hex(identifier);
  }

  String _hex(Uint8List bytes) => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}
