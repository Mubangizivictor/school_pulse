import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/domain/entities/staff_identity.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/staff_id_card_service.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/staff_identity_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/staff_identity_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/staff_identity_state.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/injection_container.dart';

class StaffIdCardScreen extends StatefulWidget {
  final UserEntity staff;

  const StaffIdCardScreen({super.key, required this.staff});

  @override
  State<StaffIdCardScreen> createState() => _StaffIdCardScreenState();
}

class _StaffIdCardScreenState extends State<StaffIdCardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffIdentityBloc>().add(
      LoadStaffIdentityEvent(widget.staff.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff ID Card')),
      body: BlocConsumer<StaffIdentityBloc, StaffIdentityState>(
        listener: (context, state) {
          if (state is StaffIdentityActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is StaffIdentityError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is StaffIdentityLoading || state is StaffIdentityInitial) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is StaffIdentityLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _IdCardPreview(staff: widget.staff, identity: state.identity),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _printIdCard(context, state.identity),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Print ID Card'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.read<StaffIdentityBloc>().add(
                          RegenerateStaffQrCredentialEvent(state.identity),
                        ),
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Replace QR'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
                  _NfcCardSection(
                    staff: widget.staff,
                    identity: state.identity,
                    assignedCardUid: state.assignedCardUid,
                  ),
                ],
              ),
            );
          }

          if (state is StaffIdentityError) {
            return _IdentityErrorState(
              message: state.message,
              onRetry: () => context.read<StaffIdentityBloc>().add(
                LoadStaffIdentityEvent(widget.staff.id),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _printIdCard(
    BuildContext context,
    StaffIdentity identity,
  ) async {
    final idCardService = GetIt.I<StaffIdCardService>();
    final schoolName =
        context.read<ThemeProvider>().config?.schoolName ??
        'School Pulse Academy';
    try {
      final pdfData = await idCardService.generateStaffIdCardPdf(
        schoolName: schoolName,
        staffName: widget.staff.name,
        staffCode: widget.staff.staffCode ?? identity.uniqueSystemId,
        roleLabel: widget.staff.roles.isEmpty
            ? '—'
            : UserRoleDisplay.name(widget.staff.roles.first),
        qrData: identity.qrCodeData.isNotEmpty
            ? identity.qrCodeData
            : identity.uniqueSystemId,
      );
      await idCardService.printIdCard(pdfData);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to print ID card: $error')));
    }
  }
}

class _IdentityErrorState extends StatelessWidget {
  const _IdentityErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

/// Front + back of the card, matching the two-sided student ID card layout:
/// front carries the photo/name/role identity, back carries the QR and
/// authenticity/return-if-found footer. Shown side by side in a scrollable
/// row instead of stacked, since a physical card has both sides at once.
class _IdCardPreview extends StatelessWidget {
  const _IdCardPreview({required this.staff, required this.identity});

  final UserEntity staff;
  final StaffIdentity identity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardFront(staff: staff),
          const SizedBox(width: 16),
          _CardBack(staff: staff, identity: identity),
        ],
      ),
    );
  }
}

const _cardWidth = 240.0;
const _cardHeight = 380.0;

class _CardFront extends StatelessWidget {
  const _CardFront({required this.staff});
  final UserEntity staff;

