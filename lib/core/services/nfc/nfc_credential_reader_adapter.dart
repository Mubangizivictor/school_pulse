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
  bool _continuousAttendanceSession = false;

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

    final wantsContinuousAttendance = context.purpose == 'attendance.nfc.scan';

    // Attendance is a rapid multi-student workflow. nfc_manager 3.5.x
    // supports keeping the iOS reader session alive with
    // invalidateAfterFirstRead=false and re-arming it with restartPolling().
    // If School Pulse asks to start again while that session is still alive,
    // do NOT close/re-open Apple's sheet - simply poll for the next card.
    if (_sessionActive &&
        _continuousAttendanceSession &&
        wantsContinuousAttendance) {
      debugPrint('[SchoolPulse:NFC] re-arming continuous attendance polling');
      try {
        await NfcManager.instance.restartPolling();
        return;
      } catch (error) {
        // If iOS already invalidated the native session, fall through and
        // create a fresh one instead of leaving attendance stuck.
        debugPrint('[SchoolPulse:NFC] restartPolling failed; reopening: $error');
        _sessionActive = false;
      }
    }

    // Assignment and other one-shot workflows must always begin with a clean
    // native session. Also clear an attendance session that iOS invalidated.
    if (_sessionActive) {
      debugPrint('[SchoolPulse:NFC] clearing stale NFC session before restart');
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {
        // It is expected that the native session may already be gone.
      }
      _sessionActive = false;
    }

    _continuousAttendanceSession = wantsContinuousAttendance;
    debugPrint(
      wantsContinuousAttendance
          ? '[SchoolPulse:NFC] starting continuous ISO14443 attendance session'
          : '[SchoolPulse:NFC] starting fresh ISO14443 session',
    );
    _sessionActive = true;

    try {
      await NfcManager.instance.startSession(
        // NTAG213 = ISO 14443-3A / NFC Forum Type 2.
        pollingOptions: const {NfcPollingOption.iso14443},
        // For attendance, keep the iOS NFCTagReaderSession alive after a read
        // so the next child does not require pressing Start Scanning again.
        invalidateAfterFirstRead: !wantsContinuousAttendance,
        alertMessage: wantsContinuousAttendance
            ? 'Attendance scanning is active. Tap student cards one after another.'
            : 'Hold the NTAG213 student card near the top edge of your iPhone.',
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
            if (_continuousAttendanceSession && _sessionActive) {
              try {
                await NfcManager.instance.restartPolling();
              } catch (_) {}
            }
            return;
          }

          debugPrint('[SchoolPulse:NFC] UID=$uid');

          if (!_controller.isClosed) {
            _controller.add(
              NfcScanCredential(cardUid: uid, scannedAt: DateTime.now()),
            );
          }

          if (_continuousAttendanceSession) {
            // Do not invalidate the native reader. The attendance screen will
            // resolve/save/show the student and then call start() again after
            // its short preview; start() above converts that into
            // restartPolling() rather than opening a new sheet.
            return;
          }

          _sessionActive = false;
          try {
            await NfcManager.instance.stopSession();
          } catch (_) {
            // iOS may have invalidated the one-shot session already.
          }
        },
        onError: (error) async {
          debugPrint('[SchoolPulse:NFC] native session error: $error');
          _sessionActive = false;
          _continuousAttendanceSession = false;
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
      _continuousAttendanceSession = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    // During attendance the screen calls stop() after each discovered
    // credential while it resolves/saves the student. Treat that as a soft
    // pause: keep the native session alive so the scheduled next scan can use
    // restartPolling() without requiring the user to close/re-open anything.
    if (_continuousAttendanceSession && _sessionActive) {
      debugPrint('[SchoolPulse:NFC] soft-pausing continuous attendance session');
      return;
    }

    final wasActive = _sessionActive;
    _sessionActive = false;
    _continuousAttendanceSession = false;
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
    // dispose is the true end of an attendance session (Done/back/navigation),
    // so force-close the native reader even though stop() is intentionally a
    // soft pause during the rapid multi-card loop.
    _sessionActive = false;
    _continuousAttendanceSession = false;
    try {
      NfcManager.instance.stopSession();
    } catch (_) {}
    _controller.close();
  }

  String? _extractUid(NfcTag tag) {
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
