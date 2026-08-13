const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const {
  requirePlatformOwner,
  rejectIfPlatformOwner,
  OwnerAuthorizationError,
} = require('./vendor/owner-auth');
const { ownerRateLimit } = require('./owner_rate_limit');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const VALID_PROVIDER_IDS = new Set(['google.com', 'apple.com', 'password']);

/**
 * Thin wrapper around the canonical `@school-pulse/owner-auth` package
 * (shared/owner-auth/index.js), which is the ONE authoritative
 * implementation of "is this authenticated UID the School Pulse SaaS
 * Owner" - consumed identically by this codebase (public_functions/,
 * deployed as the `publicwebsite` codebase) and functions/index.js
 * (deployed as the `default` codebase), resolved via a local
 * `file:../shared/owner-auth` npm dependency in both package.json files
 * so `npm install` copies one identical implementation into each
 * codebase's own node_modules rather than two hand-maintained copies
 * that can silently drift apart (which is what existed here previously -
 * see this function's git history for the two divergent implementations
 * this replaced).
 *
 * Only responsibility left to this wrapper: translate the shared
 * package's transport-agnostic `OwnerAuthorizationError` into this
 * codebase's `firebase-functions` `HttpsError`, since the shared package
 * deliberately has no dependency on firebase-functions itself.
 */
async function requireOwner(request) {
  try {
    return await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }
}

/**
 * Called by the Flutter client immediately after Firebase Authentication
 * accepts a first-factor credential (email/password, Google, or Apple) on
 * the dedicated Platform Owner Access screen - never from the ordinary
 * Staff Gateway. Firebase Auth succeeding only proves *an* identity; this
 * is the server-side gate that decides whether *that* identity is the
 * platform owner before the client is allowed to treat the session as
 * anything more than "signed into Firebase".
 *
 * On denial the client must sign out immediately and show a generic
 * "Access denied" - this function intentionally returns the same
 * permission-denied error regardless of *why* the caller isn't the owner
 * (wrong account entirely vs. a deactivated owner account), so a random
 * Google/Apple account discovering the hidden entry point learns nothing
 * about whether an owner account exists.
 */
exports.assertPlatformOwnerAccess = onCall({ region: 'europe-west1' }, async (request) => {
  // Keyed on the authenticated (not-yet-proven-owner) UID rather than only
  // gating after requireOwner() succeeds - a caller who is NOT the owner
  // still consumes their own bucket, so a compromised or curious non-owner
  // Google/Apple account can't hammer this endpoint indefinitely to see if
  // *anything* about the response ever changes.
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign in first.');
  }
  const allowed = await ownerRateLimit(uid, 'assert_owner_access', 20);
  if (!allowed) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const owner = await requireOwner(request);
  return { ok: true, uid: owner.uid };
});

/**
 * Called by the Flutter client from every NON-owner authentication surface
 * (Staff Gateway email/password login, and app-start session restore) right
 * after Firebase Authentication resolves a UID - the inverse gate of
 * [assertPlatformOwnerAccess]. The seeded owner must never be able to reach
 * a staff session, even with correct credentials, a remembered session, or a
 * restored Firebase session: this callable rejects the request outright if
 * (and only if) the authenticated UID is the canonical seeded owner UID
 * (`platform_config/owner_seed.ownerUid`), the same single source of truth
 * [assertPlatformOwnerAccess] uses - never keyed on email.
 *
 * Rate-limited per-UID for the same reason assertPlatformOwnerAccess is: a
 * caller who ISN'T the owner still consumes their own bucket, so this can't
 * be hammered to probe for behavior differences.
 */
exports.assertNotPlatformOwner = onCall({ region: 'europe-west1' }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign in first.');
  }
  const allowed = await ownerRateLimit(uid, 'assert_not_owner_access', 30);
  if (!allowed) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  try {
    await rejectIfPlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }

  return { ok: true };
});

/**
 * Audits a Google/Apple/password provider link or unlink event. The actual
 * `linkWithCredential`/`unlink` call is client-side Firebase Auth SDK work
 * (Cloud Functions have no equivalent Admin SDK operation for interactive
 * OAuth linking) - this callable only runs AFTER that already succeeded,
 * to (a) confirm the UID performing the link/unlink is still the seeded
 * owner and (b) write the audit trail entry server-side so the client can't
 * fabricate a fake "linked" audit record for a link that never happened.
 */
exports.logOwnerProviderEvent = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);

  const allowed = await ownerRateLimit(owner.uid, 'provider_link_event', 20);
  if (!allowed) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const providerId = String(request.data?.providerId ?? '');
  const action = request.data?.action === 'unlink' ? 'unlink' : 'link';
  if (!VALID_PROVIDER_IDS.has(providerId)) {
    throw new HttpsError('invalid-argument', 'Unknown provider.');
  }

  const auditRef = db.collection('super_admin_audit_logs').doc();
  await auditRef.set({
    id: auditRef.id,
    ownerId: owner.uid,
    action: action === 'link' ? 'OWNER_PROVIDER_LINKED' : 'OWNER_PROVIDER_UNLINKED',
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    device: 'Owner Console',
    metadata: { providerId },
  });

  // Required lazily (not at module top-level) to avoid a circular
  // require: owner_recovery_codes.js itself requires this module for
  // requireOwner(). Any change to sign-in methods invalidates outstanding
  // recovery challenges - a challenge issued against the owner's old
  // provider set must not remain redeemable after that set changes.
  const { invalidateOutstandingChallenges } = require('./owner_recovery_codes');
  await invalidateOutstandingChallenges(owner.uid);

  return { ok: true };
});

module.exports.requireOwner = requireOwner;
