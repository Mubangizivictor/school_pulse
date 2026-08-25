import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';
import 'package:school_pulse/features/auth/data/datasources/remembered_login_store.dart';
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
  final _rememberedLoginStore = RememberedLoginStore();
  bool _obscure = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _rememberedLoginStore.getStaffEmail().then((email) {
      if (!mounted || email == null) return;
      setState(() => _emailController.text = email);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    _rememberedLoginStore.setStaffEmail(_rememberMe ? email : null);
    context.read<AuthBloc>().add(
      LoginWithEmailPressed(email: email, password: _passwordController.text),
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
          title: 'Staff Portal',
          backgroundColor: isDark
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.surfaceLight,
          children: [
            const SizedBox(height: AppSpacing.x3l),
            Text(
              'Enter your credentials to continue\naccessing the staff portal.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.45,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: AppSpacing.x6l),
            _StaffPortalField(
              label: 'Email Address',
              hint: 'name@school.com',
              icon: Icons.mail_outline_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.x3l),
            _StaffPortalField(
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
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
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    side: BorderSide(color: colorScheme.onSurface, width: 1.6),
                    activeColor: colorScheme.onSurface,
                    checkColor: colorScheme.surface,
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
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3l),
            AuthCtaButton(
              label: 'Sign In',
              gradient: const [Color(0xFFEF4A17), Color(0xFFFFB020)],
              filled: !isDark,
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: AppSpacing.x3l),
            const _StaffTrustStrip(),
            const SizedBox(height: AppSpacing.x3l),
            const _StaffPrivacyNote(),
          ],
        );
      },
    );
  }
}

/// The staff portal's clean, focused badge treatment.  It deliberately stays
/// local to this page so the Parent and Platform Owner entry screens retain
/// their existing presentation.
class _StaffPortalField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _StaffPortalField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = AppColors.textPrimary(context);
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
            border: Border.all(
              color: accent.withValues(alpha: .8),
              width: 1.25,
            ),
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
              letterSpacing: .1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              hintText: hint,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: .65),
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
                      color: accent.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: accent, size: 23),
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

class _StaffTrustStrip extends StatelessWidget {
  const _StaffTrustStrip();

  static const _items = [
    (Icons.verified_user_outlined, 'Secure', 'Your data is\nprotected'),
    (Icons.cloud_sync_outlined, 'Sync', 'Works online\n& offline'),
    (Icons.speed_outlined, 'Fast', 'Built for\nperformance'),
    (Icons.headset_mic_outlined, 'Support', 'We are here\nto help'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = AppColors.textPrimary(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++) ...[
              if (index != 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: .45),
                ),
              Expanded(
                child: Column(
                  children: [
                    Icon(_items[index].$1, color: accent, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      _items[index].$2,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _items[index].$3,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.5,
                        height: 1.45,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StaffPrivacyNote extends StatelessWidget {
  const _StaffPrivacyNote();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = AppColors.textPrimary(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: .11),
            ),
            child: Icon(Icons.lock_outline_rounded, color: accent, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is secure with us',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We value your privacy and protect your information.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
