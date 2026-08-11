const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { isOwnerData } = require('./owner_notification_engine');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 200) {
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

/**
 * Marks a single owner notification as read. Notifications are server-write
 * only (see firestore.rules), so the client goes through this callable
 * instead of writing to super_admin_notifications directly.
 */
exports.markOwnerNotificationRead = onCall(
  { region: 'europe-west1' },
  async (request) => {
    await requireOwner(request);
    const id = text(request.data?.id, 300);
    if (!id) throw new HttpsError('invalid-argument', 'A notification id is required.');

    const ref = db.collection('super_admin_notifications').doc(id);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Notification not found.');

    await ref.set({
      status: snap.data()?.status === 'resolved' ? 'resolved' : 'read',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return { ok: true };
  },
);

/**
 * Permanently deletes a single owner notification. Owner-only; the
 * underlying school application/payment record is untouched - this only
 * removes the notification feed entry.
 */
exports.deleteOwnerNotification = onCall(
  { region: 'europe-west1' },
  async (request) => {
    await requireOwner(request);
    const id = text(request.data?.id, 300);
    if (!id) throw new HttpsError('invalid-argument', 'A notification id is required.');

    await db.collection('super_admin_notifications').doc(id).delete();
    return { ok: true, id };
  },
);

/**
 * Deletes every notification currently in the owner's feed. Owner-only,
 * used by the "Clear all" action in the notification center.
 */
exports.clearOwnerNotifications = onCall(
  { region: 'europe-west1' },
  async (request) => {
    await requireOwner(request);
    const snap = await db.collection('super_admin_notifications').get();
    if (snap.empty) return { ok: true, deleted: 0 };

    const batches = [];
    let batch = db.batch();
    let count = 0;
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
      count += 1;
      if (count % 400 === 0) {
        batches.push(batch.commit());
        batch = db.batch();
      }
    }
    batches.push(batch.commit());
    await Promise.all(batches);

    return { ok: true, deleted: snap.size };
  },
);
