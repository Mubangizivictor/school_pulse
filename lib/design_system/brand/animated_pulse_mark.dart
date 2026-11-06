import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';

/// The School Pulse mark (pulse line + gold dot) drawn as vectors and
/// animated the same way as the brand loading GIF
/// (`assets/branding/loading_*.gif`): the line drops to a faint track, a
/// solid pulse travels along it from left to right, and the dot swells while
/// the pulse climbs.
///
/// The geometry is traced from `assets/branding/splash_*_mode.png` in that
/// image's 1254 x 1254 pixel space, so when this widget is laid out at the
/// splash image's logical size ([splashSize]) the first frame lines up
/// exactly with the native splash it replaces. It stays crisp at any size,
/// unlike the 240 px GIF.
///
/// When the platform asks for reduced motion it shows the static mark.
class AnimatedPulseMark extends StatefulWidget {
  /// Logical size of the native splash image: the 1254 px artwork is
  /// generated as a 4x asset by flutter_native_splash.
  static const double splashSize = 1254 / 4;

  final double size;

  /// Pulse line colour. Defaults to brand blue on light backgrounds and
  /// white on dark ones, matching the splash artwork.
  final Color? lineColor;

  /// Dot colour. Defaults to the brand gold.
  final Color? dotColor;

  /// Overrides the brightness used to pick [lineColor]'s default. Splash
  /// screens pass the platform brightness so they match the native splash
  /// even before the saved in-app theme is restored.
  final Brightness? brightness;

  final String? semanticsLabel;

  /// Start straight in the animated state instead of fading in from the
  /// solid mark. Used when an animated HTML splash was already showing.
  final bool skipIntro;

  const AnimatedPulseMark({
    super.key,
    this.size = 72,
    this.lineColor,
    this.dotColor,
    this.brightness,
    this.semanticsLabel,
    this.skipIntro = false,
  });

  @override
  State<AnimatedPulseMark> createState() => _AnimatedPulseMarkState();
}

class _AnimatedPulseMarkState extends State<AnimatedPulseMark>
    with TickerProviderStateMixin {
  // 24 frames x 40 ms, as in the GIF.
  static const Duration _cycleDuration = Duration(milliseconds: 960);
  static const Duration _introDuration = Duration(milliseconds: 320);

  late final AnimationController _cycle;
  late final AnimationController _intro;
  late final Animation<double> _introCurve;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _cycle = AnimationController(vsync: this, duration: _cycleDuration);
    _intro = AnimationController(vsync: this, duration: _introDuration);
    _introCurve = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;

    if (reducedMotion) {
      _cycle.stop();
      _intro.value = 0;
    } else if (widget.skipIntro) {
      _intro.value = 1;
      _cycle.repeat();
    } else {
      _intro.forward();
      _cycle.repeat();
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = widget.brightness ?? Theme.of(context).brightness;
    final lineColor =
        widget.lineColor ??
        (brightness == Brightness.dark
            ? Colors.white
            : AppColorValues.lightPrimary);
    final dotColor = widget.dotColor ?? AppColorValues.lightAccent;

    final mark = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: PulseMarkPainter(
          cycle: _cycle,
          intro: _introCurve,
          lineColor: lineColor,
          dotColor: dotColor,
        ),
      ),
    );

    final label = widget.semanticsLabel;
    if (label == null) return ExcludeSemantics(child: mark);
    return Semantics(label: label, liveRegion: true, child: mark);
  }
}

/// Paints the pulse mark for a given loop position.
///
/// [cycle] runs 0 -> 1 once per loop; [intro] runs 0 -> 1 once, fading the
/// solid mark down to its track. At `intro == 0` this paints the static mark.
class PulseMarkPainter extends CustomPainter {
  // Traced from splash_light_mode.png (1254 px canvas; 98.7 % overlap).
  static const double canvasSize = 1254;
  static const double strokeWidth = 50;
  static const List<Offset> linePoints = [
    Offset(389, 744.5),
    Offset(483.5, 744.5),
    Offset(519, 798.5),
    Offset(626, 563.5),
    Offset(733, 744.5),
    Offset(864, 744.5),
  ];
  static const Offset dotCenter = Offset(626.5, 474.5);
  static const double dotRadius = 40.5;

  // Measured from the GIF frames.
  static const double trackOpacity = 0.2;
  static const double pulseLengthFraction = 0.412;
  static const double dotSwell = 0.2;

  static final Path _line = () {
    final path = Path()..moveTo(linePoints.first.dx, linePoints.first.dy);
    for (final point in linePoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }();
  static final PathMetric _metric = _line.computeMetrics().single;

  final Animation<double> cycle;
  final Animation<double> intro;
  final Color lineColor;
  final Color dotColor;

  PulseMarkPainter({
    required this.cycle,
    required this.intro,
    required this.lineColor,
    required this.dotColor,
  }) : super(repaint: Listenable.merge([cycle, intro]));

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / canvasSize;
    canvas
      ..save()
      ..translate(
        (size.width - canvasSize * scale) / 2,
        (size.height - canvasSize * scale) / 2,
      )
      ..scale(scale);

    final t = intro.value.clamp(0.0, 1.0);
    final u = cycle.value;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Track: the full line, fading from solid to the GIF's faint track.
    final trackAlpha = 1 - (1 - trackOpacity) * t;
    canvas.drawPath(
      _line,
      stroke..color = lineColor.withValues(alpha: lineColor.a * trackAlpha),
    );

    // Travelling pulse: head sweeps 0 -> length + pulse so the tail exits.
    if (t > 0) {
      final length = _metric.length;
      final pulse = length * pulseLengthFraction;
      final head = u * (length + pulse);
      final start = math.max(0.0, head - pulse);
      final end = math.min(length, head);
      if (end > start) {
        canvas.drawPath(
          _metric.extractPath(start, end),
          stroke..color = lineColor.withValues(alpha: lineColor.a * t),
        );
      }
    }

    // Dot swells during the first half of the loop (frames 0-12 in the GIF).
    final swell = u < 0.5 ? math.sin(math.pi * u / 0.5) : 0.0;
    canvas.drawCircle(
      dotCenter,
      dotRadius * (1 + dotSwell * swell * t),
      Paint()
        ..color = dotColor
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(PulseMarkPainter oldDelegate) =>
      oldDelegate.cycle != cycle ||
      oldDelegate.intro != intro ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor;
}
