import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
                        color: Colors.lightBlueAccent,
                        onPressed: () => _shareIdCard(context, state.identity),
                      ),
                      _CardActionTile(
                        label: 'Share',
                        icon: Icons.share_outlined,
                        color: Colors.greenAccent,
                        onPressed: () => _shareIdCard(context, state.identity),
                      ),
                      _CardActionTile(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        color: Colors.deepPurpleAccent,
                        onPressed: () => _printIdCard(context, state.identity),
                      ),
                      _CardActionTile(
                        label: 'Replace',
                        icon: Icons.badge_outlined,
                        color: Colors.amberAccent,
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
                        color: Colors.redAccent,
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
        constraints: const BoxConstraints(maxWidth: 360),
        child: AspectRatio(
          aspectRatio: .68,
          child: showFront
              ? _MetallicStudentIdFront(
                  student: student,
                  schoolName: schoolName,
                  motto: profile.motto,
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

const _metallicCardBackground = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(24)),
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF102330), Color(0xFF0D1B24), Color(0xFF071017)],
    stops: [0, .5, 1],
  ),
  boxShadow: [
    BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
  ],
);

const _metallicGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFDFBA6B),
    Color(0xFF9E7D3B),
    Color(0xFFFCE7B2),
    Color(0xFF876527),
    Color(0xFFE8CA82),
  ],
  stops: [0, .25, .5, .75, 1],
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
  Widget build(BuildContext context) => _MetallicCardFrame(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        children: [
          _MetallicCrest(logoUrl: logoUrl, size: 47),
          const SizedBox(height: 7),
          Text(
            schoolName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF0D98C),
              fontSize: 17,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
          if (motto.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              motto,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 18),
          _MetallicAvatar(photoUrl: student.photoUrl),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => _metallicGoldGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              student.name.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.25,
              ),
            ),
          ),
          if (classAndStream.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              classAndStream,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          const SizedBox(height: 13),
          Expanded(
            child: _MetallicDetailPanel(
              studentCode: student.studentCode,
              admissionNumber: student.admissionNumber,
              academicYear: academicYear,
            ),
          ),
          const SizedBox(height: 5),
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Official Student Identity Card',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _MetallicSealBadge(initials: _initialsOf(schoolName)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => _MetallicCardFrame(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        children: [
          Row(
            children: [
              _MetallicCrest(logoUrl: logoUrl, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schoolName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF0D98C),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: const Color(0xFFD4AF37).withValues(alpha: .35),
          ),
          const SizedBox(height: 14),
          const Text(
            'Scan to Verify Student',
            style: TextStyle(
              color: Color(0xFFF0D98C),
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
              border: const Border.fromBorderSide(
                BorderSide(color: Color(0xFFD4AF37), width: 1.6),
              ),
            ),
            child: qrCodeData.isNotEmpty
                ? QrImageView(
                    data: qrCodeData,
                    size: 140,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0B1B3A),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0B1B3A),
                    ),
                  )
                : const SizedBox(
                    width: 140,
                    height: 140,
                    child: Icon(
                      Icons.qr_code_2_outlined,
                      size: 96,
                      color: Color(0xFF0B1B3A),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            'Keep this card with you. It is non-transferable and remains the property of $schoolName.',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MetallicStatusPill(
                icon: Icons.check_circle_outline,
                text: 'Identity\nVerified',
              ),
              SizedBox(width: 10),
              _MetallicStatusPill(
                icon: Icons.vpn_key_outlined,
                text: 'Authorized\nAccess',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (contact.isNotEmpty)
            Text(
              contact,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: _metallicGoldGradient,
            ),
            child: const Text(
              'NON-TRANSFERABLE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0D1B24),
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MetallicCardFrame extends StatelessWidget {
  const _MetallicCardFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: _metallicCardBackground,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _CircuitTraceryPainter()),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: .55),
                width: 1.4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: CustomPaint(
                painter: _GradientBorderPainter(
                  gradient: _metallicGoldGradient,
                  strokeWidth: 1.25,
                  radius: 11,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class _CircuitTraceryPainter extends CustomPainter {
  const _CircuitTraceryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final trace = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: .34)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final node = Paint()
      ..color = const Color(0xFFF0D98C).withValues(alpha: .42)
      ..style = PaintingStyle.fill;

    void corner(Offset origin, double x, double y) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + 60 * y)
        ..lineTo(origin.dx, origin.dy + 22 * y)
        ..lineTo(origin.dx + 22 * x, origin.dy)
        ..lineTo(origin.dx + 60 * x, origin.dy);
      canvas.drawPath(path, trace);
      final branch = Path()
        ..moveTo(origin.dx + 14 * x, origin.dy + 66 * y)
        ..lineTo(origin.dx + 34 * x, origin.dy + 46 * y)
        ..lineTo(origin.dx + 72 * x, origin.dy + 46 * y);
      canvas.drawPath(branch, trace);
      for (final point in [
        Offset(origin.dx + 60 * x, origin.dy),
        Offset(origin.dx, origin.dy + 60 * y),
        Offset(origin.dx + 72 * x, origin.dy + 46 * y),
      ]) {
        canvas.drawRect(
          Rect.fromCenter(center: point, width: 4, height: 4),
          node,
        );
      }
    }

    corner(const Offset(18, 18), 1, 1);
    corner(Offset(size.width - 18, 18), -1, 1);
    corner(Offset(18, size.height - 18), 1, -1);
    corner(Offset(size.width - 18, size.height - 18), -1, -1);
  }

  @override
  bool shouldRepaint(covariant _CircuitTraceryPainter oldDelegate) => false;
}

class _MetallicCrest extends StatelessWidget {
  const _MetallicCrest({required this.logoUrl, required this.size});
  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: logoUrl?.isNotEmpty == true
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: _metallicGoldGradient,
            ),
            child: ClipOval(child: Image.network(logoUrl!, fit: BoxFit.cover)),
          )
        : CustomPaint(painter: _CrestPainter()),
  );
}

