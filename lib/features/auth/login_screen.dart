import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/design_system/app_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  String? _verificationId;
  List<String>? _pendingLinkedStudentIds;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthBloc>().add(
        LoginWithEmailPressed(email: email, password: password),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
    }
  }

  void _handlePhoneLogin() {
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && phone.startsWith('+')) {
      context.read<AuthBloc>().add(
        LoginWithPhonePressed(phoneNumber: phone),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter number in international format (e.g. +256...)')),
      );
    }
  }

  void _handleVerifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isNotEmpty && _verificationId != null) {
      context.read<AuthBloc>().add(
        VerifyOtpPressed(
          verificationId: _verificationId!,
          smsCode: otp,
          linkedStudentIds: _pendingLinkedStudentIds,
        ),
      );
    }
  }

  void _showAccessCodeDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Family Access Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('If you have a code from the school, enter it here to link your children.'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Access Code',
                hintText: 'e.g. KHA1234',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                context.read<AuthBloc>().add(ResolveAccessCodeRequested(code: code));
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate based on role
          if (state.user.role.name == 'parent') {
            context.go('/parent/home');
          } else {
            context.go('/staff/dashboard');
          }
        } else if (state is AuthOtpSent) {
          setState(() {
            _isOtpSent = true;
            _verificationId = state.verificationId;
          });
        } else if (state is AuthAccessCodeResolved) {
          // Show confirmation or proceed to phone login with linked IDs
          setState(() {
            _pendingLinkedStudentIds = state.code.studentIds;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Access code for ${state.code.studentNames.join(", ")} recognized. Please login with your phone.')),
          );
          _tabController.animateTo(0); // Ensure on Phone tab
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FadeInSlide(
                    child: Icon(Icons.school, size: 80, color: Color(0xFF1F3864)),
                  ),
                  const SizedBox(height: 16),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'School Pulse',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Phone Login'),
                          Tab(text: 'Email Login'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          height: 350,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _isOtpSent ? _buildOtpVerification() : _buildPhoneLogin(state is AuthLoading),
                              _buildEmailLogin(state is AuthLoading),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLogin(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Login with Phone Number',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'We will send a verification code to your phone.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'e.g. +256 700 000000',
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send Code',
          isLoading: isLoading,
          onPressed: _handlePhoneLogin,
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _showAccessCodeDialog,
          icon: const Icon(Icons.vpn_key),
          label: const Text('Have a family access code?'),
        ),
      ],
    );
  }

  Widget _buildOtpVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verify Your Phone',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to ${_phoneController.text}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Verify & Login',
          onPressed: _handleVerifyOtp,
        ),
        TextButton(
          onPressed: () => setState(() => _isOtpSent = false),
          child: const Text('Change Phone Number'),
        ),
      ],
    );
  }

  Widget _buildEmailLogin(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Login with Email',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Login',
          isLoading: isLoading,
          onPressed: _handleEmailLogin,
        ),
      ],
    );
  }
}
