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
                        child: PulseLogo(width: 320, variant: PulseLogoVariant.auth),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        title,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      child,
                    ],
                  ),
                );
              }
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
  bool _isValid = false;
  bool _isLooking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validate);
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
    const accent = AppColors.electricBlue;

    return AuthPortalScaffold(
      accent: accent,
      children: [
        const AuthHeroScene(accent: accent, badgeIcon: Icons.family_restroom_rounded),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Parent Portal',
          textAlign: TextAlign.center,
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          "Enter the code provided by the school office\nto access your child's records.",
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),
        AuthField(
          label: 'Access Code',
          hint: 'e.g. KHA1234',
          icon: Icons.vpn_key_outlined,
          accent: accent,
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          errorText: _error,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: AppColors.brightCyan, size: 26),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Don't have a code?",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.brightCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Please contact your school's\nadministration office.",
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              const Icon(Icons.support_agent_rounded, color: AppColors.brightCyan, size: 32),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),
        AuthCtaButton(
          label: 'Continue',
          gradient: const [AppColors.royalBlue, AppColors.brightCyan],
          isLoading: _isLooking,
          onPressed: _isValid && !_isLooking ? _continue : null,
        ),
        const SizedBox(height: AppSpacing.x2l),
        const AuthPrivacyNote(accent: accent),
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
        context.push('/parent/login/pin', extra: {
          'accessCode': widget.accessCode,
          'phoneNumber': inputPhone,
        });
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
      subtitle: "Enter the phone number registered with this access code to continue.",
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
  String? _error;

  void _login() {
    final isFirstTime = widget.accessCode.pin == null || widget.accessCode.pin!.isEmpty;
    
    if (isFirstTime) {
      if (_pinController.text.length < 4) {
        setState(() => _error = 'PIN must be 4 digits.');
        return;
      }
      if (_pinController.text != _confirmPinController.text) {
        setState(() => _error = 'PINs do not match.');
        return;
      }
      
      context.read<AuthBloc>().add(CompleteParentPinSetupRequested(
        code: widget.accessCode.parentCode,
        phoneNumber: widget.phoneNumber,
        newPin: _pinController.text,
      ));
    } else {
      context.read<AuthBloc>().add(LoginParentPressed(
        code: widget.accessCode.parentCode,
        phoneNumber: widget.phoneNumber,
        pin: _pinController.text,
      ));
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
          context.go('/school-splash', extra: state.user);
        } else if (state is AuthFailureState) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isFirstTime = widget.accessCode.pin == null || widget.accessCode.pin!.isEmpty;

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

