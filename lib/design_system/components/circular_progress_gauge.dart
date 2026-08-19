import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// A circular ring gauge showing a 0.0–1.0 progress value.
///
/// Draws a background track plus a progress arc, colored by threshold
/// (danger / warning / success) using the semantic [AppColors] tokens.
/// The center shows an animated percentage (via [AnimatedNumberText])
/// with a status label underneath.
class CircularProgressGauge extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final String label;
  final double warningThreshold;
  final double successThreshold;
  final Color? overrideColor;

  const CircularProgressGauge({
    super.key,
    required this.value,
    required this.label,
    this.size = 140,
    this.strokeWidth = 12,
    this.warningThreshold = 0.5,
    this.successThreshold = 0.8,
    this.overrideColor,
  });

  Color _colorForValue(BuildContext context) {
    if (overrideColor != null) return overrideColor!;
    final clamped = value.clamp(0.0, 1.0);
    if (clamped >= successThreshold) return AppColors.success(context);
    if (clamped >= warningThreshold) return AppColors.warning(context);
    return AppColors.danger(context);
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final color = _colorForValue(context);
    final trackColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.4);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              value: clamped,
              strokeWidth: strokeWidth,
              trackColor: trackColor,
              progressColor: color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedNumberText(
                value: clamped * 100,
                suffix: '%',
                style: AppTypography.kpiStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _GaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
