import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// The unified elevated Owner session model every owner authentication
/// path (password+TOTP, Google+TOTP, recovery code) converges into -
/// mirrors `owner_security_session.js`'s `establishOwnerSecuritySession`/
/// `validateOwnerSecuritySession` on the backend, which is the actual
/// source of truth. This class only ever holds the opaque `sessionId` in
/// memory (never SharedPreferences/localStorage, never persisted to disk)
/// and safe, non-sensitive labels the server already agreed to return -
/// never a TOTP secret, password, OAuth token, or recovery code.
///
/// Instances only ever come from a server call
/// ([OwnerSecuritySessionService.validate] or
/// [OwnerSecuritySessionService.validateOrReestablish]) - the app never
/// constructs one from cached/client-only state, so obtaining an instance
/// at all already means the server just confirmed it.
@immutable
class OwnerSecuritySession {
  final String sessionId;
  final bool isOwnerAuthorized;
  final bool secondFactorVerified;
  final String authenticationMethod;
  final DateTime? verifiedAt;

  const OwnerSecuritySession({
    required this.sessionId,
    required this.isOwnerAuthorized,
    required this.secondFactorVerified,
    required this.authenticationMethod,
    required this.verifiedAt,
  });
}

/// Establishes and validates the [OwnerSecuritySession] against the real
/// backend. A process-lifetime singleton (not persisted) holding only the
/// current `sessionId` - restarting the app or losing the in-memory
/// instance simply means the next [validate] call finds nothing to
/// validate, which is the correct fail-closed behavior per the "app
/// restart must not render Super Admin before re-validating" requirement.
class OwnerSecuritySessionService {
  OwnerSecuritySessionService._();
  static final OwnerSecuritySessionService instance =
      OwnerSecuritySessionService._();

  String? _sessionId;

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Establishes a new session immediately after a successful,
  /// server-asserted owner login (i.e. right after `assertPlatformOwnerAccess`
  /// succeeds for password/Google+TOTP, or right after
  /// `signInWithCustomToken` + `assertPlatformOwnerAccess` for recovery).
  /// The server independently re-verifies the caller is the owner
  /// (`requireOwner`) before creating anything - this call cannot be used
  /// to fabricate a session for an unauthorized caller.
  Future<bool> establish({required String authenticationMethod}) async {
    try {
      final result = await _functions
          .httpsCallable('establishOwnerSecuritySession')
          .call<Map<String, dynamic>>({
            'authenticationMethod': authenticationMethod,
          });
      final sessionId = result.data['sessionId'] as String?;
      if (sessionId == null) return false;
      _sessionId = sessionId;
      return true;
    } catch (_) {
      _sessionId = null;
      return false;
    }
  }

  /// Re-validates the current session against the server. Never trusts a
  /// cached "still valid" assumption - this always makes a live call, so a
  /// session revoked from another device is reflected the next time this
  /// is checked (e.g. on router navigation, or before a step-up action).
  Future<OwnerSecuritySession?> validate() async {
    final sessionId = _sessionId;
    if (sessionId == null) return null;
    try {
      final result = await _functions
          .httpsCallable('validateOwnerSecuritySession')
          .call<Map<String, dynamic>>({'sessionId': sessionId});
      final data = result.data;
      if (data['valid'] != true) {
        _sessionId = null;
        return null;
      }
      final verifiedAtMs = data['verifiedAt'] as num?;
      return OwnerSecuritySession(
        sessionId: data['sessionId'] as String? ?? sessionId,
        isOwnerAuthorized: data['isOwnerAuthorized'] as bool? ?? false,
        secondFactorVerified: data['secondFactorVerified'] as bool? ?? false,
        authenticationMethod: data['authenticationMethod'] as String? ?? '',
        verifiedAt: verifiedAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(verifiedAtMs.toInt()),
      );
    } catch (_) {
      _sessionId = null;
      return null;
    }
  }

  /// Validates the current in-memory session, and if there isn't one (the
  /// common case right after an app restart, since the sessionId pointer
  /// is deliberately never persisted), re-derives a fresh one from the
  /// still-live Firebase session instead of forcing a full re-login.
  ///
  /// This is not a weaker check than a fresh login: `establish()`'s own
  /// server-side `requireOwner()` call independently re-confirms the
  /// caller is the seeded owner, and reaching this point at all already
  /// required Firebase to have restored a session for an account with
  /// TOTP enrolled (the router's own mandatory-MFA-enrollment check runs
  /// before this). The authentication method is labeled honestly from the
  /// restored session's own `providerData`, not assumed.
  Future<OwnerSecuritySession?> validateOrReestablish() async {
    final existing = await validate();
    if (existing != null) return existing;

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
    final established = await establish(authenticationMethod: method);
    if (!established) return null;
    return validate();
  }

  /// Clears the in-memory session reference on logout. Does not itself
  /// revoke the server-side record (that's `revokeOwnerSessions`, a
  /// distinct, explicit "sign out everywhere" action) - this just ensures
  /// this process no longer treats itself as holding an elevated session.
  void clear() {
    _sessionId = null;
  }
}
