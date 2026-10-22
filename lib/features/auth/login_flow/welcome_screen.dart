import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart' as tokens;
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';

/// A deliberately quiet entry point for the three School Pulse portals.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, layout) {
            final isMobile = layout == ResponsiveLayout.mobile;
            final contentWidth = layout == ResponsiveLayout.desktop
                ? 560.0
                : 480.0;
            final horizontalPadding = isMobile ? AppSpacing.xl : AppSpacing.x4l;
            final verticalPadding = isMobile ? AppSpacing.x3l : AppSpacing.x5l;

            return LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewport.maxHeight - (verticalPadding * 2),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _WelcomeBrand(),
                          const SizedBox(height: AppSpacing.x5l),
                          const SizedBox(height: AppSpacing.xl),
                          _RoleCard(
                            title: 'Parent Portal',
                            subtitle: "Manage your child's education",
                            icon: Icons.people_alt_rounded,
                            onTap: () => context.push('/parent/login/child-id'),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          _RoleCard(
                            title: 'Staff Gateway',
                            subtitle: 'School operations & management',
                            icon: Icons.badge_rounded,
                            onTap: () => context.push('/staff/login'),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          _RoleCard(
                            title: 'Student Hub',
                            subtitle: 'Your learning journey begins here',
                            icon: Icons.school_rounded,
                            onTap: () => context.push('/student/login'),
                          ),
                          const SizedBox(height: AppSpacing.x5l),
                          const _TrustRow(),
                          const SizedBox(height: AppSpacing.x4l),
                          Text(
                            '© 2024 School Pulse. All rights reserved.',
                            textAlign: TextAlign.center,
                            style: tokens.AppText.body.copyWith(
                              color: AppColors.textMuted(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

/// Uses a reliable vector mark instead of the splash asset. The old asset's
/// large transparent bounds made the badge appear missing on some devices.
class _WelcomeBrand extends StatefulWidget {
  const _WelcomeBrand();

  @override
  State<_WelcomeBrand> createState() => _WelcomeBrandState();
}

class _WelcomeBrandState extends State<_WelcomeBrand> {
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
    _cancelHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branding = context.watch<ThemeProvider>().branding;
    final foreground = AppColors.textPrimary(context);
    final schoolName = branding?.schoolName.trim().isNotEmpty == true
        ? branding!.schoolName
        : 'SCHOOL PULSE';
    final motto = branding?.schoolMotto.trim().isNotEmpty == true
        ? branding!.schoolMotto
        : 'Your school, in sync';
    final badgeUrl = branding?.badgeUrl ?? branding?.logoUrl;
    return GestureDetector(
      onLongPressStart: (_) => _armHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: Semantics(
        label: 'School Pulse',
        child: Column(
          children: [
            SchoolBadge(badgeUrl: badgeUrl, size: 84),
            const SizedBox(height: AppSpacing.l),
            Text(
              schoolName.toUpperCase(),
              textAlign: TextAlign.center,
              style: tokens.AppText.body.copyWith(
                color: foreground,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.black;
    final background = isDark ? AppColors.grey850 : AppColors.white;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: foreground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: background, size: 30),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tokens.AppText.body.copyWith(
                          color: AppColors.textPrimary(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.35,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: tokens.AppText.body.copyWith(
                          color: AppColors.textSecondary(context),
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textPrimary(context),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TrustItem(
            icon: Icons.verified_user_outlined,
            label: 'Secure',
            color: color,
          ),
          _TrustItem(
            icon: Icons.cloud_done_outlined,
            label: 'Reliable',
            color: color,
          ),
          _TrustItem(
            icon: Icons.headset_mic_outlined,
            label: 'Support',
            color: color,
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.s),
          Text(
            label,
            style: tokens.AppText.body.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
