/** Institution Health control plane.
 *
 * This module deliberately reads/writes only health read models. Owning
 * modules publish deterministic check results after their own validation;
 * this function queues targeted rechecks and records human acknowledgement.
 */
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const ADMIN_ROLES = new Set(['schoolAdmin', 'headTeacher', 'director']);
const allowedStates = new Set(['acknowledged', 'inProgress', 'ignored']);
async function actor(request, permission) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const user = await admin.firestore().collection('users').doc(request.auth.uid).get();
  const data = user.data();
  if (!user.exists || !data.schoolId || data.isActive === false) throw new HttpsError('permission-denied', 'No active institution membership.');
  const roles = [data.role, ...(Array.isArray(data.roles) ? data.roles : [])];
  const permissions = Array.isArray(data.permissions) ? data.permissions : [];
  if (!roles.some((role) => ADMIN_ROLES.has(role)) && !permissions.includes(permission)) throw new HttpsError('permission-denied', 'Your effective permissions do not allow this health action.');
  return { uid: request.auth.uid, institutionId: data.schoolId };
}
function healthRoot(institutionId) { return admin.firestore().collection('institutions').doc(institutionId); }
async function audit(institutionId, actorId, action, metadata) {
  await healthRoot(institutionId).collection('health_audit').add({ actorId, action, metadata, createdAt: admin.firestore.FieldValue.serverTimestamp() });
}

exports.requestInstitutionHealthRecheck = onCall(async (request) => {
  const institutionId = String(request.data?.institutionId || '');
  const user = await actor(request, 'institution_health.recheck');
  if (institutionId !== user.institutionId) throw new HttpsError('permission-denied', 'Health data belongs to another institution.');
  const checkKey = String(request.data?.checkKey || '');
  // Queue deduplication makes repeated UI refreshes retry-safe. A worker owned
  // by the source module consumes this job; it must not cause a client scan.
  const id = checkKey ? `check_${checkKey.replace(/[^a-zA-Z0-9_-]/g, '_')}` : 'institution';
  await healthRoot(institutionId).collection('health_recheck_requests').doc(id).set({ institutionId, checkKey: checkKey || null, requestedBy: user.uid, status: 'requested', requestedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  await audit(institutionId, user.uid, 'health.recheck_requested', { checkKey: checkKey || null });
  return { ok: true };
});

exports.resolveInstitutionHealthIssue = onCall(async (request) => {
  const institutionId = String(request.data?.institutionId || '');
  const checkId = String(request.data?.checkId || '');
  const state = String(request.data?.state || '');
  const user = await actor(request, state === 'ignored' ? 'institution_health.ignore' : 'institution_health.acknowledge');
  if (institutionId !== user.institutionId || !checkId || !allowedStates.has(state)) throw new HttpsError('invalid-argument', 'The health resolution request is invalid.');
  if (state === 'ignored' && !String(request.data?.reason || '').trim()) throw new HttpsError('invalid-argument', 'Ignoring an issue requires a reason.');
  const check = healthRoot(institutionId).collection('health_checks').doc(checkId);
  const snapshot = await check.get();
  if (!snapshot.exists) throw new HttpsError('not-found', 'Health check not found.');
  if (state === 'ignored' && snapshot.data().severity === 'critical') throw new HttpsError('failed-precondition', 'Critical issues cannot be ignored.');
  const resolution = healthRoot(institutionId).collection('health_resolutions').doc();
  await admin.firestore().runTransaction(async (tx) => {
    tx.update(check, { resolutionState: state, resolutionUpdatedAt: admin.firestore.FieldValue.serverTimestamp() });
    tx.set(resolution, { institutionId, checkId, state, reason: String(request.data?.reason || ''), reviewAt: request.data?.reviewAt || null, actorId: user.uid, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  });
  await audit(institutionId, user.uid, `health.${state}`, { checkId });
  return { ok: true };
});
