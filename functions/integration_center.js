/**
 * Institution integration control plane.
 *
 * Provider credentials are deliberately absent from Firestore.  This module
 * only stores safe connection metadata; a future provider adapter receives a
 * credentialReference that points at Secret Manager, never secret material.
 */
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const REGISTRY = Object.freeze({
  google_sheets: { name: 'Google Sheets', category: 'Productivity', module: 'Attendance', entitlement: 'standard', testable: true, sync: true },
  google_calendar: { name: 'Google Calendar', category: 'Productivity', module: 'Calendar', entitlement: 'standard', testable: true, sync: true },
  transactional_email: { name: 'Transactional Email', category: 'Communication', module: 'Notifications', entitlement: 'included', testable: true },
  sms_gateway: { name: 'SMS Provider', category: 'Communication', module: 'Messaging', entitlement: 'standard', testable: true },
  push_notifications: { name: 'Push Notifications', category: 'Communication', module: 'Notifications', entitlement: 'included' },
  institution_mtn_momo: { name: 'MTN MoMo for school fees', category: 'Payments', module: 'Finance', entitlement: 'premium', testable: true },
  institution_airtel_money: { name: 'Airtel Money for school fees', category: 'Payments', module: 'Finance', entitlement: 'premium', testable: true },
  pesapal: { name: 'PesaPal', category: 'Payments', module: 'Finance', entitlement: 'premium', testable: true },
  biometric_device: { name: 'Biometric devices', category: 'Devices', module: 'Attendance', entitlement: 'standard' },
  receipt_printer: { name: 'Receipt printer', category: 'Printing', module: 'Finance', entitlement: 'standard', testable: true },
  custom_domain: { name: 'Custom domain', category: 'Domains', module: 'Public portal', entitlement: 'premium', testable: true },
  outbound_webhook: { name: 'Outbound webhooks', category: 'Data & APIs', module: 'Integrations', entitlement: 'premium', testable: true },
});

