import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';

class SchoolSplashScreen extends StatefulWidget {
  final UserEntity user;
  const SchoolSplashScreen({super.key, required this.user});

  @override
  State<SchoolSplashScreen> createState() => _SchoolSplashScreenState();
}

class _SchoolSplashScreenState extends State<SchoolSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
    ]).animate(_mainController);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );

    _mainController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<SystemConfigBloc>().state;
        if (state is SystemConfigLoaded || state is SystemConfigError) {
          _scheduleNavigation();
        }
      }
    });

    _fallbackTimer = Timer(const Duration(seconds: 8), _scheduleNavigation);
  }

  Timer? _fallbackTimer;
  bool _navigationScheduled = false;

  void _scheduleNavigation() {
    if (_navigationScheduled) return;
    _navigationScheduled = true;
    
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _mainController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    final user = widget.user;
    if (user.role == UserRole.parent) {
      context.go('/parent/home');
    } else if (user.roles.length > 1) {
      context.go('/staff/hub');
    } else {
      context.go(UserRoleRouting.dashboardPath(user.role));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<SystemConfigBloc, SystemConfigState>(
      listener: (context, state) {
        if (state is SystemConfigLoaded || state is SystemConfigError) {
          _scheduleNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: BlocBuilder<SystemConfigBloc, SystemConfigState>(
          builder: (context, state) {
            final config = state is SystemConfigLoaded 
                ? state.config 
                : (state is SystemConfigError ? state.config : null);

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x4l),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) => Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(scale: _logoScale.value, child: child),
                      ),
                      child: const PulseLogo(size: 100, variant: PulseLogoVariant.vertical),
                    ),
                    const SizedBox(height: AppSpacing.x6l),
                    if (config != null)
                      FadeTransition(
                        opacity: _contentOpacity,
                        child: Column(
                          children: [
                            Text(
                              config.schoolName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTypography.headlineMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Container(
                              height: 2,
                              width: 60,
                              color: AppColors.electricBlue.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              config.schoolMotto,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x7l),
                            Text(
                              "Welcome back,",
                              style: AppTypography.bodyLarge,
                            ),
                            Text(
                              widget.user.name,
                              style: AppTypography.titleLarge.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
