import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/injection_container.dart' as di;

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
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_myejioos.json', // Example parent/family animation
                height: 180,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.badge_outlined, size: 36, color: primaryColor),
                ),
              ),
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
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Getting an Access Code'),
                  content: const Text(
                    'Parent access codes are issued by the school office. '
                    'Visit or call your school\'s administration and ask them '
                    'to register you as a parent — they will give you a code '
                    'that covers all of your children at the school.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
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
    
    // Simulate a brief delay for UX
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
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Lottie.network(
                'https://assets9.lottiefiles.com/private_files/lf30_gqzkc8b6.json', // Verification/Phone animation
                height: 180,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone_android_outlined, size: 36, color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Identity Verification",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your registered phone number to continue.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '07xx xxx xxx',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Verify Phone',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _verifyPhone,
            ),
          ],
        ),
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
        setState(() => _error = 'PIN must be at least 4 digits.');
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
    final primaryColor = Theme.of(context).extension<SemanticColors>()?.primaryBlue ??
        Theme.of(context).colorScheme.primary;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/school-splash', extra: state.user);
        } else if (state is AuthFailureState) {
          setState(() => _error = state.message);
        } else if (state is AuthInitial && _pinController.text.isNotEmpty) {
           // This handles the redirect after CompleteParentPinSetupRequested success 
           // if the bloc refreshes via AuthCheckRequested
           // Actually, better to just let the loginParent handle it in the next step or 
           // manually trigger login here. For now, let's assume the bloc handles the flow.
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isFirstTime = widget.accessCode.pin == null || widget.accessCode.pin!.isEmpty;

        return Scaffold(
          appBar: AppBar(title: Text(isFirstTime ? 'Set Your PIN' : 'Enter PIN')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Lottie.network(
                    'https://assets8.lottiefiles.com/packages/lf20_mkmptv89.json', // Security/PIN animation
                    height: 180,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFirstTime ? Icons.security_outlined : Icons.lock_person_outlined,
                        size: 36,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isFirstTime ? "Create Your Secure PIN" : "Security Check",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isFirstTime 
                    ? "Choose a 4-digit PIN to secure your access. You will use this every time you log in."
                    : "Enter your 4-digit PIN to access the portal.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: isFirstTime ? 'Create PIN' : 'PIN',
                    hintText: 'xxxx',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    counterText: "",
                    errorText: _error,
                  ),
                ),
                if (isFirstTime) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Confirm PIN',
                      hintText: 'xxxx',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_reset),
                      counterText: "",
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: isFirstTime ? 'Save PIN & Continue' : 'Login',
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

