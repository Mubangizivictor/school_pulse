import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/injection_container.dart';

import '../../../student/domain/entities/student.dart';
import '../../domain/entities/student_identity.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';

/// Combines the "ID Card" and "NFC Card Management" + "QR Credential"
/// concerns into one screen with sections, rather than three separate
/// screens - the NFC scanning flow here is lifted straight from
/// [StudentIdCardScreen]'s `_NfcCardSection`, which already talks to the
/// real Core NFC adapter (`NfcCredentialReaderAdapter`) on physical
/// iPhones. That screen remains reachable separately (router path
/// 'student-id-card') for the dedicated print/preview flow; this screen
/// links out to it for the full card preview instead of re-rendering it.
class IdentityAndCardsScreen extends StatelessWidget {
  final Student student;

  const IdentityAndCardsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Identity & Cards')),
    body: IdentityAndCardsBody(student: student),
  );
}

/// The screen's content without its own [Scaffold], so the admin student
/// profile can host it as an Identity tab while the standalone route
/// ([IdentityAndCardsScreen]) keeps working unchanged. Both paths share this
/// one implementation - the bloc wiring, NFC flow and QR sections are not
/// duplicated.
///
/// Callers must provide a [StudentIdentityBloc] above this widget, exactly as
/// the standalone route already does.
class IdentityAndCardsBody extends StatefulWidget {
  final Student student;

  const IdentityAndCardsBody({super.key, required this.student});

  @override
  State<IdentityAndCardsBody> createState() => _IdentityAndCardsBodyState();
}

