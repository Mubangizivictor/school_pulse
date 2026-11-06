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

/// The auth-check hand-off from the native splash.
///
/// It repeats the native splash layout exactly (same background, same mark
/// at the same size and position, same wordmark at the bottom) so the
/// hand-off is invisible, then animates the mark with the brand pulse while
/// the auth state resolves. It navigates as soon as that state is known.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // When the auth state is already resolved at first build (e.g. a warm
    // start, or a test that signs in before pumping), navigating straight
    // from initState runs router redirects against a not-yet-stable element
    // tree ("deactivated widget's ancestor"). Defer to after the first
    // frame; the async branch below is already post-frame by construction.
    if (authState is AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
        if (mounted) _navigate(authState);
      });
      return;
    }
    if (authState is AuthUnauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
        if (mounted) context.go('/welcome');
      });
      return;
    }

    // The initial AuthCheckRequested read (Firebase session + Firestore
    // profile fetch, plus a live verifyOwnerSession round trip for a
    // superAdmin session) may still be in flight, e.g. on a slow network or
    // cold start - routinely well over a second before a cold Cloud
    // Function instance responds. Resolving that as "unauthenticated" would
    // force a valid, still-persisted session back to the login screen, so
    // wait for the real result instead of racing a fixed timer. AuthBloc's
    // own internal timeouts (15s per network step) are the actual backstop
    // against a stuck check stranding the user here.
    final resolvedState = await authBloc.stream.firstWhere(
      (state) => state is AuthAuthenticated || state is AuthUnauthenticated,
    );
    FlutterNativeSplash.remove();
    if (!mounted) return;
    if (resolvedState is AuthAuthenticated) {
      _navigate(resolvedState);
    } else {
      context.go('/welcome');
    }
  }

  void _navigate(AuthAuthenticated state) {
    // superAdmin is the SaaS platform owner, not a school tenant - they have
    // no schoolId to resolve and must never enter the tenant-branding
    // pipeline. On mobile the console is unavailable; redirect to /welcome
    // so the super admin sees a clear message rather than a redirect loop.
    if (state.user.role == UserRole.superAdmin) {
      if (!kIsWeb) {
        context.go('/welcome');
        return;
      }
      context.go(UserRoleRouting.dashboardPath(UserRole.superAdmin));
      return;
    }
    // SchoolSplashScreen resolves tenant membership and Structure-owned
    // branding itself before any protected dashboard is allowed to render.
    context.go('/school-splash');
  }

  @override
  Widget build(BuildContext context) {
    // The native splash follows the OS theme, not the saved in-app theme.
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;
    return Scaffold(
      // Must match flutter_native_splash.yaml `color` / `color_dark`.
      backgroundColor: isDark
          ? AppColorValues.lightSecondary
          : AppColorValues.lightSurface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedPulseMark(
              size: AnimatedPulseMark.splashSize,
              brightness: brightness,
              semanticsLabel: 'Loading School Pulse',
              // web/index.html already played the intro in its HTML splash.
              skipIntro: kIsWeb,
            ),
            const SizedBox(height: 20),
            Image.asset(
              isDark ? BrandAssets.wordmarkDark : BrandAssets.wordmarkLight,
              // The wordmark is a 4x asset, like the native branding image.
              width: 731 / 4,
              excludeFromSemantics: true,
            ),
          ],
        ),
      ),
    );
  }
}
