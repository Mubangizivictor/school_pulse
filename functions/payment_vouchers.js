// Authoritative voucher state transitions. Client SDKs only read vouchers.
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const txt = (v, n = 240) => String(v || '').trim().slice(0, n);
  const financeRoles = new Set(['bursar', 'schoolAdmin', 'headTeacher', 'director']);
  async function caller(request, schoolId) {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in required.');
    const user = (await db.doc(`users/${request.auth.uid}`).get()).data() || {};
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId || !roles.some((r) => financeRoles.has(r))) throw new HttpsError('permission-denied', 'Not authorised for this school finance workflow.');
    return { uid: request.auth.uid, roles };
  }
  const ref = (s, id) => db.doc(`schools/${s}/payment_vouchers/${id}`);
  const audit = (s, a, u, id, extra = {}) => db.collection(`schools/${s}/finance_audit_events`).add({ module: 'voucher', action: a, actorId: u.uid, voucherId: id, ...extra, at: admin.firestore.FieldValue.serverTimestamp() });
  const amount = (v) => { if (!Number.isSafeInteger(v) || v <= 0) throw new HttpsError('invalid-argument', 'Voucher amounts must be positive whole UGX.'); return v; };
  const api = {};
  api.savePaymentVoucherDraft = onCall(async (request) => {
    const d = request.data || {}; const schoolId = txt(d.schoolId); const u = await caller(request, schoolId);
    const supplierId = txt(d.supplierId), invoiceReference = txt(d.invoiceReference), budgetVote = txt(d.budgetVote), fundingAccount = txt(d.fundingAccount);
    const lines = Array.isArray(d.lines) ? d.lines.map((l) => ({ description: txt(l.description), amountUgx: amount(l.amountUgx) })) : [];
    if (!supplierId || !invoiceReference || !budgetVote || !fundingAccount || !lines.length || lines.some((l) => !l.description)) throw new HttpsError('invalid-argument', 'Supplier, invoice reference, budget vote, funding account and lines are required.');
    const total = lines.reduce((sum, l) => sum + l.amountUgx, 0); const voucherId = txt(d.voucherId) || db.collection(`schools/${schoolId}/payment_vouchers`).doc().id;
    await db.runTransaction(async (tx) => { const existing = await tx.get(ref(schoolId, voucherId)); if (existing.exists && existing.data().status !== 'draft' && existing.data().status !== 'returned') throw new HttpsError('failed-precondition', 'Submitted vouchers are immutable.'); tx.set(ref(schoolId, voucherId), { schoolId, supplierId, supplierName: txt(d.supplierName), invoiceReference, budgetVote, fundingAccount, lines, amountUgx: total, narration: txt(d.narration, 1000), attachmentPaths: d.attachmentPaths || [], status: 'draft', updatedAt: admin.firestore.FieldValue.serverTimestamp(), createdAt: existing.exists ? existing.data().createdAt : admin.firestore.FieldValue.serverTimestamp(), createdBy: existing.exists ? existing.data().createdBy : u.uid }, { merge: true }); });
    await audit(schoolId, 'voucher_draft_saved', u, voucherId); return { voucherId };
  });
  api.submitPaymentVoucher = onCall(async (request) => {
    const d = request.data || {}; const schoolId = txt(d.schoolId), voucherId = txt(d.voucherId); const u = await caller(request, schoolId);
    await db.runTransaction(async (tx) => { const snap = await tx.get(ref(schoolId, voucherId)); if (!snap.exists) throw new HttpsError('not-found', 'Voucher not found.'); const v = snap.data(); if (!['draft','returned'].includes(v.status)) throw new HttpsError('failed-precondition', 'Only draft or returned vouchers can be submitted.'); const duplicate = await tx.get(db.collection(`schools/${schoolId}/payment_vouchers`).where('supplierId','==',v.supplierId).where('invoiceReference','==',v.invoiceReference).where('status','in',['submitted','under_review','approved','paid','reconciled']).limit(1)); if (!duplicate.empty) throw new HttpsError('already-exists', 'This supplier invoice is already in the payment workflow.'); tx.update(snap.ref, { status: 'under_review', submittedAt: admin.firestore.FieldValue.serverTimestamp(), submittedBy: u.uid, submittedSnapshot: v, version: admin.firestore.FieldValue.increment(1) }); });
    await audit(schoolId, 'voucher_submitted', u, voucherId); return { voucherId };
  });
  api.markVoucherPaid = onCall(async (request) => {
    const d = request.data || {}; const schoolId = txt(d.schoolId), voucherId = txt(d.voucherId); const u = await caller(request, schoolId); if (!u.roles.some((r) => ['bursar','schoolAdmin'].includes(r))) throw new HttpsError('permission-denied', 'Only authorised finance officers may mark payment.');
    if (!txt(d.paymentReference) || !txt(d.proofPath)) throw new HttpsError('invalid-argument', 'Payment reference and proof are required.');
    await db.runTransaction(async (tx) => { const snap = await tx.get(ref(schoolId, voucherId)); if (!snap.exists || snap.data().status !== 'approved') throw new HttpsError('failed-precondition', 'Only approved vouchers can be paid.'); tx.update(snap.ref, { status: 'paid', paymentReference: txt(d.paymentReference), paymentMethod: txt(d.paymentMethod), paymentProofPath: txt(d.proofPath, 500), paidAt: admin.firestore.FieldValue.serverTimestamp(), paidBy: u.uid }); }); await audit(schoolId, 'voucher_paid', u, voucherId); return { voucherId };
  });
  return api;
};
