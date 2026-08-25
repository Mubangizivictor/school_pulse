import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/data/datasources/remembered_login_store.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/injection_container.dart' as di;

class ParentAuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;

  const ParentAuthLayout({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  padding: isDesktop
                      ? const EdgeInsets.all(AppSpacing.x4l)
                      : null,
                  decoration: isDesktop
                      ? BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? AppColors.white
                                : AppColors.borderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: PulseLogo(
                          width: 320,
                          variant: PulseLogoVariant.auth,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        title,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      child,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ChildIdScreen extends StatefulWidget {
  const ChildIdScreen({super.key});

  @override
  State<ChildIdScreen> createState() => _ChildIdScreenState();
}

class _ChildIdScreenState extends State<ChildIdScreen> {
  final _controller = TextEditingController();
  final _rememberedLoginStore = RememberedLoginStore();
  bool _isValid = false;
  bool _isLooking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validate);
    _rememberedLoginStore.getParentIdentity().then((identity) {
      if (!mounted || identity == null) return;
      setState(() => _controller.text = identity.code);
    });
  }

  void _validate() {
    final text = _controller.text;
    final regex = RegExp(r'^[A-Z]{3}\d{4}$');
    setState(() {
      _isValid = regex.hasMatch(text);
      _error = null;
    });
  }

  Future<void> _continue() async {
    setState(() {
      _isLooking = true;
      _error = null;
    });

    final result = await di.sl<ResolveParentAccessCode>()(_controller.text);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isLooking = false;
        _error = failure.message;
      }),
      (accessCode) {
        setState(() => _isLooking = false);
        context.push('/parent/login/verify', extra: accessCode);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AuthPortalScaffold(
      accent: AppColors.emeraldGreen,
      alignToTop: true,
      title: 'Parent Portal',
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      children: [
        const _ParentPortalIntroduction(),
        const SizedBox(height: AppSpacing.x5l),
        _ParentAccessCodeField(
          label: 'Access Code',
          hint: 'e.g. KHA1234',
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          errorText: _error,
        ),
        const SizedBox(height: AppSpacing.x2l),
        const _ParentPortalHelpCard(),
        const SizedBox(height: AppSpacing.x2l),
        _ParentContinueButton(
          isLoading: _isLooking,
          onPressed: _isValid && !_isLooking ? _continue : null,
        ),
        const SizedBox(height: AppSpacing.x3l),
        const _ParentPortalPrivacyNote(),
      ],
    );
  }
}

