const { onCall, HttpsError } = require('firebase-functions/v2/https');
const crypto = require('crypto');
const admin = require('firebase-admin');
const { requireOwner } = require('./owner_auth');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// Server-only (allow read, write: if false in firestore.rules). The client
// never reads this collection directly - it only ever holds the opaque
// sessionId returned by establishOwnerSecuritySession, and asks the server
// to validate it via validateOwnerSecuritySession. This is the single
// converged security-session model every owner authentication path
// (password+TOTP, Google+TOTP, recovery code) writes into, so
// /super-admin route protection has ONE thing to check regardless of how
// the owner actually signed in.
const SESSIONS_COLLECTION = db.collection('owner_security_sessions');

const SESSION_TTL_MS = 12 * 60 * 60 * 1000; // 12 hours - a normal owner console session
const VALID_METHODS = new Set(['password_totp', 'google_totp', 'apple_totp', 'recovery_code']);

function randomSessionId() {
  return crypto.randomBytes(32).toString('base64url');
}

/**
 * Pure predicate: is this session document valid for THIS owner UID,
 * right now? Extracted for the same reason isChallengeValid is in
 * owner_recovery_codes.js - the actual security-critical branching is
 * unit-testable without a Firestore emulator.
 */
function isSessionValid(sessionData, ownerUid, nowMs) {
  if (!sessionData) return false;
  if (sessionData.ownerUid !== ownerUid) return false;
  if (sessionData.revoked) return false;
  const expiresAtMs = typeof sessionData.expiresAt?.toMillis === 'function'
    ? sessionData.expiresAt.toMillis()
    : sessionData.expiresAt;
  if (typeof expiresAtMs !== 'number' || expiresAtMs < nowMs) return false;
  return true;
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
 * Establishes a new elevated Owner security session immediately after a
 * successful, server-verified owner authentication - called by the client
 * right after `assertPlatformOwnerAccess` succeeds (for password/Google
 * first-factor + TOTP logins) or right after `verifyOwnerRecoveryCode`
 * succeeds and the resulting custom token is signed into (for recovery).
 * The caller must ALREADY be an authenticated, owner-asserted session
 * (gated by `requireOwner`) - this never accepts a client-asserted
 * `authenticationMethod`/`secondFactor` as a substitute for that.
 *
 * This is the ONE thing every owner login path converges into: whichever
 * of the three methods was used, the resulting session record has the
 * same shape, so route protection and the step-up policy only ever need
 * to check ONE thing (`validateOwnerSecuritySession`) instead of
 * re-deriving "is this really an authorized, second-factor-verified owner
 * session" from AuthBloc's client-side role state.
 */
exports.establishOwnerSecuritySession = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);

  const authenticationMethod = String(request.data?.authenticationMethod ?? '');
  if (!VALID_METHODS.has(authenticationMethod)) {
    throw new HttpsError('invalid-argument', 'Unknown authentication method.');
  }
  const firstFactorProvider = authenticationMethod === 'recovery_code'
    ? String(request.data?.firstFactorProvider ?? 'password')
    : authenticationMethod.replace('_totp', '');
  const secondFactor = authenticationMethod === 'recovery_code' ? 'recovery_code' : 'totp';

  const sessionId = randomSessionId();
  const now = Date.now();
  await SESSIONS_COLLECTION.doc(sessionId).set({
    sessionId,
    ownerUid: owner.uid,
    authenticationMethod,
    firstFactorProvider,
    secondFactor,
    verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromMillis(now + SESSION_TTL_MS),
    revoked: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await writeAuditLog(owner.uid, 'OWNER_LOGIN_SUCCESS', { authenticationMethod });

  return { ok: true, sessionId, expiresAt: now + SESSION_TTL_MS };
});

/**
 * Validates an existing Owner security session. This is what
 * `/super-admin` route protection and the central step-up policy both
 * call - neither trusts AuthBloc's client-side role state alone. Returns
 * only safe, non-sensitive fields (never anything that could reconstruct
 * a credential or bypass future checks).
 */
exports.validateOwnerSecuritySession = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);

  const sessionId = String(request.data?.sessionId ?? '');
  if (!sessionId) {
    return { valid: false };
  }

  const snap = await SESSIONS_COLLECTION.doc(sessionId).get();
  const valid = isSessionValid(snap.exists ? snap.data() : null, owner.uid, Date.now());
  if (!valid) {
    return { valid: false };
  }

  const data = snap.data();
  const verifiedAtMs = typeof data.verifiedAt?.toMillis === 'function' ? data.verifiedAt.toMillis() : null;
  return {
    valid: true,
    isOwnerAuthorized: true,
    secondFactorVerified: true,
    authenticationMethod: data.authenticationMethod,
    verifiedAt: verifiedAtMs,
    sessionId,
  };
});

/**
 * Marks every Owner security session for [ownerUid] revoked. Called from
 * `revokeOwnerSessions` (owner_sign_in_events.js) so a "sign out
 * everywhere" also immediately invalidates the elevated session model,
 * not just Firebase's own refresh tokens - the two are kept in sync but
 * are independent mechanisms (a revoked security session with a still-live
 * Firebase refresh token must still be denied by validateOwnerSecuritySession).
 */
async function revokeAllOwnerSecuritySessions(ownerUid) {
  const snap = await SESSIONS_COLLECTION
    .where('ownerUid', '==', ownerUid)
    .where('revoked', '==', false)
    .get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.update(doc.ref, { revoked: true, revokedAt: admin.firestore.FieldValue.serverTimestamp() }));
  await batch.commit();
}

exports.revokeAllOwnerSecuritySessions = revokeAllOwnerSecuritySessions;

exports.__test__ = { isSessionValid, VALID_METHODS, SESSION_TTL_MS };
