import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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

    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // The initial AuthCheckRequested read (Firebase session + Firestore
    // profile fetch) may still be in flight after the splash delay, e.g. on
    // a slow network or cold start. Resolving that as "unauthenticated"
    // would force a valid session back to the login screen, so wait for the
    // real result instead of racing a fixed timer.
    if (authState is AuthAuthenticated) {
      _navigate(authState);
      return;
    }
    if (authState is AuthUnauthenticated) {
      context.go('/welcome');
      return;
    }

    final resolvedState = await authBloc.stream.firstWhere(
      (state) => state is AuthAuthenticated || state is AuthUnauthenticated,
    );
    if (!mounted) return;
    if (resolvedState is AuthAuthenticated) {
      _navigate(resolvedState);
    } else {
      context.go('/welcome');
    }
  }

  void _navigate(AuthAuthenticated state) {
    context.go(UserRoleRouting.dashboardPath(state.user.role));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final taglineColor = isDark
        ? AppColors.iceBlue.withValues(alpha: 0.7)
        : AppColors.textSecondaryLight;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: isDark ? AppGradients.premiumDark : null,
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
                          AppColors.electricBlue.withValues(
                            alpha: 0.15 * (1 - _controller.value),
                          ),
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
                      PulseLogo(
                        variant: PulseLogoVariant.vertical,
                        width: 240,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 48),
                      const SchoolPulseLoader.small(),
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
                      color: taglineColor,
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
