import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:school_pulse/features/auth/data/datasources/apple_nonce.dart';
import 'package:school_pulse/features/auth/data/datasources/google_sign_in_config.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/google_glyph.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/owner_security_policy.dart';

/// Super Admin > Settings > Security > Sign-in Methods.
///
/// Shows the owner's real linked first-factor providers, read directly
/// from `FirebaseAuth.currentUser.providerData` - never a locally cached or
/// assumed "linked" flag - and lets the owner link/unlink Google. The
/// actual link/unlink call is Firebase Auth client SDK work
/// (`linkWithCredential`/`unlink`); this screen additionally calls the
/// server-side `logOwnerProviderEvent` callable afterwards so the audit
/// trail entry is written by a trusted server context rather than trusted
/// entirely from client intent.
///
/// Every link/unlink action requires [OwnerSecurityPolicy.ensureFreshAuthentication]
/// first (fresh sign-in within the last few minutes, prompting for
/// reauthentication otherwise), and unlinking is blocked outright if it
/// would leave the owner with zero remaining sign-in methods - Firebase
/// Auth does not prevent this itself.
class SignInMethodsScreen extends StatefulWidget {
  const SignInMethodsScreen({super.key});

  @override
  State<SignInMethodsScreen> createState() => _SignInMethodsScreenState();
}

class _SignInMethodsScreenState extends State<SignInMethodsScreen> {
  // Which provider's link/unlink action is in flight, if any - not a plain
  // bool, so tapping Google doesn't also spin the Apple row's trailing
  // widget (and vice versa).
  String? _busyProvider;
  String? _error;

  Set<String> get _providerIds =>
      FirebaseAuth.instance.currentUser?.providerData
          .map((p) => p.providerId)
          .toSet() ??
      const {};

  Future<void> _logProviderEvent(String providerId, String action) async {
    try {
      await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('logOwnerProviderEvent')
          .call({'providerId': providerId, 'action': action});
    } catch (_) {
      // Audit logging failure must never block the already-completed
      // link/unlink from reflecting in the UI - providerData (re-read on
      // next build) remains the source of truth regardless.
    }
  }

  Future<void> _linkGoogle() async {
    setState(() {
      _busyProvider = 'google.com';
      _error = null;
    });
    try {
      final fresh = await OwnerSecurityPolicy.ensureFreshAuthentication(
        context,
        reason: 'Confirm it\'s you before linking a new sign-in method.',
      );
      if (!fresh) {
        setState(() => _error = 'Reauthentication is required to link Google.');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final beforeUid = user.uid;

      final googleSignIn = ownerGoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // cancelled
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await user.linkWithCredential(credential);

      // Firebase Auth linking always operates on and returns the SAME
      // user - this assertion exists purely as a defensive invariant
      // check, not because linkWithCredential is expected to ever change
      // the UID; if it somehow did, treat it as a fatal integration bug
      // rather than silently accepting a different account.
      if (result.user?.uid != beforeUid) {
        throw StateError('Linking unexpectedly changed the signed-in account.');
      }

      await _logProviderEvent('google.com', 'link');
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google linked to your owner account.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _messageForLinkError(e));
    } catch (e) {
      setState(() => _error = 'Could not link Google.');
    } finally {
      if (mounted) setState(() => _busyProvider = null);
    }
  }

  String _messageForLinkError(FirebaseAuthException e) {
    return switch (e.code) {
      'credential-already-in-use' =>
        'This Google account is already linked to a different account.',
      'provider-already-linked' => 'Google is already linked.',
      'invalid-credential' => 'That Google sign-in could not be verified.',
      'requires-recent-login' => 'Please reauthenticate and try again.',
      _ => e.message ?? 'Could not link Google.',
    };
  }

  Future<void> _linkApple() async {
    setState(() {
      _busyProvider = 'apple.com';
      _error = null;
    });
    try {
      final fresh = await OwnerSecurityPolicy.ensureFreshAuthentication(
        context,
        reason: 'Confirm it\'s you before linking a new sign-in method.',
      );
      if (!fresh) {
        setState(() => _error = 'Reauthentication is required to link Apple.');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final beforeUid = user.uid;

      final result = kIsWeb
          ? await user.linkWithPopup(
              OAuthProvider('apple.com')
                ..addScope('email')
                ..addScope('name'),
            )
          : await _linkAppleNative(user);

      // Same defensive invariant as Google linking - linkWithCredential
      // always operates on and returns the same user; treat any deviation
      // as a fatal integration bug rather than silently accepting it.
      if (result.user?.uid != beforeUid) {
        throw StateError('Linking unexpectedly changed the signed-in account.');
      }

      await _logProviderEvent('apple.com', 'link');
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple linked to your owner account.')),
        );
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        setState(() => _error = 'Could not link Apple.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _messageForLinkError(e));
    } catch (e) {
      setState(() => _error = 'Could not link Apple.');
    } finally {
      if (mounted) setState(() => _busyProvider = null);
    }
  }

  Future<UserCredential> _linkAppleNative(User user) async {
    final nonce = AppleNonce.generate();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce.hashed,
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: nonce.raw,
      accessToken: appleCredential.authorizationCode,
    );
    return user.linkWithCredential(credential);
  }

