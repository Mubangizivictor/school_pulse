import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';

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
      duration: const Duration(milliseconds: 900),
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
    // Keep the platform identity quick while the auth restoration is already
    // running in parallel.
    await Future.delayed(const Duration(milliseconds: 900));
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
    // superAdmin is the SaaS platform owner, not a school tenant - they have
    // no schoolId to resolve and must never enter the tenant-bootstrap
    // pipeline. The router's own redirect already exempts every superAdmin
    // route from the tenant check (see router.dart), but /school-bootstrap
    // has no such exemption and no way back out once landed on, so a
    // superAdmin sent there was stuck on "Preparing your school workspace"
    // indefinitely. Route them straight to the owner console instead.
    if (state.user.role == UserRole.superAdmin) {
      context.go(UserRoleRouting.dashboardPath(UserRole.superAdmin));
      return;
    }
    // Tenant membership and Structure-owned branding must resolve before any
    // protected dashboard is allowed to build.
    context.go('/school-bootstrap');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundGradient = isDark
        ? AppGradients.premiumDark
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.iceBlue,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
              AppColors.bgLight,
            ],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
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
                        variant: PulseLogoVariant.splash,
                        width: 220,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      Text('School Pulse', style: AppTypography.titleLarge),
                    ],
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
