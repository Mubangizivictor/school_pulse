import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/injection_container.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);
    late final dynamic result;
    try {
      result = await sl<AuthRepository>().changePassword(
        _currentController.text,
        _newController.text,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Unable to change your password. Please try again.';
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold((failure) => setState(() => _error = failure.message), (_) {
      // Best-effort: burns any outstanding owner recovery challenge, since
      // a challenge issued against the OLD password must not remain
      // redeemable after it changes. This screen is shared by every role,
      // so for a non-owner the callable's own requireOwner() check simply
      // denies it - harmless, swallowed below.
      unawaited(_invalidateOwnerRecoveryChallenges());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      context.pop();
    });
  }

  Future<void> _invalidateOwnerRecoveryChallenges() async {
    try {
      await FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('invalidateOwnerRecoveryChallenges').call();
    } catch (_) {
      // Not the owner account, or best-effort cleanup failed - never
      // blocks the already-completed password change.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              AlertBanner(
                title: 'Error',
                message: _error!,
                color: AppColors.danger(context),
                icon: Icons.error_outline,
              ),
              const SizedBox(height: 8),
            ],
            PulseTextField(
              label: 'Current Password',
              controller: _currentController,
              isPassword: true,
              prefixIcon: Icons.lock_outline,
              isRequired: true,
              validator: (value) => value == null || value.isEmpty
                  ? 'Enter your current password.'
                  : null,
            ),
            const SizedBox(height: 16),
            PulseTextField(
              label: 'New Password',
              controller: _newController,
              isPassword: true,
              prefixIcon: Icons.lock_reset_outlined,
              isRequired: true,
              helperText: 'Use at least 6 characters.',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a new password.';
                }
                if (value.length < 6) {
                  return 'New password must be at least 6 characters.';
                }
                if (value == _currentController.text) {
                  return 'Your new password must be different.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PulseTextField(
              label: 'Confirm New Password',
              controller: _confirmController,
              isPassword: true,
              prefixIcon: Icons.lock_reset_outlined,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm your new password.';
                }
                return value == _newController.text
                    ? null
                    : 'New passwords do not match.';
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Update Password',
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
