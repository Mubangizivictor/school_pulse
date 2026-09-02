const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 200) {
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

/**
 * True when the owner feed document belongs to `ownerUid`, OR carries no
 * `ownerId` at all (legacy documents written before ownerId scoping was
 * added - there is exactly one canonical seeded platform owner, so an
 * unscoped legacy doc can only ever have been meant for them). A doc that
 * carries a *different* ownerId is never visible - that is the cross-owner
 * isolation guarantee, enforced here in addition to the Firestore rule.
 */
function belongsToOwner(data, ownerUid) {
  const owner = text(data?.ownerId, 200);
  return owner === '' || owner === ownerUid;
}

/**
 * Marks a single owner notification as read. Notifications are server-write
 * only (see firestore.rules), so the client goes through this callable
 * instead of writing to super_admin_notifications directly.
 */
exports.markOwnerNotificationRead = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const id = text(request.data?.id, 300);
    if (!id) throw new HttpsError('invalid-argument', 'A notification id is required.');

    const ref = db.collection('super_admin_notifications').doc(id);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Notification not found.');
    if (!belongsToOwner(snap.data(), owner.uid)) {
      throw new HttpsError('permission-denied', 'That notification is not in your feed.');
    }

    await ref.set({
      status: snap.data()?.status === 'resolved' ? 'resolved' : 'read',
      readAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return { ok: true };
  },
);

/**
 * Marks every unread notification in the owner's feed as read in a single
 * call, so the client's "Mark all read" action does not have to fan out one
 * callable invocation per document.
 */
exports.markAllOwnerNotificationsRead = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const snap = await db.collection('super_admin_notifications')
      .where('status', '==', 'unread')
      .get();
    const serverTime = admin.firestore.FieldValue.serverTimestamp();

    const targets = snap.docs.filter((doc) => belongsToOwner(doc.data(), owner.uid));
    if (targets.length === 0) return { ok: true, updated: 0 };

    const commits = [];
    let batch = db.batch();
    let count = 0;
    for (const doc of targets) {
      batch.set(doc.ref, { status: 'read', readAt: serverTime, updatedAt: serverTime }, { merge: true });
      count += 1;
      if (count % 400 === 0) {
        commits.push(batch.commit());
        batch = db.batch();
      }
    }
    commits.push(batch.commit());
    await Promise.all(commits);

    return { ok: true, updated: targets.length };
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
    const owner = await requireOwner(request);
    const id = text(request.data?.id, 300);
    if (!id) throw new HttpsError('invalid-argument', 'A notification id is required.');

    const ref = db.collection('super_admin_notifications').doc(id);
    const snap = await ref.get();
    if (snap.exists && !belongsToOwner(snap.data(), owner.uid)) {
      throw new HttpsError('permission-denied', 'That notification is not in your feed.');
    }

    await ref.delete();
    return { ok: true, id };
  },
);

/**
 * Deletes every notification currently in the owner's feed. Owner-only,
 * used by the "Clear all" action in the notification center. Only documents
 * that belong to (or are legacy-unscoped for) the calling owner are
 * removed - a notification carrying a different ownerId is left untouched.
 */
exports.clearOwnerNotifications = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const snap = await db.collection('super_admin_notifications').get();
    if (snap.empty) return { ok: true, deleted: 0 };

    const targets = snap.docs.filter((doc) => belongsToOwner(doc.data(), owner.uid));
    if (targets.length === 0) return { ok: true, deleted: 0 };

    const batches = [];
    let batch = db.batch();
    let count = 0;
    for (const doc of targets) {
      batch.delete(doc.ref);
      count += 1;
      if (count % 400 === 0) {
        batches.push(batch.commit());
        batch = db.batch();
      }
    }
    batches.push(batch.commit());
    await Promise.all(batches);

    return { ok: true, deleted: targets.length };
  },
);

module.exports.belongsToOwner = belongsToOwner;
