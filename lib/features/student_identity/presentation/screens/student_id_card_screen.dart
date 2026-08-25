import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';

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
                      ? Colors.black
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
                        icon: Icon(Icons.badge_outlined),
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
                    children: [
                      _CardActionTile(
                        label: 'Download',
                        icon: Icons.download_outlined,
                        color: Colors.black,
                        onPressed: () => _shareIdCard(context, state.identity),
                      ),
                      _CardActionTile(
                        label: 'Share',
                        icon: Icons.share_outlined,
                        color: Colors.black,
                        onPressed: () => _shareIdCard(context, state.identity),
                      ),
                      _CardActionTile(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        color: Colors.black,
                        onPressed: () => _printIdCard(context, state.identity),
                      ),
                      _CardActionTile(
                        label: 'Replace',
                        icon: Icons.badge_outlined,
                        color: Colors.black,
                        onPressed: () => _confirmCardAction(
                          context,
                          title: 'Replace this card?',
                          onConfirm: () => context
                              .read<StudentIdentityBloc>()
                              .add(RegenerateQrCredentialEvent(state.identity)),
                        ),
                      ),
                      _CardActionTile(
                        label: 'Revoke',
                        icon: Icons.shield_outlined,
                        color: Colors.black,
                        onPressed: () => _confirmCardAction(
                          context,
                          title: 'Revoke this card?',
                          onConfirm: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Card revocation requested.'),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _CardStatusPanel(),
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

  Future<void> _confirmCardAction(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Confirm'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) onConfirm();
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
    final logoUrl = profile.logoUrl.isNotEmpty
        ? profile.logoUrl
        : branding?.logoUrl;
    final contact = [
      profile.phone,
      profile.email,
    ].where((item) => item.isNotEmpty).join('  •  ');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: AspectRatio(
          aspectRatio: 540 / 856,
          child: showFront
              ? _MetallicStudentIdFront(
                  student: student,
                  schoolName: schoolName,
                  motto: profile.motto.isNotEmpty
                      ? profile.motto
                      : 'Knowledge  •  Integrity  •  Service',
                  logoUrl: logoUrl,
                  classAndStream: [
                    className,
                    stream,
                  ].where((item) => item.isNotEmpty).join(' • '),
                  academicYear: year,
                )
              : _MetallicStudentIdBack(
                  schoolName: schoolName,
                  logoUrl: logoUrl,
                  contact: contact,
                  qrCodeData: identity.qrCodeData,
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PALETTE — matches the Victor High School reference design exactly.
// ---------------------------------------------------------------------------
const _navy = Colors.black;
const _teal = Colors.black;
const _gold = Colors.black;
const _goldBright = Colors.black;
const _ivory = Colors.black;

const _cardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_navy, _teal],
);

class _MetallicStudentIdFront extends StatelessWidget {
  const _MetallicStudentIdFront({
    required this.student,
    required this.schoolName,
    required this.motto,
    required this.logoUrl,
    required this.classAndStream,
    required this.academicYear,
  });

  final Student student;
  final String schoolName;
  final String motto;
  final String? logoUrl;
  final String classAndStream;
  final String academicYear;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      children: [
        _Crest(logoUrl: logoUrl, size: 48),
        const SizedBox(height: 8),
        Text(
          schoolName.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.playfairDisplay(
            color: _goldBright,
            fontSize: 17,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          motto,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cormorant(
            color: _ivory,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        _Avatar(photoUrl: student.photoUrl),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                student.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  color: _goldBright,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                ),
              ),
            ),
            if (classAndStream.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _gold),
                ),
                child: Text(
                  classAndStream,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _goldBright,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _DetailRow(
          icon: Icons.badge_outlined,
          label: 'Student Code',
          value: student.studentCode,
        ),
        _divider(),
        _DetailRow(
          icon: Icons.description_outlined,
          label: 'Admission No.',
          value: student.admissionNumber,
        ),
        _divider(),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          label: 'Academic Year',
          value: academicYear,
        ),
        const Spacer(),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Official Student Identity Card',
              style: GoogleFonts.cormorant(
                color: _ivory,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _SealBadge(initials: _initialsOf(schoolName)),
            ),
          ],
        ),
      ],
    ),
  );

  static Widget _divider() => Container(height: 1, color: _ivory);
}

class _MetallicStudentIdBack extends StatelessWidget {
  const _MetallicStudentIdBack({
    required this.schoolName,
    required this.logoUrl,
    required this.contact,
    required this.qrCodeData,
  });

