import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/data/models/system_config.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class SchoolSplashScreen extends StatefulWidget {
  final UserEntity user;
  const SchoolSplashScreen({super.key, required this.user});

  @override
  State<SchoolSplashScreen> createState() => _SchoolSplashScreenState();
}

class _SchoolSplashScreenState extends State<SchoolSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  
  // Logo Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  
  // Text Animations
  late Animation<Offset> _textSlide;
  late Animation<double> _nameOpacity;
  late Animation<double> _mottoOpacity;
  late Animation<double> _dividerWidth;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),
    ]).animate(_mainController);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    _mottoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();

    // Check if config is already loaded from the watch started in main.dart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<SystemConfigBloc>().state;
        if (state is SystemConfigLoaded) {
          _scheduleNavigation();
        }
      }
    });
  }

  bool _navigationScheduled = false;
  void _scheduleNavigation() {
    if (_navigationScheduled) return;
    _navigationScheduled = true;
    // Wait for animation + a small delay for branding impact
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _navigateToHome();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    final user = widget.user;
    if (user.role == UserRole.parent) {
      context.go('/parent/home');
    } else {
      context.go(UserRoleRouting.dashboardPath(user.role));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SystemConfigBloc, SystemConfigState>(
      listener: (context, state) {
        if (state is SystemConfigLoaded) {
          _scheduleNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocBuilder<SystemConfigBloc, SystemConfigState>(
          builder: (context, state) {
            if (state is SystemConfigLoaded) {
              final config = state.config;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildLogo(config),
                      ),
                      const SizedBox(height: 48),
                      
                      // School Name
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _nameOpacity,
                          child: Text(
                            config.schoolName.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Animated Divider
                      AnimatedBuilder(
                        animation: _dividerWidth,
                        builder: (context, child) {
                          return Container(
                            height: 2,
                            width: 80 * _dividerWidth.value,
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Motto
                      FadeTransition(
                        opacity: _mottoOpacity,
                        child: Text(
                          config.schoolMotto,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.2,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildLogo(SystemConfig config) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: config.schoolLogoUrl != null && config.schoolLogoUrl!.isNotEmpty
            ? Image.network(
                config.schoolLogoUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.school,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Icon(
                Icons.school,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
      ),
    );
  }
}

