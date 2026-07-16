import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
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
        CompleteParentPinSetupParams(code: code, newPin: password),
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
    
    context.go('/school-splash', extra: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    final title = _isParent ? 'Set Your Secret PIN' : 'Set New Password';
    final subtitle = _isParent 
        ? "For your security, please choose a 4-digit PIN to use for future logins."
        : "For your security, choose a new password to replace the one your admin gave you.";
    final label = _isParent ? 'New 4-Digit PIN' : 'New Password';
    final confirmLabel = _isParent ? 'Confirm PIN' : 'Confirm Password';

    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(_isParent ? Icons.pin_outlined : Icons.password_outlined, size: 64, color: primaryColor),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: _isParent ? TextInputType.number : TextInputType.text,
                  maxLength: _isParent ? 4 : null,
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(_isParent ? Icons.dialpad : Icons.lock_outline),
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  keyboardType: _isParent ? TextInputType.number : TextInputType.text,
                  maxLength: _isParent ? 4 : null,
                  decoration: InputDecoration(
                    labelText: confirmLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(_isParent ? Icons.dialpad : Icons.lock_outline),
                    errorText: _error,
                    counterText: "",
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
