import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

/// Wraps `nfc_manager` behind the shared `CredentialReaderAdapter`
/// contract. Card technology is abstracted away here - callers only ever
/// receive a normalized hexadecimal UID.
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
    final available = await isAvailable();
    if (!available) {
      throw StateError(
        'NFC is not available on this device. Use a physical NFC-capable iPhone.',
      );
    }

    // Never silently return because of a stale Dart-side flag. iOS can close
    // a Core NFC session itself (timeout/cancel/system interruption) before
    // our state receives a matching callback. A stale `_sessionActive=true`
    // previously made every later Assign Card attempt a no-op that merely
    // waited for the UI timeout.
    if (_sessionActive) {
      debugPrint('[SchoolPulse:NFC] clearing stale NFC session before restart');
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {
        // It is expected that the native session may already be gone.
      }
      _sessionActive = false;
    }

    debugPrint('[SchoolPulse:NFC] starting fresh ISO14443 session');
    _sessionActive = true;

    try {
      await NfcManager.instance.startSession(
        // The test cards are NXP NTAG213: ISO 14443-3A / NFC Forum Type 2.
        // Poll only ISO14443 so Core NFC is not asked to negotiate unrelated
        // technologies and the assignment path stays deterministic.
        pollingOptions: const {NfcPollingOption.iso14443},
        alertMessage: 'Hold the NTAG213 student card near the top edge of your iPhone.',
        onDiscovered: (tag) async {
          debugPrint('[SchoolPulse:NFC] Core NFC discovered a tag');

          final uid = _extractUid(tag);
          if (uid == null) {
            debugPrint('[SchoolPulse:NFC] tag discovered but no UID adapter matched');
            if (!_controller.isClosed) {
              _controller.addError(
                StateError(
                  'NFC tag detected, but School Pulse could not extract its UID.',
                ),
              );
            }
            return;
          }

          debugPrint('[SchoolPulse:NFC] UID=$uid');

          // Publish the credential immediately. The assignment UI subscribes
          // before start() is called, so this completes the scan without
          // waiting for its 30-second guard timeout.
          if (!_controller.isClosed) {
            _controller.add(
              NfcScanCredential(cardUid: uid, scannedAt: DateTime.now()),
            );
          }

          _sessionActive = false;
          try {
            await NfcManager.instance.stopSession(
              alertMessage: 'Student card detected successfully.',
            );
          } catch (_) {
            // iOS may have invalidated the session immediately after read.
          }
        },
        onError: (error) async {
          debugPrint('[SchoolPulse:NFC] native session error: $error');
          _sessionActive = false;
          if (!_controller.isClosed) {
            _controller.addError(
              StateError('iPhone NFC session failed: $error'),
            );
          }
        },
      );

      debugPrint('[SchoolPulse:NFC] native Core NFC session started');
    } catch (error) {
      debugPrint('[SchoolPulse:NFC] startSession threw: $error');
      _sessionActive = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    // Cleanup is intentionally attempted even if our Dart-side flag says the
    // session is inactive. This keeps native and Dart state synchronized.
    final wasActive = _sessionActive;
    _sessionActive = false;
    if (wasActive) {
      debugPrint('[SchoolPulse:NFC] stopping NFC session');
    }
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {
      // Safe when no native session exists.
    }
  }

  void dispose() {
    _controller.close();
  }

  String? _extractUid(NfcTag tag) {
    // On iOS an NTAG213 normally appears through MiFare; on Android it may
    // appear as NfcA/MifareUltralight. Keep all compatible representations
    // so the same physical card has one normalized UID on every platform.
    final identifier =
        MiFare.from(tag)?.identifier ??
        NfcA.from(tag)?.identifier ??
        MifareUltralight.from(tag)?.identifier ??
        Iso7816.from(tag)?.identifier ??
        IsoDep.from(tag)?.identifier ??
        MifareClassic.from(tag)?.identifier ??
        Iso15693.from(tag)?.identifier ??
        NfcB.from(tag)?.identifier ??
        NfcF.from(tag)?.identifier ??
        NfcV.from(tag)?.identifier;

    if (identifier == null || identifier.isEmpty) return null;
    return _hex(identifier);
  }

  String _hex(Uint8List bytes) => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}
