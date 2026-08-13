const { onCall, HttpsError } = require('firebase-functions/v2/https');
const crypto = require('crypto');
const admin = require('firebase-admin');
const { requireOwner } = require('./owner_auth');
const { ownerRateLimit, isCoolingDown, recordFailure, recordSuccess } = require('./owner_rate_limit');
const { verifyOwnerPassword, verifyGoogleIdToken } = require('./owner_first_factor_verify');

// The OAuth client ID(s) a Google ID token's `aud` claim must match for
// verifyGoogleIdToken to accept it. EMPTY until Google Sign-In's Firebase
// provider is configured for this project (see MANUAL CONFIG note on
// beginOwnerRecoveryChallenge below - confirmed still unconfigured:
// android/app/google-services.json's oauth_client array is empty).
// Deliberately not defaulted to something permissive - see
// verifyGoogleIdToken's own guard, which refuses to run with none set.
const GOOGLE_OAUTH_CLIENT_IDS = [];

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// Deliberately a *separate* top-level collection from super_admin_settings
// (not a sub-map on that doc): super_admin_settings/{ownerId} is
// client-readable by its owner (see firestore.rules), and a recovery-code
// *hash* must never be fetchable by the client even though it can't be
// reversed to the plaintext code - hashes of a 10-character random code are
// still a meaningfully smaller search space than the code generation itself
// guards against if an attacker can grind against them offline. This
// collection has `allow read, write: if false` in firestore.rules - Admin
// SDK (these callables) only.
const CODES_DOC = (ownerUid) => db.collection('owner_recovery_codes').doc(ownerUid);

// Recovery-login challenges: proof that a caller reached this specific
// account's MFA-required stage via a real first-factor login, before they
// may attempt a recovery code. Also server-only.
const CHALLENGES_COLLECTION = db.collection('owner_recovery_challenges');

const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I - avoids transcription errors
const CODE_LENGTH = 10;
const CODE_COUNT = 10;
const CHALLENGE_TTL_MS = 5 * 60 * 1000; // 5 minutes

function randomCode() {
  let out = '';
  const bytes = crypto.randomBytes(CODE_LENGTH);
  for (let i = 0; i < CODE_LENGTH; i++) {
    out += CODE_ALPHABET[bytes[i] % CODE_ALPHABET.length];
  }
  // Grouped for readability when the owner transcribes/stores it, e.g.
  // "ABCD-EFGHIJ" - purely cosmetic, stripped before hashing/verification.
  return `${out.slice(0, 4)}-${out.slice(4)}`;
}

function randomChallengeId() {
  return crypto.randomBytes(32).toString('base64url');
}

function normalize(code) {
  return String(code ?? '').trim().toUpperCase().replace(/[^A-Z0-9]/g, '');
}

function hashCode(code) {
  return crypto.createHash('sha256').update(normalize(code)).digest('hex');
}

// Deliberately separate from hashCode(): a client-generated session nonce
// (opaque, high-entropy, case-sensitive) has no reason to go through
// normalize()'s recovery-code-specific formatting (uppercasing, stripping
// non-alphanumerics) - that would needlessly throw away entropy and could
// even collide two different nonces that only differ in case/punctuation.
function hashNonce(nonce) {
  return crypto.createHash('sha256').update(String(nonce ?? '')).digest('hex');
}

/**
 * Pure predicate: is this challenge document (as read inside the
 * transaction) valid for THIS owner UID, right now, presented with the
 * SAME session nonce it was created with? Extracted from the transaction
 * body so the actual security-critical branching - the exact conditions
 * under which a challenge is accepted - is unit-testable without a
 * Firestore emulator, matching this codebase's existing convention (see
 * classifySignInEmail in owner_sign_in_events.js) of pulling pure decision
 * logic out of the Admin-SDK-calling function.
 *
 * `submittedNonceHash` is supplementary binding, not identity proof (see
 * beginOwnerRecoveryChallenge's comment on `clientSessionNonce`) - a
 * mismatch is treated identically to every other invalid-challenge case,
 * never distinguished in the response.
 */
function isChallengeValid(challengeData, ownerUid, nowMs, submittedNonceHash) {
  if (!challengeData) return false;
  if (challengeData.ownerUid !== ownerUid) return false;
  if (challengeData.used) return false;
  if (challengeData.nonceHash !== submittedNonceHash) return false;
  const expiresAtMs = typeof challengeData.expiresAt?.toMillis === 'function'
    ? challengeData.expiresAt.toMillis()
    : challengeData.expiresAt;
  if (typeof expiresAtMs !== 'number' || expiresAtMs < nowMs) return false;
  return true;
}

