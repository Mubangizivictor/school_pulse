import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Shared chrome for the three portal entry screens (Staff, Parent, Student).
/// Each screen is the same composition - a glowing badge sitting on a line-art
/// school horizon, title, form, CTA - recoloured by the portal's accent, so
/// the set reads as one family.

/// Line-art school scene with a glowing horizon, drawn rather than shipped as
/// three separate images so it recolours per portal and scales to any width.
class AuthHeroScene extends StatelessWidget {
  final Color accent;
  final IconData badgeIcon;
  final double height;

  const AuthHeroScene({
    super.key,
    required this.accent,
    required this.badgeIcon,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HorizonPainter(accent: accent)),
          ),
          // Badge: a glowing ring with the portal's glyph at its centre.
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface,
              border: Border.all(color: accent, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.55),
                  blurRadius: 34,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 70,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: Icon(badgeIcon, size: 46, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _HorizonPainter extends CustomPainter {
  final Color accent;
  const _HorizonPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.45);

    // The ground curve every element sits on.
    final horizonY = h * 0.78;
    final horizon = Path()
      ..moveTo(0, horizonY + 26)
      ..quadraticBezierTo(w / 2, horizonY - 34, w, horizonY + 26);

    canvas.drawPath(
      horizon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = accent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      horizon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = accent.withValues(alpha: 0.9),
    );

    _drawSchool(canvas, Offset(w * 0.14, horizonY + 2), h, stroke);
    _drawTree(canvas, Offset(w * 0.85, horizonY + 4), h, stroke);
    _drawSparks(canvas, size, horizonY);
  }

  /// Schoolhouse on the left: body, roof, clock, door, windows and a flag.
  void _drawSchool(Canvas canvas, Offset base, double h, Paint stroke) {
    final bw = h * 0.46;
    final bh = h * 0.40;
    final left = base.dx - bw / 2;
    final top = base.dy - bh;

    canvas.drawRect(Rect.fromLTWH(left, top, bw, bh), stroke);

    // Roof.
    canvas.drawPath(
      Path()
        ..moveTo(left - 6, top)
        ..lineTo(base.dx, top - bh * 0.34)
        ..lineTo(left + bw + 6, top)
        ..close(),
      stroke,
    );

    // Clock face in the gable.
    canvas.drawCircle(Offset(base.dx, top - bh * 0.10), bh * 0.09, stroke);

    // Flag pole and pennant.
    final poleTop = top - bh * 0.34;
    canvas.drawLine(
      Offset(base.dx, poleTop),
      Offset(base.dx, poleTop - bh * 0.32),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, poleTop - bh * 0.32)
        ..lineTo(base.dx + bw * 0.24, poleTop - bh * 0.24)
        ..lineTo(base.dx, poleTop - bh * 0.16)
        ..close(),
      stroke,
    );

    // Door.
    final doorW = bw * 0.20;
    canvas.drawRect(
      Rect.fromLTWH(base.dx - doorW / 2, base.dy - bh * 0.42, doorW, bh * 0.42),
      stroke,
    );

    // Two windows either side of the door.
    final winW = bw * 0.16;
    for (final dx in [-bw * 0.30, bw * 0.30]) {
      canvas.drawRect(
        Rect.fromLTWH(base.dx + dx - winW / 2, top + bh * 0.22, winW, winW),
        stroke,
      );
    }
  }

  /// Rounded canopy tree on the right.
  void _drawTree(Canvas canvas, Offset base, double h, Paint stroke) {
    final canopyR = h * 0.15;
    final trunkH = h * 0.20;
    canvas.drawLine(base, Offset(base.dx, base.dy - trunkH), stroke);
    canvas.drawCircle(
      Offset(base.dx, base.dy - trunkH - canopyR * 0.7),
      canopyR,
      stroke,
    );
    canvas.drawCircle(
      Offset(base.dx - canopyR * 0.75, base.dy - trunkH - canopyR * 0.1),
      canopyR * 0.6,
      stroke,
    );
    canvas.drawCircle(
      Offset(base.dx + canopyR * 0.78, base.dy - trunkH - canopyR * 0.15),
      canopyR * 0.55,
      stroke,
    );
  }

  /// Embers drifting above the horizon.
  void _drawSparks(Canvas canvas, Size size, double horizonY) {
    final rand = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 26; i++) {
      final x = rand.nextDouble() * size.width;
      final y = horizonY * (0.15 + rand.nextDouble() * 0.85);
      paint.color = accent.withValues(alpha: 0.10 + rand.nextDouble() * 0.35);
      canvas.drawCircle(Offset(x, y), rand.nextDouble() * 1.6 + 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_HorizonPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

/// The four reassurance tiles, recoloured per portal.
class AuthTrustStrip extends StatelessWidget {
  final Color accent;
  const AuthTrustStrip({super.key, required this.accent});

  static const _items = [
    (
      icon: Icons.verified_user_outlined,
      label: 'Secure',
      desc: 'Your data is\nprotected',
    ),
    (
      icon: Icons.cloud_sync_outlined,
      label: 'Sync',
      desc: 'Works online\n& offline',
    ),
    (icon: Icons.speed_outlined, label: 'Fast', desc: 'Built for\nperformance'),
    (
      icon: Icons.headset_mic_outlined,
      label: 'Support',
      desc: 'We are here\nto help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  color: accent.withValues(alpha: 0.22),
                ),
              Expanded(
                child: Column(
                  children: [
                    Icon(_items[i].icon, color: accent, size: 26),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      _items[i].label,
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].desc,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Closing privacy reassurance line.
class AuthPrivacyNote extends StatelessWidget {
  final Color accent;
  const AuthPrivacyNote({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: accent, size: 24),
        const SizedBox(width: AppSpacing.m),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your data is secure with us',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'We value your privacy and protect your information.',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-width gradient CTA with a trailing arrow, as on all three screens.
class AuthCtaButton extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthCtaButton({
    super.key,
    required this.label,
    required this.gradient,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: gradient.last.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else ...[
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Positioned(
                  right: AppSpacing.x2l,
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Outlined field matching the screenshots: accent border, leading glyph and
/// a label sitting above the box.
class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color accent;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
  final String? errorText;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(icon, color: accent.withValues(alpha: 0.85)),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.xl,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.55)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.55)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Page scaffold shared by the three portals: back button, dark backdrop and
/// a viewport-height scroll body that centres when it fits and scrolls when
/// it does not.
class AuthPortalScaffold extends StatelessWidget {
  final Color accent;
  final List<Widget> children;

  const AuthPortalScaffold({
    super.key,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2l,
                AppSpacing.m,
                AppSpacing.x2l,
                AppSpacing.x2l,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewport.maxHeight - AppSpacing.x3l,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
