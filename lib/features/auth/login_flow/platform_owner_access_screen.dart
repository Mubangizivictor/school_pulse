import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/components/google_glyph.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Dedicated Platform Owner Access screen, reached only via the concealed
/// long-press on the welcome screen logo - never linked from any visible
/// UI, and never routed through the ordinary Staff Gateway.
///
/// Always renders in the dark premium treatment regardless of the device
/// theme, per spec: this is a deliberately distinct, restricted surface,
/// not one of the three portal cards.
///
/// Security note: a successful Google or email/password sign-in here is
/// only the first factor. `AuthBloc` calls the server-side
/// `assertPlatformOwnerAccess` callable before ever emitting
/// `AuthAuthenticated`; a non-owner identity is signed out and this screen
/// shows the same generic "Access denied" regardless of why. This screen
/// itself never reveals whether an owner account exists.
class PlatformOwnerAccessScreen extends StatefulWidget {
  const PlatformOwnerAccessScreen({super.key});

  @override
  State<PlatformOwnerAccessScreen> createState() =>
      _PlatformOwnerAccessScreenState();
}

class _PlatformOwnerAccessScreenState extends State<PlatformOwnerAccessScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmailPassword() {
    context.read<AuthBloc>().add(
      LoginOwnerWithEmailPressed(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _submitGoogle() {
    context.read<AuthBloc>().add(LoginOwnerWithGooglePressed());
  }

  void _submitApple() {
    context.read<AuthBloc>().add(LoginOwnerWithApplePressed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Platform owners are deliberately tenantless until they enter an
          // explicit support session, so they never run the school pipeline.
          context.go(UserRoleRouting.dashboardPath(state.user.role));
        } else if (state is AuthMfaChallengeRequired) {
          context.go('/auth/mfa-challenge', extra: state.resolver);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Access denied.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimaryDark,
              ),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/welcome'),
            ),
          ),
          body: Stack(
            children: [
              const Positioned.fill(child: _OwnerBackdrop()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    // Keep the form compact on phones while giving the paired
                    // social buttons equal, comfortable targets on web.
                    final isDesktop = viewport.maxWidth >= 1024;
                    final horizontalPadding = isDesktop
                        ? AppSpacing.x6l
                        : AppSpacing.x2l;
                    final formWidth = isDesktop ? 520.0 : 440.0;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.m,
                        horizontalPadding,
                        AppSpacing.x2l,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewport.maxHeight - AppSpacing.x3l,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _OwnerBadge(),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'School Pulse',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textSecondaryDark,
                                    letterSpacing: 2.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s),
                                Text(
                                  'Platform Owner Access',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: AppColors.textPrimaryDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.m),
                                Text(
                                  'Restricted platform administration',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.x3l),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SocialSignInButton(
                                        label: 'Google',
                                        icon: const GoogleGlyph(size: 20),
                                        onPressed: isLoading
                                            ? null
                                            : _submitGoogle,
                                        dimWhenDisabled: true,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.m),
                                    Expanded(
                                      child: _SocialSignInButton(
                                        label: 'Apple',
                                        icon: const Icon(Icons.apple, size: 22),
                                        onPressed: isLoading
                                            ? null
                                            : _submitApple,
                                        dimWhenDisabled: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _OrDivider(),
                                const SizedBox(height: AppSpacing.xl),
                                AuthField(
                                  label: 'Email Address',
                                  hint: 'Enter email',
                                  icon: Icons.mail_outline_rounded,
                                  foreground: AppColors.textPrimaryDark,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AuthField(
                                  label: 'Password',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  foreground: AppColors.textPrimaryDark,
                                  controller: _passwordController,
                                  isPassword: _obscure,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.x2l),
                                AuthCtaButton(
                                  label: 'Continue',
                                  gradient: const [
                                    Colors.black,
                                    AppColors.brightCyan,
                                  ],
                                  isLoading: isLoading,
                                  onPressed: isLoading
                                      ? null
                                      : _submitEmailPassword,
                                ),
                                const SizedBox(height: AppSpacing.x3l),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.verified_user_outlined,
                                      size: 16,
                                      color: AppColors.textMutedDark,
                                    ),
                                    const SizedBox(width: AppSpacing.s),
                                    Flexible(
                                      child: Text(
                                        'Secure access protected by additional verification.',
                                        textAlign: TextAlign.center,
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.textMutedDark,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceDark,
          border: Border.all(color: AppColors.textPrimaryDark, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryDark,
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.shield_moon_outlined,
          color: AppColors.textPrimaryDark,
          size: 36,
        ),
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool dimWhenDisabled;

  const _SocialSignInButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.dimWhenDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: dimWhenDisabled && !enabled ? 0.5 : 1,
      child: Material(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme(
                  data: const IconThemeData(color: AppColors.textPrimaryDark),
                  child: icon,
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.borderDark)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(
            'OR',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMutedDark,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.borderDark)),
      ],
    );
  }
}

/// Same deep-space backdrop family as the welcome screen, kept static (no
/// animation controller) since this screen doesn't need the pulse/entrance
/// choreography - just the visual language.
class _OwnerBackdrop extends StatelessWidget {
  const _OwnerBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OwnerBackdropPainter());
  }
}

class _OwnerBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black, Colors.black],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.18),
      size.width * 0.62,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppColors.brightCyan, AppColors.brightCyan],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width / 2, size.height * 0.18),
                radius: size.width * 0.62,
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(_OwnerBackdropPainter oldDelegate) => false;
}
