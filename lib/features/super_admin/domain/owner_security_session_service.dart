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

/// Why a session check came back without a usable session.
///
/// The router needs to tell "the server said this caller is definitely not
/// an authorized owner (or has no session)" apart from "we could not reach
/// the server right now". Only the former should bounce the user to
/// `/owner-login`; the latter must leave the current screen in place and
/// re-check on the next router refresh, otherwise a slow/failed Cloud
/// Function call briefly navigates an authenticated owner out of the
/// console and back - the flash/return behaviour.
enum OwnerSessionOutcomeStatus { valid, invalid, indeterminate }

@immutable
class OwnerSessionOutcome {
  const OwnerSessionOutcome._(this.status, this.session);

  factory OwnerSessionOutcome.valid(OwnerSecuritySession session) =>
      OwnerSessionOutcome._(OwnerSessionOutcomeStatus.valid, session);

  static const OwnerSessionOutcome invalid = OwnerSessionOutcome._(
    OwnerSessionOutcomeStatus.invalid,
    null,
  );
  static const OwnerSessionOutcome indeterminate = OwnerSessionOutcome._(
    OwnerSessionOutcomeStatus.indeterminate,
    null,
  );

  final OwnerSessionOutcomeStatus status;
  final OwnerSecuritySession? session;

  bool get isValid => status == OwnerSessionOutcomeStatus.valid;
  bool get isInvalid => status == OwnerSessionOutcomeStatus.invalid;
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

  /// Short-lived memo of the last successful validation. The router calls
  /// [validateOrReestablishOutcome] on every navigation into `/super-admin`
  /// (and its `refreshListenable` fires that again on every AuthBloc
  /// emission); without this, each tap made one or two live Cloud Function
  /// round-trips, and any that resolved slowly raced the optimistic
  /// navigation. A confirmed-valid session does not change second to
  /// second, so a brief cache here is safe and removes the per-tap await
  /// after the first resolve. Invalidated by [clear] and by [establish].
  OwnerSecuritySession? _cachedSession;
  DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 30);

  bool get _cacheIsFresh {
    final at = _cachedAt;
    return _cachedSession != null &&
        at != null &&
        DateTime.now().difference(at) < _cacheTtl;
  }

  void _storeCache(OwnerSecuritySession session) {
    _cachedSession = session;
    _cachedAt = DateTime.now();
  }

  void _invalidateCache() {
    _cachedSession = null;
    _cachedAt = null;
  }

  @visibleForTesting
  void debugSetCache(OwnerSecuritySession? session, {DateTime? at}) {
    _cachedSession = session;
    _cachedAt = session == null ? null : (at ?? DateTime.now());
  }

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
      _invalidateCache();
      return true;
    } catch (_) {
      _sessionId = null;
      _invalidateCache();
      return false;
    }
  }

  /// Re-validates the current session against the server. Never trusts a
  /// cached "still valid" assumption - this always makes a live call, so a
  /// session revoked from another device is reflected the next time this
  /// is checked (e.g. on router navigation, or before a step-up action).
  Future<OwnerSecuritySession?> validate() async {
    final outcome = await validateOutcome();
    return outcome.session;
  }

  /// Like [validate] but distinguishes a server-confirmed negative
  /// ([OwnerSessionOutcome.invalid] - no session, or the server said it is
  /// not valid) from a transport/availability failure
  /// ([OwnerSessionOutcome.indeterminate]). The router redirects to
  /// `/owner-login` only on the former.
  Future<OwnerSessionOutcome> validateOutcome() async {
    final sessionId = _sessionId;
    if (sessionId == null) return OwnerSessionOutcome.invalid;
    try {
      final result = await _functions
          .httpsCallable('validateOwnerSecuritySession')
          .call<Map<String, dynamic>>({'sessionId': sessionId});
      final data = result.data;
      if (data['valid'] != true) {
        _sessionId = null;
        _invalidateCache();
        return OwnerSessionOutcome.invalid;
      }
      final verifiedAtMs = data['verifiedAt'] as num?;
      final session = OwnerSecuritySession(
        sessionId: data['sessionId'] as String? ?? sessionId,
        isOwnerAuthorized: data['isOwnerAuthorized'] as bool? ?? false,
        secondFactorVerified: data['secondFactorVerified'] as bool? ?? false,
        authenticationMethod: data['authenticationMethod'] as String? ?? '',
        verifiedAt: verifiedAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(verifiedAtMs.toInt()),
      );
      _storeCache(session);
      return OwnerSessionOutcome.valid(session);
    } on FirebaseFunctionsException catch (e) {
      // `unauthenticated` / `permission-denied` are the server deciding
      // this caller is not entitled - a real negative. Everything else
      // (`unavailable`, `deadline-exceeded`, `internal`, network) is an
      // availability problem: do not tear down the session over it.
      if (e.code == 'unauthenticated' || e.code == 'permission-denied') {
        _sessionId = null;
        _invalidateCache();
        return OwnerSessionOutcome.invalid;
      }
      return OwnerSessionOutcome.indeterminate;
    } catch (_) {
      return OwnerSessionOutcome.indeterminate;
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
    final outcome = await validateOrReestablishOutcome();
    return outcome.session;
  }

  /// Outcome-typed variant used by the router guard. Returns a fresh
  /// [OwnerSessionOutcome.valid] from the short-lived cache without any
  /// network call when the cache is still warm.
  Future<OwnerSessionOutcome> validateOrReestablishOutcome() async {
    if (_cacheIsFresh) return OwnerSessionOutcome.valid(_cachedSession!);

    final existing = await validateOutcome();
    if (existing.isValid) return existing;
    // Could not reach the server - keep the caller where they are rather
    // than forcing a re-login over a transient failure.
    if (existing.status == OwnerSessionOutcomeStatus.indeterminate) {
      return existing;
    }

    Set<String> providerIds;
    try {
      providerIds =
          FirebaseAuth.instance.currentUser?.providerData
              .map((p) => p.providerId)
              .toSet() ??
          const <String>{};
    } catch (_) {
      // No Firebase available (or currentUser access failed) - can't
      // re-establish, so this is not a confirmed-invalid session.
      return OwnerSessionOutcome.indeterminate;
    }
    final method = providerIds.contains('google.com')
        ? 'google_totp'
        : providerIds.contains('apple.com')
        ? 'apple_totp'
        : 'password_totp';
    final established = await establish(authenticationMethod: method);
    if (!established) return OwnerSessionOutcome.indeterminate;
    return validateOutcome();
  }

  /// Clears the in-memory session reference on logout. Does not itself
  /// revoke the server-side record (that's `revokeOwnerSessions`, a
  /// distinct, explicit "sign out everywhere" action) - this just ensures
  /// this process no longer treats itself as holding an elevated session.
  void clear() {
    _sessionId = null;
    _invalidateCache();
  }
}