/**
 * Pure predicate: does this submitted code hash match an unused entry in
 * the stored codes array? Returns the array index (>= 0) or -1.
 */
function findUnusedCodeIndex(codes, submittedHash) {
  if (!Array.isArray(codes)) return -1;
  return codes.findIndex((c) => c?.hash === submittedHash && !c?.used);
}

async function writeAuditLog(ownerUid, action, metadata = {}) {
  const ref = db.collection('super_admin_audit_logs').doc();
  await ref.set({
    id: ref.id,
    ownerId: ownerUid,
    action,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    device: 'Owner Console',
    metadata,
  });
}

/**
 * Resolves the single seeded owner UID from `platform_config/owner_seed`,
 * the same authoritative source `requireOwner()` uses. Throws the same
 * generic denial as everywhere else in this file if unseeded - never
 * reveals whether an owner account exists to an unauthenticated caller.
 */
async function seededOwnerUid() {
  const seedSnap = await db.collection('platform_config').doc('owner_seed').get();
  const seed = seedSnap.exists ? seedSnap.data() : null;
  if (!seed?.seeded || !seed.ownerUid) {
    throw new HttpsError('permission-denied', 'Verification failed.');
  }
  return seed.ownerUid;
}

/**
 * Generates a fresh set of 10 recovery codes for the caller, replacing any
 * existing set (regeneration invalidates all previously issued codes).
 * Requires the owner to already have at least one TOTP factor enrolled,
 * since recovery codes exist to recover *that*; there's nothing to recover
 * if it was never set up. Also invalidates every outstanding, unused
 * recovery-login challenge for this owner - an old challenge bound to a
 * now-superseded code set must not remain redeemable.
 *
 * Returns the raw codes ONCE. Only their SHA-256 hashes are persisted.
 */
exports.generateOwnerRecoveryCodes = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);

  const allowed = await ownerRateLimit(owner.uid, 'recovery_codes_generate', 5);
  if (!allowed) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const authUser = await admin.auth().getUser(owner.uid);
  const enrolledFactors = authUser.multiFactor?.enrolledFactors ?? [];
  if (enrolledFactors.length === 0) {
    throw new HttpsError(
      'failed-precondition',
      'Set up Two-Step Verification before generating recovery codes.'
    );
  }

  const codes = Array.from({ length: CODE_COUNT }, randomCode);
  const hashes = codes.map((code) => ({ hash: hashCode(code), used: false }));

  await CODES_DOC(owner.uid).set({
    ownerUid: owner.uid,
    codes: hashes,
    generatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await invalidateOutstandingChallenges(owner.uid);

  await writeAuditLog(owner.uid, 'OWNER_RECOVERY_CODES_REGENERATED', {
    count: codes.length,
  });

  return { ok: true, codes };
});

async function invalidateOutstandingChallenges(ownerUid) {
  const snap = await CHALLENGES_COLLECTION
    .where('ownerUid', '==', ownerUid)
    .where('used', '==', false)
    .get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.update(doc.ref, { used: true, invalidatedAt: admin.firestore.FieldValue.serverTimestamp() }));
  await batch.commit();
}

/**
 * Reports only whether recovery codes currently exist and how many are
 * still unused - never the codes or hashes themselves - so the Security
 * Settings screen can show real state without a second privileged read
 * path into the codes document.
 */
exports.getOwnerRecoveryCodesStatus = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  const snap = await CODES_DOC(owner.uid).get();
  if (!snap.exists) return { exists: false, remaining: 0 };
  const codes = Array.isArray(snap.data()?.codes) ? snap.data().codes : [];
  return { exists: true, remaining: codes.filter((c) => !c.used).length };
});

