const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const BILLING_ROLES = new Set(['director', 'headTeacher', 'schoolAdmin', 'bursar']);
const clean = (value, max = 500) => String(value ?? '').trim().slice(0, max);

async function callerFor(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'Sign in to request a subscription change.');
  const snap = await db.collection('users').doc(request.auth.uid).get();
  const user = snap.data() || {}; const schoolId = clean(user.schoolId, 180);
  const roles = [user.role, ...(Array.isArray(user.roles) ? user.roles : [])].map((v) => clean(v, 40));
  if (!schoolId || !roles.some((role) => BILLING_ROLES.has(role))) throw new HttpsError('permission-denied', 'You are not allowed to manage this institution subscription.');
  return { uid: request.auth.uid, schoolId };
}

// Creates an immutable, owner-reviewed request. It intentionally never writes
// a subscription, invoice, entitlement, usage metric, or payment state.
exports.requestSubscriptionChange = onCall({ region: 'europe-west1' }, async (request) => {
  const caller = await callerFor(request); const type = clean(request.data?.type, 40);
  if (!['upgrade', 'downgrade', 'cycle', 'addon', 'support'].includes(type)) throw new HttpsError('invalid-argument', 'Unsupported subscription request.');
  const planId = clean(request.data?.planId, 80), addOnId = clean(request.data?.addOnId, 80);
  if ((type === 'upgrade' || type === 'downgrade') && !planId) throw new HttpsError('invalid-argument', 'Choose an available plan.');
  if (type === 'addon' && !addOnId) throw new HttpsError('invalid-argument', 'Choose an available add-on.');
  if (planId) { const plan = await db.collection('subscription_plans').doc(planId).get(); if (!plan.exists || plan.data()?.isActive === false || plan.data()?.isPublic === false) throw new HttpsError('failed-precondition', 'That plan is not available.'); }
  if (addOnId) { const addOn = await db.collection('subscription_addons').doc(addOnId).get(); if (!addOn.exists || addOn.data()?.isActive === false) throw new HttpsError('failed-precondition', 'That add-on is not available.'); }
  const root = db.collection('institutions').doc(caller.schoolId); const requests = root.collection('subscription_requests');
  const requestId = `${type}_${planId || addOnId || 'billing'}`;
  await db.runTransaction(async (tx) => {
    const ref = requests.doc(requestId); const existing = await tx.get(ref);
    if (existing.exists && ['requested', 'pendingApproval'].includes(clean(existing.data()?.status, 40))) return;
    tx.set(ref, { requestId, institutionId: caller.schoolId, type, requestedPlanId: planId || null, requestedAddOnId: addOnId || null, note: clean(request.data?.note), status: 'requested', requestedBy: caller.uid, requestedAt: admin.firestore.FieldValue.serverTimestamp(), correlationId: requestId });
    tx.set(root.collection('subscription_history').doc(), { institutionId: caller.schoolId, eventType: 'Request submitted', requestType: type, actorId: caller.uid, createdAt: admin.firestore.FieldValue.serverTimestamp(), correlationId: requestId });
    tx.set(db.collection('super_admin_audit_logs').doc(), { schoolId: caller.schoolId, tenantId: caller.schoolId, actorUserId: caller.uid, action: 'SUBSCRIPTION_REQUESTED', target: requestId, timestamp: admin.firestore.FieldValue.serverTimestamp(), correlationId: requestId });
  });
  return { ok: true, requestId };
});

// A refresh is deliberately a queued backend request, never a client-side
// collection scan or a client write to usage_metrics. The platform's usage
// worker can coalesce these requests and recompute authoritative aggregates.
exports.requestSubscriptionUsageRefresh = onCall({ region: 'europe-west1' }, async (request) => {
  const caller = await callerFor(request);
  const root = db.collection('institutions').doc(caller.schoolId);
  const refreshRef = root.collection('subscription_requests').doc('usage_refresh');
  const correlationId = `usage_refresh_${caller.schoolId}`;
  let duplicate = false;
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(refreshRef);
    const status = clean(existing.data()?.status, 40);
    if (existing.exists && ['requested', 'pendingApproval', 'processing'].includes(status)) {
      duplicate = true;
      return;
    }
    tx.set(refreshRef, {
      requestId: 'usage_refresh', institutionId: caller.schoolId,
      type: 'usage_refresh', status: 'requested', requestedBy: caller.uid,
      requestedAt: admin.firestore.FieldValue.serverTimestamp(), correlationId,
    });
    tx.set(root.collection('subscription_history').doc(), {
      institutionId: caller.schoolId, eventType: 'Usage refresh requested',
      actorId: caller.uid, createdAt: admin.firestore.FieldValue.serverTimestamp(), correlationId,
    });
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      schoolId: caller.schoolId, tenantId: caller.schoolId, actorUserId: caller.uid,
      action: 'SUBSCRIPTION_USAGE_REFRESH_REQUESTED', target: 'usage_metrics',
      timestamp: admin.firestore.FieldValue.serverTimestamp(), correlationId,
    });
  });
  return { ok: true, duplicate };
});
