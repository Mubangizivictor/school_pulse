const crypto = require('crypto');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 500) {
  return String(value ?? '').trim().slice(0, max);
}

// Thin wrapper over the canonical @school-pulse/owner-auth package - see
// shared/owner-auth/index.js.
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

function tokenId(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

/**
 * Canonical FCM registration endpoint for the SaaS Owner device.
 *
 * The Flutter app still mirrors the token below users/{uid}/tokens for the
 * shared notification engine, but this Admin-SDK registry gives platform
 * notifications a rule-independent source of truth.
 */
exports.registerOwnerNotificationDevice = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const token = text(request.data?.token, 4096);
    if (token.length < 20) throw new HttpsError('invalid-argument', 'A valid FCM token is required.');

    const platform = text(request.data?.platform, 40) || 'unknown';
    const appVersion = text(request.data?.appVersion, 80);
    const id = tokenId(token);
    const serverTime = admin.firestore.FieldValue.serverTimestamp();

    const globalRef = db.collection('platform_owner_device_tokens').doc(id);
    const userRef = db.collection('users').doc(owner.uid).collection('tokens').doc(token);
    const batch = db.batch();
    batch.set(globalRef, {
      token,
      ownerId: owner.uid,
      platform,
      appVersion,
      enabled: true,
      createdAt: serverTime,
      updatedAt: serverTime,
      lastSeenAt: serverTime,
    }, { merge: true });
    batch.set(userRef, {
      token,
      ownerId: owner.uid,
      schoolId: '',
      platform,
      app: 'school_pulse_owner',
      enabled: true,
      createdAt: serverTime,
      updatedAt: serverTime,
      lastSeenAt: serverTime,
    }, { merge: true });
    await batch.commit();

    return { ok: true, tokenId: id, platform };
  },
);

exports.unregisterOwnerNotificationDevice = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const token = text(request.data?.token, 4096);
    if (!token) return { ok: true, removed: false };

    const batch = db.batch();
    batch.delete(db.collection('platform_owner_device_tokens').doc(tokenId(token)));
    batch.delete(db.collection('users').doc(owner.uid).collection('tokens').doc(token));
    await batch.commit();
    return { ok: true, removed: true };
  },
);
