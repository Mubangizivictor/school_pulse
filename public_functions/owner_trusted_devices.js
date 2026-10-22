const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

// Thin wrapper over the canonical @school-pulse/owner-auth package.
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

function sessionRef(ownerUid, deviceId) {
  return db
    .collection('super_admin_settings')
    .doc(ownerUid)
    .collection('sessions')
    .doc(deviceId);
}

async function writeAudit(ownerUid, action, deviceId, extra = {}) {
  await db.collection('super_admin_audit_logs').add({
    action,
    actorUid: ownerUid,
    ownerId: ownerUid,
    entityType: 'owner_trusted_device',
    entityId: deviceId,
    device: 'Owner Console',
    metadata: extra,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Sets the trusted flag on one of the owner's own device/session records.
 *
 * The Firestore rule already scopes super_admin_settings/{ownerId}/sessions
 * to the owner, so this callable is defence in depth for a security-
 * sensitive write: it re-checks ownership against the canonical
 * platform_config/owner_seed boundary (not just a superAdmin role) and
 * writes an audit entry the direct client write never produced. Renaming a
 * device rides on the same path via the optional `deviceName`.
 */
exports.setOwnerDeviceTrust = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const deviceId = text(request.data?.deviceId, 200);
    const trusted = request.data?.trusted === true;
    const deviceName = text(request.data?.deviceName, 120);
    if (!deviceId) throw new HttpsError('invalid-argument', 'A deviceId is required.');

    const ref = sessionRef(owner.uid, deviceId);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'That device is not in your registry.');

    const patch = { trusted, updatedAt: admin.firestore.FieldValue.serverTimestamp() };
    if (deviceName) patch.deviceName = deviceName;
    await ref.set(patch, { merge: true });

    await writeAudit(
      owner.uid,
      trusted ? 'OWNER_DEVICE_TRUSTED' : 'OWNER_DEVICE_UNTRUSTED',
      deviceId,
      { deviceName: deviceName || snap.data()?.deviceName || null },
    );
    return { ok: true, deviceId, trusted };
  },
);

/**
 * Revokes a device from the owner's registry (remote session
 * invalidation). Deletes the session record and, when a canonical owner
 * device token registry entry exists for that install, disables it so
 * platform pushes stop targeting the revoked device. Always audited.
 *
 * The current device cannot be revoked through this path - that is what the
 * explicit "sign out this device" flow is for - so a stale client cannot
 * lock the owner out of their own console.
 */
exports.revokeOwnerDevice = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const deviceId = text(request.data?.deviceId, 200);
    const currentDeviceId = text(request.data?.currentDeviceId, 200);
    if (!deviceId) throw new HttpsError('invalid-argument', 'A deviceId is required.');
    if (deviceId === currentDeviceId) {
      throw new HttpsError(
        'failed-precondition',
        'You cannot revoke the device you are currently signed in on from here.',
      );
    }

    const ref = sessionRef(owner.uid, deviceId);
    const snap = await ref.get();
    const deviceName = text(snap.data()?.deviceName, 120) || null;

    await ref.delete();

    // Best effort: disable owner push tokens registered from this install.
    try {
      const tokens = await db
        .collection('platform_owner_device_tokens')
        .where('ownerId', '==', owner.uid)
        .where('deviceId', '==', deviceId)
        .get();
      const batch = db.batch();
      tokens.docs.forEach((doc) => batch.set(doc.ref, { enabled: false }, { merge: true }));
      if (!tokens.empty) await batch.commit();
    } catch (error) {
      console.error('revokeOwnerDevice token disable failed', error);
    }

    await writeAudit(owner.uid, 'OWNER_DEVICE_REVOKED', deviceId, { deviceName });
    return { ok: true, deviceId };
  },
);