  Future<void> _unlinkApple() async {
    if (_providerIds.length <= 1) {
      setState(
        () => _error =
            'You must keep at least one sign-in method. Link another method '
            'before unlinking Apple.',
      );
      return;
    }

    final confirmed = await confirmActionDialog(
      context,
      title: 'Unlink Apple?',
      message:
          'You will no longer be able to sign in to the Platform Owner '
          'console with this Apple account.',
      confirmLabel: 'Unlink',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busyProvider = 'apple.com';
      _error = null;
    });
    try {
      final fresh = await OwnerSecurityPolicy.ensureFreshAuthentication(
        context,
        reason: 'Confirm it\'s you before removing a sign-in method.',
      );
      if (!fresh) {
        setState(
          () => _error = 'Reauthentication is required to unlink Apple.',
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      if (user.providerData.length <= 1) {
        setState(() => _error = 'You must keep at least one sign-in method.');
        return;
      }

      await user.unlink('apple.com');
      await _logProviderEvent('apple.com', 'unlink');
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Apple unlinked.')));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Could not unlink Apple.');
    } finally {
      if (mounted) setState(() => _busyProvider = null);
    }
  }

  Future<void> _unlinkGoogle() async {
    if (_providerIds.length <= 1) {
      setState(
        () => _error =
            'You must keep at least one sign-in method. Link another method '
            'before unlinking Google.',
      );
      return;
    }

    final confirmed = await confirmActionDialog(
      context,
      title: 'Unlink Google?',
      message:
          'You will no longer be able to sign in to the Platform Owner '
          'console with this Google account.',
      confirmLabel: 'Unlink',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busyProvider = 'google.com';
      _error = null;
    });
    try {
      final fresh = await OwnerSecurityPolicy.ensureFreshAuthentication(
        context,
        reason: 'Confirm it\'s you before removing a sign-in method.',
      );
      if (!fresh) {
        setState(
          () => _error = 'Reauthentication is required to unlink Google.',
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      // Re-check under the freshly reauthenticated state - the count could
      // only have changed if another linked session unlinked something in
      // the meantime, but this keeps the invariant airtight regardless.
      if (user.providerData.length <= 1) {
        setState(() => _error = 'You must keep at least one sign-in method.');
        return;
      }

      await user.unlink('google.com');
      await _logProviderEvent('google.com', 'unlink');
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google unlinked.')));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Could not unlink Google.');
    } finally {
      if (mounted) setState(() => _busyProvider = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerIds = _providerIds;
    final hasPassword = providerIds.contains('password');
    final hasGoogle = providerIds.contains('google.com');
    final hasApple = providerIds.contains('apple.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-in Methods'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          if (_error != null) ...[
            AlertBanner(
              title: 'Could not complete that action',
              message: _error!,
              color: AppColors.danger(context),
              icon: Icons.error_outline,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          Text(
            'These are the ways you can sign in to the Platform Owner '
            'console. Google and Apple sign-in are always linked to this '
            'same owner account - they never create a separate account.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _ProviderTile(
            leading: Icon(
              Icons.password_rounded,
              color: hasPassword
                  ? AppColors.success(context)
                  : AppColors.textMuted(context),
              size: 22,
            ),
            title: 'Email & Password',
            linked: hasPassword,
            // Password isn't linked/unlinked from here - it's the account's
            // original credential (see admin_seeder.dart/bootstrap_owner.js)
            // managed via Change Password instead.
            trailing: hasPassword
                ? const StatusBadge(
                    label: 'Active',
                    color: AppColors.emeraldGreen,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.m),
          _ProviderTile(
            leading: const GoogleGlyph(size: 22),
            title: 'Google',
            linked: hasGoogle,
            trailing: _busyProvider == 'google.com'
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : hasGoogle
                ? OutlinedButton(
                    onPressed: _unlinkGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger(context),
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    child: const Text('Unlink'),
                  )
                : FilledButton(
                    onPressed: _linkGoogle,
                    child: const Text('Link Google'),
                  ),
          ),
          const SizedBox(height: AppSpacing.m),
          _ProviderTile(
            leading: Icon(
              Icons.apple_rounded,
              color: hasApple
                  ? AppColors.success(context)
                  : AppColors.textMuted(context),
              size: 22,
            ),
            title: 'Apple',
            linked: hasApple,
            trailing: _busyProvider == 'apple.com'
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : hasApple
                ? OutlinedButton(
                    onPressed: _unlinkApple,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger(context),
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    child: const Text('Unlink'),
                  )
                : FilledButton(
                    onPressed: _linkApple,
                    child: const Text('Link Apple'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.leading,
    required this.title,
    required this.linked,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final bool linked;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = linked
        ? AppColors.success(context)
        : AppColors.textMuted(context);
    return AppCard(
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: leading,
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
