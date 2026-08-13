import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:school_pulse/design_system/components/reauth_password_dialog.dart';
import 'package:school_pulse/features/auth/data/datasources/apple_nonce.dart';
import 'package:school_pulse/features/auth/data/datasources/google_sign_in_config.dart';
import 'package:school_pulse/features/super_admin/domain/owner_security_session_service.dart';

/// Central policy for "is the current owner session fresh enough for a
/// sensitive action", and the one place that knows how to step up that
/// freshness regardless of which first-factor provider the owner actually
/// uses. Every sensitive owner action (provider link/unlink, MFA disable,
/// recovery-code regeneration, mass session revocation, plan/pricing
/// changes, payment approvals, school suspension, payment-destination
/// changes, etc.) routes through [ensureFreshAuthentication] rather than
/// each screen inventing its own reauth rule - the existing
/// `showReauthPasswordDialog` only works for an owner whose sign-in method
/// is email/password, and silently fails/misleads an owner who signed in
/// with Google only.
class OwnerSecurityPolicy {
  const OwnerSecurityPolicy._();

  /// Firebase considers a sign-in "recent" for privileged operations like
  /// `updatePassword`/`unlink` for a short server-defined window, after
  /// which those calls throw `auth/requires-recent-login`. 10 minutes is
  /// the freshness window used everywhere in this app for owner step-up -
  /// one number, not invented per screen - deliberately inside Firebase's
  /// own tolerance so the app prompts before hitting that server-side wall
  /// with a confusing mid-action failure, rather than after.
  static const Duration freshnessWindow = Duration(minutes: 10);

  /// True if [FirebaseAuth.currentUser]'s last sign-in was recent enough
  /// that a sensitive action can proceed without prompting again. This is
  /// the LOCAL half of freshness (cheap, synchronous, no network call) -
  /// [ensureFreshAuthentication] additionally confirms the unified
  /// [OwnerSecuritySession] is still valid server-side before proceeding,
  /// since a locally-fresh Firebase sign-in says nothing about whether the
  /// session was since revoked from another device.
  static bool isSessionFresh() {
    final lastSignIn =
        FirebaseAuth.instance.currentUser?.metadata.lastSignInTime;
    if (lastSignIn == null) return false;
    return DateTime.now().difference(lastSignIn) < freshnessWindow;
  }

  /// Ensures the current session is fresh AND still valid server-side,
  /// prompting for reauthentication with whichever first-factor provider
  /// the owner actually has - password if enrolled, otherwise the first
  /// linked OAuth provider - when either check fails. Returns true only
  /// once both the local freshness window and a live
  /// [OwnerSecuritySessionService.validate] check pass, so a sensitive
  /// action can never proceed against a session that was revoked from
  /// another device even if this device's own Firebase sign-in still looks
  /// locally recent.
  static Future<bool> ensureFreshAuthentication(
    BuildContext context, {
    required String reason,
  }) async {
    // validateOrReestablish (not validate) because the very first time an
    // owner enables TOTP there is no elevated session yet to validate - one
    // must be derived from the still-live Firebase sign-in instead, or this
    // always fails closed before the reauth dialog below ever gets a
    // chance to run.
    final session = await OwnerSecuritySessionService.instance
        .validateOrReestablish();
    if (session == null) return false;

    if (isSessionFresh()) return true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final providerIds = user.providerData.map((p) => p.providerId).toSet();

    final reauthenticated = providerIds.contains('password')
        ? await showReauthPasswordDialog(context, reason: reason)
        : providerIds.contains('google.com')
        ? await _reauthenticateWithGoogle(user)
        : providerIds.contains('apple.com')
        ? await _reauthenticateWithApple(user)
        : false; // No recognized first factor to step up with - fail closed.

    if (!reauthenticated) return false;

    // A fresh first-factor reauth is itself worth re-anchoring the
    // elevated session to, so the next sensitive action in this same
    // session doesn't immediately re-prompt.
    await OwnerSecuritySessionService.instance.establish(
      authenticationMethod: providerIds.contains('google.com')
          ? 'google_totp'
          : providerIds.contains('apple.com')
          ? 'apple_totp'
          : 'password_totp',
    );
    return true;
  }

  static Future<bool> _reauthenticateWithGoogle(User user) async {
    final googleSignIn = ownerGoogleSignIn();
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException {
      return false;
    } finally {
      await googleSignIn.signOut();
    }
  }

  static Future<bool> _reauthenticateWithApple(User user) async {
    try {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(OAuthProvider('apple.com'));
        return true;
      }
      final nonce = AppleNonce.generate();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email],
        nonce: nonce.hashed,
      );
      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: nonce.raw,
        accessToken: appleCredential.authorizationCode,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException {
      return false;
    } on SignInWithAppleAuthorizationException {
      return false;
    }
  }
}
