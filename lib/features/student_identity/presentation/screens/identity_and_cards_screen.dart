import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart' show SemanticColors;
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/injection_container.dart';

import '../../../student/domain/entities/student.dart';
import '../../domain/entities/student_identity.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';
import '../widgets/card_history_sheet.dart';
import '../widgets/nfc_scan_flow_mixin.dart';
import 'package:school_pulse/design_system/components/app_error_state.dart';

/// Combines the "School ID", "NFC card" and "QR credential" concerns into
/// one screen with three cards, matching the Identity & credentials
/// mockup. The NFC scanning flow is lifted from [StudentIdCardScreen]'s
/// `_NfcCardSection`, which already talks to the real Core NFC adapter
/// (`NfcCredentialReaderAdapter`) on physical iPhones. That screen remains
/// reachable separately (router path 'student-id-card') for the dedicated
/// print/preview flow; "Preview or print ID" / "View credential" here link
/// out to it rather than re-rendering a QR or ID card inline - this tab's
/// own summary must never show a raw credential value or a scannable QR
/// image.
class IdentityAndCardsScreen extends StatelessWidget {
  final Student student;
  final bool canMutate;

  const IdentityAndCardsScreen({
    super.key,
    required this.student,
    this.canMutate = true,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Identity & credentials')),
    body: IdentityAndCardsBody(student: student, canMutate: canMutate),
  );
}

/// The screen's content without its own [Scaffold], so the admin student
/// profile can host it as an Identity tab while the standalone route
/// ([IdentityAndCardsScreen]) keeps working unchanged. Both paths share this
/// one implementation - the bloc wiring, NFC flow and QR sections are not
/// duplicated.
///
/// Callers must provide a [StudentIdentityBloc] above this widget, exactly as
/// the standalone route already does. [canMutate] gates every issue/replace/
/// revoke/reactivate action - server (Cloud Functions) and Firestore rules
/// are the real enforcement boundary, this is defense-in-depth for any
/// future caller that reuses this widget for a non-staff viewer.
class IdentityAndCardsBody extends StatefulWidget {
  final Student student;
  final bool canMutate;

  const IdentityAndCardsBody({
    super.key,
    required this.student,
    this.canMutate = true,
  });

  @override
  State<IdentityAndCardsBody> createState() => _IdentityAndCardsBodyState();
}

class _IdentityAndCardsBodyState extends State<IdentityAndCardsBody> {
  bool? _isOnline;

  @override
  void initState() {
    super.initState();
    context.read<StudentIdentityBloc>().add(
      LoadStudentIdentityEvent(
        widget.student.id,
        schoolId: widget.student.schoolId,
      ),
    );
    sl<NetworkInfo>().isConnected.then((connected) {
      if (mounted) setState(() => _isOnline = connected);
    });
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
          return AppErrorState(
            message: state.message,
            onRetry: () => context.read<StudentIdentityBloc>().add(
              LoadStudentIdentityEvent(
                widget.student.id,
                schoolId: widget.student.schoolId,
              ),
            ),
          );
        }

        if (state is StudentIdentityLoaded) {
          return ResponsiveBuilder(
            builder: (context, layout) {
              final isDesktop = layout == ResponsiveLayout.desktop;
              final offline = _isOnline == false;

              final schoolIdCard = _SchoolIdCard(
                student: widget.student,
                identity: state.identity,
                canMutate: widget.canMutate && !offline,
              );
              final nfcCard = _NfcCard(
                student: widget.student,
                identity: state.identity,
                assignedCardUid: state.assignedCardUid,
                canMutate: widget.canMutate && !offline,
              );
              final qrCard = _QrCredentialCard(
                student: widget.student,
                identity: state.identity,
                canMutate: widget.canMutate && !offline,
              );

              final banner = offline
                  ? const _OfflineBanner()
                  : const SizedBox.shrink();

              if (isDesktop) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          banner,
                          if (offline) const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(children: [schoolIdCard]),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    nfcCard,
                                    const SizedBox(height: 16),
                                    qrCard,
                                  ],
                                ),
                              ),
                            ],
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
                    banner,
                    if (offline) const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Identity & credentials',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Manage the learner's school ID and access "
                              'credentials.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    schoolIdCard,
                    const SizedBox(height: 16),
                    nfcCard,
                    const SizedBox(height: 16),
                    qrCard,
                    const SizedBox(height: 12),
                    _HistoryPreservedNote(),
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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: scheme.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "You're offline — issuing, replacing and revoking "
              'credentials is unavailable until you reconnect.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPreservedNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Replacing or revoking a credential preserves its history.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// SCHOOL ID CARD
// ---------------------------------------------------------------------------
class _SchoolIdCard extends StatelessWidget {
  final Student student;
  final StudentIdentity identity;
  final bool canMutate;

