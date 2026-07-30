import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffCredentialsScreen extends StatefulWidget {
  const StaffCredentialsScreen({super.key});

  @override
  State<StaffCredentialsScreen> createState() => _StaffCredentialsScreenState();
}

class _StaffCredentialsScreenState extends State<StaffCredentialsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.read<AuthBloc>().add(LoginWithEmailPressed(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.mustChangePassword) {
            context.go('/auth/force-setup', extra: state.user);
          } else {
            context.go('/school-splash', extra: state.user);
          }
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark ? AppGradients.premiumDark : null,
              color: isDark ? null : AppColors.bgLight,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.x3l),
                child: ResponsiveBuilder(
                  builder: (context, layout) {
                    final isDesktop = layout == ResponsiveLayout.desktop;
                    
                    return Container(
                      constraints: BoxConstraints(maxWidth: isDesktop ? 450 : 400),
                      padding: isDesktop ? const EdgeInsets.all(AppSpacing.x4l) : null,
                        decoration: isDesktop ? BoxDecoration(
                          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.borderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: PulseLogo(size: 80, variant: PulseLogoVariant.auth),
                          ),
                          const SizedBox(height: AppSpacing.x4l),
                          Text(
                            "Staff Portal",
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "Enter your credentials to continue",
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.x6l),
                          PulseTextField(
                            label: 'Email Address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            hint: 'name@school.com',
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PulseTextField(
                            label: 'Password',
                            controller: _passwordController,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            hint: '••••••••',
                          ),
                          const SizedBox(height: AppSpacing.x4l),
                          PulseButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _handleLogin,
                            isFullWidth: true,
                          ),
                          const SizedBox(height: AppSpacing.x2l),
                          TextButton(
                            onPressed: () {
                              // Forgot password logic
                            },
                            child: Text(
                              "Forgot Password?",
                              style: AppTypography.labelLarge.copyWith(
                                color: isDark ? AppColors.brightCyan : AppColors.royalBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

