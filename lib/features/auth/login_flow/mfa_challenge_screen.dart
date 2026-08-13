import 'dart:convert';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/super_admin/domain/owner_security_session_service.dart';

class MfaChallengeScreen extends StatefulWidget {
  final MultiFactorResolver resolver;

  const MfaChallengeScreen({super.key, required this.resolver});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

/// Recovery is a two-step flow, distinct from the normal TOTP step:
///  1. [totp] - the default, ordinary authenticator-app code entry.
///  2. [recoveryFirstFactor] - re-enter email + password so the backend can
///     INDEPENDENTLY re-verify a real first-factor credential (never
///     derived from `resolver`/`hints` - see beginOwnerRecoveryChallenge's
///     doc comment in owner_recovery_codes.js for why that's required).
///  3. [recoveryCode] - once a challenge is issued, enter the recovery code
///     itself.
enum _Mode { totp, recoveryFirstFactor, recoveryCode }

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;
  _Mode _mode = _Mode.totp;
  String? _recoveryChallengeId;

  /// Fresh, cryptographically random per-attempt nonce, generated client-side
  /// and never sent anywhere except beginOwnerRecoveryChallenge (as plaintext,
  /// over the same authenticated HTTPS call) and later verifyOwnerRecoveryCode.
  /// The server only ever stores/compares its hash. Supplementary binding
  /// only, not identity proof - see beginOwnerRecoveryChallenge's doc comment
  /// (public_functions/owner_recovery_codes.js) for what this actually
  /// protects against and what it doesn't.
  String? _recoverySessionNonce;

