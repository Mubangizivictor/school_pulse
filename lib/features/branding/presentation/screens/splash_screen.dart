import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.bounceOut),
      ),
    );

    _controller.forward();
    _checkAuth();
  }

  void _checkAuth() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    final brandingState = context.read<BrandingBloc>().state;

    if (authState is AuthAuthenticated) {
      if (brandingState is BrandingLoaded && brandingState.branding != null) {
        context.go('/branded-splash');
      } else {
        context.go(UserRoleRouting.dashboardPath(authState.user.role));
      }
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.premiumDark,
        ),
        child: Stack(
          children: [
            // Background Pulse Effect (Subtle)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 300 * _controller.value,
                    height: 300 * _controller.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.electricBlue.withValues(alpha: 0.15 * (1 - _controller.value)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PulseLogo(
                        variant: PulseLogoVariant.vertical,
                        width: 240,
                      ),
                      const SizedBox(height: 48),
                      // Loading indicator
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brightCyan),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Tagline at the bottom
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    'Modern Education Innovation',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.iceBlue.withValues(alpha: 0.7),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
