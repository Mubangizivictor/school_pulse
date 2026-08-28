/**
 * Money-authoritative Payroll & Compliance workflow.  The client can only
 * request state transitions; payroll figures, statutory rules, snapshots,
 * audit rows and remittance state are all written here in transactions.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
  const api = {};
  const db = admin.firestore();
  const now = () => admin.firestore.FieldValue.serverTimestamp();
  const text = (v, n = 160) => String(v || '').trim().slice(0, n);
  const money = (v, field) => {
    if (!Number.isSafeInteger(v) || v < 0) throw new HttpsError('invalid-argument', `${field} must be a non-negative whole UGX amount.`);
    return v;
  };
  const payrollRoles = new Set(['bursar', 'hrOfficer', 'schoolAdmin', 'headTeacher', 'director']);

  async function caller(request, schoolId) {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in required.');
    if (!schoolId) throw new HttpsError('invalid-argument', 'schoolId is required.');
    const user = (await db.doc(`users/${request.auth.uid}`).get()).data() || {};
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId || !roles.some((r) => payrollRoles.has(r))) {
      throw new HttpsError('permission-denied', 'You are not authorised to access this school payroll.');
    }
    return { uid: request.auth.uid, roles, name: text(user.name || user.displayName || 'Authorised staff') };
  }
  const runRef = (schoolId, runId) => db.doc(`schools/${schoolId}/payroll_runs/${runId}`);
  const audit = (schoolId, action, actor, payload = {}) => db.collection(`schools/${schoolId}/finance_audit_events`).doc().set({
    action, actorId: actor.uid, actor: actor.name, module: 'payroll', ...payload, at: now(),
  });
  const allowed = (c, roles) => roles.some((r) => c.roles.includes(r));
  const locked = (run) => ['paid', 'cancelled', 'locked'].includes(run.status);

  // Creates the run from a server-side prepared snapshot.  The snapshot is
  // produced by the existing payroll engine/HR import, never calculated in UI.
  api.preparePayrollRun = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const c = await caller(request, schoolId);
    if (!allowed(c, ['bursar', 'hrOfficer', 'schoolAdmin'])) throw new HttpsError('permission-denied', 'Only payroll preparers may create a run.');
    const periodId = text(d.periodId); const idempotencyKey = text(d.idempotencyKey);
    if (!periodId || !idempotencyKey) throw new HttpsError('invalid-argument', 'periodId and idempotencyKey are required.');
    const source = await db.doc(`schools/${schoolId}/payroll_preparations/${periodId}`).get();
    if (!source.exists) throw new HttpsError('failed-precondition', 'No authorised payroll preparation exists for this period.');
    const prepared = source.data() || {};
    if (prepared.status !== 'ready') throw new HttpsError('failed-precondition', 'Payroll preparation is not ready.');
    const rules = await db.doc(`schools/${schoolId}/payroll_tax_rules/current`).get();
    if (!rules.exists || rules.data()?.status !== 'published') throw new HttpsError('failed-precondition', 'A published statutory rule version is required.');
    const idempotencyRef = db.doc(`schools/${schoolId}/payroll_idempotency/${idempotencyKey}`);
    let runId;
    await db.runTransaction(async (tx) => {
      const prior = await tx.get(idempotencyRef);
      if (prior.exists) { runId = prior.data().runId; return; }
      const existing = await tx.get(db.collection(`schools/${schoolId}/payroll_runs`).where('periodId', '==', periodId).limit(1));
      if (!existing.empty) throw new HttpsError('already-exists', 'A payroll run already exists for this period.');
      const ref = db.collection(`schools/${schoolId}/payroll_runs`).doc(); runId = ref.id;
      const totals = prepared.totals || {};
      ['grossPayUgx','payeUgx','nssfEmployerUgx','nssfEmployeeUgx','netPayUgx','staffCount'].forEach((k) => money(totals[k] || 0, k));
      tx.set(ref, { schoolId, periodId, periodLabel: text(prepared.periodLabel), periodOrder: prepared.periodOrder || 0,
        status: 'draft', totals, grossPayUgx: totals.grossPayUgx || 0, payeUgx: totals.payeUgx || 0,
        nssfEmployerUgx: totals.nssfEmployerUgx || 0, nssfEmployeeUgx: totals.nssfEmployeeUgx || 0,
        netPayUgx: totals.netPayUgx || 0, staffCount: totals.staffCount || 0,
        submissionDeadline: prepared.submissionDeadline || null, taxRuleVersionId: rules.id,
        preparationId: source.id, createdBy: c.uid, createdAt: now(), updatedAt: now(), approvalSteps: [] });
      tx.set(idempotencyRef, { runId, createdAt: now(), actorId: c.uid });
    });
    await audit(schoolId, 'payroll_run_prepared', c, { runId, periodId }); return { runId };
  });

  api.submitPayrollForApproval = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const runId = text(d.runId); const c = await caller(request, schoolId);
    if (!allowed(c, ['bursar', 'hrOfficer', 'schoolAdmin'])) throw new HttpsError('permission-denied', 'Only payroll preparers may submit a run.');
    const policy = await db.doc(`schools/${schoolId}/payroll_approval_policy/current`).get();
    if (!policy.exists || !Array.isArray(policy.data()?.steps) || !policy.data().steps.length) throw new HttpsError('failed-precondition', 'Configure the payroll approval workflow first.');
    await db.runTransaction(async (tx) => { const snap = await tx.get(runRef(schoolId, runId)); if (!snap.exists) throw new HttpsError('not-found', 'Payroll run not found.'); const run = snap.data();
      if (run.status !== 'draft' && run.status !== 'rejected') throw new HttpsError('failed-precondition', 'Only draft or rejected payroll can be submitted.');
      tx.update(snap.ref, { status: 'reviewed', approvalSteps: policy.data().steps.map((s) => ({ role: text(s.role), status: 'pending' })), submittedAt: now(), submittedBy: c.uid, updatedAt: now() });
    }); await audit(schoolId, 'payroll_submitted_for_approval', c, { runId }); return { runId };
  });

  api.decidePayrollApproval = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const runId = text(d.runId); const decision = text(d.decision); const c = await caller(request, schoolId);
    if (!['approve','reject'].includes(decision)) throw new HttpsError('invalid-argument', 'decision must be approve or reject.');
    await db.runTransaction(async (tx) => { const snap = await tx.get(runRef(schoolId, runId)); if (!snap.exists) throw new HttpsError('not-found', 'Payroll run not found.'); const run = snap.data();
      if (run.status !== 'reviewed') throw new HttpsError('failed-precondition', 'Payroll is not awaiting approval.');
      const steps = [...(run.approvalSteps || [])]; const index = steps.findIndex((s) => s.status === 'pending'); if (index < 0) throw new HttpsError('failed-precondition', 'No approval step is pending.');
      if (!c.roles.includes(steps[index].role)) throw new HttpsError('permission-denied', 'You are not the configured approver for this step.');
      steps[index] = { ...steps[index], status: decision === 'approve' ? 'approved' : 'rejected', actorId: c.uid, at: new Date(), note: text(d.note, 500) };
      tx.update(snap.ref, { approvalSteps: steps, status: decision === 'reject' ? 'rejected' : (steps.every((s) => s.status === 'approved') ? 'approved' : 'reviewed'), updatedAt: now() });
    }); await audit(schoolId, `payroll_${decision}d`, c, { runId, note: text(d.note, 500) }); return { runId };
  });

  api.finalisePayrollPayment = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const runId = text(d.runId); const reference = text(d.reference); const c = await caller(request, schoolId);
    if (!allowed(c, ['bursar', 'schoolAdmin'])) throw new HttpsError('permission-denied', 'Only an authorised finance officer may finalise payment.');
    if (!reference) throw new HttpsError('invalid-argument', 'A payment reference is required.');
    await db.runTransaction(async (tx) => { const snap = await tx.get(runRef(schoolId, runId)); if (!snap.exists) throw new HttpsError('not-found', 'Payroll run not found.'); const run = snap.data();
      if (run.status !== 'approved') throw new HttpsError('failed-precondition', 'Only fully approved payroll can be paid.');
      const duplicate = await tx.get(db.collection(`schools/${schoolId}/payroll_runs`).where('paymentReference', '==', reference).limit(1)); if (!duplicate.empty) throw new HttpsError('already-exists', 'This payment reference has already been used.');
      tx.update(snap.ref, { status: 'paid', paymentReference: reference, paidAt: now(), paidBy: c.uid, lockedAt: now(), lockedBy: c.uid, immutableSnapshot: run, updatedAt: now() });
    }); await audit(schoolId, 'payroll_paid_and_locked', c, { runId, reference }); return { runId };
  });

  api.submitPayrollRemittance = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const runId = text(d.runId); const type = text(d.type).toLowerCase(); const c = await caller(request, schoolId);
    if (!['paye', 'nssf'].includes(type)) throw new HttpsError('invalid-argument', 'type must be PAYE or NSSF.'); if (!allowed(c, ['bursar', 'schoolAdmin'])) throw new HttpsError('permission-denied', 'Only finance may submit remittance.');
    const reference = text(d.reference); const proofPath = text(d.proofPath, 500); if (!reference || !proofPath) throw new HttpsError('invalid-argument', 'A remittance reference and proof attachment are required.');
    const proofPrefix = `schools/${schoolId}/payroll_remittances/${runId}/`;
    if (!proofPath.startsWith(proofPrefix)) throw new HttpsError('invalid-argument', 'Proof attachment is outside the secured remittance folder.');
    const [proofExists] = await admin.storage().bucket().file(proofPath).exists();
    if (!proofExists) throw new HttpsError('failed-precondition', 'Proof attachment was not found.');
    await db.runTransaction(async (tx) => { const run = await tx.get(runRef(schoolId, runId)); if (!run.exists || !['paid','locked'].includes(run.data().status)) throw new HttpsError('failed-precondition', 'Remittance requires a paid payroll.');
      const ref = db.doc(`schools/${schoolId}/payroll_remittances/${runId}_${type}`); const prior = await tx.get(ref); if (prior.exists && prior.data().status === 'verified') throw new HttpsError('failed-precondition', 'Verified remittance is immutable.');
      const amountUgx = type === 'paye' ? run.data().payeUgx : run.data().nssfEmployerUgx + run.data().nssfEmployeeUgx;
      tx.set(ref, { schoolId, runId, type, amountUgx, dueDate: d.dueDate || null, status: 'submitted', reference, proofPath, remittedAt: now(), submittedBy: c.uid, updatedAt: now() }, { merge: true });
    }); await audit(schoolId, 'payroll_remittance_submitted', c, { runId, remittanceType: type }); return { runId, type };
  });

  api.verifyPayrollRemittance = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const runId = text(d.runId); const type = text(d.type).toLowerCase(); const c = await caller(request, schoolId);
    if (!allowed(c, ['headTeacher', 'director', 'schoolAdmin'])) throw new HttpsError('permission-denied', 'Only an authorised verifier may verify remittance.');
    const ref = db.doc(`schools/${schoolId}/payroll_remittances/${runId}_${type}`);
    await db.runTransaction(async (tx) => { const rem = await tx.get(ref); if (!rem.exists || rem.data().status !== 'submitted') throw new HttpsError('failed-precondition', 'Only submitted remittance can be verified.'); tx.update(ref, { status: 'verified', verifiedAt: now(), verifiedBy: c.uid, verifierName: c.name, updatedAt: now() }); });
    await audit(schoolId, 'payroll_remittance_verified', c, { runId, remittanceType: type }); return { runId, type };
  });
  return api;
};
