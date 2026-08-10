import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';

class MfaChallengeScreen extends StatefulWidget {
  final MultiFactorResolver resolver;

  const MfaChallengeScreen({super.key, required this.resolver});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  final _codeController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeController.text.trim().length != 6) {
      setState(
        () => _error = 'Enter the 6-digit code from your authenticator app.',
      );
      return;
    }
    final hint = widget.resolver.hints
        .whereType<TotpMultiFactorInfo>()
        .firstOrNull;
    if (hint == null) {
      setState(
        () => _error = 'No authenticator method is available for this account.',
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
        hint.uid,
        _codeController.text.trim(),
      );
      await widget.resolver.resolveSignIn(assertion);
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthCheckRequested());
      context.go('/staff/login');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.message ?? 'That verification code is invalid.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify it’s you')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter the 6-digit code from your authenticator app to finish signing in.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Authentication code',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _verify,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Verify'),
          ),
        ],
      ),
    ),
  );
}
