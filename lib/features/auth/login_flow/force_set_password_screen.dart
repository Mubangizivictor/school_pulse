import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_gradients.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/set_new_password.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Shown right after a first successful login if a password or PIN change is required.
/// Unified for both Staff (Email/Password) and Parents (Access Code/PIN).
class ForceSetPasswordScreen extends StatefulWidget {
  final UserEntity? user;
  const ForceSetPasswordScreen({super.key, this.user});

  @override
  State<ForceSetPasswordScreen> createState() => _ForceSetPasswordScreenState();
}

class _ForceSetPasswordScreenState extends State<ForceSetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isParent => widget.user?.role == UserRole.parent;

  Future<void> _submit() async {
    final password = _passwordController.text;

    if (_isParent) {
      if (password.length != 4 || int.tryParse(password) == null) {
        setState(() => _error = 'PIN must be 4 digits.');
        return;
      }
    } else {
      if (password.length < 6) {
        setState(() => _error = 'Password must be at least 6 characters.');
        return;
      }
    }

    if (password != _confirmController.text) {
      setState(() => _error = 'Entries do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_isParent) {
      // For parents, the 'id' was set to 'parent_CODE' in loginParent
      final code = widget.user!.id.replaceFirst('parent_', '');
      final result = await di.sl<CompleteParentPinSetup>()(
        CompleteParentPinSetupParams(
          code: code,
          phoneNumber: widget.user!.phoneNumber ?? '',
          newPin: password,
        ),
      );
      _handleResult(result);
    } else {
      final result = await di.sl<SetNewPassword>()(password);
      _handleResult(result);
    }
  }

  void _handleResult(dynamic result) {
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure.message;
      }),
      (_) {
        setState(() => _isLoading = false);
        _routeToDashboard();
      },
    );
  }

  void _routeToDashboard() {
    if (widget.user == null) {
      context.go('/welcome');
      return;
    }

    context.go('/school-bootstrap');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = _isParent ? 'Set Your Secret PIN' : 'Set New Password';
    final subtitle = _isParent
        ? "For your security, please choose a 4-digit PIN to use for future logins."
        : "For your security, choose a new password to replace the temporary one.";
    final label = _isParent ? 'New 4-Digit PIN' : 'New Password';
    final confirmLabel = _isParent ? 'Confirm PIN' : 'Confirm Password';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                          color: isDark
                              ? AppColors.surfaceDark.withValues(alpha: 0.5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? AppColors.white.withValues(alpha: 0.1)
                                : AppColors.borderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
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
                          size: 80,
                          variant: PulseLogoVariant.auth,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x4l),
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
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.x6l),
                      PulseTextField(
                        controller: _passwordController,
                        isPassword: true,
                        keyboardType: _isParent
                            ? TextInputType.number
                            : TextInputType.text,
                        label: label,
                        hint: _isParent ? '••••' : '••••••••',
                        prefixIcon: _isParent
                            ? Icons.dialpad
                            : Icons.lock_outline,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PulseTextField(
                        controller: _confirmController,
                        isPassword: true,
                        keyboardType: _isParent
                            ? TextInputType.number
                            : TextInputType.text,
                        label: confirmLabel,
                        hint: _isParent ? '••••' : '••••••••',
                        prefixIcon: _isParent
                            ? Icons.dialpad
                            : Icons.lock_reset_rounded,
                        validator: (_) => _error,
                      ),
                      const SizedBox(height: AppSpacing.x4l),
                      PulseButton(
                        label: 'Update & Continue',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                        isFullWidth: true,
                      ),
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
