import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';

/// The auth-check hand-off from the native splash. Renders nothing visible
/// so it reads as a continuation of the native splash rather than a second,
/// different-looking screen, and resolves as soon as the auth state is known.
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
    // profile fetch) may still be in flight, e.g. on a slow network or cold
    // start. Resolving that as "unauthenticated" would force a valid session
    // back to the login screen, so wait for the real result instead of
    // racing a fixed timer, but cap the wait so a stuck check doesn't strand
    // the user on the splash screen.
    final resolvedState = await authBloc.stream
        .firstWhere(
          (state) => state is AuthAuthenticated || state is AuthUnauthenticated,
        )
        .timeout(
          const Duration(milliseconds: 800),
          onTimeout: () => AuthUnauthenticated(),
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
    // pipeline. The router's own redirect already exempts every superAdmin
    // route from the tenant check (see router.dart).
    if (state.user.role == UserRole.superAdmin) {
      context.go(UserRoleRouting.dashboardPath(UserRole.superAdmin));
      return;
    }
    // SchoolSplashScreen resolves tenant membership and Structure-owned
    // branding itself before any protected dashboard is allowed to render.
    context.go('/school-splash');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: isDark ? Colors.black : Colors.white);
  }
}