  const _SchoolIdCard({
    required this.student,
    required this.identity,
    required this.canMutate,
  });

  bool get _issued => identity.qrCodeData.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.badge_outlined, color: scheme.onSurface),
              ),
              const SizedBox(width: 12),
              Text(
                'School ID',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusBadge(
            label: _issued ? 'ID card issued' : 'Not yet issued',
            color: _issued
                ? Theme.of(context).extension<SemanticColors>()!.success
                : scheme.onSurfaceVariant,
            icon: _issued
                ? Icons.check_circle_outline
                : Icons.remove_circle_outline,
          ),
          if (_issued && identity.issuedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last issued ${DateFormat('d MMM yyyy').format(identity.issuedAt!)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          if (_issued)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<StudentIdentityBloc>().add(
                    RecordIdentityPreviewedEvent(
                      studentId: student.id,
                      schoolId: student.schoolId,
                      kind: 'school_id',
                    ),
                  );
                  // Sibling route registered at lib/app/router.dart around
                  // 'student-id-card'. This widget is mounted as a sibling
                  // under the same parent by both call sites (the profile
                  // tab and the standalone Identity route), so a relative
                  // push resolves correctly.
                  context.push('student-id-card', extra: student);
                },
                icon: const Icon(Icons.badge_outlined),
                label: const Text('Preview or print ID'),
              ),
            )
          else if (canMutate)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.read<StudentIdentityBloc>().add(
                  GenerateStudentIdentityEvent(student),
                ),
                icon: const Icon(Icons.add_card_outlined),
                label: const Text('Issue ID'),
              ),
            )
          else
            Text(
              'No identity has been issued for this learner yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR CREDENTIAL CARD - never renders qrCodeData or a QrImageView.
// ---------------------------------------------------------------------------
class _QrCredentialCard extends StatelessWidget {
  final Student student;
  final StudentIdentity identity;
  final bool canMutate;

  const _QrCredentialCard({
    required this.student,
    required this.identity,
    required this.canMutate,
  });

  bool get _issued => identity.qrCodeData.isNotEmpty;
  bool get _active => identity.qrCredentialStatus == 'active';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.qr_code_2_rounded, color: scheme.onSurface),
              ),
              const SizedBox(width: 12),
              Text(
                'QR credential',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_issued)
            StatusBadge(
              label: _active ? 'Active' : 'Revoked',
              color: _active
                  ? Theme.of(context).extension<SemanticColors>()!.success
                  : Theme.of(context).extension<SemanticColors>()!.error,
              icon: _active ? Icons.check_circle_outline : Icons.block_outlined,
            )
          else
            StatusBadge(
              label: 'Not yet issued',
              color: scheme.onSurfaceVariant,
              icon: Icons.remove_circle_outline,
            ),
          const SizedBox(height: 8),
          Text(
            'Used for verified check-in and school services.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (_issued)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.read<StudentIdentityBloc>().add(
                      RecordIdentityPreviewedEvent(
                        studentId: student.id,
                        schoolId: student.schoolId,
                        kind: 'qr',
                      ),
                    );
                    context.push('student-id-card', extra: student);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View credential'),
                ),
                if (canMutate)
                  TextButton.icon(
                    onPressed: () => _confirmReplace(context),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Replace'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmReplace(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace QR credential?'),
        content: const Text(
          'The current QR code will stop working immediately and a new one '
          'will be issued. This cannot be undone, but the previous '
          "credential's history is preserved.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<StudentIdentityBloc>().add(
        RegenerateQrCredentialEvent(identity),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// NFC CARD - assign/replace/revoke/reactivate. The scan flow (adapter.start/
// stop against NfcCredentialReaderAdapter, listening for NfcScanCredential
// on the credentials stream) is the same real Core NFC adapter integration
// StudentIdCardScreen uses on physical iPhones. Replace/Revoke reason
// capture uses a modal bottom sheet, matching the rest of the app's
// convention (no shared bottom-sheet helper exists anywhere in
// lib/design_system or lib/core).
// ---------------------------------------------------------------------------
class _NfcCard extends StatefulWidget {
  final Student student;
  final StudentIdentity identity;
  final String? assignedCardUid;
  final bool canMutate;

  const _NfcCard({
    required this.student,
    required this.identity,
    required this.assignedCardUid,
    required this.canMutate,
  });

  @override
  State<_NfcCard> createState() => _NfcCardState();
}

class _NfcCardState extends State<_NfcCard> with NfcScanFlowMixin {
  Future<void> _assign() async {
    final uid = await scanCard(
      'Hold the card near the top edge of your physical iPhone until Apple confirms the scan.',
      schoolId: widget.student.schoolId,
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
    final reason = await pickReasonAndConfirm(actionLabel: 'Replace');
    if (reason == null || !mounted) return;
    final newUid = await scanCard(
      'Hold the replacement card near the top edge of your physical iPhone.',
      schoolId: widget.student.schoolId,
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
    final reason = await pickReasonAndConfirm(actionLabel: 'Revoke');
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

  void _showCardHistory(BuildContext context) {
    CardHistorySheet.show(
      context,
      studentId: widget.student.id,
      schoolId: widget.student.schoolId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.identity.nfcStatus;
    final scheme = Theme.of(context).colorScheme;
    final hasCard = widget.assignedCardUid != null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wifi_rounded, color: scheme.onSurface),
              ),
              const SizedBox(width: 12),
              Text(
                'NFC card',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusBadge(
            label: switch (status) {
              'active' => 'Active',
              'revoked' => 'Revoked',
              _ => 'No active card',
            },
            color: switch (status) {
              'active' => Theme.of(
                context,
              ).extension<SemanticColors>()!.success,
              'revoked' => Theme.of(context).extension<SemanticColors>()!.error,
              _ => scheme.onSurfaceVariant,
            },
            icon: switch (status) {
              'active' => Icons.check_circle_outline,
              'revoked' => Icons.block_outlined,
              _ => Icons.remove_circle_outline,
            },
          ),
          if (status == 'unassigned') ...[
            const SizedBox(height: 8),
            Text(
              'Assign a physical card for gate, library and attendance use.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          if (nfcScanning)
            const Center(child: SchoolPulseLoader())
          else if (widget.canMutate)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (status != 'active')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _assign,
                      icon: const Icon(Icons.nfc),
                      label: Text(
                        status == 'revoked'
                            ? 'Assign replacement card'
                            : 'Assign NFC card',
                      ),
                    ),
                  ),
                if (status == 'active' && hasCard) ...[
                  OutlinedButton.icon(
                    onPressed: _replace,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Replace'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _revoke,
                    icon: const Icon(Icons.block),
                    label: const Text('Revoke'),
                  ),
                ],
                if (status == 'revoked' && hasCard)
                  OutlinedButton.icon(
                    onPressed: _reactivate,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reactivate'),
                  ),
              ],
            ),
          if (hasCard) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _showCardHistory(context),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('View card history'),
            ),
          ],
        ],
      ),
    );
  }
}
