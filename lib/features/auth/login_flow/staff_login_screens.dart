import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Staff Portal sign-in. Orange accent, email + password, remember-me and a
/// forgot-password link, then the trust strip and privacy note.
class StaffCredentialsScreen extends StatefulWidget {
  const StaffCredentialsScreen({super.key});

  @override
  State<StaffCredentialsScreen> createState() => _StaffCredentialsScreenState();
}

class _StaffCredentialsScreenState extends State<StaffCredentialsScreen> {
  static const _accent = AppColors.brightOrange;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.read<AuthBloc>().add(
      LoginWithEmailPressed(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.mustChangePassword) {
            // Institution Administrators get the full first-login security
            // and institution-confirmation flow; other staff just change
            // their temporary password.
            final route = state.user.role == UserRole.schoolAdmin
                ? '/auth/onboarding'
                : '/auth/force-setup';
            context.go(route, extra: state.user);
          } else {
            context.go('/school-splash', extra: state.user);
          }
        } else if (state is AuthMfaChallengeRequired) {
          context.go('/auth/mfa-challenge', extra: state.resolver);
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
        final colorScheme = Theme.of(context).colorScheme;

        return AuthPortalScaffold(
          accent: _accent,
          children: [
            const AuthHeroScene(
              accent: _accent,
              badgeIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Staff Portal',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Enter your credentials to continue\naccessing the staff portal.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            AuthField(
              label: 'Email Address',
              hint: 'name@school.com',
              icon: Icons.mail_outline_rounded,
              accent: _accent,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthField(
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              accent: _accent,
              controller: _passwordController,
              isPassword: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    side: const BorderSide(color: _accent, width: 1.6),
                    activeColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Text(
                  'Remember me',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthCtaButton(
              label: 'Sign In',
              gradient: const [Color(0xFFEF4A17), Color(0xFFFFB020)],
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: AppSpacing.xl),
            const AuthTrustStrip(accent: _accent),
            const SizedBox(height: AppSpacing.xl),
            const AuthPrivacyNote(accent: _accent),
          ],
        );
      },
    );
  }
}
