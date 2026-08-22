import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/injection_container.dart';

import '../../../student/domain/entities/student.dart';
import '../../domain/entities/student_identity.dart';
import '../../domain/services/id_card_service.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';

class StudentIdCardScreen extends StatefulWidget {
  final Student student;

  const StudentIdCardScreen({super.key, required this.student});

  @override
  State<StudentIdCardScreen> createState() => _StudentIdCardScreenState();
}

class _StudentIdCardScreenState extends State<StudentIdCardScreen> {
  bool _showFront = true;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Card'),
        actions: [
          BlocBuilder<StudentIdentityBloc, StudentIdentityState>(
            builder: (context, state) {
              final blocked =
                  state is StudentIdentityLoaded &&
                  state.identity.nfcStatus == 'revoked';
              final active = state is StudentIdentityLoaded && !blocked;
              return IconButton(
                tooltip: active ? 'Card active' : 'Card unavailable',
                onPressed: null,
                icon: Icon(
                  blocked ? Icons.block_rounded : Icons.verified_rounded,
                  color: active
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<StudentIdentityBloc, StudentIdentityState>(
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
          if (state is StudentIdentityLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is StudentIdentityLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.badge_outlined),
                        label: Text('Front'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.qr_code_2_outlined),
                        label: Text('Back'),
                      ),
                    ],
                    selected: {_showFront},
                    onSelectionChanged: (values) =>
                        setState(() => _showFront = values.first),
                  ),
                  const SizedBox(height: 18),
                  _IdCardPreview(
                    student: widget.student,
                    identity: state.identity,
                    showFront: _showFront,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CardActionIcon(
                        tooltip: 'Download ID card',
                        icon: Icons.download_outlined,
                        onPressed: () => _shareIdCard(context, state.identity),
                      ),
                      _CardActionIcon(
                        tooltip: 'Share ID card',
                        icon: Icons.share_outlined,
                        onPressed: () => _shareIdCard(context, state.identity),
                      ),
                      _CardActionIcon(
                        tooltip: 'Print ID card',
                        icon: Icons.print_outlined,
                        onPressed: () => _printIdCard(context, state.identity),
                      ),
                      _CardActionIcon(
                        tooltip: 'Replace card',
                        icon: Icons.badge_outlined,
                        onPressed: () => context
                            .read<StudentIdentityBloc>()
                            .add(RegenerateQrCredentialEvent(state.identity)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _QrCredentialSection(identity: state.identity),
                  const SizedBox(height: 20),
                  _NfcCardSection(
                    student: widget.student,
                    identity: state.identity,
                    assignedCardUid: state.assignedCardUid,
                  ),
                ],
              ),
            );
          }

          if (state is StudentIdentityError) {
            return _IdentityErrorState(
              message: state.message,
              onRetry: () => context.read<StudentIdentityBloc>().add(
                GenerateStudentIdentityEvent(widget.student),
              ),
            );
          }

          return Center(
            child: FilledButton.icon(
              onPressed: () => context.read<StudentIdentityBloc>().add(
                GenerateStudentIdentityEvent(widget.student),
              ),
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Generate Student ID'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _printIdCard(
    BuildContext context,
    StudentIdentity identity,
  ) async {
    try {
      await GetIt.I<IdCardService>().printIdCard(
        await _cardPdf(context, identity),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print ID card: $error')),
      );
    }
  }

  Future<void> _shareIdCard(
    BuildContext context,
    StudentIdentity identity,
  ) async {
    try {
      await GetIt.I<IdCardService>().shareIdCard(
        await _cardPdf(context, identity),
        '${widget.student.studentCode}_id_card.pdf',
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share ID card: $error')),
        );
      }
    }
  }

  Future<Uint8List> _cardPdf(BuildContext context, StudentIdentity identity) {
    final structure = context.read<StructureBloc>().state;
    final className =
        structure.classes
            .where((item) => item.id == widget.student.classId)
            .firstOrNull
            ?.name ??
        '';
    final stream =
        structure.streams
            .where((item) => item.id == widget.student.streamId)
            .firstOrNull
            ?.name ??
        '';
    final year =
        structure.academicYears
            .where((item) => item.id == widget.student.academicYearId)
            .firstOrNull
            ?.name ??
        '';
    final branding = context.read<ThemeProvider>().branding;
    final schoolName = branding?.schoolName.isNotEmpty == true
        ? branding!.schoolName
        : (context.read<ThemeProvider>().config?.schoolName ?? 'School');
    return GetIt.I<IdCardService>().generateIdCardPdf(
      schoolName: schoolName,
      studentName: widget.student.name,
      admissionNumber: widget.student.admissionNumber,
      studentId: widget.student.studentCode,
      className: className,
      stream: stream,
      uniqueSystemId: '',
      academicYear: year,
      qrCodeData: identity.qrCodeData,
    );
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

class _IdCardPreview extends StatelessWidget {
  const _IdCardPreview({
    required this.student,
    required this.identity,
    required this.showFront,
  });

  final Student student;
  final StudentIdentity identity;
  final bool showFront;

  @override
  Widget build(BuildContext context) {
    final structure = context.watch<StructureBloc>().state;
    final profile = structure.institutionProfile;
    final branding = context.watch<ThemeProvider>().branding;
    final schoolName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (branding?.schoolName.isNotEmpty == true
              ? branding!.schoolName
              : (context.watch<ThemeProvider>().config?.schoolName ??
                    'School'));
    final className =
        structure.classes
            .where((item) => item.id == student.classId)
            .firstOrNull
            ?.name ??
        'Class unavailable';
    final stream =
        structure.streams
            .where((item) => item.id == student.streamId)
            .firstOrNull
            ?.name ??
        '';
    final year =
        structure.academicYears
            .where((item) => item.id == student.academicYearId)
            .firstOrNull
            ?.name ??
        '';
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AspectRatio(
          aspectRatio: .68,
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer,
                    scheme.surfaceContainerHigh,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (profile.logoUrl.isNotEmpty ||
                          branding?.logoUrl?.isNotEmpty == true) ...[
                        CircleAvatar(
                          radius: 17,
                          backgroundImage: NetworkImage(
                            profile.logoUrl.isNotEmpty
                                ? profile.logoUrl
                                : branding!.logoUrl!,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          schoolName.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (profile.motto.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        profile.motto,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (showFront) ...[
                    CircleAvatar(
                      radius: 42,
                      backgroundImage: student.photoUrl?.isNotEmpty == true
                          ? NetworkImage(student.photoUrl!)
                          : null,
                      child: student.photoUrl?.isNotEmpty == true
                          ? null
                          : const Icon(Icons.person, size: 44),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      [
                        className,
                        stream,
                      ].where((item) => item.isNotEmpty).join(' • '),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _PreviewRow('Student Code', student.studentCode),
                    _PreviewRow('Admission No.', student.admissionNumber),
                    if (year.isNotEmpty) _PreviewRow('Academic Year', year),
                    const Spacer(),
                    Text(
                      'Official student identity card',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Scan to verify student',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (identity.qrCodeData.isNotEmpty)
                      QrImageView(
                        data: identity.qrCodeData,
                        version: QrVersions.auto,
                        size: 164,
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Icon(Icons.qr_code_2_outlined, size: 96),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      'Keep this card with you. It is non-transferable and remains the property of $schoolName.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('IDENTITY VERIFIED')),
                        Chip(label: Text('AUTHORIZED ACCESS')),
                        Chip(label: Text('NON-TRANSFERABLE')),
                      ],
                    ),
                    if (profile.phone.isNotEmpty || profile.email.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          [
                            profile.phone,
                            profile.email,
                          ].where((item) => item.isNotEmpty).join(' • '),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const Spacer(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _CardActionIcon extends StatelessWidget {
  const _CardActionIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: IconButton.filledTonal(onPressed: onPressed, icon: Icon(icon)),
  );
}

class _QrCredentialSection extends StatelessWidget {
  const _QrCredentialSection({required this.identity});
  final StudentIdentity identity;
  @override
  Widget build(BuildContext context) {
    final active = identity.qrCodeData.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_2_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'QR Credential',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text(active ? 'ACTIVE' : 'UNAVAILABLE')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              active
                  ? 'A secure signed credential is encoded in the QR code.'
                  : 'No QR credential has been issued for this student.',
            ),
            if (active) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.read<StudentIdentityBloc>().add(
                  RegenerateQrCredentialEvent(identity),
                ),
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Replace QR'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NfcCardSection extends StatefulWidget {
  const _NfcCardSection({
    required this.student,
    required this.identity,
    required this.assignedCardUid,
  });

  final Student student;
  final StudentIdentity identity;
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
          schoolId: widget.student.schoolId,
        ),
        operatorUser: auth.user,
        purpose: 'student_identity.nfc_assign',
        deviceId: 'app',
        requestedAt: DateTime.now(),
      );

      // On a physical iPhone this starts Apple's native Core NFC sheet.
      // We deliberately do not put a Flutter AlertDialog on top of it.
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

  Future<String?> _pickReason() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Reason'),
        children: [
          for (final reason in const ['Lost', 'Stolen', 'Damaged', 'Other'])
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, reason.toLowerCase()),
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
              : 'Assign a physical NFC card to this student. iOS will show its native NFC scan sheet.',
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
