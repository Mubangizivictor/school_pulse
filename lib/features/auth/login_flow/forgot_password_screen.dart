import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';

/// Self-service "Forgot password" for the Staff Portal. Posts directly to
/// the `requestPasswordReset` onRequest function (public_functions/
/// password_reset.js) rather than the Firebase Auth SDK's own
/// sendPasswordResetEmail(), so the reset link is delivered branded via
/// Resend instead of Firebase's default noreply@`<project>`.firebaseapp.com
/// sender - same reasoning as the email-verification fix this mirrors.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _accent = AppColors.brightOrange;
  static const _endpoint =
      'https://europe-west1-school-pulse-3d95b.cloudfunctions.net/requestPasswordReset';

  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRe.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 20));

      // The endpoint always returns 200 with the same generic message
      // whether or not the email belongs to an account (enumeration
      // protection) - only a genuine transport/server failure lands here.
      if (response.statusCode != 200) {
        setState(() => _error = 'Could not send the reset link. Please try again.');
        return;
      }
      setState(() => _sent = true);
    } catch (_) {
      setState(() => _error = 'Could not reach School Pulse. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AuthPortalScaffold(
      accent: _accent,
      alignToTop: true,
      title: 'Reset Password',
      children: [
        const SizedBox(height: AppSpacing.x3l),
        if (_sent) ...[
          Text(
            'If an account exists for that email, we\'ve sent a link to reset your password. Open it, then sign in with your new password.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
          AuthCtaButton(
            label: 'Back to Sign In',
            gradient: const [Colors.black, Colors.black],
            filled: true,
            onPressed: () => context.pop(),
          ),
        ] else ...[
          Text(
            'Enter the email address for your staff account. We\'ll send you a link to reset your password.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.x6l),
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.textPrimary(context),
                width: 1.25,
              ),
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 16,
                ),
                hintText: 'name@school.com',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _error!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.x3l),
          AuthCtaButton(
            label: 'Send Reset Link',
            gradient: const [Colors.black, Colors.black],
            filled: true,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ],
    );
  }
}
