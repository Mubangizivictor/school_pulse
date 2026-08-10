const crypto = require('crypto');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const {
  notifyOwners,
  notificationHealth,
  isOwnerData,
} = require('./owner_notification_engine');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const EMAIL_SECRETS = [
  'SMTP_HOST',
  'SMTP_PORT',
  'SMTP_USER',
  'SMTP_PASS',
  'SMTP_FROM',
  'OWNER_NOTIFICATION_EMAIL',
];

function text(value, max = 500) {
  return String(value ?? '').trim().slice(0, max);
}

async function requireOwner(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Sign in as the School Pulse SaaS Owner first.');
  }
  const snap = await db.collection('users').doc(request.auth.uid).get();
  const user = snap.data() || {};
  if (user.isActive === false || !isOwnerData(user)) {
    throw new HttpsError('permission-denied', 'Only the School Pulse SaaS Owner can manage owner notifications.');
  }
  return { uid: request.auth.uid, user };
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

/** Returns live diagnostics without sending anything. */
exports.getOwnerNotificationHealth = onCall(
  { region: 'europe-west1', secrets: EMAIL_SECRETS },
  async (request) => {
    await requireOwner(request);
    const health = await notificationHealth();
    return { ok: true, ...health };
  },
);

/**
 * Owner-only end-to-end test. Uses exactly the same in-app, FCM and email
 * pipeline as real application/payment events and returns every channel's
 * delivery result instead of hiding failures in logs.
 */
exports.testOwnerNotificationDelivery = onCall(
  { region: 'europe-west1', secrets: EMAIL_SECRETS },
  async (request) => {
    const owner = await requireOwner(request);
    const eventId = `owner_test_${owner.uid}_${Date.now()}`;
    const result = await notifyOwners({
      eventId,
      eventType: 'Notification system test',
      title: 'School Pulse notification test',
      body: 'This test uses the same delivery pipeline as new-school and payment alerts.',
      schoolName: 'School Pulse',
      data: {
        type: 'owner_notification_test',
        notificationType: 'custom',
        priority: 'high',
        sourceModule: 'super_admin',
        sourceEntityId: eventId,
      },
    });

    return {
      ok: true,
      eventId,
      ownerIds: result.ownerIds || [],
      ownerCount: result.ownerCount || 0,
      inApp: result.inApp || null,
      push: result.push || null,
      email: result.email || null,
    };
  },
);