class _IdentityAndCardsBodyState extends State<IdentityAndCardsBody> {
  @override
  void initState() {
    super.initState();
    context.read<StudentIdentityBloc>().add(
      LoadStudentIdentityEvent(
        widget.student.id,
        schoolId: widget.student.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentIdentityBloc, StudentIdentityState>(
      listener: (context, state) {
        if (state is StudentIdentityActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is StudentIdentityError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is StudentIdentityLoading ||
            state is StudentIdentityInitial) {
          return const Center(child: SchoolPulseLoader());
        }

        if (state is StudentIdentityError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<StudentIdentityBloc>().add(
                      LoadStudentIdentityEvent(
                        widget.student.id,
                        schoolId: widget.student.schoolId,
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is StudentIdentityLoaded) {
          return ResponsiveBuilder(
            builder: (context, layout) {
              final isDesktop = layout == ResponsiveLayout.desktop;
              final idCardSection = _IdCardPreviewSection(
                student: widget.student,
              );
              final nfcSection = _NfcManagementSection(
                student: widget.student,
                identity: state.identity,
                assignedCardUid: state.assignedCardUid,
              );
              final qrSection = _QrCredentialSection(identity: state.identity);

              if (isDesktop) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(children: [idCardSection]),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                nfcSection,
                                const SizedBox(height: 24),
                                qrSection,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    idCardSection,
                    const SizedBox(height: 24),
                    nfcSection,
                    const SizedBox(height: 24),
                    qrSection,
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _IdCardPreviewSection extends StatelessWidget {
  final Student student;

  const _IdCardPreviewSection({required this.student});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'ID Card',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: student.photoUrl?.isNotEmpty == true
                    ? NetworkImage(student.photoUrl!)
                    : null,
                child: student.photoUrl?.isNotEmpty == true
                    ? null
                    : const Icon(Icons.person),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${student.studentId} · ${student.className}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            // Sibling route registered by the teammate owning router
            // wiring, at lib/app/router.dart around 'student-id-card'
            // (path: 'student-id-card', extra: Student). This screen is
            // expected to be mounted as another sibling under the same
            // parent, so a relative push resolves correctly; if it is
            // instead mounted elsewhere, this should be swapped for an
            // absolute path by whoever wires final navigation.
            onPressed: () => context.push('student-id-card', extra: student),
            icon: const Icon(Icons.badge_outlined),
            label: const Text('View / Print ID Card'),
          ),
        ],
      ),
    );
  }
}

class _QrCredentialSection extends StatelessWidget {
  final StudentIdentity identity;

  const _QrCredentialSection({required this.identity});

  @override
  Widget build(BuildContext context) {
    final issued = identity.qrCodeData.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'QR Credential',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                issued ? Icons.check_circle : Icons.circle_outlined,
                color: issued ? Colors.black : scheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(issued ? 'QR credential issued' : 'Not yet issued'),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.read<StudentIdentityBloc>().add(
              RegenerateQrCredentialEvent(identity),
            ),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Regenerate QR'),
          ),
        ],
      ),
    );
  }
}

// NFC card lifecycle - assign/replace/revoke/reactivate. The scan flow
// (adapter.start/stop against NfcCredentialReaderAdapter, listening for
// NfcScanCredential on the credentials stream) is copied verbatim from
// StudentIdCardScreen's `_NfcCardSection` - that is the only reusable NFC
// scan integration found in the app (see report). Replace/Revoke reason
// capture uses a modal bottom sheet here since no shared bottom-sheet
// helper widget exists anywhere in lib/design_system or lib/core -
// confirmed by search; every other screen in the app also calls
// showModalBottomSheet directly with ad hoc content.
class _NfcManagementSection extends StatefulWidget {
  final Student student;
  final StudentIdentity identity;
  final String? assignedCardUid;

  const _NfcManagementSection({
    required this.student,
    required this.identity,
    required this.assignedCardUid,
  });

  @override
  State<_NfcManagementSection> createState() => _NfcManagementSectionState();
}

class _NfcManagementSectionState extends State<_NfcManagementSection> {
  bool _scanning = false;
  final TextEditingController _manualUidController = TextEditingController();

  @override
  void dispose() {
    _manualUidController.dispose();
    super.dispose();
  }

  Future<String?> _scanCard(String promptMessage) async {
    if (_scanning) return null;

    final adapter = sl<NfcCredentialReaderAdapter>();
    StreamSubscription<ScanCredential>? subscription;
    final completer = Completer<String?>();

    try {
      final available = await adapter.isAvailable();
      if (!available) {
        if (!mounted) return null;
        return _manualUidFallback();
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
        setState(() => _scanning = true);
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
          if (!completer.isCompleted)
            completer.completeError(error, stackTrace);
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
          schoolId: widget.student.schoolId,
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
      if (mounted) setState(() => _scanning = false);
    }
  }

  // TODO(identity-cards): NFC hardware scanning is unavailable in this
  // context (e.g. simulator, unsupported device, or web). Physical NFC
  // scan integration for card assignment is otherwise handled above via
  // NfcCredentialReaderAdapter (the same adapter StudentIdCardScreen
  // uses) - this manual entry is only a fallback for when that adapter
  // reports itself unavailable.
  Future<String?> _manualUidFallback() async {
    _manualUidController.clear();
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
              controller: _manualUidController,
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
              final uid = _manualUidController.text.trim();
              Navigator.pop(dialogContext, uid.isEmpty ? null : uid);
            },
            child: const Text('Use UID'),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickReason() {
    return showModalBottomSheet<String>(
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
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
  }

  Future<void> _assign() async {
    final uid = await _scanCard(
      'Hold the card near the top edge of your physical iPhone until Apple confirms the scan.',
    );
    if (uid == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(
      AssignNfcCardEvent(
        cardUid: uid,
        studentId: widget.student.id,
        uniqueSystemId: widget.identity.uniqueSystemId,
        schoolId: widget.student.schoolId,
      ),
    );
  }

  Future<void> _replace() async {
    final oldUid = widget.assignedCardUid;
    if (oldUid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    final newUid = await _scanCard(
      'Hold the replacement card near the top edge of your physical iPhone.',
    );
    if (newUid == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(
      ReplaceNfcCardEvent(
        oldCardUid: oldUid,
        newCardUid: newUid,
        studentId: widget.student.id,
        uniqueSystemId: widget.identity.uniqueSystemId,
        schoolId: widget.student.schoolId,
        reason: reason,
      ),
    );
  }

  Future<void> _revoke() async {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(
      RevokeNfcCardEvent(
        cardUid: uid,
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
        reason: reason,
      ),
    );
  }

  void _reactivate() {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    context.read<StudentIdentityBloc>().add(
      ReactivateNfcCardEvent(
        cardUid: uid,
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.identity.nfcStatus;
    final scheme = Theme.of(context).colorScheme;
    final Color statusColor = switch (status) {
      'active' => Colors.black,
      'revoked' => Colors.black,
      _ => scheme.onSurfaceVariant,
    };

    return _SectionCard(
      title: 'NFC Card Management',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(status.toUpperCase()),
                backgroundColor: statusColor,
                labelStyle: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              if (widget.assignedCardUid != null)
                Expanded(
                  child: Text(
                    'Card UID: ${widget.assignedCardUid}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_scanning)
            const Center(child: SchoolPulseLoader())
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (status != 'active')
                  FilledButton.icon(
                    onPressed: _assign,
                    icon: const Icon(Icons.nfc),
                    label: Text(
                      status == 'revoked'
                          ? 'Assign Replacement Card'
                          : 'Assign Card',
                    ),
                  ),
                if (status == 'active' && widget.assignedCardUid != null) ...[
                  OutlinedButton.icon(
                    onPressed: _replace,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Replace Card'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _revoke,
                    icon: const Icon(Icons.block),
                    label: const Text('Revoke Card'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
                if (status == 'revoked' && widget.assignedCardUid != null)
                  OutlinedButton.icon(
                    onPressed: _reactivate,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reactivate Card'),
                  ),
                if (widget.assignedCardUid != null)
                  TextButton.icon(
                    onPressed: () => _showCardHistory(context),
                    icon: const Icon(Icons.history),
                    label: const Text('View Card History'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _showCardHistory(BuildContext context) {
    // No dedicated card-history query/usecase exists yet on
    // StudentIdentityBloc/Repository - this surfaces what we do know
    // (current status + UID) until a history usecase is added.
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card History',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text('Current status: ${widget.identity.nfcStatus}'),
              if (widget.assignedCardUid != null)
                Text('Current card UID: ${widget.assignedCardUid}'),
              const SizedBox(height: 8),
              Text(
                'Full assignment/replace/revoke history is not yet exposed by the backend.',
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
