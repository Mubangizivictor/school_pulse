import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Ugandan local numbers (07xxxxxxxx) into E.164 for Firebase Phone Auth.
String _toE164(String localPhone) {
  final digits = localPhone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('256')) return '+$digits';
  if (digits.startsWith('0')) return '+256${digits.substring(1)}';
  return '+256$digits';
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
    // Basic format check: {SCHOOLCODE}{4-digit}, e.g. KHA1234
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
        _error = 'Something went wrong. Please try again.';
      }),
      (accessCode) {
        setState(() => _isLooking = false);
        if (accessCode == null) {
          setState(() => _error = 'No account found with this code.');
          return;
        }
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
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.badge_outlined, size: 36, color: primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              "Enter your Parent Access Code",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "The school office gives you one code that covers all of your children.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Access Code',
                hintText: 'KHA1234',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge_outlined),
                errorText: _error,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Show contact dialog
              },
              child: const Text("Don't have this code? Contact your school office."),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continue',
              isLoading: _isLooking,
              onPressed: _isValid && !_isLooking ? _continue : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ParentVerifyScreen extends StatefulWidget {
  final ParentAccessCode? accessCode;
  const ParentVerifyScreen({super.key, this.accessCode});

  @override
  State<ParentVerifyScreen> createState() => _ParentVerifyScreenState();
}

class _ParentVerifyScreenState extends State<ParentVerifyScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  void _login() {
    if (widget.accessCode == null) return;
    context.read<AuthBloc>().add(LoginParentPressed(
          code: widget.accessCode!.code,
          phoneNumber: _toE164(_phoneController.text),
          pin: _pinController.text,
        ));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.mustChangePassword) {
            context.go('/auth/force-setup', extra: state.user);
          } else {
            context.go('/school-splash', extra: state.user);
          }
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Verify Identity')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_outlined,
                    size: 36,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Parent Login",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your registered phone number and PIN to continue.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                if (widget.accessCode != null && widget.accessCode!.studentNames.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Signing in for: ${widget.accessCode!.studentNames.join(', ')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor),
                  ),
                ],
                const SizedBox(height: 32),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '07xx xxx xxx',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    hintText: 'Enter your 4 or 6 digit PIN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Login',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _login,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ParentUnlockScreen extends StatelessWidget {
  const ParentUnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/parent/home');
        } else if (state is AuthUnauthenticated) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Theme.of(context).extension<SemanticColors>()?.primaryBlue),
              const SizedBox(height: 24),
              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Enter your PIN to unlock"),
              const SizedBox(height: 48),
              // Mock PIN entry
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Unlock with Biometrics',
                onPressed: () => context.read<AuthBloc>().add(AuthCheckRequested()),
              ),
              TextButton(
                onPressed: () => context.go('/welcome'),
                child: const Text("Not you? Switch account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
