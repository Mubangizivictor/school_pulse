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
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Your Password'),
      content: Form(
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
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: AppColors.danger(context))),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _confirm,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}
