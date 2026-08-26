import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:ui';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Monochrome backdrop
          Positioned.fill(
            child: _BackgroundEffect(
              pulseAnimation: _pulseController,
              isDark: isDark,
            ),
          ),

          SafeArea(
            child: ResponsiveBuilder(
              builder: (context, layout) {
                final isDesktop = layout == ResponsiveLayout.desktop;
                final isMobile = layout == ResponsiveLayout.mobile;
                final contentWidth = isDesktop ? 600.0 : 480.0;

                // The reference layout uses generous but deliberate vertical
                // rhythm: the brand sits above a compact welcome message,
                // followed by the three large portal choices.
                final headerGap = isMobile ? AppSpacing.m : AppSpacing.l;

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
                        vertical: AppSpacing.l,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewport.maxHeight - (AppSpacing.l * 2),
                        ),
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: contentWidth),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Brand Identity Section - the splash mark
                                // already carries the shield, its surrounding icons
                                // and the SCHOOL PULSE wordmark with tagline.
                                // Intentionally static: only the visual entrance
                                // treatment was removed. _WelcomeLogo retains its
                                // concealed long-press owner access behaviour.
                                _WelcomeLogo(size: isMobile ? 160 : 185),

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
                                  opacity: _cardOpacities[2],
                                  slide: _cardSlides[2],
                                  pulse: _pulseController,
                                  onTap: () => context.push('/student/login'),
                                ),

                                const SizedBox(height: AppSpacing.x2l),
                                const _BottomFeatures(),
                                const SizedBox(height: AppSpacing.x2l),

                                // Footer
                                Text(
                                  "© 2024 School Pulse. All rights reserved.",
                                  textAlign: TextAlign.center,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary(context),
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

/// Monochrome backdrop: a soft radial glow behind the logo, a second glow
/// low on the page, and a faint dot grid - painted rather than shipped as an
/// image so it scales to any screen size. Black/white/gray only.
class _BackgroundEffect extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final bool isDark;
  const _BackgroundEffect({required this.pulseAnimation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _BackgroundPainter(
            progress: pulseAnimation.value,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  const _BackgroundPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = isDark ? Colors.black : Colors.white;
    final accent = isDark ? Colors.white : Colors.black;

    canvas.drawRect(rect, Paint()..color = base);

    // Dot grid, fading out toward the bottom of the screen.
    final dotPaint = Paint()..color = accent;
    const spacing = 26.0;
    for (double y = 0; y < size.height; y += spacing) {
      dotPaint.color = accent;
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
        ..shader = RadialGradient(colors: [accent, accent]).createShader(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height * 0.18),
            radius: size.width * 0.62 * glow,
          ),
        ),
    );

    // Second glow low on the page.
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.92),
      size.width * 0.7,
      Paint()
        ..shader = RadialGradient(colors: [accent, accent]).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.92),
            radius: size.width * 0.7,
          ),
        ),
    );

    // Fine orbital lines add the distinctive sweeping motion of the
    // reference without adding a bitmap that would blur on large screens.
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = accent;
    for (var i = 0; i < 10; i++) {
      final offset = i * 4.2;
      final path = Path()
        ..moveTo(size.width * 0.58 + offset, size.height * 0.045)
        ..cubicTo(
          size.width * 1.00 + offset,
          size.height * 0.07,
          size.width * 0.78 + offset,
          size.height * 0.19,
          size.width * 1.04 + offset,
          size.height * 0.27,
        );
      canvas.drawPath(path, orbitPaint);
    }

    final lowerOrbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accent;
    final lowerPath = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.96)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.87,
        size.width * 0.76,
        size.height * 0.89,
        size.width * 1.08,
        size.height * 0.98,
      );
    canvas.drawPath(lowerPath, lowerOrbit);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
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
    (title: 'Welcome to School Pulse', body: 'Select your portal to continue'),
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
          height: 54,
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
                          style: GoogleFonts.manrope(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
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
        // Keep the swipe/auto-advance behaviour, without visible pagination
        // so the welcome panel matches the clean reference composition.
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
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 1.35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: _isHovered ? 32 : 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      // Frosted black glass, regardless of app theme, so the
                      // card reads consistently over either splash background.
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.black, Colors.black],
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _CardWavePainter(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Decorative watermark icons sitting behind the
                              // text on the right of the card. Positioned
                              // relative to the card width so they stay inside
                              // the card on every screen size instead of being
                              // pushed off by fixed offsets.
                              Positioned(
                                right: constraints.maxWidth * 0.13,
                                top: 10,
                                child: Icon(
                                  widget.bgIcons[0],
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                right: constraints.maxWidth * 0.20,
                                bottom: 8,
                                child: Icon(
                                  widget.bgIcons[1],
                                  size: 34,
                                  color: Colors.white,
                                ),
                              ),
                              // Content Layout
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.l,
                                ),
                                child: Row(
                                  children: [
                                    // Left Icon Container
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: Icon(
                                        widget.icon,
                                        color: Colors.black,
                                        size: 33,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.l),
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
                                            style: GoogleFonts.manrope(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19,
                                              letterSpacing: -0.25,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.subtitle,
                                            style: GoogleFonts.manrope(
                                              color: Colors.white,
                                              fontSize: 12.5,
                                              height: 1.25,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Action Button
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.black,
                                        size: 30,
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

/// Delicate nested curves that make each portal feel like part of the same
/// system while retaining its own blue, orange or green identity.
class _CardWavePainter extends CustomPainter {
  final Color color;
  const _CardWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = color;
    for (var i = 0; i < 7; i++) {
      final offset = i * 5.5;
      final path = Path()
        ..moveTo(size.width * 0.54, size.height + 10 - offset)
        ..cubicTo(
          size.width * 0.72,
          size.height * 0.73 - offset,
          size.width * 0.75,
          size.height * 0.12 + offset,
          size.width + 10,
          size.height * 0.20 + offset,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CardWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BottomFeatures extends StatelessWidget {
  const _BottomFeatures();

  @override
  Widget build(BuildContext context) {
    const items = [
      _FeatureItem(
        icon: Icons.verified_user_outlined,
        label: "Secure",
        desc: "Your data is\nprotected",
      ),
      _FeatureItem(
        icon: Icons.cloud_sync_rounded,
        label: "Reliable",
        desc: "Works online\n& offline",
      ),
      _FeatureItem(
        icon: Icons.rocket_launch_outlined,
        label: "Fast",
        desc: "Built for\nperformance",
      ),
      _FeatureItem(
        icon: Icons.headset_mic_outlined,
        label: "Support",
        desc: "We are here\nto help",
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.textPrimary(context))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '•  W H Y   S C H O O L   P U L S E ?  •',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.1,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.textPrimary(context))),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    color: AppColors.textPrimary(context),
                  ),
                Expanded(child: items[i]),
              ],
            ],
          ),
        ),
      ],
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
    final textColor = AppColors.textPrimary(context);
    final iconForeground = Theme.of(context).colorScheme.surface;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: textColor,
            border: Border.all(color: textColor),
          ),
          child: Icon(icon, color: iconForeground, size: 26),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: textColor,
            fontSize: 9.5,
            height: 1.3,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

/// The brand mark, rendered from the theme-appropriate splash asset. Wraps a
/// concealed long-press gesture that opens Platform Owner Access - deliberately
/// undecorated (no highlight, no hint text, no icon change) so a normal user
/// has no visual indication the gesture does anything. A short tap is a no-op,
/// matching every other logo placement in the app.
class _WelcomeLogo extends StatefulWidget {
  final double size;
  const _WelcomeLogo({required this.size});

  @override
  State<_WelcomeLogo> createState() => _WelcomeLogoState();
}

class _WelcomeLogoState extends State<_WelcomeLogo> {
  static const _holdDuration = Duration(seconds: 3);
  Timer? _holdTimer;

  void _armHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer(_holdDuration, () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      context.push('/owner-login');
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/splash/splash_dark_mode.png'
        : 'assets/splash/splash_light_mode.png';

    return GestureDetector(
      onLongPressStart: (_) => _armHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: Semantics(
        label: 'School Pulse',
        child: Image.asset(asset, width: widget.size, fit: BoxFit.contain),
      ),
    );
  }
}
