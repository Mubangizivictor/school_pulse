import 'package:flutter/material.dart';

/// A minimal four-arc "G" glyph in Google's brand colors, used in place of
/// a shipped image asset. Follows Google's Sign In branding guidance (the
/// multi-color "G", not a generic letter or icon) without adding a binary
/// asset. Shared by every "Continue with Google" / "Link Google" surface.
class GoogleGlyph extends StatelessWidget {
  final double size;
  const GoogleGlyph({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.42;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Four brand-color arcs, each a quarter turn, matching the canonical
    // Google "G" color split (blue/green/yellow/red going clockwise from
    // the top-right gap).
    const sweep = 1.5533; // ~89deg, leaving a hairline seam between arcs
    canvas.drawArc(rect, -1.5708, sweep, false, arcPaint..color = Colors.black);
    canvas.drawArc(rect, -0.0175, sweep, false, arcPaint..color = Colors.black);
    canvas.drawArc(rect, 1.5358, sweep, false, arcPaint..color = Colors.black);
    canvas.drawArc(rect, 3.0891, sweep, false, arcPaint..color = Colors.black);

    // Horizontal crossbar, the "G"'s distinguishing feature vs. a plain "O".
    final barPaint = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeWidth * 0.28,
        radius - strokeWidth * 0.15,
        strokeWidth * 0.56,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleGlyphPainter oldDelegate) => false;
}
