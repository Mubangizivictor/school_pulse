import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/brand/animated_pulse_mark.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart' as tokens;
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';

// --- Portal definitions -------------------------------------------------

class _PortalDef {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color accent;

  const _PortalDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.accent,
  });
}

const _portals = [
  _PortalDef(
    id: 'staff',
    title: 'Staff Portal',
    subtitle: 'School admin, teachers & operations',
    icon: Icons.badge_rounded,
    route: '/staff/login',
    accent: AppColors.brightOrange,
  ),
  _PortalDef(
    id: 'parent',
    title: 'Parent Portal',
    subtitle: "Monitor your child's education",
    icon: Icons.family_restroom_rounded,
    route: '/parent/login/child-id',
    accent: AppColors.royalBlue,
  ),
  _PortalDef(
    id: 'student',
    title: 'Student Hub',
    subtitle: 'Your learning journey begins here',
    icon: Icons.school_rounded,
    route: '/student/login',
    accent: AppColors.successGreen,
  ),
];

// --- Screen -------------------------------------------------------------

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Header fade-in
  late final AnimationController _headerCtrl;
  // Per-card stagger
  late final List<AnimationController> _cardCtrls;
  // Footer fade-in
  late final AnimationController _footerCtrl;

  // Owner long-press (web only)
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _cardCtrls = List.generate(
      _portals.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      ),
    );
    _footerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _runEntryAnimation();
  }

  void _runEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    _headerCtrl.forward();
    for (var i = 0; i < _cardCtrls.length; i++) {
      await Future.delayed(Duration(milliseconds: 80 + i * 70));
      if (!mounted) return;
      _cardCtrls[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 90));
    if (mounted) _footerCtrl.forward();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _headerCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    _footerCtrl.dispose();
    super.dispose();
  }

  void _armOwnerHold() {
    if (!kIsWeb) return;
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      context.push('/owner-login');
    });
  }

  void _cancelOwnerHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final branding = context.watch<ThemeProvider>().branding;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            final isDesktop = layout == ResponsiveLayout.desktop;
            final hPad = isDesktop ? AppSpacing.x4l : AppSpacing.xl;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(hPad, AppSpacing.x2l, hPad, AppSpacing.x2l),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 520.0 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AnimatedSlide(
                        controller: _headerCtrl,
                        child: _WelcomeHeader(
                          branding: branding,
                          onLogoLongPressStart: _armOwnerHold,
                          onLogoLongPressEnd: _cancelOwnerHold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x4l),
                      for (var i = 0; i < _portals.length; i++) ...[
                        _AnimatedSlide(
                          controller: _cardCtrls[i],
                          slideOffset: const Offset(0, 0.3),
                          child: _PortalCard(portal: _portals[i]),
                        ),
                        if (i < _portals.length - 1)
                          const SizedBox(height: AppSpacing.l),
                      ],
                      const SizedBox(height: AppSpacing.x3l),
                      _AnimatedSlide(
                        controller: _footerCtrl,
                        child: const _WelcomeFooter(),
                      ),
                    ],
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

// --- Header -------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  final SchoolBranding? branding;
  final VoidCallback? onLogoLongPressStart;
  final VoidCallback? onLogoLongPressEnd;

  const _WelcomeHeader({
    required this.branding,
    this.onLogoLongPressStart,
    this.onLogoLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    final schoolName = branding?.schoolName.trim().isNotEmpty == true
        ? branding!.schoolName.toUpperCase()
        : 'SCHOOL PULSE';
    final motto = branding?.schoolMotto.trim().isNotEmpty == true
        ? branding!.schoolMotto
        : 'Your school, in sync';
    final badgeUrl = branding?.badgeUrl ?? branding?.logoUrl;

    return Column(
      children: [
        GestureDetector(
          onLongPressStart: (_) => onLogoLongPressStart?.call(),
          onLongPressEnd: (_) => onLogoLongPressEnd?.call(),
          onLongPressCancel: () => onLogoLongPressEnd?.call(),
          child: Semantics(
            label: schoolName,
            child: Center(
              child: badgeUrl != null
                  ? SchoolBadge(badgeUrl: badgeUrl, size: 80)
                  : AnimatedPulseMark(
                      size: 80,
                      semanticsLabel: 'School Pulse',
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          schoolName,
          textAlign: TextAlign.center,
          style: tokens.AppText.body.copyWith(
            color: AppColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          motto,
          textAlign: TextAlign.center,
          style: tokens.AppText.body.copyWith(
            color: AppColors.textSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// --- Portal card --------------------------------------------------------

class _PortalCard extends StatefulWidget {
  final _PortalDef portal;
  const _PortalCard({super.key, required this.portal});

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.portal;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.grey850 : AppColors.white;
    final accentSoft = p.accent.withOpacity(isDark ? 0.18 : 0.08);

    return Semantics(
      button: true,
      label: '${p.title}. ${p.subtitle}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          context.push(p.route);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minHeight: 86),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: _pressed ? accentSoft : bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _pressed
                    ? p.accent.withOpacity(0.6)
                    : AppColors.border(context),
                width: 1.4,
              ),
              boxShadow: _pressed
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.055),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                _PortalIcon(icon: p.icon, accent: p.accent),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p.title,
                        style: tokens.AppText.body.copyWith(
                          color: AppColors.textPrimary(context),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p.subtitle,
                        style: tokens.AppText.body.copyWith(
                          color: AppColors.textSecondary(context),
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary(context),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _PortalIcon({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: accent, size: 28),
    );
  }
}

// --- Footer -------------------------------------------------------------

class _WelcomeFooter extends StatelessWidget {
  const _WelcomeFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RegisterSchoolTile(),
        const SizedBox(height: AppSpacing.x2l),
        _TrustRow(),
        const SizedBox(height: AppSpacing.x2l),
        Text(
          '© ${DateTime.now().year} School Pulse. All rights reserved.',
          textAlign: TextAlign.center,
          style: tokens.AppText.body.copyWith(
            color: AppColors.textMuted(context),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RegisterSchoolTile extends StatelessWidget {
  const _RegisterSchoolTile();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/register-school'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.royalBlue.withOpacity(0.2)
                    : AppColors.royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_business_rounded,
                color: AppColors.royalBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New institution?',
                    style: tokens.AppText.body.copyWith(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Register your school on School Pulse',
                    style: tokens.AppText.body.copyWith(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.royalBlue,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  static const _items = [
    (Icons.verified_user_outlined, 'Secure'),
    (Icons.cloud_done_outlined, 'Reliable'),
    (Icons.headset_mic_outlined, 'Support'),
  ];

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: AppSpacing.l),
            Container(
              width: 1,
              height: 20,
              color: AppColors.border(context),
            ),
            const SizedBox(width: AppSpacing.l),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_items[i].$1, color: muted, size: 15),
              const SizedBox(width: 5),
              Text(
                _items[i].$2,
                style: tokens.AppText.body.copyWith(
                  color: muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// --- Shared animated slide widget ---------------------------------------

class _AnimatedSlide extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final Offset slideOffset;

  const _AnimatedSlide({
    required this.controller,
    required this.child,
    this.slideOffset = const Offset(0, 0.18),
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
