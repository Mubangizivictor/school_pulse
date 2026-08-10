import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final _codeController = TextEditingController();
  TotpSecret? _secret;
  String? _qrUrl;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _beginEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _showError('You are not signed in.');
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final session = await user.multiFactor.getSession();
      final secret = await TotpMultiFactorGenerator.generateSecret(session);
      final qrUrl = await secret.generateQrCodeUrl(
        accountName: user.email ?? user.uid,
        issuer: 'School Pulse',
      );
      if (mounted) {
        setState(() {
          _secret = secret;
          _qrUrl = qrUrl;
        });
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Could not start authenticator setup.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmEnrollment() async {
    final secret = _secret;
    if (secret == null || _codeController.text.trim().length != 6) {
      return _showError('Enter the 6-digit code from your authenticator app.');
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final assertion =
          await TotpMultiFactorGenerator.getAssertionForEnrollment(
            secret,
            _codeController.text.trim(),
          );
      await FirebaseAuth.instance.currentUser!.multiFactor.enroll(
        assertion,
        displayName: 'Authenticator app',
      );
      final result = await sl<AuthRepository>().updateMfaEnabled(true);
      result.fold((failure) => _showError(failure.message), (_) {
        context.read<AuthBloc>().add(AuthCheckRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Two-factor authentication enabled.')),
        );
        context.pop();
      });
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'That verification code could not be confirmed.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _disable() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return _showError('You are not signed in.');
      final factors = await user.multiFactor.getEnrolledFactors();
      for (final factor in factors) {
        await user.multiFactor.unenroll(multiFactorInfo: factor);
      }
      final result = await sl<AuthRepository>().updateMfaEnabled(false);
      result.fold(
        (failure) => _showError(failure.message),
        (_) => context.read<AuthBloc>().add(AuthCheckRequested()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Could not disable two-factor authentication.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final enabled = authState is AuthAuthenticated && authState.user.mfaEnabled;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            AlertBanner(
              title: 'Setup error',
              message: _error!,
              color: AppColors.danger(context),
              icon: Icons.error_outline,
            ),
          if (_error != null) const SizedBox(height: 12),
          AppCard(
            child: SwitchListTile.adaptive(
              value: enabled,
              onChanged: _saving
                  ? null
                  : (value) => value ? _beginEnrollment() : _disable(),
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable Two-Factor Authentication',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              subtitle: Text(
                enabled
                    ? 'Your authenticator app is required when you sign in.'
                    : 'Use an authenticator app to protect your account.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            ),
          ),
          if (!enabled && _qrUrl != null) ...[
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  Text(
                    'Set up your authenticator',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan this QR code with Google Authenticator, Microsoft Authenticator, Authy, or another authenticator app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: _qrUrl!,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: '6-digit verification code',
                    ),
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Confirm and Enable',
                    isLoading: _saving,
                    onPressed: _confirmEnrollment,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