/**
 * Issues a short-lived, single-use recovery-login challenge. Callable ONLY
 * after this function has itself independently re-verified a real
 * first-factor credential against Google's own infrastructure - it never
 * relies on `resolver`/`hints`/`MultiFactorSession` from the Firebase MFA
 * client SDK for this, because none of those are server-verifiable by our
 * own backend (Firebase's opaque MFA session can only ever be redeemed by
 * Firebase's own `resolver.resolveSignIn()`, and the Admin SDK has no
 * equivalent verification call - see owner_first_factor_verify.js's header
 * comment for the full audit trail on why, including the confirmed-absent
 * `verifyMfaPendingCredential`-equivalent in firebase-admin, and Google's
 * own Identity Platform docs stating there is no built-in MFA-recovery
 * bridge). An enrolled-factor UID, which the previous version of this
 * function relied on, is static account metadata - not a signed,
 * time-limited, single-use credential - so it was NOT sufficient proof
 * that this specific caller, right now, supplied a valid first factor.
 *
 * Supported first-factor re-verification methods:
 *  - `password`: re-checks the owner's actual current password directly
 *    against Identity Toolkit's `accounts:signInWithPassword` REST
 *    endpoint (the same one every Firebase client SDK calls internally).
 *    The password is never stored/logged - see verifyOwnerPassword.
 *  - `google`: re-verifies a fresh Google ID token's signature, issuer,
 *    audience and expiry directly against Google's own infrastructure.
 *    MANUAL CONFIG STILL REQUIRED: this project has not yet configured
 *    Google Sign-In's OAuth client IDs in Firebase (confirmed:
 *    android/app/google-services.json's oauth_client array is empty, no
 *    REVERSED_CLIENT_ID in GoogleService-Info.plist). GOOGLE_OAUTH_CLIENT_IDS
 *    is intentionally left empty until that's done; this path returns
 *    `failed-precondition` rather than skipping the audience check, since
 *    an unchecked audience would accept a validly-signed Google ID token
 *    from ANY app, not just this one.
 *  - Apple: deferred, matching the rest of this codebase's current scope.
 *
 * The resulting verified identity (Firebase `localId` for password,
 * `googleSub` cross-referenced to a Firebase account for Google) MUST
 * equal the seeded owner UID before a challenge is issued - this function
 * never issues a challenge for any other account, and never trusts a
 * client-supplied UID to shortcut that check.
 */
exports.beginOwnerRecoveryChallenge = onCall({ region: 'europe-west1' }, async (request) => {
  const ownerUid = await seededOwnerUid();

  const allowed = await ownerRateLimit(ownerUid, 'recovery_challenge_begin', 10);
  if (!allowed) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const cooldownMs = await isCoolingDown(ownerUid, 'recovery_challenge_begin');
  if (cooldownMs > 0) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const provider = request.data?.provider;
  let verifiedUid = null;

  if (provider === 'password') {
    const email = String(request.data?.email ?? '').trim();
    const password = String(request.data?.password ?? '');
    if (!email || !password) {
      throw new HttpsError('invalid-argument', 'Missing verification context.');
    }
    const verification = await verifyOwnerPassword(email, password);

    // The seeded owner account is REQUIRED to have TOTP enrolled (Phase 1's
    // mandatory-MFA enforcement) - a correct password for that account
    // with no mfaPendingCredential/mfaInfo present is not a normal
    // outcome. Fail closed and audit it distinctly from an ordinary wrong
    // password, since it indicates a security-configuration anomaly (MFA
    // somehow disabled, or an unexpected Identity Toolkit response shape)
    // rather than an attacker simply guessing wrong.
    if (verification.localId === ownerUid && verification.mfaAnomaly) {
      await writeAuditLog(ownerUid, 'OWNER_SECURITY_CONFIG_ANOMALY', {
        method: 'recovery_challenge_begin',
        reason: 'password_correct_but_no_mfa_pending',
      });
      throw new HttpsError('failed-precondition', 'Verification failed.');
    }

    verifiedUid = verification.mfaEnrolled ? verification.localId : null;
  } else if (provider === 'google') {
    if (GOOGLE_OAUTH_CLIENT_IDS.length === 0) {
      throw new HttpsError(
        'failed-precondition',
        'Google recovery is not yet configured for this project.'
      );
    }
    const idToken = String(request.data?.idToken ?? '');
    if (!idToken) {
      throw new HttpsError('invalid-argument', 'Missing verification context.');
    }
    const googleIdentity = await verifyGoogleIdToken(idToken, GOOGLE_OAUTH_CLIENT_IDS);
    if (googleIdentity) {
      // A verified Google identity proves control of that Google account -
      // it does NOT by itself prove which Firebase UID it's linked to.
      // Cross-reference via the Admin SDK's own provider-linking record
      // (the same trust boundary link/unlink already establishes) rather
      // than trusting any client-supplied UID or matching by email, which
      // both Apple private-relay addresses and plain account-collision
      // risk make unsafe (see sign_in_methods_screen.dart's own handling).
      try {
        const linkedUser = await admin.auth().getUserByProviderUid('google.com', googleIdentity.googleSub);
        verifiedUid = linkedUser.uid;
      } catch (_) {
        verifiedUid = null; // no Firebase account linked to this Google identity
      }
    }
  } else {
    throw new HttpsError('invalid-argument', 'Unsupported recovery method.');
  }

  if (verifiedUid !== ownerUid) {
    // Same generic denial as everywhere else - this covers "wrong
    // password", "correct password but not the owner's account" (not
    // possible here since ownerUid is fixed, but kept structurally
    // uniform), and "Google identity not linked to the owner" as one case
    // among several, without distinguishing them in the response.
    await recordFailure(ownerUid, 'recovery_challenge_begin');
    await writeAuditLog(ownerUid, 'OWNER_MFA_FAILURE', { method: 'recovery_challenge_begin', provider });
    throw new HttpsError('permission-denied', 'Verification failed.');
  }
  await recordSuccess(ownerUid, 'recovery_challenge_begin');

  // Supplementary binding, NOT identity proof: the client generates a
  // fresh cryptographically random nonce for this one recovery attempt
  // and sends it here; only its hash is stored. verifyOwnerRecoveryCode
  // later requires the same plaintext nonce back, so a challengeId alone
  // (e.g. leaked via a logging bug, a shared clipboard, a compromised
  // proxy that saw the begin-challenge response but not the client's own
  // in-memory nonce) is not sufficient to redeem the challenge. The real
  // security boundary remains the independently-verified first factor
  // above; this only narrows the window for a stolen challengeId.
  const clientSessionNonce = String(request.data?.clientSessionNonce ?? '');
  if (!clientSessionNonce || clientSessionNonce.length < 16) {
    throw new HttpsError('invalid-argument', 'Missing verification context.');
  }
  const nonceHash = hashNonce(clientSessionNonce);

  const challengeId = randomChallengeId();
  const ref = CHALLENGES_COLLECTION.doc(challengeId);
  await ref.set({
    id: challengeId,
    ownerUid,
    firstFactorProvider: provider,
    firstFactorVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    nonceHash,
    used: false,
    attemptCount: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + CHALLENGE_TTL_MS),
  });

  return { ok: true, challengeId };
});

