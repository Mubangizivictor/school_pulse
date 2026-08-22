import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';

/// Wraps `nfc_manager` behind the shared `CredentialReaderAdapter` contract.
///
/// IMPORTANT: every physical NFC tap is deliberately handled as a ONE-SHOT
/// native Core NFC session. Rapid attendance is achieved by the attendance
/// screen automatically starting a fresh session after its short result
/// preview. We do not keep one native session alive between students because
/// repeated native discovery callbacks can otherwise replay/overlap scans and
/// make the UI jump between previously resolved students.
class NfcCredentialReaderAdapter implements CredentialReaderAdapter {
  final _controller = StreamController<ScanCredential>.broadcast();
  bool _sessionActive = false;
  bool _deliveredCurrentSession = false;

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

    // A scan request always owns exactly one native session. Clean up any
    // previous native/Dart state first; never reuse a session across students.
    if (_sessionActive) {
      debugPrint('[SchoolPulse:NFC] closing previous session before new scan');
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {
        // Native session may already have been invalidated by iOS.
      }
    }

    _sessionActive = true;
    _deliveredCurrentSession = false;
    debugPrint('[SchoolPulse:NFC] starting one-shot ISO14443 session');

    try {
      await NfcManager.instance.startSession(
        pollingOptions: const {NfcPollingOption.iso14443},
        // One physical card tap must produce one credential only. The screen
        // automatically starts another session after the result preview.
        invalidateAfterFirstRead: true,
        alertMessage: context.purpose == 'attendance.nfc.scan'
            ? 'Hold one student card near the top edge of your iPhone.'
            : 'Hold the NTAG213 student card near the top edge of your iPhone.',
        onDiscovered: (tag) async {
          // Core NFC/plugin callbacks can occasionally re-enter during session
          // teardown. Never publish more than one credential from one session.
          if (_deliveredCurrentSession) {
            debugPrint('[SchoolPulse:NFC] duplicate native callback ignored');
            return;
          }
          _deliveredCurrentSession = true;

          debugPrint('[SchoolPulse:NFC] Core NFC discovered a tag');
          final uid = _extractUid(tag);
          if (uid == null) {
            debugPrint(
              '[SchoolPulse:NFC] tag discovered but no UID adapter matched',
            );
            _sessionActive = false;
            if (!_controller.isClosed) {
              _controller.addError(
                StateError(
                  'NFC tag detected, but School Pulse could not extract its UID.',
                ),
              );
            }
            try {
              await NfcManager.instance.stopSession(
                errorMessage: 'Could not read this student card.',
              );
            } catch (_) {}
            return;
          }

          debugPrint('[SchoolPulse:NFC] UID=$uid');

          // Publish exactly once, then immediately invalidate the native
          // session. Student resolution/attendance happens in Flutter only
          // after this isolated hardware transaction is finished.
          if (!_controller.isClosed) {
            _controller.add(
              NfcScanCredential(cardUid: uid, scannedAt: DateTime.now()),
            );
          }

          _sessionActive = false;
          try {
            await NfcManager.instance.stopSession();
          } catch (_) {
            // invalidateAfterFirstRead may already have closed it.
          }
        },
        onError: (error) async {
          debugPrint('[SchoolPulse:NFC] native session error: $error');
          _sessionActive = false;
          _deliveredCurrentSession = false;
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
      _deliveredCurrentSession = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    final wasActive = _sessionActive;
    _sessionActive = false;
    _deliveredCurrentSession = false;
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
    _sessionActive = false;
    _deliveredCurrentSession = false;
    try {
      NfcManager.instance.stopSession();
    } catch (_) {}
    _controller.close();
  }

  String? _extractUid(NfcTag tag) {
    // iOS presents an NTAG213 through MiFare. Android may expose the same
    // card through NfcA/MifareUltralight. Normalize all compatible paths to
    // the same hexadecimal UID.
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