const ADMIN_ROLES = new Set(['schoolAdmin', 'headTeacher', 'director']);
const DB = () => admin.firestore();
function safeText(value, max = 160) { return String(value || '').trim().slice(0, max); }
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
function configRef(schoolId, key) { return DB().collection('schools').doc(schoolId).collection('integrations').doc(key); }
async function audit(schoolId, actorId, integrationKey, action, metadata = {}) {
  await DB().collection('schools').doc(schoolId).collection('integration_logs').add({
    institutionId: schoolId, integrationKey, action, actorId,
    metadata, createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
function toSafeConfig(key, snapshot) {
  const base = REGISTRY[key]; const data = snapshot && snapshot.exists ? snapshot.data() : {};
  return {
    integrationKey: key, displayName: base.name, category: base.category, requiredModule: base.module,
    minimumEntitlement: base.entitlement, supportsTestConnection: !!base.testable, supportsSync: !!base.sync,
    status: data.status || 'notConnected', enabled: data.enabled === true,
    connectedAccountDisplay: data.connectedAccountDisplay || '', configuration: data.configuration || {},
    credentialReference: data.credentialReference ? 'configured' : '', lastValidatedAt: data.lastValidatedAt || null,
    lastSuccessfulSyncAt: data.lastSuccessfulSyncAt || null, lastFailedAt: data.lastFailedAt || null,
    lastErrorSummary: data.lastErrorSummary || '', configurationVersion: data.configurationVersion || 0,
    connectedBy: data.connectedBy || '', connectedAt: data.connectedAt || null,
  };
}

exports.getIntegrationCenter = onCall(async (request) => {
  const actor = await caller(request, 'integrations.view');
  const snapshots = await Promise.all(Object.keys(REGISTRY).map((key) => configRef(actor.schoolId, key).get()));
  // Attendance's export engine predates this control plane. Mirror its safe
  // status here rather than creating a second export configuration.
  const sheetsLegacy = await DB().collection('schools').doc(actor.schoolId)
    .collection('attendance_sheets_integration').doc('config').get();
  const integrations = Object.keys(REGISTRY).map((key, index) => toSafeConfig(key, snapshots[index]));
  const sheetsIndex = integrations.findIndex((item) => item.integrationKey === 'google_sheets');
  if (sheetsIndex >= 0 && !snapshots[sheetsIndex].exists && sheetsLegacy.exists) {
    const legacy = sheetsLegacy.data();
    integrations[sheetsIndex] = { ...integrations[sheetsIndex], status: legacy.linked ? (legacy.lastSyncStatus === 'failed' ? 'failed' : 'connected') : 'notConnected', enabled: legacy.linked === true, connectedAccountDisplay: legacy.spreadsheetName || '', lastSuccessfulSyncAt: legacy.lastSyncStatus === 'success' ? legacy.lastSyncAt || null : null, lastErrorSummary: legacy.lastSyncStatus === 'failed' ? 'The most recent attendance export failed. Open Google Sheets to retry.' : '' };
  }
  return { institutionId: actor.schoolId, integrations };
});

exports.saveIntegrationMetadata = onCall(async (request) => {
  const actor = await caller(request, 'integrations.configure');
  const key = safeText(request.data?.integrationKey, 64);
  if (!REGISTRY[key]) throw new HttpsError('invalid-argument', 'Unknown integration.');
  const current = await configRef(actor.schoolId, key).get();
  const supplied = request.data?.configuration;
  if (supplied != null && (typeof supplied !== 'object' || Array.isArray(supplied))) throw new HttpsError('invalid-argument', 'Configuration must be an object.');
  // Only safe display/mapping metadata crosses this callable. Credential setup
  // must be a separate provider-specific Secret Manager/OAuth flow.
  const configuration = Object.fromEntries(Object.entries(supplied || {}).filter(([name, value]) =>
    /^[a-zA-Z][a-zA-Z0-9_]{0,63}$/.test(name) && typeof value !== 'object' && safeText(value, 256).length > 0
  ).map(([name, value]) => [name, safeText(value, 256)]));
  await configRef(actor.schoolId, key).set({
    institutionId: actor.schoolId, integrationKey: key, provider: key,
    configuration, connectedAccountDisplay: safeText(request.data?.connectedAccountDisplay, 160),
    enabled: request.data?.enabled === true, status: current.data()?.credentialReference ? 'setupRequired' : 'notConnected',
    configurationVersion: (current.data()?.configurationVersion || 0) + 1,
    updatedBy: actor.uid, updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  await audit(actor.schoolId, actor.uid, key, 'configuration_changed', { configurationKeys: Object.keys(configuration) });
  return { ok: true };
});

exports.testIntegrationConnection = onCall(async (request) => {
  const actor = await caller(request, 'integrations.test');
  const key = safeText(request.data?.integrationKey, 64);
  if (!REGISTRY[key] || !REGISTRY[key].testable) throw new HttpsError('failed-precondition', 'This integration cannot be tested safely.');
  const ref = configRef(actor.schoolId, key); const current = await ref.get();
  // A test is intentionally a validation of an already server-side credential
  // reference. It never attempts a financial charge or accepts client success.
  const configured = current.exists && !!current.data().credentialReference;
  const now = admin.firestore.FieldValue.serverTimestamp();
  await ref.set({ status: configured ? 'healthy' : 'setupRequired', lastValidatedAt: now,
    lastErrorSummary: configured ? '' : 'Secure provider authorization is required before this connection can be tested.',
    lastFailedAt: configured ? null : now, updatedAt: now }, { merge: true });
  await audit(actor.schoolId, actor.uid, key, 'connection_tested', { outcome: configured ? 'healthy' : 'setup_required' });
  return { healthy: configured, message: configured ? 'Connection metadata is valid. Provider operations remain server-side.' : 'Provider authorization has not been completed.' };
});

exports.disconnectIntegration = onCall(async (request) => {
  const actor = await caller(request, 'integrations.disconnect');
  const key = safeText(request.data?.integrationKey, 64);
  if (!REGISTRY[key]) throw new HttpsError('invalid-argument', 'Unknown integration.');
  await configRef(actor.schoolId, key).set({ enabled: false, status: 'disabled',
    connectedAccountDisplay: '', credentialReference: admin.firestore.FieldValue.delete(),
    webhookReference: admin.firestore.FieldValue.delete(), updatedAt: admin.firestore.FieldValue.serverTimestamp(), updatedBy: actor.uid }, { merge: true });
  await audit(actor.schoolId, actor.uid, key, 'disconnected', { operationalDataPreserved: true });
  return { ok: true };
});

exports.__test__ = { REGISTRY, toSafeConfig };
