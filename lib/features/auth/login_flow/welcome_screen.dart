import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:ui';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoFloat;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;

  final List<Animation<double>> _cardOpacities = [];
  final List<Animation<Offset>> _cardSlides = [];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (!WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      _pulseController.repeat(reverse: true);
    }

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoFloat = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    for (int i = 0; i < 3; i++) {
      double start = 0.5 + (i * 0.1);
      double end = (start + 0.3).clamp(0.0, 1.0);
      _cardOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        ),
      );
      _cardSlides.add(
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    if (WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      _entranceController.value = 1.0;
    } else {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      if (_entranceController.isAnimating) _entranceController.value = 1.0;
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    } else {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Deep Space/Tech Background
          Positioned.fill(
            child: _BackgroundEffect(pulseAnimation: _pulseController),
          ),

          SafeArea(
            child: ResponsiveBuilder(
              builder: (context, layout) {
                final isDesktop = layout == ResponsiveLayout.desktop;
                final isMobile = layout == ResponsiveLayout.mobile;
                final contentWidth = isDesktop ? 600.0 : 480.0;

                final headerGap = isMobile ? AppSpacing.x2l : AppSpacing.x3l;

                // minHeight ties the content to the viewport height, so the
                // column centres itself on a tall screen and simply scrolls -
                // rather than overflowing - once it outgrows a short one.
                return LayoutBuilder(
                  builder: (context, viewport) {
                    final horizontalPad = isMobile
                        ? AppSpacing.l
                        : AppSpacing.xl;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPad,
                        vertical: AppSpacing.m,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewport.maxHeight - (AppSpacing.m * 2),
                        ),
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: contentWidth),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Brand Identity Section - the horizontal logo asset
                                // already carries the shield, its surrounding icons
                                // and the SCHOOL PULSE wordmark with tagline.
                                FadeTransition(
                                  opacity: _logoOpacity,
                                  child: ScaleTransition(
                                    scale: _logoScale,
                                    child: AnimatedBuilder(
                                      animation: _logoFloat,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, _logoFloat.value),
                                          child: child,
                                        );
                                      },
                                      // The asset carries a transparent margin.
                                      // Clipping it back keeps the mark large without
                                      // the empty space pushing the page down.
                                      child: ClipRect(
                                        child: Align(
                                          alignment: Alignment.center,
                                          heightFactor: 0.84,
                                          child: PulseLogo(
                                            width: isMobile ? 190 : 220,
                                            variant: PulseLogoVariant.vertical,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: headerGap),

                                // Welcome & Call to Action
                                FadeTransition(
                                  opacity: _headerOpacity,
                                  child: SlideTransition(
                                    position: _headerSlide,
                                    child: const _WelcomeCarousel(),
                                  ),
                                ),

                                SizedBox(height: headerGap),

                                // Role Gateways
                                _RoleCard(
                                  index: 0,
                                  title: "Parent Portal",
                                  subtitle: "Manage your child's education",
                                  icon: Icons.people_alt_rounded,
                                  bgIcons: const [
                                    Icons.school_outlined,
                                    Icons.menu_book_rounded,
                                  ],
                                  color: AppColors.electricBlue,
                                  opacity: _cardOpacities[0],
                                  slide: _cardSlides[0],
                                  pulse: _pulseController,
                                  onTap: () =>
                                      context.push('/parent/login/child-id'),
                                ),
                                const SizedBox(height: AppSpacing.l),
                                _RoleCard(
                                  index: 1,
                                  title: "Staff Gateway",
                                  subtitle: "School operations & management",
                                  icon: Icons.badge_rounded,
                                  bgIcons: const [
                                    Icons.calendar_today_rounded,
                                    Icons.bar_chart_rounded,
                                  ],
                                  color: AppColors.brightOrange,
                                  opacity: _cardOpacities[1],
                                  slide: _cardSlides[1],
                                  pulse: _pulseController,
                                  onTap: () => context.push('/staff/login'),
                                ),
                                const SizedBox(height: AppSpacing.l),
                                _RoleCard(
                                  index: 2,
                                  title: "Student Hub",
                                  subtitle: "Your learning journey begins here",
                                  icon: Icons.school_rounded,
                                  bgIcons: const [
                                    Icons.menu_book_outlined,
                                    Icons.lightbulb_outline,
                                  ],
                                  color: AppColors.emeraldGreen,
                                  opacity: _cardOpacities[2],
                                  slide: _cardSlides[2],
                                  pulse: _pulseController,
                                  onTap: () => context.push('/student/login'),
                                ),

                                SizedBox(height: headerGap),
                                const _BottomFeatures(),
                                const SizedBox(height: AppSpacing.x2l),

                                // Footer
                                Text(
                                  "© 2024 School Pulse. All rights reserved.",
                                  textAlign: TextAlign.center,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondaryDark
                                        .withValues(alpha: 0.5),
                                    fontSize: 11,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Deep-space backdrop: a radial glow behind the logo, a second cooler glow
/// low on the page, and a faint dot grid - painted rather than shipped as an
/// image so it scales to any screen size.
class _BackgroundEffect extends StatelessWidget {
  final Animation<double> pulseAnimation;
  const _BackgroundEffect({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _BackgroundPainter(progress: pulseAnimation.value),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  const _BackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base vertical gradient - near-black at the edges, navy through the middle.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF040B1C), Color(0xFF071235), Color(0xFF03081A)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    // Dot grid, fading out toward the bottom of the screen.
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const spacing = 26.0;
    for (double y = 0; y < size.height; y += spacing) {
      final fade = (1.0 - (y / size.height)).clamp(0.0, 1.0);
      dotPaint.color = Colors.white.withValues(alpha: 0.06 * fade);
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    // Breathing glow behind the logo.
    final glow = 0.9 + (progress * 0.2);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.18),
      size.width * 0.62 * glow,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF1E6BFF).withValues(alpha: 0.20),
                const Color(0xFF1E6BFF).withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width / 2, size.height * 0.18),
                radius: size.width * 0.62 * glow,
              ),
            ),
    );

    // Cooler secondary glow low on the page.
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.92),
      size.width * 0.7,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF0A2A6B).withValues(alpha: 0.35),
                const Color(0xFF0A2A6B).withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.5, size.height * 0.92),
                radius: size.width * 0.7,
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// The headline/subtitle pair, presented as a swipeable carousel that also
/// advances on its own. The page indicator below it is driven by the real
/// PageView offset, so dragging tracks the finger rather than snapping.
class _WelcomeCarousel extends StatefulWidget {
  const _WelcomeCarousel();

  @override
  State<_WelcomeCarousel> createState() => _WelcomeCarouselState();
}

class _WelcomeCarouselState extends State<_WelcomeCarousel> {
  static const _slides = [
    (title: 'Welcome to School Pulse', body: 'Choose how you want to continue'),
    (
      title: 'One School, One Pulse',
      body: 'Parents, staff and students in a single place',
    ),
    (
      title: 'Always In Sync',
      body: 'Attendance, fees and results update in real time',
    ),
    (
      title: 'Built For Your School',
      body: 'Secure by default, and it works offline too',
    ),
  ];

  static const _autoAdvance = Duration(seconds: 5);

  final PageController _controller = PageController();
  Timer? _timer;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page;
      if (page != null && page != _page) setState(() => _page = page);
    });
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    // Respect the platform "reduce motion" setting - an unprompted slide is
    // exactly the kind of movement that setting asks us to suppress.
    if (WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      return;
    }
    _timer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_controller.page ?? 0).round() + 1;
      _controller.animateToPage(
        next >= _slides.length ? 0 : next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 84,
          // A manual swipe should not fight the timer, so any touch restarts
          // the countdown from zero.
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _timer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoAdvance();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                // Fade and lift each slide out as it leaves the viewport.
                final delta = (_page - index).abs().clamp(0.0, 1.0);
                return Opacity(
                  opacity: 1.0 - delta,
                  child: Transform.translate(
                    offset: Offset(0, delta * 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        _PageIndicator(count: _slides.length, page: _page),
      ],
    );
  }
}

