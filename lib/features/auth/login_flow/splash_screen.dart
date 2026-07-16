import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _pulseController;
  late Animation<double> _rotateAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _opacityAnim;

  bool _animationFinished = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _rotateAnim = Tween<double>(begin: 0, end: 6.28319).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOutBack),
    );

    _scaleAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
        );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _iconController.forward().then((_) {
      if (mounted) {
        setState(() => _animationFinished = true);
        debugPrint('SplashScreen: Animation finished. Checking for navigation...');
        _navigateToNextIfReady();
      }
    });
  }

  void _navigateToNextIfReady() {
    if (!_animationFinished || _isNavigating) return;

    final authState = context.read<AuthBloc>().state;
    final configState = context.read<SystemConfigBloc>().state;

    // We wait for both Authentication and System Configuration (Branding)
    // to be decided before moving off the primary splash screen.
    final isAuthDecided =
        authState is AuthAuthenticated || 
        authState is AuthUnauthenticated || 
        authState is AuthFailureState;
        
    final isConfigDecided =
        configState is SystemConfigLoaded || 
        configState is SystemConfigError;

    debugPrint('SplashScreen: Readiness Check - Auth: ${authState.runtimeType} (Decided: $isAuthDecided), '
        'Config: ${configState.runtimeType} (Decided: $isConfigDecided)');

    if (!isAuthDecided || !isConfigDecided) {
      debugPrint('SplashScreen: Still waiting for states to settle...');
      return;
    }

    _isNavigating = true;
    debugPrint('SplashScreen: All conditions met. Transitioning...');

    if (authState is AuthAuthenticated) {
      final user = authState.user;

      debugPrint('SplashScreen: Navigating to branded school splash for user: ${user.id}');
      context.go('/school-splash', extra: user);
    } else if (authState is AuthUnauthenticated || authState is AuthFailureState) {
      // AuthUnauthenticated or AuthFailureState
      debugPrint('SplashScreen: Unauthenticated or Failure. Navigating to welcome');
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated || 
                state is AuthUnauthenticated || 
                state is AuthFailureState) {
              _navigateToNextIfReady();
            }
          },
        ),
        BlocListener<SystemConfigBloc, SystemConfigState>(
          listener: (context, state) {
            if (state is SystemConfigLoaded || state is SystemConfigError) {
              _navigateToNextIfReady();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: primaryColor,
        body: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Container(
                    width: 200 * _pulseAnim.value,
                    height: 200 * _pulseAnim.value,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _iconController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnim.value,
                        child: Transform.rotate(
                          angle: _rotateAnim.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(Icons.school, size: 80, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _opacityAnim,
                    child: Column(
                      children: [
                        const Text(
                          'School Pulse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PRECISION IN EDUCATION',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _opacityAnim,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
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