/**
 * Verifies a recovery code presented as the SECOND factor during owner
 * sign-in, in place of a TOTP code. Requires a valid, unexpired, unused
 * `challengeId` from `beginOwnerRecoveryChallenge` bound to the same owner
 * UID - a recovery code alone, with no such challenge, is never sufficient
 * (see that function's doc comment for why this exists at all).
 *
 * Deliberately callable WITHOUT an authenticated `request.auth` - at the
 * point this fires (the MFA challenge screen, in place of resolving
 * Firebase's own TOTP `MultiFactorAssertion`), Firebase has not finished
 * sign-in yet: `resolver.resolveSignIn()` is what would normally mint the
 * session, and recovery codes are this app's own mechanism, not a Firebase
 * MFA factor Firebase itself understands, so there is no
 * `resolveSignIn`-equivalent to call afterwards. The challenge (rather than
 * `request.auth`) is what proves this caller already passed first factor.
 *
 * On success the recovery code AND the challenge are consumed atomically in
 * one transaction, then a fresh Firebase custom token is minted for the
 * seeded owner UID so the client can complete sign-in via
 * `signInWithCustomToken` - fully replacing what `resolver.resolveSignIn()`
 * would have done. The custom token carries no custom claims (no
 * `platformOwner`/`mfaVerified`/`superAdmin` flags) - it only asserts the
 * Firebase UID, exactly like every other `createCustomToken` call in this
 * codebase. The client must call `assertPlatformOwnerAccess` again
 * immediately after signing in with it (see mfa_challenge_screen.dart) -
 * this function proves the recovery code was valid, it does not itself
 * grant standing owner-console access.
 */
