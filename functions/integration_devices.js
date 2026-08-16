/**
 * Biometric/scan device registry for the Integrations Center. Devices are
 * tenant-scoped hardware records only - no credential material lives here.
 * institutionId is immutable after registration: a device can never be
 * re-parented to another school through these callables.
 */
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const ADMIN_ROLES = new Set(['schoolAdmin', 'headTeacher', 'director']);
const DB = () => admin.firestore();
const ALLOWED_STATUS = new Set(['online', 'offline', 'revoked', 'pendingActivation']);
function safeText(value, max = 160) { return String(value || '').trim().slice(0, max); }
async function caller(request, permission) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const user = await DB().collection('users').doc(request.auth.uid).get();
  if (!user.exists || !user.data().schoolId || user.data().isActive === false) throw new HttpsError('permission-denied', 'No active institution membership.');
  const data = user.data();
  const roles = [data.role, ...(Array.isArray(data.roles) ? data.roles : [])];
  const permissions = Array.isArray(data.permissions) ? data.permissions : [];
  if (!ADMIN_ROLES.has(data.role) && !roles.some((role) => ADMIN_ROLES.has(role)) && !permissions.includes(permission)) {
    throw new HttpsError('permission-denied', 'You do not have device management permission.');
  }
  return { uid: request.auth.uid, schoolId: data.schoolId };
}
function devicesRef(schoolId) { return DB().collection('schools').doc(schoolId).collection('integration_devices'); }
async function audit(schoolId, actorId, action, metadata = {}) {
  await DB().collection('schools').doc(schoolId).collection('integration_logs').add({
    institutionId: schoolId, integrationKey: 'biometric_device', action, actorId,
    metadata, createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
// Tenant-isolation guard shared by update/revoke - a device doc's
// institutionId must always equal the caller's own schoolId, and is never
// accepted from client input on updates.
function assertOwnedByCaller(deviceData, schoolId) {
  if (!deviceData || deviceData.institutionId !== schoolId) {
    throw new HttpsError('permission-denied', 'This device belongs to another institution.');
  }
}

exports.registerIntegrationDevice = onCall(async (request) => {
  const actor = await caller(request, 'integrations.manage_devices');
  const d = request.data || {};
  if (!safeText(d.deviceType) || !safeText(d.serialNumber)) throw new HttpsError('invalid-argument', 'deviceType and serialNumber are required.');
  const ref = devicesRef(actor.schoolId).doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  await ref.set({
    deviceId: ref.id, institutionId: actor.schoolId,
    deviceType: safeText(d.deviceType, 64), vendor: safeText(d.vendor, 96), model: safeText(d.model, 96),
    serialNumber: safeText(d.serialNumber, 128), campus: safeText(d.campus, 96), physicalLocation: safeText(d.physicalLocation, 160),
    assignedModule: safeText(d.assignedModule, 64), assignedGateFacility: safeText(d.assignedGateFacility, 96),
    connectionMethod: safeText(d.connectionMethod, 32), status: 'pendingActivation', lastSeen: null,
    firmwareVersion: safeText(d.firmwareVersion, 32), registeredBy: actor.uid, registeredAt: now, updatedAt: now,
  });
  await audit(actor.schoolId, actor.uid, 'device_registered', { deviceId: ref.id, deviceType: d.deviceType });
  return { deviceId: ref.id };
});

exports.updateIntegrationDeviceStatus = onCall(async (request) => {
  const actor = await caller(request, 'integrations.manage_devices');
  const deviceId = safeText(request.data?.deviceId, 128);
  const status = safeText(request.data?.status, 32);
  if (!deviceId || !ALLOWED_STATUS.has(status)) throw new HttpsError('invalid-argument', 'A valid deviceId and status are required.');
  const ref = devicesRef(actor.schoolId).doc(deviceId);
  const snapshot = await ref.get();
  if (!snapshot.exists) throw new HttpsError('not-found', 'Device not found.');
  assertOwnedByCaller(snapshot.data(), actor.schoolId);
  // institutionId is never accepted from client input here - only status,
  // lastSeen and firmwareVersion may move after registration.
  await ref.update({
    status, lastSeen: status === 'online' ? admin.firestore.FieldValue.serverTimestamp() : snapshot.data().lastSeen,
    firmwareVersion: request.data?.firmwareVersion ? safeText(request.data.firmwareVersion, 32) : snapshot.data().firmwareVersion,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await audit(actor.schoolId, actor.uid, 'device_status_updated', { deviceId, status });
  return { ok: true };
});

exports.revokeIntegrationDevice = onCall(async (request) => {
  const actor = await caller(request, 'integrations.manage_devices');
  const deviceId = safeText(request.data?.deviceId, 128);
  if (!deviceId) throw new HttpsError('invalid-argument', 'deviceId is required.');
  const ref = devicesRef(actor.schoolId).doc(deviceId);
  const snapshot = await ref.get();
  if (!snapshot.exists) throw new HttpsError('not-found', 'Device not found.');
  assertOwnedByCaller(snapshot.data(), actor.schoolId);
  await ref.update({ status: 'revoked', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
  await audit(actor.schoolId, actor.uid, 'device_revoked', { deviceId });
  return { ok: true };
});

exports.listIntegrationDevices = onCall(async (request) => {
  const actor = await caller(request, 'integrations.view');
  const snapshot = await devicesRef(actor.schoolId).orderBy('registeredAt', 'desc').get();
  return { devices: snapshot.docs.map((doc) => doc.data()) };
});

exports.__test__ = { assertOwnedByCaller, ALLOWED_STATUS };
