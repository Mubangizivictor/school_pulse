import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/usecases/set_new_password.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Shown right after a staff member's first successful login with an
/// admin-issued temporary password. They must set their own password before
/// reaching their dashboard.
class ForceSetPasswordScreen extends StatefulWidget {
  final UserRole? role;
  const ForceSetPasswordScreen({super.key, this.role});

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

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await di.sl<SetNewPassword>()(password);
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
    final role = widget.role ?? UserRole.classTeacher;
    if (!PlatformAccess.isAllowedOnCurrentPlatform(role)) {
      context.go('/platform-blocked?role=${role.name}');
      return;
    }
    context.go(UserRoleRouting.dashboardPath(role));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password'), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.password_outlined, size: 64, color: primaryColor),
                const SizedBox(height: 24),
                Text(
                  "Set a new password",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "For your security, choose a new password to replace the one your admin gave you.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Continue',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
