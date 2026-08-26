import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/design_system/app_theme.dart' show SemanticColors;
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/teacher/domain/entities/student_guardian_contact.dart';
import 'package:school_pulse/injection_container.dart';

import '../../../student/domain/entities/student.dart';
import '../../domain/entities/student_identity.dart';
import '../../domain/services/id_card_service.dart';
import '../../domain/services/primary_guardian_lookup_service.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';
import '../widgets/card_history_sheet.dart';
import '../widgets/nfc_scan_flow_mixin.dart';

/// Portrait Student ID Card preview - Front (photo/details) and Back
/// (QR + non-transferable notice), matching the school's branded template.
/// Monochrome (black/white/grey) throughout, no color.
class StudentIdCardScreen extends StatefulWidget {
  final Student student;

  const StudentIdCardScreen({super.key, required this.student});

  @override
  State<StudentIdCardScreen> createState() => _StudentIdCardScreenState();
}

class _StudentIdCardScreenState extends State<StudentIdCardScreen>
    with NfcScanFlowMixin {
  bool _showFront = true;
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
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Card'),
        actions: [
          BlocBuilder<StudentIdentityBloc, StudentIdentityState>(
            builder: (context, state) {
              final revoked =
                  state is StudentIdentityLoaded &&
                  state.identity.nfcStatus == 'revoked';
              final active = state is StudentIdentityLoaded && !revoked;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  active
                      ? Icons.verified_rounded
                      : (revoked ? Icons.block_rounded : null) ??
                            Icons.verified_outlined,
                  color: active
                      ? semantic.success
                      : (revoked
                            ? semantic.error
                            : Theme.of(context).colorScheme.onSurfaceVariant),
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
          if (state is StudentIdentityLoading ||
              state is StudentIdentityInitial) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is StudentIdentityError) {
            final denied = state.message.toLowerCase().contains(
              'permission',
            );
            return _MessageState(
              icon: denied
                  ? Icons.lock_outline_rounded
                  : Icons.error_outline_rounded,
              message: denied
                  ? 'You do not have permission to view this card.'
                  : state.message,
              actionLabel: denied ? null : 'Try Again',
              onAction: denied
                  ? null
                  : () => context.read<StudentIdentityBloc>().add(
                      LoadStudentIdentityEvent(
                        widget.student.id,
                        schoolId: widget.student.schoolId,
                      ),
                    ),
            );
          }

          if (state is StudentIdentityLoaded) {
            final identity = state.identity;
            final noCard = identity.qrCodeData.isEmpty;
            if (noCard) {
              return _MessageState(
                icon: Icons.badge_outlined,
                message: 'No identity has been issued for this learner yet.',
                actionLabel: 'Issue ID',
                onAction: () => context.read<StudentIdentityBloc>().add(
                  GenerateStudentIdentityEvent(widget.student),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isOnline == false) const _OfflineBanner(),
                  if (_isOnline == false) const SizedBox(height: 16),
                  _FrontBackSelector(
                    showFront: _showFront,
                    onChanged: (value) => setState(() => _showFront = value),
                  ),
                  const SizedBox(height: 18),
                  _IdCardPreview(
                    student: widget.student,
                    identity: identity,
                    showFront: _showFront,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _CardActionTile(
                        label: 'Download',
                        icon: Icons.download_outlined,
                        onPressed: _isOnline == false
                            ? null
                            : () => _downloadIdCard(context, identity),
                      ),
                      _CardActionTile(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onPressed: _isOnline == false
                            ? null
                            : () => _printIdCard(context, identity),
                      ),
                      _CardActionTile(
                        label: 'Replace',
                        icon: Icons.autorenew_rounded,
                        onPressed: _isOnline == false
                            ? null
                            : () => _handleReplace(
                                context,
                                identity,
                                state.assignedCardUid,
                              ),
                      ),
                      _CardActionTile(
                        label: 'Revoke',
                        icon: Icons.shield_outlined,
                        onPressed: _isOnline == false
                            ? null
                            : () => _handleRevoke(
                                context,
                                identity,
                                state.assignedCardUid,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _CardStatusPanel(
                    identity: identity,
                    onViewHistory: () => CardHistorySheet.show(
                      context,
                      studentId: widget.student.id,
                      schoolId: widget.student.schoolId,
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Export actions
  // ---------------------------------------------------------------------

  Future<void> _printIdCard(
    BuildContext context,
    StudentIdentity identity,
  ) async {
    context.read<StudentIdentityBloc>().add(
      RecordIdentityPreviewedEvent(
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
        kind: 'school_id_print',
      ),
    );
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

  Future<void> _downloadIdCard(
    BuildContext context,
    StudentIdentity identity,
  ) async {
    context.read<StudentIdentityBloc>().add(
      RecordIdentityPreviewedEvent(
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
        kind: 'school_id_download',
      ),
    );
    try {
      await GetIt.I<IdCardService>().shareIdCard(
        await _cardPdf(context, identity),
        '${widget.student.studentCode}_id_card.pdf',
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save ID card: $error')),
        );
      }
    }
  }

  Future<Uint8List> _cardPdf(BuildContext context, StudentIdentity identity) async {
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
    final profile = structure.institutionProfile;
    final schoolName = profile.displayName.isNotEmpty
        ? profile.displayName
        : 'School';

    final photoBytes = await _fetchImageBytes(widget.student.photoUrl);
    final logoBytes = await _fetchImageBytes(profile.logoUrl);

    return GetIt.I<IdCardService>().generateIdCardPdf(
      schoolName: schoolName,
      studentName: widget.student.name,
      admissionNumber: widget.student.admissionNumber,
      studentId: widget.student.studentCode,
      className: className,
      stream: stream,
      uniqueSystemId: identity.uniqueSystemId,
      academicYear: year,
      qrCodeData: identity.qrCodeData,
      schoolLogoBytes: logoBytes,
      studentPhotoBytes: photoBytes,
    );
  }

  Future<Uint8List?> _fetchImageBytes(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // Replace / Revoke
  // ---------------------------------------------------------------------

  Future<void> _handleReplace(
    BuildContext context,
    StudentIdentity identity,
    String? assignedCardUid,
  ) async {
    if (assignedCardUid == null) {
      // No NFC card on file - only the QR credential can be replaced.
      await _confirmReplaceQr(context, identity);
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_2_rounded),
              title: const Text('Replace QR credential'),
              subtitle: const Text('Issues a new QR code for this student'),
              onTap: () => Navigator.pop(sheetContext, 'qr'),
            ),
            ListTile(
              leading: const Icon(Icons.nfc),
              title: const Text('Replace NFC card'),
              subtitle: const Text('Scan a new physical card'),
              onTap: () => Navigator.pop(sheetContext, 'nfc'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    if (choice == 'qr') {
      await _confirmReplaceQr(context, identity);
    } else {
      await _replaceNfcCard(context, identity, assignedCardUid);
    }
  }

  Future<void> _confirmReplaceQr(
    BuildContext context,
    StudentIdentity identity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace QR credential?'),
        content: const Text(
          'The current QR code will stop working immediately and a new one '
          'will be issued. The previous credential\'s history is preserved.',
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

  Future<void> _replaceNfcCard(
    BuildContext context,
    StudentIdentity identity,
    String oldCardUid,
  ) async {
    final reason = await pickReasonAndConfirm(actionLabel: 'Replace');
    if (reason == null || !mounted) return;
    final newUid = await scanCard(
      'Hold the replacement card near the top edge of your physical iPhone.',
      schoolId: widget.student.schoolId,
    );
    if (newUid == null || !context.mounted) return;
    context.read<StudentIdentityBloc>().add(
      ReplaceNfcCardEvent(
        oldCardUid: oldCardUid,
        newCardUid: newUid,
        studentId: widget.student.id,
        uniqueSystemId: identity.uniqueSystemId,
        schoolId: widget.student.schoolId,
        reason: reason,
      ),
    );
  }

  Future<void> _handleRevoke(
    BuildContext context,
    StudentIdentity identity,
    String? assignedCardUid,
  ) async {
    if (assignedCardUid == null) {
      // No NFC card assigned - there is no standalone QR-revoke callable;
      // "revoking" the QR is achieved by replacing it (old one marked
      // 'replaced', immediately inactive).
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Revoke QR credential?'),
          content: const Text(
            'This student has no NFC card on file, so revoking invalidates '
            'the current QR code by issuing a new one - the old QR stops '
            'working immediately. This cannot be undone, but history is '
            'preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Revoke'),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        context.read<StudentIdentityBloc>().add(
          RegenerateQrCredentialEvent(identity),
        );
      }
      return;
    }

    final reason = await pickReasonAndConfirm(actionLabel: 'Revoke');
    if (reason == null || !context.mounted) return;
    context.read<StudentIdentityBloc>().add(
      RevokeNfcCardEvent(
        cardUid: assignedCardUid,
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
        reason: reason,
      ),
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
              "You're offline — print/download still work, but replacing or "
              'revoking a credential requires a connection.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrontBackSelector extends StatelessWidget {
  final bool showFront;
  final ValueChanged<bool> onChanged;
  const _FrontBackSelector({required this.showFront, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(context, 'Front', showFront, () => onChanged(true)),
          ),
          Expanded(
            child: _segment(context, 'Back', !showFront, () => onChanged(false)),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? scheme.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_rounded : Icons.crop_free_rounded,
              size: 16,
              color: selected ? scheme.surface : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.surface : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CARD PREVIEW
// ---------------------------------------------------------------------------
class _IdCardPreview extends StatefulWidget {
  const _IdCardPreview({
    required this.student,
    required this.identity,
    required this.showFront,
  });

  final Student student;
  final StudentIdentity identity;
  final bool showFront;

  @override
  State<_IdCardPreview> createState() => _IdCardPreviewState();
}

class _IdCardPreviewState extends State<_IdCardPreview> {
  late Future<StudentGuardianContact?> _guardianFuture;

  @override
  void initState() {
    super.initState();
    _guardianFuture = sl<PrimaryGuardianLookupService>()
        .getPrimaryGuardian(
          schoolId: widget.student.schoolId,
          studentId: widget.student.id,
        )
        .then((result) => result.fold((_) => null, (contact) => contact));
  }

  @override
  Widget build(BuildContext context) {
    final structure = context.watch<StructureBloc>().state;
    final profile = structure.institutionProfile;
    final schoolName = profile.displayName.isNotEmpty
        ? profile.displayName
        : 'School';
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: AspectRatio(
          aspectRatio: 0.62,
          child: widget.showFront
              ? FutureBuilder<StudentGuardianContact?>(
                  future: _guardianFuture,
                  builder: (context, snapshot) => _IdCardFront(
                    student: widget.student,
                    identity: widget.identity,
                    profile: profile,
                    schoolName: schoolName,
                    classAndStream: [
                      className,
                      stream,
                    ].where((item) => item.isNotEmpty).join(' · '),
                    academicYear: year,
                    guardianName: snapshot.data?.name,
                  ),
                )
              : _IdCardBack(
                  student: widget.student,
                  identity: widget.identity,
                  profile: profile,
                  schoolName: schoolName,
                ),
        ),
      ),
    );
  }
}

/// The card's own brand accent - a deep indigo, not pure black, so the
/// physical card reads as designed rather than a plain black-and-white
/// printout. Deliberately restrained (one hue, no gradients) per "add
/// colors if you want but nothing crazy."
const _cardAccent = Color(0xFF1B2A6B);
const _cardAccentSoft = Color(0xFFE9EBF7);

class _CardChrome extends StatelessWidget {
  final Widget headerContent;
  final Widget body;
  final String footerText;

  const _CardChrome({
    required this.headerContent,
    required this.body,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black12),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          width: double.infinity,
          color: _cardAccent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: headerContent,
        ),
        Container(width: double.infinity, height: 3, color: _cardAccentSoft),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: body,
          ),
        ),
        Container(
          width: double.infinity,
          color: _cardAccent,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            footerText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SchoolCrest extends StatelessWidget {
  final String? logoUrl;
  final double size;
  const _SchoolCrest({required this.logoUrl, this.size = 44});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: logoUrl?.isNotEmpty == true
        ? ClipOval(
            child: Image.network(
              logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => CustomPaint(painter: _CrestPainter()),
            ),
          )
        : CustomPaint(painter: _CrestPainter()),
  );
}

/// Simple monochrome line-art crest (open book + laurel), single black
/// stroke - no gradients, no color, matching the mockup's clean mark.
class _CrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;

    canvas.drawCircle(Offset(w / 2, h / 2), w / 2 - 1, stroke);

    final book = Path()
      ..moveTo(w * 0.28, h * 0.36)
      ..lineTo(w * 0.5, h * 0.3)
      ..lineTo(w * 0.72, h * 0.36)
      ..lineTo(w * 0.72, h * 0.62)
      ..lineTo(w * 0.5, h * 0.56)
      ..lineTo(w * 0.28, h * 0.62)
      ..close();
    canvas.drawPath(book, stroke);
    canvas.drawLine(
      Offset(w * 0.5, h * 0.3),
      Offset(w * 0.5, h * 0.56),
      stroke,
    );

    for (final side in [-1, 1]) {
      for (var i = 0; i < 2; i++) {
        final yBase = h * (0.68 + i * 0.1);
        final leaf = Path()
          ..moveTo(w * 0.5 + side * 2, yBase)
          ..quadraticBezierTo(
            w * 0.5 + side * (10 + i * 2),
            yBase + 3,
            w * 0.5 + side * (16 + i * 2),
            yBase - 2,
          );
        canvas.drawPath(leaf, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IdCardFront extends StatelessWidget {
  const _IdCardFront({
    required this.student,
    required this.identity,
    required this.profile,
    required this.schoolName,
    required this.classAndStream,
    required this.academicYear,
    required this.guardianName,
  });

  final Student student;
  final StudentIdentity identity;
  final InstitutionProfile profile;
  final String schoolName;
  final String classAndStream;
  final String academicYear;
  final String? guardianName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header band with crest + school name, and the photo overlapping
          // the seam below it - the classic ID-card composition, rather
          // than everything stacked in one flat column.
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_cardAccent, Color(0xFF2C3F8F)],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SchoolCrest(logoUrl: profile.logoUrl, size: 28),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            schoolName.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.motto.isNotEmpty
                          ? profile.motto
                          : 'Knowledge · Integrity · Service',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 58,
                child: _LearnerAvatar(photoUrl: student.photoUrl),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  student.name.isNotEmpty ? student.name : 'Unnamed learner',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (classAndStream.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _cardAccentSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      classAndStream,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _cardAccent,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _DataGrid(
                  rows: [
                    _DataCell(
                      icon: Icons.person_outline_rounded,
                      label: 'Student No.',
                      value: student.studentCode,
                    ),
                    _DataCell(
                      icon: Icons.badge_outlined,
                      label: 'Admission No.',
                      value: student.admissionNumber,
                    ),
                    _DataCell(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date of Birth',
                      value: DateFormat('d MMM yyyy').format(student.dateOfBirth),
                    ),
                    if (guardianName != null && guardianName!.isNotEmpty)
                      _DataCell(
                        icon: Icons.people_outline_rounded,
                        label: 'Guardian',
                        value: guardianName!,
                      ),
                    if (academicYear.isNotEmpty)
                      _DataCell(
                        icon: Icons.school_outlined,
                        label: 'Academic Year',
                        value: academicYear,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _NfcPill(active: identity.nfcStatus == 'active'),
                const SizedBox(height: 14),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: _cardAccent,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text(
              'Official student identity card',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCardBack extends StatelessWidget {
  const _IdCardBack({
    required this.student,
    required this.identity,
    required this.profile,
    required this.schoolName,
  });

  final Student student;
  final StudentIdentity identity;
  final InstitutionProfile profile;
  final String schoolName;

  @override
  Widget build(BuildContext context) => _CardChrome(
    footerText: 'NON-TRANSFERABLE',
    headerContent: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SchoolCrest(logoUrl: profile.logoUrl, size: 26),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            schoolName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
        ),
      ],
    ),
    body: Column(
      children: [
        const SizedBox(height: 6),
        Text(
          'Scan to verify learner',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _cardAccent,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _cardAccentSoft, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: identity.qrCodeData.isNotEmpty
              ? QrImageView(
                  data: identity.qrCodeData,
                  size: 148,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: _cardAccent,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                )
              : const SizedBox(
                  width: 148,
                  height: 148,
                  child: Icon(
                    Icons.qr_code_2_outlined,
                    size: 96,
                    color: Colors.black26,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _cardAccentSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            student.studentCode.isNotEmpty ? student.studentCode : '—',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _cardAccent,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'This card is non-transferable. Please return to $schoolName if found.',
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10.5, color: Colors.black54),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

class _LearnerAvatar extends StatelessWidget {
  const _LearnerAvatar({required this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) => Container(
    width: 84,
    height: 84,
    padding: const EdgeInsets.all(3),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
      ],
    ),
    child: ClipOval(
      child: photoUrl?.isNotEmpty == true
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _AvatarFallback(),
            )
          : const _AvatarFallback(),
    ),
  );
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();
  @override
  Widget build(BuildContext context) => Container(
    color: _cardAccentSoft,
    child: const Icon(Icons.person_rounded, size: 44, color: _cardAccent),
  );
}

/// Two-column grid of labeled facts, replacing the old single-column stack
/// so the card reads as a designed layout rather than a plain list -
/// mirrors how a real printed ID card groups fields.
class _DataGrid extends StatelessWidget {
  const _DataGrid({required this.rows});
  final List<_DataCell> rows;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1)
            const Divider(height: 14, color: Colors.black12),
        ],
      ],
    ),
  );
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: _cardAccentSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 13, color: _cardAccent),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: Colors.black45),
            ),
            Text(
              value.isNotEmpty ? value : '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: value.isNotEmpty ? Colors.black87 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _NfcPill extends StatelessWidget {
  const _NfcPill({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFE6F4EA) : const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(
          Icons.wifi_rounded,
          size: 15,
          color: active ? const Color(0xFF1E8E3E) : Colors.black45,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Tap for school use',
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF1E8E3E) : Colors.black45,
            ),
          ),
        ),
        Text(
          active ? 'NFC enabled' : 'NFC not set up',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF1E8E3E) : Colors.black45,
          ),
        ),
      ],
    ),
  );
}

class _CardActionTile extends StatelessWidget {
  const _CardActionTile({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final scheme = Theme.of(context).colorScheme;
    final color = enabled ? scheme.onSurface : scheme.onSurfaceVariant;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            side: BorderSide(
              color: enabled ? scheme.outline : scheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStatusPanel extends StatelessWidget {
  const _CardStatusPanel({required this.identity, required this.onViewHistory});

  final StudentIdentity identity;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final revoked =
        identity.nfcStatus == 'revoked' || identity.qrCredentialStatus == 'revoked';
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final statusColor = revoked ? semantic.error : semantic.success;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            revoked ? Icons.block_rounded : Icons.verified_user_outlined,
            color: statusColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  revoked ? 'Card revoked' : 'Card active',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (identity.issuedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Issued ${DateFormat('d MMM yyyy').format(identity.issuedAt!)}',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onViewHistory,
                  child: Text(
                    'View card history',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              border: Border.all(color: statusColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              revoked ? 'REVOKED' : 'ACTIVE',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
