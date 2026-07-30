import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.02).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    ]).animate(_mainController);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ThemeProvider>().config;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.premiumDark : null,
          color: isDark ? null : AppColors.bgLight,
        ),
        child: ResponsiveBuilder(
          builder: (context, layout) {
            final isDesktop = layout == ResponsiveLayout.desktop;
            
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? AppSpacing.x7l : AppSpacing.x3l,
                    vertical: AppSpacing.x3l,
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                          child: const PulseLogo(size: 100, variant: PulseLogoVariant.full),
                        ),
                        const SizedBox(height: AppSpacing.x6l),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                Text(
                                  config?.schoolName ?? 'School Pulse',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.headlineLarge.copyWith(
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSpacing.s),
                                  ),
                                  child: Text(
                                    config?.schoolMotto ?? 'Precision in Education Management',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isDark ? AppColors.brightCyan : AppColors.royalBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.x8l),
                                if (isDesktop) 
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _RoleCard(
                                          title: "I'm a Parent",
                                          subtitle: "Access student grades, attendance, and financial records in real-time.",
                                          icon: Icons.family_restroom_rounded,
                                          onTap: () => context.push('/parent/login/child-id'),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xl),
                                      Expanded(
                                        child: _RoleCard(
                                          title: "I'm a Staff Member",
                                          subtitle: "Manage academic operations, student tracking, and administrative tasks.",
                                          icon: Icons.badge_rounded,
                                          onTap: () => context.push('/staff/login'),
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _RoleCard(
                                    title: "I'm a Parent",
                                    subtitle: "Check grades, fees & attendance",
                                    icon: Icons.family_restroom_rounded,
                                    onTap: () => context.push('/parent/login/child-id'),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  _RoleCard(
                                    title: "I'm a Staff Member",
                                    subtitle: "Manage classes and student records",
                                    icon: Icons.badge_rounded,
                                    onTap: () => context.push('/staff/login'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
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

    return PulseCard(
      onTap: onTap,
      variant: PulseCardVariant.glass,
      padding: const EdgeInsets.all(AppSpacing.x3l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppSpacing.l),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? AppColors.brightCyan : AppColors.royalBlue,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

