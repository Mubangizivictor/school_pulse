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

    if (_newController.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }

    setState(() => _saving = true);
    final result = await sl<AuthRepository>().changePassword(
      _currentController.text,
      _newController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => setState(() => _error = failure.message),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        context.pop();
      },
    );
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
      body: ListView(
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
          ),
          const SizedBox(height: 16),
          PulseTextField(
            label: 'New Password',
            controller: _newController,
            isPassword: true,
            prefixIcon: Icons.lock_reset_outlined,
          ),
          const SizedBox(height: 16),
          PulseTextField(
            label: 'Confirm New Password',
            controller: _confirmController,
            isPassword: true,
            prefixIcon: Icons.lock_reset_outlined,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Update Password',
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
