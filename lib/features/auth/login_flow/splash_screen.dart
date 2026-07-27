import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    // Give it a small delay just to show the logo briefly if everything is cached
    Timer(const Duration(seconds: 2), _navigateToNextIfReady);

    _fallbackTimer = Timer(const Duration(seconds: 10), () {
      if (_isNavigating || !mounted) return;
      _navigateToNextIfReady();
    });
  }

  void _navigateToNextIfReady() {
    if (_isNavigating || !mounted) return;

    final authState = context.read<AuthBloc>().state;
    final configState = context.read<SystemConfigBloc>().state;

    final isAuthDecided =
        authState is AuthAuthenticated || 
        authState is AuthUnauthenticated || 
        authState is AuthFailureState;
        
    final isConfigDecided =
        configState is SystemConfigLoaded || 
        configState is SystemConfigError;

    if (!isAuthDecided || !isConfigDecided) return;

    _isNavigating = true;

    if (authState is AuthAuthenticated) {
      context.go('/school-splash', extra: authState.user);
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) => _navigateToNextIfReady(),
        ),
        BlocListener<SystemConfigBloc, SystemConfigState>(
          listener: (context, state) => _navigateToNextIfReady(),
        ),
      ],
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'School Pulse',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
