import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

/// The global School Pulse loading indicator.
///
/// It uses the approved SP mark, adapts to the active color scheme, and
/// automatically reduces motion when the platform requests it.
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
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.linear));
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
      _rotationController.stop();
      _pulseController.stop();
      _fadeController.repeat(reverse: true);
    } else {
      _fadeController.stop();
      _fadeController.value = 1;
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logo = RepaintBoundary(
      child: Image.asset(
        isDark
            ? 'assets/logos/icon_dark_mode.png'
            : 'assets/logos/icon_light_Mode.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );

    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: FadeTransition(
        opacity: _reducedMotion == true
            ? _fadeAnimation
            : const AlwaysStoppedAnimation<double>(1),
        child: AnimatedBuilder(
          animation: _pulseController,
          child: logo,
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: _reducedMotion == true
                        ? 0.10
                        : 0.06 + (_pulseController.value * 0.06),
                  ),
                  blurRadius: widget.size * 0.18,
                  spreadRadius: widget.size * 0.015,
                ),
              ],
            ),
            child: RotationTransition(
              turns: _rotationController,
              child: ScaleTransition(scale: _scaleAnimation, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
