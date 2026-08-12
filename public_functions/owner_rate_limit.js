const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

/**
 * Per-owner, per-bucket, per-hour rate limit for sensitive onCall security
 * actions (session revocation, password/MFA/trusted-device event logging).
 * Mirrors the transactional counter pattern already used for the public
 * school-application endpoint in index.js (`rateLimit(req, bucket, limit)`),
 * adapted to key on the authenticated owner UID instead of caller IP, since
 * onCall functions here are always behind `requireOwner()` and an IP-keyed
 * limit would be trivially sidestepped by a compromised account switching
 * networks.
 *
 * Returns true if the action is allowed (and records it), false if the
 * caller has hit the limit for this hour.
 */
async function ownerRateLimit(ownerUid, bucket, limit) {
  const hour = new Date().toISOString().slice(0, 13);
  const ref = db.collection('_owner_rate_limits').doc(`${bucket}_${ownerUid}_${hour}`);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const count = snap.exists ? Number(snap.data()?.count ?? 0) : 0;
    if (count >= limit) return false;
    tx.set(ref, {
      count: count + 1,
      ownerUid,
      bucket,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    return true;
  });
}

module.exports = { ownerRateLimit };