  String _generateSessionNonce() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64UrlEncode(bytes);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyTotp() async {
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
      await _establishOwnerSecuritySessionIfOwner();
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

  /// Establishes the unified OwnerSecuritySession right after a TOTP
  /// second-factor succeeds - the method label (password_totp vs
  /// google_totp vs apple_totp) is derived from the just-signed-in user's
  /// own `providerData`, never asserted by this screen. This screen is
  /// shared by every role with MFA enrolled, not owner-only: for a
  /// non-owner caller, `establishOwnerSecuritySession`'s own server-side
  /// `requireOwner()` check simply denies it, which `establish()` already
  /// treats as a harmless no-op (see OwnerSecuritySessionService).
  Future<void> _establishOwnerSecuritySessionIfOwner() async {
    final providerIds =
        FirebaseAuth.instance.currentUser?.providerData
            .map((p) => p.providerId)
            .toSet() ??
        const <String>{};
    final method = providerIds.contains('google.com')
        ? 'google_totp'
        : providerIds.contains('apple.com')
        ? 'apple_totp'
        : 'password_totp';
    await OwnerSecuritySessionService.instance.establish(
      authenticationMethod: method,
    );
  }

  /// Re-verifies email + password INDEPENDENTLY of Firebase's MFA resolver
  /// - never trusts `resolver.hints`/`resolver.session` as proof of a
  /// current credential check, since neither is server-verifiable by our
  /// own backend (Firebase's opaque MFA session can only ever be redeemed
  /// by Firebase's own `resolver.resolveSignIn()`, and an enrolled-factor
  /// UID is static account metadata, not a signed/time-limited credential -
  /// see beginOwnerRecoveryChallenge's doc comment in
  /// public_functions/owner_recovery_codes.js for the full audit trail).
  /// This calls the actual Identity Toolkit `signInWithPassword` REST
  /// endpoint server-side, a second time, independently of whatever
  /// resolver Firebase already handed the client - the same guarantee the
  /// original first-factor sign-in already gave, just re-established in a
  /// form our own backend can check.
  Future<void> _beginRecovery() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final nonce = _generateSessionNonce();
      final result = await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('beginOwnerRecoveryChallenge')
          .call<Map<String, dynamic>>({
            'provider': 'password',
            'email': email,
            'password': password,
            'clientSessionNonce': nonce,
          });
      final challengeId = result.data['challengeId'] as String?;
      if (challengeId == null) {
        setState(() => _error = 'Verification failed.');
        return;
      }
      _recoveryChallengeId = challengeId;
      _recoverySessionNonce = nonce;
      _passwordController.clear();
      setState(() => _mode = _Mode.recoveryCode);
    } on FirebaseFunctionsException catch (e) {
      setState(
        () => _error = e.code == 'resource-exhausted'
            ? 'Too many attempts. Try again later.'
            : 'Verification failed.',
      );
    } catch (_) {
      setState(() => _error = 'Verification failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyRecoveryCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a recovery code.');
      return;
    }
    final challengeId = _recoveryChallengeId;
    final nonce = _recoverySessionNonce;
    if (challengeId == null || nonce == null) {
      setState(() => _error = 'Verification failed.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('verifyOwnerRecoveryCode')
          .call<Map<String, dynamic>>({
            'challengeId': challengeId,
            'code': code,
            'clientSessionNonce': nonce,
          });
      final customToken = result.data['customToken'] as String?;
      if (customToken == null) {
        setState(() => _error = 'Verification failed.');
        return;
      }
      // A recovery code is single-use, and so is the challenge it was
      // redeemed against - clearing this means a retry after any failure
      // correctly requires beginning recovery again (a fresh password
      // re-check) rather than silently reusing a now-consumed challenge.
      _recoveryChallengeId = null;
      _recoverySessionNonce = null;
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      // The custom token only proves the recovery code was valid - it
      // carries no owner claims (see the callable's doc comment) - so the
      // same server-side owner assertion every other login path requires
      // runs here too (inside establishOwnerSecuritySession's own
      // requireOwner() call) before the app is allowed to treat this as an
      // authenticated owner session.
      await OwnerSecuritySessionService.instance.establish(
        authenticationMethod: 'recovery_code',
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthCheckRequested());
      context.go('/staff/login');
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.code == 'resource-exhausted'
              ? 'Too many attempts. Try again later.'
              : 'Verification failed.',
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Verification failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchMode(_Mode mode) {
    setState(() {
      _mode = mode;
      _codeController.clear();
      _emailController.clear();
      _passwordController.clear();
      _error = null;
      _recoveryChallengeId = null;
      _recoverySessionNonce = null;
    });
  }

  VoidCallback? get _primaryAction {
    if (_loading) return null;
    return switch (_mode) {
      _Mode.totp => _verifyTotp,
      _Mode.recoveryFirstFactor => _beginRecovery,
      _Mode.recoveryCode => _verifyRecoveryCode,
    };
  }

  String get _primaryLabel => switch (_mode) {
    _Mode.recoveryFirstFactor => 'Continue',
    _ => 'Verify',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify it’s you')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(switch (_mode) {
            _Mode.totp =>
              'Enter the 6-digit code from your authenticator app to finish signing in.',
            _Mode.recoveryFirstFactor =>
              'Re-enter your email and password to start account recovery.',
            _Mode.recoveryCode => 'Enter one of your recovery codes.',
          }),
          const SizedBox(height: 24),
          if (_mode == _Mode.recoveryFirstFactor) ...[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _error,
              ),
            ),
          ] else
            TextField(
              controller: _codeController,
              keyboardType: _mode == _Mode.recoveryCode
                  ? TextInputType.text
                  : TextInputType.number,
              maxLength: _mode == _Mode.recoveryCode ? null : 6,
              autofocus: true,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: _mode == _Mode.recoveryCode
                    ? 'Recovery code'
                    : 'Authentication code',
                errorText: _error,
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _primaryAction,
            child: _loading
                ? const CircularProgressIndicator()
                : Text(_primaryLabel),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading
                ? null
                : () => _switchMode(
                    _mode == _Mode.totp
                        ? _Mode.recoveryFirstFactor
                        : _Mode.totp,
                  ),
            child: Text(
              _mode == _Mode.totp
                  ? 'Use a recovery code'
                  : 'Use authenticator app instead',
            ),
          ),
        ],
      ),
    ),
  );
}
