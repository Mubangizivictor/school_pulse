/**
 * Integration Health summary - cheap aggregate counts over already-stored
 * schools/{schoolId}/integrations and schools/{schoolId}/integration_devices
 * documents. Deliberately does not fan out to any provider network call;
 * "healthy"/"failed" here reflects the last recorded status only.
 */
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const ADMIN_ROLES = new Set(['schoolAdmin', 'headTeacher', 'director']);
const DB = () => admin.firestore();
async function caller(request, permission) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const user = await DB().collection('users').doc(request.auth.uid).get();
  if (!user.exists || !user.data().schoolId || user.data().isActive === false) throw new HttpsError('permission-denied', 'No active institution membership.');
  const data = user.data();
  const roles = [data.role, ...(Array.isArray(data.roles) ? data.roles : [])];
  const permissions = Array.isArray(data.permissions) ? data.permissions : [];
  if (!ADMIN_ROLES.has(data.role) && !roles.some((role) => ADMIN_ROLES.has(role)) && !permissions.includes(permission)) {
    throw new HttpsError('permission-denied', 'You do not have integration permission.');
  }
  return { uid: request.auth.uid, schoolId: data.schoolId };
}

exports.getIntegrationHealthSummary = onCall(async (request) => {
  const actor = await caller(request, 'integrations.view');
  const [integrationsSnap, devicesSnap] = await Promise.all([
    DB().collection('schools').doc(actor.schoolId).collection('integrations').get(),
    DB().collection('schools').doc(actor.schoolId).collection('integration_devices').get(),
  ]);
  const summary = { connected: 0, healthy: 0, warning: 0, failed: 0, reauthRequired: 0, deviceOffline: 0, deviceTotal: devicesSnap.size };
  integrationsSnap.forEach((doc) => {
    const data = doc.data();
    if (data.enabled === true) summary.connected += 1;
    if (data.status === 'healthy') summary.healthy += 1;
    else if (data.status === 'failed') summary.failed += 1;
    else if (data.status === 'setupRequired') summary.reauthRequired += 1;
    else if (data.status === 'warning') summary.warning += 1;
  });
  devicesSnap.forEach((doc) => {
    if (doc.data().status === 'offline') summary.deviceOffline += 1;
  });
  return { institutionId: actor.schoolId, summary };
});

exports.__test__ = { caller };
