import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Student Hub sign-in screen. Students receive a school-issued email
/// address and a temporary password from their school administrator; they
/// sign in here using those credentials.
class StudentHubScreen extends StatefulWidget {
  const StudentHubScreen({super.key});

  @override
  State<StudentHubScreen> createState() => _StudentHubScreenState();
}

class _StudentHubScreenState extends State<StudentHubScreen> {
  static const _accent = AppColors.successGreen;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    context.read<AuthBloc>().add(
      LoginWithEmailPressed(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.mustChangePassword) {
            context.go('/auth/force-setup', extra: state.user);
          } else {
            context.go('/school-splash');
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
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AuthPortalScaffold(
          accent: _accent,
          alignToTop: true,
          title: 'Student Hub',
          backgroundColor: isDark
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.surfaceLight,
          children: [
            const SizedBox(height: AppSpacing.x3l),
            Text(
              'Sign in with the email and password\nprovided by your school.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.x6l),
            _StudentField(
              label: 'School Email',
              hint: 'student@school.edu',
              icon: Icons.school_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              accent: _accent,
            ),
            const SizedBox(height: AppSpacing.x3l),
            _StudentField(
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              isPassword: _obscure,
              accent: _accent,
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
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.push('/auth/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
            AuthCtaButton(
              label: 'Sign In',
              gradient: const [Colors.black, Colors.black],
              filled: !isDark,
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: AppSpacing.x4l),
            _StudentContactNote(),
          ],
        );
      },
    );
  }
}

class _StudentField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? suffix;
  final Color accent;

  const _StudentField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.textPrimary(context), width: 1.25),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            cursorColor: accent,
            autofillHints: isPassword
                ? const [AutofillHints.password]
                : const [AutofillHints.username, AutofillHints.email],
            style: AppTypography.bodyLarge.copyWith(
              color: colors.onSurface,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              hintText: hint,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary(context),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: colors.surface, size: 23),
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(
                width: 64,
                height: 56,
              ),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentContactNote extends StatelessWidget {
  const _StudentContactNote();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.successGreen.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              "Your sign-in details are issued by your school. Contact your class teacher or school admin if you haven't received them.",
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
