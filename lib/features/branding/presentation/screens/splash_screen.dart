import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/brand/animated_pulse_mark.dart';
import 'package:school_pulse/design_system/brand/brand_assets.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';

/// Minimum time (ms) the splash is shown so the animation always plays
/// even on a warm/cached auth start where Firebase resolves instantly.
const _kMinSplashMs = 1600;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wordmarkCtrl;
  late final Animation<double> _wordmarkFade;

  @override
  void initState() {
    super.initState();
    _wordmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wordmarkFade = CurvedAnimation(parent: _wordmarkCtrl, curve: Curves.easeOut);

    // Fade the wordmark in after the mark has had a moment to animate.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _wordmarkCtrl.forward();
    });

    _checkAuth();
  }

  @override
  void dispose() {
    _wordmarkCtrl.dispose();
    super.dispose();
  }

  void _checkAuth() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // Always enforce the minimum display time so the animation is visible.
    final minDelay = Future.delayed(const Duration(milliseconds: _kMinSplashMs));

    AuthState resolvedState;

    if (authState is AuthAuthenticated || authState is AuthUnauthenticated) {
      resolvedState = authState;
    } else {
      resolvedState = await authBloc.stream.firstWhere(
        (s) => s is AuthAuthenticated || s is AuthUnauthenticated,
      );
    }

    // Wait for both: auth resolved AND minimum time elapsed.
    await minDelay;

    FlutterNativeSplash.remove();
    if (!mounted) return;

    if (resolvedState is AuthAuthenticated) {
      _navigate(resolvedState);
    } else {
      context.go('/welcome');
    }
  }

  void _navigate(AuthAuthenticated state) {
    if (state.user.role == UserRole.superAdmin) {
      if (!kIsWeb) {
        context.go('/welcome');
        return;
      }
      context.go(UserRoleRouting.dashboardPath(UserRole.superAdmin));
      return;
    }
    context.go('/school-splash');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColorValues.lightSecondary
          : AppColorValues.lightSurface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedPulseMark(
              size: 96,
              brightness: brightness,
              semanticsLabel: 'Loading School Pulse',
              skipIntro: kIsWeb,
            ),
            const SizedBox(height: 14),
            FadeTransition(
              opacity: _wordmarkFade,
              child: Image.asset(
                isDark ? BrandAssets.wordmarkDark : BrandAssets.wordmarkLight,
                width: 160,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
