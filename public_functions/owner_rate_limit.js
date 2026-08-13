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

/**
 * Progressive cooldown on top of [ownerRateLimit]'s flat hourly cap, for
 * endpoints where a fixed "N per hour" ceiling isn't enough on its own -
 * specifically recovery-code verification, where an attacker who can make
 * bursts of guesses right up to the hourly limit still gets a meaningful
 * number of attempts. Tracks consecutive failures per owner+bucket; each
 * call to [recordFailure] escalates the cooldown window, and
 * [recordSuccess] clears it. The cooldown is checked via [isCoolingDown]
 * BEFORE attempting the action, so a caller mid-cooldown never even
 * reaches the code-comparison step.
 *
 * Escalation is deliberately capped (not indefinite lockout) - the spec
 * this implements is explicit that the legitimate owner must not be
 * permanently locked out after a handful of typos.
 */
const COOLDOWN_STEPS_MS = [
  0, // first failure: no cooldown yet
  30 * 1000, // 2nd failure: 30s
  2 * 60 * 1000, // 3rd: 2min
  10 * 60 * 1000, // 4th: 10min
  30 * 60 * 1000, // 5th+: 30min, does not grow further
];

function cooldownDoc(ownerUid, bucket) {
  return db.collection('_owner_rate_limits').doc(`cooldown_${bucket}_${ownerUid}`);
}

/** Returns milliseconds remaining in an active cooldown, or 0 if none. */
async function isCoolingDown(ownerUid, bucket) {
  const snap = await cooldownDoc(ownerUid, bucket).get();
  if (!snap.exists) return 0;
  const until = snap.data()?.cooldownUntilMs;
  if (!until) return 0;
  const remaining = until - Date.now();
  return remaining > 0 ? remaining : 0;
}

async function recordFailure(ownerUid, bucket) {
  const ref = cooldownDoc(ownerUid, bucket);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const failureCount = snap.exists ? Number(snap.data()?.failureCount ?? 0) + 1 : 1;
    const step = Math.min(failureCount, COOLDOWN_STEPS_MS.length) - 1;
    const cooldownMs = COOLDOWN_STEPS_MS[step];
    tx.set(ref, {
      ownerUid,
      bucket,
      failureCount,
      cooldownUntilMs: Date.now() + cooldownMs,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  });
}

async function recordSuccess(ownerUid, bucket) {
  await cooldownDoc(ownerUid, bucket).set({
    ownerUid,
    bucket,
    failureCount: 0,
    cooldownUntilMs: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

module.exports = { ownerRateLimit, isCoolingDown, recordFailure, recordSuccess };
