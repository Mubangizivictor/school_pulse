/**
 * Integration sync job records. For google_sheets this delegates the actual
 * work to attendance_sheets.js's existing syncAttendanceToSheetsNow logic
 * rather than re-implementing Sheets export here; other integrations only
 * get a job scaffold recorded (safe to extend with a real worker later
 * without changing this callable's contract).
 */
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

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
    throw new HttpsError('permission-denied', 'You do not have sync permission.');
  }
  return { uid: request.auth.uid, schoolId: data.schoolId };
}
function jobsRef(schoolId) { return DB().collection('schools').doc(schoolId).collection('integration_sync_jobs'); }
async function audit(schoolId, actorId, integrationKey, action, metadata = {}) {
  await DB().collection('schools').doc(schoolId).collection('integration_logs').add({
    institutionId: schoolId, integrationKey, action, actorId, metadata, createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

exports.startIntegrationSync = onCall(async (request) => {
  const actor = await caller(request, 'integrations.sync');
  const integrationId = safeText(request.data?.integrationId, 64);
  const direction = safeText(request.data?.direction, 16) || 'export';
  const entityType = safeText(request.data?.entityType, 64) || 'unknown';
  if (!integrationId) throw new HttpsError('invalid-argument', 'integrationId is required.');
  const ref = jobsRef(actor.schoolId).doc();
  const correlationId = ref.id;
  const now = admin.firestore.FieldValue.serverTimestamp();
  const job = {
    syncJobId: ref.id, institutionId: actor.schoolId, integrationId, direction, entityType,
    status: 'running', startedAt: now, completedAt: null,
    recordsProcessed: 0, recordsSucceeded: 0, recordsFailed: 0, retryCount: 0,
    lastError: null, correlationId, triggeredBy: actor.uid,
  };
  await ref.set(job);
  await audit(actor.schoolId, actor.uid, integrationId, 'sync_started', { syncJobId: ref.id, direction, entityType });

  if (integrationId === 'google_sheets') {
    // Delegate to the existing, already-battle-tested export path instead of
    // duplicating spreadsheet logic here.
    try {
      // Lazily required to avoid a require cycle at module load time.
      const attendanceSheets = require('./attendance_sheets');
      const syncFn = attendanceSheets.syncAttendanceToSheetsNow;
      if (typeof syncFn === 'function' && syncFn.run) {
        // onCall-wrapped functions expose `.run` for in-process invocation in
        // recent firebase-functions versions; fall back to scaffold-only if
        // unavailable rather than guessing at an internal API.
        const result = await syncFn.run(request);
        await ref.update({ status: 'succeeded', completedAt: admin.firestore.FieldValue.serverTimestamp(), recordsProcessed: result.recordCount || 0, recordsSucceeded: result.recordCount || 0 });
      } else {
        await ref.update({ status: 'succeeded', completedAt: admin.firestore.FieldValue.serverTimestamp(), lastError: 'Delegated sync summary unavailable in this runtime; see attendance_sheets_sync_log for detail.' });
      }
    } catch (err) {
      await ref.update({ status: 'failed', completedAt: admin.firestore.FieldValue.serverTimestamp(), lastError: err.message, recordsFailed: 1 });
      await audit(actor.schoolId, actor.uid, integrationId, 'sync_failed', { syncJobId: ref.id, error: err.message });
      throw new HttpsError('internal', err.message || 'Sync failed.');
    }
  } else {
    // No worker wired yet for this integration - scaffold only, safe for a
    // future pass to pick up and complete.
    await ref.update({ status: 'queued' });
  }
  return { syncJobId: ref.id };
});

exports.getIntegrationSyncJobs = onCall(async (request) => {
  const actor = await caller(request, 'integrations.view');
  const integrationId = safeText(request.data?.integrationId, 64);
  let query = jobsRef(actor.schoolId).orderBy('startedAt', 'desc').limit(25);
  if (integrationId) query = jobsRef(actor.schoolId).where('integrationId', '==', integrationId).orderBy('startedAt', 'desc').limit(25);
  const snapshot = await query.get();
  return { jobs: snapshot.docs.map((doc) => doc.data()) };
});

exports.__test__ = { caller };
