import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Prompts the current Firebase user to re-enter their password and
/// reauthenticates them before a sensitive security action proceeds.
///
/// Returns `true` if reauthentication succeeded, `false` if the user
/// cancelled or reauthentication failed.
Future<bool> showReauthPasswordDialog(
  BuildContext context, {
  required String reason,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ReauthPasswordDialog(reason: reason),
  );
  return result ?? false;
}

class _ReauthPasswordDialog extends StatefulWidget {
  const _ReauthPasswordDialog({required this.reason});

  final String reason;

  @override
  State<_ReauthPasswordDialog> createState() => _ReauthPasswordDialogState();
}

class _ReauthPasswordDialogState extends State<_ReauthPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  bool _submitting = false;
  String? _error;

  // Every owner has TOTP mandatorily enrolled, so
  // reauthenticateWithCredential on a password-linked account always throws
  // FirebaseAuthMultiFactorException here, never just succeeding outright -
  // this holds the resolver Firebase hands back so the code field below can
  // complete the same reauth attempt instead of failing it.
  MultiFactorResolver? _mfaResolver;

  @override
  void dispose() {
    _passwordController.dispose();
    _totpController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() => _error = 'You are not signed in.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthMultiFactorException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _mfaResolver = e.resolver;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = switch (e.code) {
          'wrong-password' ||
          'invalid-credential' => 'Your password is incorrect.',
          'too-many-requests' =>
            'Too many attempts. Please wait a moment and try again.',
          'network-request-failed' =>
            'Network error — check your connection and try again.',
          _ => e.message ?? 'Unable to verify your password.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Unable to verify your password.';
      });
    }
  }

  Future<void> _confirmTotp() async {
    final resolver = _mfaResolver;
    if (resolver == null) return;
    if (_totpController.text.trim().length != 6) {
      setState(
        () => _error = 'Enter the 6-digit code from your authenticator app.',
      );
      return;
    }
    final hint = resolver.hints.whereType<TotpMultiFactorInfo>().firstOrNull;
    if (hint == null) {
      setState(
        () => _error = 'No authenticator method is available for this account.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
        hint.uid,
        _totpController.text.trim(),
      );
      await resolver.resolveSignIn(assertion);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message ?? 'That verification code is invalid.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'That verification code is invalid.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsTotp = _mfaResolver != null;
    return AlertDialog(
      title: Text(needsTotp ? 'Enter Authentication Code' : 'Confirm Your Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: needsTotp
            ? [
                const Text(
                  'Enter the 6-digit code from your authenticator app to finish confirming it\'s you.',
                ),
                const SizedBox(height: 16),
                PulseTextField(
                  label: 'Authentication code',
                  controller: _totpController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.pin_outlined,
                  isRequired: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: AppColors.danger(context)),
                  ),
                ],
              ]
            : [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.reason),
                      const SizedBox(height: 16),
                      PulseTextField(
                        label: 'Password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        isRequired: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter your password.'
                            : null,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: AppColors.danger(context)),
                  ),
                ],
              ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting
              ? null
              : needsTotp
              ? _confirmTotp
              : _confirm,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(needsTotp ? 'Verify' : 'Confirm'),
        ),
      ],
    );
  }
}