/// Dots that stretch into a pill for the active slide, interpolated against
/// the live page offset so the transition follows the drag.
class _PageIndicator extends StatelessWidget {
  final int count;
  final double page;

  const _PageIndicator({required this.count, required this.page});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Builder(
            builder: (context) {
              final t = (1.0 - (page - i).abs()).clamp(0.0, 1.0);
              return Container(
                width: 5 + (27 * t),
                height: 5,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.22),
                    AppColors.electricBlue,
                    t,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _RoleCard extends StatefulWidget {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<IconData> bgIcons;
  final Color color;
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Animation<double> pulse;
  final VoidCallback onTap;

  const _RoleCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgIcons,
    required this.color,
    required this.opacity,
    required this.slide,
    required this.pulse,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.opacity,
      child: SlideTransition(
        position: widget.slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0),
              duration: const Duration(milliseconds: 150),
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.color.withValues(
                      alpha: _isHovered ? 0.85 : 0.55,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    // Accent halo in the card's own colour.
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: _isHovered ? 0.30 : 0.18,
                      ),
                      blurRadius: _isHovered ? 30 : 20,
                      spreadRadius: 1,
                    ),
                    // Depth shadow so the glass lifts off the background.
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      // Frosted glass: a low-alpha accent tint over the blur,
                      // plus a white sheen falling from the top-left edge so
                      // the surface catches light like real glass.
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            widget.color.withValues(alpha: 0.16),
                            Colors.white.withValues(alpha: 0.03),
                            widget.color.withValues(alpha: 0.10),
                          ],
                          stops: const [0.0, 0.35, 0.62, 1.0],
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              // Decorative watermark icons sitting behind the
                              // text on the right of the card. Positioned
                              // relative to the card width so they stay inside
                              // the card on every screen size instead of being
                              // pushed off by fixed offsets.
                              Positioned(
                                right: constraints.maxWidth * 0.13,
                                top: 14,
                                child: Icon(
                                  widget.bgIcons[0],
                                  size: 30,
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              Positioned(
                                right: constraints.maxWidth * 0.20,
                                bottom: 12,
                                child: Icon(
                                  widget.bgIcons[1],
                                  size: 34,
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              // Content Layout
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                ),
                                child: Row(
                                  children: [
                                    // Left Icon Container
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            widget.color.withValues(
                                              alpha: 0.85,
                                            ),
                                            widget.color.withValues(
                                              alpha: 0.45,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.color.withValues(
                                              alpha: 0.45,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        widget.icon,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xl),
                                    // Text info
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.title,
                                            style: AppTypography.titleLarge
                                                .copyWith(
                                                  color:
                                                      AppColors.textPrimaryDark,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.subtitle,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors
                                                      .textSecondaryDark
                                                      .withValues(alpha: 0.8),
                                                  letterSpacing: 0.3,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Action Button
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: widget.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomFeatures extends StatelessWidget {
  const _BottomFeatures();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FeatureItem(
        icon: Icons.shield_outlined,
        label: "Secure",
        desc: "Your data is\nprotected",
      ),
      _FeatureItem(
        icon: Icons.cloud_sync_outlined,
        label: "Sync",
        desc: "Works online\n& offline",
      ),
      _FeatureItem(
        icon: Icons.speed_outlined,
        label: "Fast",
        desc: "Built for\nperformance",
      ),
      _FeatureItem(
        icon: Icons.headset_mic_outlined,
        label: "Support",
        desc: "We are here\nto help",
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  Expanded(child: items[i]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.electricBlue, size: 28),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            fontSize: 9,
            height: 1.3,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