  final String schoolName;
  final String? logoUrl;
  final String contact;
  final String qrCodeData;

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      children: [
        Row(
          children: [
            _Crest(logoUrl: logoUrl, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schoolName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  color: _goldBright,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: _gold),
        const SizedBox(height: 14),
        Text(
          'Scan to Verify Student',
          style: GoogleFonts.inter(
            color: _goldBright,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold, width: 1.6),
          ),
          child: qrCodeData.isNotEmpty
              ? QrImageView(
                  data: qrCodeData,
                  size: 140,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: _navy,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: _navy,
                  ),
                )
              : const SizedBox(
                  width: 140,
                  height: 140,
                  child: Icon(Icons.qr_code_2_outlined, size: 96, color: _navy),
                ),
        ),
        const SizedBox(height: 14),
        Text(
          'Keep this card with you. It is non-transferable and remains the property of $schoolName',
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: _ivory, fontSize: 10.5, height: 1.4),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatusPill(
              icon: Icons.check_circle_outline,
              label: 'Identity\nVerified',
            ),
            const SizedBox(width: 10),
            _StatusPill(
              icon: Icons.vpn_key_outlined,
              label: 'Authorized\nAccess',
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (contact.isNotEmpty)
          Text(
            contact,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: _ivory, fontSize: 10),
          ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: const BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            'NON-TRANSFERABLE',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _navy,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// SHARED: card shell with gradient + gold double-line frame + circuit tracery
// ---------------------------------------------------------------------------
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: _cardGradient,
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _CircuitPainter())),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _gold, width: 1.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: _gold, width: .8),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          child: child,
        ),
      ],
    ),
  );
}

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gold
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final nodePaint = Paint()..color = _gold;

    void corner(Offset origin, bool flipX, bool flipY) {
      final sx = flipX ? -1.0 : 1.0;
      final sy = flipY ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(origin.dx, origin.dy + 40 * sy)
        ..lineTo(origin.dx, origin.dy + 12 * sy)
        ..lineTo(origin.dx + 12 * sx, origin.dy)
        ..lineTo(origin.dx + 40 * sx, origin.dy);
      canvas.drawPath(path, paint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(origin.dx + 40 * sx, origin.dy),
          width: 5,
          height: 5,
        ),
        nodePaint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(origin.dx, origin.dy + 40 * sy),
          width: 5,
          height: 5,
        ),
        nodePaint,
      );
    }

    corner(const Offset(18, 18), false, false);
    corner(Offset(size.width - 18, 18), true, false);
    corner(Offset(18, size.height - 18), false, true);
    corner(Offset(size.width - 18, size.height - 18), true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// CREST — shield containing a torch, flanked by laurel leaves (line-art gold)
// ---------------------------------------------------------------------------
class _Crest extends StatelessWidget {
  const _Crest({required this.logoUrl, required this.size});
  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: logoUrl?.isNotEmpty == true
        ? ClipOval(child: Image.network(logoUrl!, fit: BoxFit.cover))
        : CustomPaint(painter: _CrestPainter()),
  );
}

class _CrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = _goldBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final w = size.width, h = size.height;

    final shield = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.82, h * 0.2)
      ..lineTo(w * 0.82, h * 0.55)
      ..cubicTo(w * 0.82, h * 0.8, w * 0.65, h * 0.92, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.35, h * 0.92, w * 0.18, h * 0.8, w * 0.18, h * 0.55)
      ..lineTo(w * 0.18, h * 0.2)
      ..close();
    canvas.drawPath(shield, gold);

    final torch = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..quadraticBezierTo(w * 0.58, h * 0.3, w * 0.5, h * 0.4)
      ..quadraticBezierTo(w * 0.42, h * 0.3, w * 0.5, h * 0.22)
      ..moveTo(w * 0.5, h * 0.4)
      ..lineTo(w * 0.5, h * 0.75);
    canvas.drawPath(torch, gold);

    for (final side in [-1, 1]) {
      for (var i = 0; i < 3; i++) {
        final yBase = h * (0.45 + i * 0.13);
        final leaf = Path()
          ..moveTo(w * 0.5 + side * 2, yBase)
          ..quadraticBezierTo(
            w * 0.5 + side * (14 + i * 2),
            yBase + 4,
            w * 0.5 + side * (22 + i * 2),
            yBase - 3,
          );
        canvas.drawPath(leaf, gold);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _initialsOf(String schoolName) {
  final words = schoolName
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  final initials = words.map((word) => word[0].toUpperCase()).join();
  return initials.isEmpty
      ? 'S'
      : (initials.length > 4 ? initials.substring(0, 4) : initials);
}

class _SealBadge extends StatelessWidget {
  const _SealBadge({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [Colors.black, Colors.black]),
      border: Border.fromBorderSide(BorderSide(color: Colors.white)),
    ),
    child: Center(
      child: Text(
        initials,
        style: GoogleFonts.playfairDisplay(
          color: _navy,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) => Container(
    width: 118,
    height: 118,
    padding: const EdgeInsets.all(4),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      border: Border.fromBorderSide(BorderSide(color: _gold, width: 2)),
    ),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold, width: 1),
        gradient: const LinearGradient(
          colors: [Colors.black, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: photoUrl?.isNotEmpty == true
            ? Image.network(photoUrl!, fit: BoxFit.cover)
            : const Icon(Icons.person_rounded, size: 54, color: Colors.white),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: _gold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: _ivory,
                  fontSize: 9.5,
                  letterSpacing: .4,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _ivory,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _gold,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _gold),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _goldBright),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: _ivory,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            height: 1.2,
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
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          side: BorderSide(color: Colors.white),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
}

class _CardStatusPanel extends StatelessWidget {
  const _CardStatusPanel();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white),
    ),
    child: Row(
      children: [
        const Icon(Icons.verified_user_outlined, color: Colors.black, size: 32),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('Issued on 12 May 2026', style: TextStyle(fontSize: 12)),
              SizedBox(height: 4),
              Text('Issued by Admin User', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ACTIVE',
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