  @override
  Widget build(BuildContext context) {
    final schoolName =
        context.watch<ThemeProvider>().config?.schoolName ??
        'SCHOOL PULSE ACADEMY';
    final scheme = Theme.of(context).colorScheme;
    final roleLabel = staff.roles.isEmpty
        ? '—'
        : UserRoleDisplay.name(staff.roles.first);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: _cardWidth,
        height: _cardHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: scheme.primary,
              child: Column(
                children: [
                  Text(
                    schoolName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'STAFF',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: Colors.amber.shade400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            CircleAvatar(
              radius: 44,
              backgroundImage: staff.photoUrl?.isNotEmpty == true
                  ? NetworkImage(staff.photoUrl!)
                  : null,
              child: staff.photoUrl?.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person, size: 42),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                staff.name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Text(roleLabel, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            if (staff.staffCode != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  staff.staffCode!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.staff, required this.identity});
  final UserEntity staff;
  final StaffIdentity identity;

  @override
  Widget build(BuildContext context) {
    final schoolName =
        context.watch<ThemeProvider>().config?.schoolName ??
        'SCHOOL PULSE ACADEMY';
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: _cardWidth,
        height: _cardHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: scheme.primary,
              child: Text(
                'STAFF ID CARD',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: identity.qrCodeData.isNotEmpty
                  ? identity.qrCodeData
                  : identity.uniqueSystemId,
              version: QrVersions.auto,
              size: 132,
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'THIS CARD IS THE PROPERTY OF $schoolName',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BackBadge(
                  icon: Icons.verified_user_outlined,
                  label: 'Identity\nVerified',
                ),
                _BackBadge(
                  icon: Icons.lock_outline,
                  label: 'Non-\nTransferable',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'If found, please return to the school office.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BackBadge extends StatelessWidget {
  const _BackBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: scheme.primary),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _NfcCardSection extends StatefulWidget {
  const _NfcCardSection({
    required this.staff,
    required this.identity,
    required this.assignedCardUid,
  });

  final UserEntity staff;
  final StaffIdentity identity;
  final String? assignedCardUid;

  @override
  State<_NfcCardSection> createState() => _NfcCardSectionState();
}

class _NfcCardSectionState extends State<_NfcCardSection> {
  bool _scanning = false;

  Future<String?> _scanCard(String promptMessage) async {
    if (_scanning) return null;

    final adapter = sl<NfcCredentialReaderAdapter>();
    StreamSubscription<ScanCredential>? subscription;
    final completer = Completer<String?>();

    try {
      final available = await adapter.isAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'NFC is unavailable. NFC card scanning must be tested on a physical NFC-capable iPhone, not the iOS Simulator.',
              ),
            ),
          );
        }
        return null;
      }

      final auth = context.read<AuthBloc>().state;
      if (auth is! AuthAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session is not ready. Sign in again and retry.'),
            ),
          );
        }
        return null;
      }

      if (mounted) {
        setState(() => _scanning = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(promptMessage), duration: const Duration(seconds: 4)),
        );
      }

      subscription = adapter.credentials.listen(
        (credential) {
          if (credential is NfcScanCredential && !completer.isCompleted) {
            completer.complete(credential.cardUid);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) completer.completeError(error, stackTrace);
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
          schoolId: widget.staff.schoolId,
        ),
        operatorUser: auth.user,
        purpose: 'staff_identity.nfc_assign',
        deviceId: 'app',
        requestedAt: DateTime.now(),
      );

      // On a physical iPhone this starts Apple's native Core NFC sheet.
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not start NFC scan: $error')));
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

  Future<String?> _pickReason() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Reason'),
        children: [
          for (final reason in const ['Lost', 'Stolen', 'Damaged', 'Other'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, reason.toLowerCase()),
              child: Text(reason),
            ),
        ],
      ),
    );
  }

  Future<void> _assign() async {
    final uid = await _scanCard(
      'Hold the card near the top edge of your physical iPhone until Apple confirms the scan.',
    );
    if (uid == null || !mounted) return;
    context.read<StaffIdentityBloc>().add(
      AssignStaffNfcCardEvent(
        cardUid: uid,
        staffId: widget.staff.id,
        schoolId: widget.staff.schoolId,
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
    context.read<StaffIdentityBloc>().add(
      ReplaceStaffNfcCardEvent(
        oldCardUid: oldUid,
        newCardUid: newUid,
        staffId: widget.staff.id,
        schoolId: widget.staff.schoolId,
        reason: reason,
      ),
    );
  }

  Future<void> _revoke() async {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    context.read<StaffIdentityBloc>().add(
      RevokeStaffNfcCardEvent(
        cardUid: uid,
        staffId: widget.staff.id,
        schoolId: widget.staff.schoolId,
        reason: reason,
      ),
    );
  }

  void _reactivate() {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    context.read<StaffIdentityBloc>().add(
      ReactivateStaffNfcCardEvent(
        cardUid: uid,
        staffId: widget.staff.id,
        schoolId: widget.staff.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.identity.nfcStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'NFC Card',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 10),
            Chip(label: Text(status.toUpperCase())),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _scanning
              ? 'Waiting for a physical NFC card…'
              : 'Assign a physical NFC card to this staff member. iOS will show its native NFC scan sheet.',
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
                    status == 'revoked' ? 'Assign Replacement Card' : 'Assign Card',
                  ),
                ),
              if (status == 'active' && widget.assignedCardUid != null) ...[
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
              if (status == 'revoked' && widget.assignedCardUid != null)
                OutlinedButton.icon(
                  onPressed: _reactivate,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reactivate Same Card'),
                ),
            ],
          ),
      ],
    );
  }
}