class _ParentPortalIntroduction extends StatelessWidget {
  const _ParentPortalIntroduction();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Text(
      "Enter the code provided by the school office to access your child's records.",
      textAlign: TextAlign.center,
      style: AppTypography.bodyMedium.copyWith(
        color: textColor,
        fontSize: 14,
        height: 1.45,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _ParentAccessCodeField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextCapitalization textCapitalization;
  final String? errorText;

  const _ParentAccessCodeField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.textCapitalization,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.textPrimary(context);
    final radius = BorderRadius.circular(16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleLarge.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          textCapitalization: textCapitalization,
          style: AppTypography.bodyLarge.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            errorMaxLines: 2,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(Icons.vpn_key_outlined, color: accent, size: 29),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: accent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParentPortalHelpCard extends StatelessWidget {
  const _ParentPortalHelpCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.textPrimary(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3l,
        vertical: AppSpacing.x2l,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accent, size: 34),
          const SizedBox(width: AppSpacing.x2l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't have a code?",
                  style: AppTypography.bodyLarge.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  "Please contact your school's\nadministration office.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Icon(Icons.support_agent_rounded, color: accent, size: 36),
        ],
      ),
    );
  }
}

class _ParentContinueButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ParentContinueButton({required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = Theme.of(context).colorScheme.onSurface;
    final fill = isDark ? Colors.white : Colors.black;
    final foreground = isDark ? Colors.black : Colors.white;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continue',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              color: enabled ? fill : disabled,
              borderRadius: BorderRadius.circular(18),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: fill,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        enabled ? foreground : fill,
                      ),
                    ),
                  )
                else ...[
                  Text(
                    'Continue',
                    style: AppTypography.titleLarge.copyWith(
                      color: enabled ? foreground : fill,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.x3l,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: enabled ? foreground : fill,
                      size: 31,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentPortalPrivacyNote extends StatelessWidget {
  const _ParentPortalPrivacyNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.textPrimary(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shield_outlined, color: accent, size: 34),
              Positioned(
                top: 23,
                child: Icon(Icons.lock_rounded, color: accent, size: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your data is secure with us',
                style: AppTypography.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'We value your privacy and protect your information.',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ParentPhoneScreen extends StatefulWidget {
  final ParentAccessCode? accessCode;
  const ParentPhoneScreen({super.key, this.accessCode});

  @override
  State<ParentPhoneScreen> createState() => _ParentPhoneScreenState();
}

class _ParentPhoneScreenState extends State<ParentPhoneScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _verifyPhone() {
    if (widget.accessCode == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final inputPhone = PhoneFormatter.toE164(_phoneController.text);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (widget.accessCode!.phoneNumber == inputPhone) {
        setState(() => _isLoading = false);
        context.push(
          '/parent/login/pin',
          extra: {'accessCode': widget.accessCode, 'phoneNumber': inputPhone},
        );
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Phone number does not match this access code.';
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentAuthLayout(
      title: "Identity Verification",
      subtitle:
          "Enter the phone number registered with this access code to continue.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PulseTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            label: 'Phone Number',
            hint: '07xx xxx xxx',
            prefixIcon: Icons.phone_android_rounded,
            validator: (_) => _error,
          ),
          const SizedBox(height: AppSpacing.l),
          PulseButton(
            label: 'Verify & Continue',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _verifyPhone,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class ParentPinScreen extends StatefulWidget {
  final ParentAccessCode accessCode;
  final String phoneNumber;

  const ParentPinScreen({
    super.key,
    required this.accessCode,
    required this.phoneNumber,
  });

  @override
  State<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends State<ParentPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _rememberedLoginStore = RememberedLoginStore();
  String? _error;

  void _login() {
    final isFirstTime =
        widget.accessCode.pin == null || widget.accessCode.pin!.isEmpty;

    if (isFirstTime) {
      if (_pinController.text.length < 4) {
        setState(() => _error = 'PIN must be 4 digits.');
        return;
      }
      if (_pinController.text != _confirmPinController.text) {
        setState(() => _error = 'PINs do not match.');
        return;
      }

      context.read<AuthBloc>().add(
        CompleteParentPinSetupRequested(
          code: widget.accessCode.parentCode,
          phoneNumber: widget.phoneNumber,
          newPin: _pinController.text,
        ),
      );
    } else {
      context.read<AuthBloc>().add(
        LoginParentPressed(
          code: widget.accessCode.parentCode,
          phoneNumber: widget.phoneNumber,
          pin: _pinController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _rememberedLoginStore.setParentIdentity(
            code: widget.accessCode.parentCode,
            phone: widget.phoneNumber,
          );
          context.go('/school-splash');
        } else if (state is AuthFailureState) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isFirstTime =
            widget.accessCode.pin == null || widget.accessCode.pin!.isEmpty;

        return ParentAuthLayout(
          title: isFirstTime ? "Secure Your Portal" : "Enter Secure PIN",
          subtitle: isFirstTime
              ? "Choose a 4-digit PIN to secure your portal access."
              : "Enter your 4-digit PIN to access your account.",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PulseTextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                isPassword: true,
                label: isFirstTime ? 'New PIN' : 'Enter PIN',
                hint: '••••',
                prefixIcon: Icons.lock_outline_rounded,
                validator: (_) => _error,
              ),
              if (isFirstTime) ...[
                const SizedBox(height: AppSpacing.xl),
                PulseTextField(
                  controller: _confirmPinController,
                  keyboardType: TextInputType.number,
                  isPassword: true,
                  label: 'Confirm PIN',
                  hint: '••••',
                  prefixIcon: Icons.lock_reset_rounded,
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              PulseButton(
                label: isFirstTime ? 'Save PIN & Login' : 'Sign In',
                isLoading: isLoading,
                onPressed: isLoading ? null : _login,
                isFullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
