import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/brand/brand_assets.dart';

/// The global School Pulse loading indicator.
///
/// It plays the brand loading animation (the pulse travelling along the
/// mark), adapts to the active color scheme, and falls back to the static
/// mark with a gentle fade when the platform requests reduced motion (no
/// single animation frame shows the whole mark).
class SchoolPulseLoader extends StatefulWidget {
  static const double smallSize = 40;
  static const double mediumSize = 72;
  static const double largeSize = 112;

  final double size;

  const SchoolPulseLoader({super.key, this.size = mediumSize});

  const SchoolPulseLoader.small({super.key}) : size = smallSize;

  const SchoolPulseLoader.medium({super.key}) : size = mediumSize;

  const SchoolPulseLoader.large({super.key}) : size = largeSize;

  @override
  State<SchoolPulseLoader> createState() => _SchoolPulseLoaderState();
}

class _SchoolPulseLoaderState extends State<SchoolPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.linear));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;

    if (reducedMotion) {
      _fadeController.repeat(reverse: true);
    } else {
      _fadeController.stop();
      _fadeController.value = 1;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = _reducedMotion == true;
    final logo = RepaintBoundary(
      child: Image.asset(
        reducedMotion
            ? BrandAssets.logoMark(context)
            : BrandAssets.loadingGif(context),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );

    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: FadeTransition(
        opacity: reducedMotion
            ? _fadeAnimation
            : const AlwaysStoppedAnimation<double>(1),
        child: logo,
      ),
    );
  }
}
