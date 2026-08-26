import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/injection_container.dart';

/// Real Core NFC scan flow (assign/replace card UID capture), shared
/// between the Identity tab's NFC card and the Student ID Card preview's
/// Replace-card action, so the same on-device integration isn't
/// copy-pasted a third time. Falls back to manual UID entry when the
/// device reports no NFC hardware (e.g. iOS Simulator).
///
/// A mixed-in [State] must expose [scanningSchoolId] (the student's
/// schoolId, needed only to satisfy [VerificationContext]'s shape) and
/// call [scanCard] to drive one scan attempt.
mixin NfcScanFlowMixin<T extends StatefulWidget> on State<T> {
  bool nfcScanning = false;
  final TextEditingController manualUidController = TextEditingController();

  @override
  void dispose() {
    manualUidController.dispose();
    super.dispose();
  }

  /// Starts one NFC scan session, prompting the user with [promptMessage],
  /// and resolves to the scanned card UID or null (cancelled/timed out/
  /// unavailable-and-manual-entry-cancelled). [schoolId] is only used to
  /// populate the required [VerificationContext.gate] shape.
  Future<String?> scanCard(String promptMessage, {required String schoolId}) async {
    if (nfcScanning) return null;

    final adapter = sl<NfcCredentialReaderAdapter>();
    StreamSubscription<ScanCredential>? subscription;
    final completer = Completer<String?>();

    try {
      final available = await adapter.isAvailable();
      if (!available) {
        if (!mounted) return null;
        return manualUidFallback();
      }

      if (!mounted) return null;
      final auth = context.read<AuthBloc>().state;
      if (auth is! AuthAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your session is not ready. Sign in again and retry.',
              ),
            ),
          );
        }
        return null;
      }

      if (mounted) {
        setState(() => nfcScanning = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(promptMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      subscription = adapter.credentials.listen(
        (credential) {
          if (credential is NfcScanCredential && !completer.isCompleted) {
            completer.complete(credential.cardUid);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
      );

      final verificationContext = VerificationContext(
        gate: Gate(
          id: 'nfc-assign',
          name: 'NFC Card Assignment',
          type: 'internal',
          location: '',
          assignedOfficerIds: const [],
          operatingHours: const {},
          allowedUserRoles: const [],
          requiredVerificationMethods: const [],
          schoolId: schoolId,
        ),
        operatorUser: auth.user,
        purpose: 'student_identity.nfc_assign',
        deviceId: 'app',
        requestedAt: DateTime.now(),
      );

      await adapter.start(verificationContext);

      final uid = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );

      if (uid == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No NFC card was detected. Try again and hold the card near the top edge of the physical iPhone.',
            ),
          ),
        );
      }
      return uid;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start NFC scan: $error')),
        );
      }
      return null;
    } finally {
      try {
        await adapter.stop();
      } catch (_) {}
      await subscription?.cancel();
      if (mounted) setState(() => nfcScanning = false);
    }
  }

  Future<String?> manualUidFallback() async {
    manualUidController.clear();
    if (!mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Card UID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NFC scanning is unavailable on this device. Enter the card UID manually.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: manualUidController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Card UID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final uid = manualUidController.text.trim();
              Navigator.pop(dialogContext, uid.isEmpty ? null : uid);
            },
            child: const Text('Use UID'),
          ),
        ],
      ),
    );
  }

  /// Reason bottom sheet (Lost/Stolen/Damaged/Other) followed by a
  /// confirmation dialog, shared by every destructive NFC lifecycle action
  /// (replace/revoke). Returns the chosen reason only if the user confirms.
  Future<String?> pickReasonAndConfirm({required String actionLabel}) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reason',
                  style: Theme.of(sheetContext).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            for (final reason in const ['Lost', 'Stolen', 'Damaged', 'Other'])
              ListTile(
                title: Text(reason),
                onTap: () => Navigator.pop(sheetContext, reason.toLowerCase()),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$actionLabel this card?'),
        content: const Text(
          'This cannot be undone from this screen, but the card history is preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return confirmed == true ? reason : null;
  }
}