class _CrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFF0D98C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    final shield = Path()
      ..moveTo(w * .5, h * .06)
      ..lineTo(w * .81, h * .19)
      ..lineTo(w * .81, h * .54)
      ..cubicTo(w * .81, h * .78, w * .65, h * .92, w * .5, h * .98)
      ..cubicTo(w * .35, h * .92, w * .19, h * .78, w * .19, h * .54)
      ..lineTo(w * .19, h * .19)
      ..close();
    canvas.drawPath(shield, gold);
    final torch = Path()
      ..moveTo(w * .5, h * .2)
      ..quadraticBezierTo(w * .58, h * .3, w * .5, h * .4)
      ..quadraticBezierTo(w * .42, h * .3, w * .5, h * .2)
      ..moveTo(w * .5, h * .4)
      ..lineTo(w * .5, h * .72);
    canvas.drawPath(torch, gold);
    for (final direction in [-1, 1]) {
      for (var i = 0; i < 3; i++) {
        final y = h * (.46 + i * .12);
        final leaf = Path()
          ..moveTo(w * .5 + direction * 2, y)
          ..quadraticBezierTo(
            w * .5 + direction * (13 + i * 2),
            y + 4,
            w * .5 + direction * (21 + i * 2),
            y - 3,
          );
        canvas.drawPath(leaf, gold);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CrestPainter oldDelegate) => false;
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

class _MetallicSealBadge extends StatelessWidget {
  const _MetallicSealBadge({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(
        colors: [Color(0xFFF0D98C), Color(0xFFD4AF37), Color(0xFF9E7D3B)],
      ),
      border: Border.all(color: Colors.white54),
    ),
    child: Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF0B1B3A),
          fontWeight: FontWeight.w800,
          fontSize: 8,
        ),
      ),
    ),
  );
}

class _MetallicAvatar extends StatelessWidget {
  const _MetallicAvatar({required this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
    ),
    child: Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: _metallicGoldGradient,
      ),
      child: CircleAvatar(
        radius: 47,
        backgroundColor: const Color(0xFF102330),
        backgroundImage: photoUrl?.isNotEmpty == true
            ? NetworkImage(photoUrl!)
            : null,
        child: photoUrl?.isNotEmpty == true
            ? null
            : const Icon(Icons.person_rounded, size: 54, color: Colors.white30),
      ),
    ),
  );
}

class _MetallicDetailPanel extends StatelessWidget {
  const _MetallicDetailPanel({
    required this.studentCode,
    required this.admissionNumber,
    required this.academicYear,
  });
  final String studentCode;
  final String admissionNumber;
  final String academicYear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFF192A36).withValues(alpha: .72),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MetallicDetailRow(
          icon: Icons.badge_outlined,
          label: 'Student Code',
          value: studentCode,
        ),
        const Divider(color: Colors.white12, height: 1),
        _MetallicDetailRow(
          icon: Icons.article_outlined,
          label: 'Admission No.',
          value: admissionNumber,
        ),
        const Divider(color: Colors.white12, height: 1),
        _MetallicDetailRow(
          icon: Icons.calendar_month_outlined,
          label: 'Academic Year',
          value: academicYear,
        ),
      ],
    ),
  );
}

class _MetallicDetailRow extends StatelessWidget {
  const _MetallicDetailRow({
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
      const Icon(Icons.circle, size: 0),
      Icon(icon, color: const Color(0xFFDFBA6B), size: 17),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFCE7B2),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _MetallicStatusPill extends StatelessWidget {
  const _MetallicStatusPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF223340),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFDFBA6B).withValues(alpha: .45)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFFDFBA6B)),
        const SizedBox(width: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.radius,
  });
  final LinearGradient gradient;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(strokeWidth / 2),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
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
          side: BorderSide(color: Colors.white.withValues(alpha: .24)),
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
      border: Border.all(color: Colors.white.withValues(alpha: .22)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.verified_user_outlined,
          color: Color(0xFFF0D98C),
          size: 32,
        ),
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
            color: Colors.green.withValues(alpha: .22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ACTIVE',
            style: TextStyle(
              color: Colors.lightGreenAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
