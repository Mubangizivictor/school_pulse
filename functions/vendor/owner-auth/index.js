/**
 * Canonical, single-source-of-truth Platform Owner authorization.
 *
 * Both Firebase Functions codebases in this repo (functions/ = codebase
 * "default", public_functions/ = codebase "publicwebsite" - see
 * repo-root firebase.json) deploy as entirely SEPARATE Cloud Functions
 * services with no shared require() graph: each `source` directory is
 * independently zipped and uploaded, so a plain `require('../../shared/...')`
 * reaching outside a function source directory would work locally but
 * silently break in deployment (the parent directory isn't in the bundle).
 *
 * This package is the fix: a local npm package at shared/owner-auth,
 * added as a `file:../shared/owner-auth` dependency in BOTH
 * functions/package.json and public_functions/package.json. `npm install`
 * resolves a `file:` dependency by copying its contents into that
 * project's own node_modules - which IS included in each codebase's
 * deploy bundle - so both codebases end up shipping an identical copy of
 * this exact code, not two hand-maintained implementations that can
 * silently diverge over time (the problem this replaces: functions/index.js
 * and public_functions/owner_auth.js previously each had their own
 * `requireOwner()` with subtly different logic).
 *
 * requirePlatformOwner(request, { db }) contract:
 *  - request must be authenticated (request.auth.uid present)
 *  - resolves platform_config/owner_seed for the canonical ownerUid -
 *    the ONLY authorization boundary that matters, written once by the
 *    offline bootstrap_owner.js script via a service-account-holding
 *    operator, never by any client or callable
 *  - the authenticated UID must equal that canonical ownerUid
 *  - users/{uid} must exist
 *  - that profile must carry an ACTIVE owner/superAdmin role
 *  - NEVER authorizes by email match
 *  - NEVER trusts any role/uid/flag the client supplied in request.data
 *
 * `db` is passed in (rather than this module calling `admin.firestore()`
 * itself) so it has no dependency on which specific `firebase-admin`
 * instance/initialization a given codebase uses - each codebase already
 * calls `admin.initializeApp()` itself; this module just needs a
 * Firestore handle, declared as a peerDependency rather than a bundled
 * dependency to avoid two different firebase-admin copies loading in the
 * same function's node_modules.
 */

const OWNER_ROLE_VALUES = new Set(['superAdmin', 'super_admin', 'saasOwner', 'saas_owner']);

/**
 * Same broadened "is this profile doc an owner" check
 * public_functions/owner_notification_engine.js's isOwnerData() already
 * used - duplicated here (not imported) since owner_notification_engine.js
 * lives in public_functions/, unreachable from functions/. Keep both in
 * sync if this logic changes; a future consolidation could migrate
 * owner_notification_engine.js's own isOwnerData() to re-export this one
 * instead, once that file's own dependents are audited.
 */
function isOwnerProfile(userData) {
  if (!userData) return false;
  if (userData.isSuperAdmin === true) return true;
  const roles = [
    ...(Array.isArray(userData.roles) ? userData.roles : []),
    userData.role,
    userData.platformRole,
  ].filter(Boolean);
  return roles.some((role) => OWNER_ROLE_VALUES.has(role));
}

class OwnerAuthorizationError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

/**
 * @param {{auth?: {uid?: string}, data?: unknown}} request - the Cloud
 *   Functions v2 `CallableRequest` (or any object exposing the same
 *   `auth.uid` shape).
 * @param {{db: import('firebase-admin').firestore.Firestore}} deps
 * @returns {Promise<{uid: string, user: object}>}
 * @throws {OwnerAuthorizationError} with code 'unauthenticated' or
 *   'permission-denied' - callers map these to their own HttpsError type
 *   (see owner_auth.js and functions/index.js's thin wrappers), since this
 *   module deliberately has no dependency on firebase-functions.
 */
async function requirePlatformOwner(request, { db }) {
  const uid = request?.auth?.uid;
  if (!uid) {
    throw new OwnerAuthorizationError('unauthenticated', 'Sign in first.');
  }

  const seedSnap = await db.collection('platform_config').doc('owner_seed').get();
  const seed = seedSnap.exists ? seedSnap.data() : null;
  if (!seed?.seeded || seed.ownerUid !== uid) {
    throw new OwnerAuthorizationError('permission-denied', 'Access denied.');
  }

  const userSnap = await db.collection('users').doc(uid).get();
  const user = userSnap.exists ? userSnap.data() : null;
  if (!user || user.isActive === false || !isOwnerProfile(user)) {
    throw new OwnerAuthorizationError('permission-denied', 'Access denied.');
  }

  return { uid, user };
}

module.exports = { requirePlatformOwner, isOwnerProfile, OwnerAuthorizationError };