exports.verifyOwnerRecoveryCode = onCall({ region: 'europe-west1' }, async (request) => {
  const uid = await seededOwnerUid();

  const allowed = await ownerRateLimit(uid, 'recovery_code_verify', 5);
  if (!allowed) {
    await writeAuditLog(uid, 'OWNER_MFA_FAILURE', { method: 'recovery_code', reason: 'rate_limited' });
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  // On top of the flat 5/hour cap above, a run of consecutive failures
  // escalates a per-owner cooldown (30s, 2min, 10min, 30min) that resets
  // on the next success - this is checked BEFORE the code is ever
  // compared, so a caller currently cooling down can't spend attempts
  // probing during the window.
  const cooldownMs = await isCoolingDown(uid, 'recovery_code_verify');
  if (cooldownMs > 0) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const challengeId = String(request.data?.challengeId ?? '');
  const submitted = normalize(request.data?.code);
  const clientSessionNonce = String(request.data?.clientSessionNonce ?? '');
  if (!challengeId || !submitted || !clientSessionNonce) {
    throw new HttpsError('invalid-argument', 'Missing verification context.');
  }
  const submittedHash = hashCode(submitted);
  const submittedNonceHash = hashNonce(clientSessionNonce);

  const challengeRef = CHALLENGES_COLLECTION.doc(challengeId);
  const codesRef = CODES_DOC(uid);

  const MAX_ATTEMPTS_PER_CHALLENGE = 5;

  const outcome = await db.runTransaction(async (tx) => {
    const challengeSnap = await tx.get(challengeRef);
    const challengeData = challengeSnap.exists ? challengeSnap.data() : null;

    if (!isChallengeValid(challengeData, uid, Date.now(), submittedNonceHash)) {
      return 'invalid_challenge';
    }

    const attemptCount = Number(challengeData.attemptCount ?? 0);
    if (attemptCount >= MAX_ATTEMPTS_PER_CHALLENGE) {
      // Burn the challenge outright rather than merely counting the
      // attempt - a fresh beginOwnerRecoveryChallenge (with a fresh
      // first-factor re-verification) is required after this many wrong
      // codes against the SAME challenge, closing the window for grinding
      // codes within one 5-minute-old challenge.
      tx.update(challengeRef, { used: true, usedAt: admin.firestore.FieldValue.serverTimestamp() });
      return 'invalid_challenge';
    }

    const codesSnap = await tx.get(codesRef);
    const codes = codesSnap.exists && Array.isArray(codesSnap.data()?.codes) ? codesSnap.data().codes : [];
    const index = findUnusedCodeIndex(codes, submittedHash);
    if (index === -1) {
      tx.update(challengeRef, { attemptCount: attemptCount + 1 });
      return 'invalid_code';
    }

    // Consume BOTH atomically: a code can never be reused, and the same
    // challenge can never be redeemed twice even with a different code.
    codes[index] = { ...codes[index], used: true, usedAt: new Date().toISOString() };
    tx.update(codesRef, { codes });
    tx.update(challengeRef, { used: true, usedAt: admin.firestore.FieldValue.serverTimestamp() });
    return 'ok';
  });

  if (outcome !== 'ok') {
    await recordFailure(uid, 'recovery_code_verify');
    await writeAuditLog(uid, 'OWNER_MFA_FAILURE', { method: 'recovery_code', reason: outcome });
    throw new HttpsError('permission-denied', 'Verification failed.');
  }

  await recordSuccess(uid, 'recovery_code_verify');
  await writeAuditLog(uid, 'OWNER_RECOVERY_CODE_USED', {});

  const customToken = await admin.auth().createCustomToken(uid);
  return { ok: true, customToken };
});

// Exported for other owner-security modules IN THIS SAME CODEBASE
// (public_functions/) to call directly (in-process, not as a separate
// callable) whenever a security-relevant event should burn any
// outstanding recovery challenge - password change, provider link/unlink,
// TOTP reset/disable, mass session revocation. See callers in
// owner_auth.js (logOwnerProviderEvent) and owner_sign_in_events.js
// (revokeOwnerSessions).
exports.invalidateOutstandingChallenges = invalidateOutstandingChallenges;

/**
 * HTTPS-callable wrapper around invalidateOutstandingChallenges, for
 * callers that can't require() this module directly - specifically the
 * client-side calls from two_factor_auth_screen.dart (TOTP disable) and
 * change_password_screen.dart (both shared, non-owner-specific screens
 * that call this best-effort after their own action succeeds), and
 * anything in functions/index.js's SEPARATE `default` Cloud Functions
 * codebase (see firebase.json's two `codebase` entries), which has no
 * module-level access to public_functions/ code at all.
 */
exports.invalidateOwnerRecoveryChallenges = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  await invalidateOutstandingChallenges(owner.uid);
  return { ok: true };
});

exports.__test__ = {
  normalize,
  hashCode,
  hashNonce,
  isChallengeValid,
  findUnusedCodeIndex,
  CHALLENGE_TTL_MS,
};
