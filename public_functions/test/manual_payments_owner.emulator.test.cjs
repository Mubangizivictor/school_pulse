// Firebase Emulator integration tests for the Super Admin "Billing" surface -
// the owner-only manual-subscription-payment callables that
// ManualPaymentService + PaymentReviewScreen + ManualPaymentConfigScreen
// drive (all in public_functions/payments.js, region europe-west1):
//   getManualPaymentsForOwner, getManualPaymentProofUrl,
//   approveManualPayment, rejectManualPayment,
//   getManualPaymentConfig, updateManualPaymentConfig
//
// Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-manual-payments-owner-test \
//     "node --test test/manual_payments_owner.emulator.test.cjs"
const { beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-manual-payments-owner-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const {
  getManualPaymentsForOwner,
  getManualPaymentProofUrl,
  approveManualPayment,
  rejectManualPayment,
  getManualPaymentConfig,
  updateManualPaymentConfig,
} = require('../payments');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_UID = 'notTheOwnerUid';
const SCHOOL_ID = 'schoolA';

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}
async function clearFirestore() {
  const cols = await db.listCollections();
  await Promise.all(cols.map((c) => del(c)));
}
async function del(ref) {
  const docs = await ref.listDocuments();
  await Promise.all(docs.map(async (d) => {
    const subs = await d.listCollections();
    await Promise.all(subs.map(del));
    await d.delete();
  }));
}
async function seedOwner() {
  await db.doc('platform_config/owner_seed').set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true, email: 'owner@example.com',
  });
  await db.doc(`users/${OTHER_UID}`).set({ role: 'superAdmin', roles: ['superAdmin'], isActive: true });
}
async function seedSchool(overrides = {}) {
  await db.doc(`schools/${SCHOOL_ID}`).set({
    id: SCHOOL_ID, name: 'School A', tenantId: 'SCHA',
    status: 'trial', subscriptionPlanId: 'starter', subscriptionExpiry: Date.now(),
    metadata: { subscriptionStatus: 'awaiting_payment' }, ...overrides,
  });
}
// A pending_verification payment whose submitted == expected (approvable).
async function seedPayment(id, overrides = {}) {
  await db.doc(`manual_subscription_payments/${id}`).set({
    id, schoolId: SCHOOL_ID, schoolName: 'School A',
    status: 'pending_verification',
    planId: 'starter', planName: 'Starter',
    method: 'mtn', reference: 'MTN-REF-1', currency: 'UGX',
    paymentType: 'activation',
    expectedAmount: 350000, submittedAmount: 350000,
    termLengthDays: 120, maxStudents: 500, maxStaff: 60, storageLimitGb: 5,
    submittedByUid: 'schoolAdminUid',
    submittedAt: admin.firestore.Timestamp.fromMillis(Date.now() - 60000),
    ...overrides,
  });
}
async function auditActions() {
  const snap = await db.collection('super_admin_audit_logs').get();
  return snap.docs.map((d) => d.data().action).sort();
}
async function payment(id) {
  return (await db.doc(`manual_subscription_payments/${id}`).get()).data();
}
async function school() {
  return (await db.doc(`schools/${SCHOOL_ID}`).get()).data();
}

describe('Super Admin - Billing: manual subscription payments', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedOwner();
  });

  // --- AUTH GATE --------------------------------------------------------

  test('unauthenticated is rejected by every billing callable', async () => {
    await assert.rejects(getManualPaymentsForOwner.run(request(null, { status: 'all' })), /sign in|unauthenticated/i);
    await assert.rejects(getManualPaymentProofUrl.run(request(null, { paymentId: 'p' })), /sign in|unauthenticated/i);
    await assert.rejects(approveManualPayment.run(request(null, { paymentId: 'p' })), /sign in|unauthenticated/i);
    await assert.rejects(rejectManualPayment.run(request(null, { paymentId: 'p', reason: 'because' })), /sign in|unauthenticated/i);
    await assert.rejects(getManualPaymentConfig.run(request(null, {})), /sign in|unauthenticated/i);
    await assert.rejects(updateManualPaymentConfig.run(request(null, {})), /sign in|unauthenticated/i);
  });

  test('a non-owner superAdmin is denied every billing callable', async () => {
    await assert.rejects(getManualPaymentsForOwner.run(request(OTHER_UID, { status: 'all' })), /access denied|permission-denied/i);
    await assert.rejects(approveManualPayment.run(request(OTHER_UID, { paymentId: 'p' })), /access denied|permission-denied/i);
    await assert.rejects(getManualPaymentConfig.run(request(OTHER_UID, {})), /access denied|permission-denied/i);
  });

  // --- getManualPaymentsForOwner --------------------------------------

  test('lists payments newest-first and filters by status; strips proof path + referenceKey', async () => {
    await seedPayment('pOld', { submittedAt: admin.firestore.Timestamp.fromMillis(1000), status: 'approved' });
    await seedPayment('pNew', {
      submittedAt: admin.firestore.Timestamp.fromMillis(2000),
      proofStoragePath: 'proofs/pNew.jpg', referenceKey: 'secret-key',
    });

    const all = await getManualPaymentsForOwner.run(request(OWNER_UID, { status: 'all' }));
    assert.equal(all.payments.length, 2);
    assert.equal(all.payments[0].id, 'pNew', 'newest first');
    assert.equal(all.payments[0].hasProof, true);
    assert.equal('proofStoragePath' in all.payments[0], false, 'proof path never leaves the server');
    assert.equal('referenceKey' in all.payments[0], false, 'reference key never leaves the server');

    const pending = await getManualPaymentsForOwner.run(request(OWNER_UID, { status: 'pending_verification' }));
    assert.deepEqual(pending.payments.map((p) => p.id), ['pNew']);
  });

  // --- getManualPaymentProofUrl -------------------------------------

  test('getManualPaymentProofUrl is not-found for a missing payment / a payment with no proof', async () => {
    await assert.rejects(getManualPaymentProofUrl.run(request(OWNER_UID, { paymentId: 'ghost' })), /not found|not-found/i);
    await seedPayment('pNoProof');
    await assert.rejects(getManualPaymentProofUrl.run(request(OWNER_UID, { paymentId: 'pNoProof' })), /no proof file|not-found/i);
  });

  // --- approveManualPayment ---------------------------------------

  test('approve activates the school, snapshots the plan, writes receipt + txn + audit', async () => {
    await seedSchool();
    await seedPayment('p1');
    const res = await approveManualPayment.run(request(OWNER_UID, { paymentId: 'p1' }));
    assert.equal(res.ok, true);
    assert.equal(res.status, 'approved');
    assert.equal(res.schoolId, SCHOOL_ID);
    assert.ok(res.subscriptionExpiry > Date.now());

    const p = await payment('p1');
    assert.equal(p.status, 'approved');
    assert.equal(p.reviewedByUid, OWNER_UID);

    const s = await school();
    assert.equal(s.status, 'active');
    assert.equal(s.accessMode, 'full');
    assert.equal(s.subscriptionPlanId, 'starter');
    assert.equal(s.subscription.price, 350000);
    assert.equal(s.subscription.termLengthDays, 120);
    assert.equal(s.metadata.hasEverActivated, true);
    assert.equal(s.metadata.lastPaymentApprovedBy, OWNER_UID);

    const receipt = (await db.doc(`subscription_receipts/p1`).get()).data();
    assert.equal(receipt.amountUgx, 350000);
    assert.equal(receipt.approvedBy, OWNER_UID);

    const txn = (await db.doc(`payment_transactions/p1`).get()).data();
    assert.equal(txn.status, 'success');
    assert.equal(txn.provider, 'manual_mtn');

    assert.ok((await auditActions()).includes('APPROVE_INITIAL_SUBSCRIPTION_PAYMENT'));
  });

  test('approve is idempotent - a second call returns alreadyApproved, no duplicate side effects', async () => {
    await seedSchool();
    await seedPayment('p1');
    await approveManualPayment.run(request(OWNER_UID, { paymentId: 'p1' }));
    const again = await approveManualPayment.run(request(OWNER_UID, { paymentId: 'p1' }));
    assert.equal(again.alreadyApproved, true);
    assert.equal((await auditActions()).filter((a) => a.startsWith('APPROVE_')).length, 1);
  });

  test('approve refuses when submitted amount != expected amount', async () => {
    await seedSchool();
    await seedPayment('pShort', { submittedAmount: 100000, expectedAmount: 350000 });
    await assert.rejects(
      approveManualPayment.run(request(OWNER_UID, { paymentId: 'pShort' })),
      /amount does not match|failed-precondition/i,
    );
    assert.equal((await payment('pShort')).status, 'pending_verification', 'unchanged');
  });

  test('approve refuses a non-pending payment', async () => {
    await seedSchool();
    await seedPayment('pRej', { status: 'rejected' });
    await assert.rejects(
      approveManualPayment.run(request(OWNER_UID, { paymentId: 'pRej' })),
      /Only pending|failed-precondition/i,
    );
  });

  test('approve is not-found for a missing payment', async () => {
    await assert.rejects(approveManualPayment.run(request(OWNER_UID, { paymentId: 'ghost' })), /not found|not-found/i);
  });

  test('renewal approval extends from the existing (future) expiry, not from now', async () => {
    const futureExpiry = Date.now() + 30 * 24 * 3600 * 1000;
    await seedSchool({ status: 'active', subscriptionExpiry: futureExpiry });
    await seedPayment('pRenew', { paymentType: 'renewal' });
    const res = await approveManualPayment.run(request(OWNER_UID, { paymentId: 'pRenew' }));
    // new expiry = futureExpiry + 120d (± a second for server time)
    const expected = futureExpiry + 120 * 24 * 3600 * 1000;
    assert.ok(Math.abs(res.subscriptionExpiry - expected) < 5000, 'renewal stacks on remaining time');
    assert.ok((await auditActions()).includes('APPROVE_SUBSCRIPTION_RENEWAL_PAYMENT'));
  });

  // --- rejectManualPayment -------------------------------------------

  test('reject marks rejected + reason, blocks an activation school, audits', async () => {
    await seedSchool();
    await seedPayment('p1');
    const res = await rejectManualPayment.run(request(OWNER_UID, { paymentId: 'p1', reason: 'Wrong reference number' }));
    assert.deepEqual(res, { ok: true, status: 'rejected' });

    const p = await payment('p1');
    assert.equal(p.status, 'rejected');
    assert.equal(p.rejectionReason, 'Wrong reference number');

    const s = await school();
    assert.equal(s.accessMode, 'blocked', 'activation rejection blocks the tenant');
    assert.equal(s.metadata.subscriptionStatus, 'awaiting_payment');

    assert.ok((await auditActions()).includes('REJECT_MANUAL_SUBSCRIPTION_PAYMENT'));
  });

  test('reject needs a real reason and only touches a pending payment', async () => {
    await seedSchool();
    await seedPayment('p1');
    await assert.rejects(rejectManualPayment.run(request(OWNER_UID, { paymentId: 'p1', reason: 'x' })), /clear rejection reason|invalid-argument/i);
    await seedPayment('pApproved', { status: 'approved' });
    await assert.rejects(rejectManualPayment.run(request(OWNER_UID, { paymentId: 'pApproved', reason: 'too late' })), /Only pending|failed-precondition/i);
  });

  // --- config -------------------------------------------------------

  test('getManualPaymentConfig returns the current config shape for the owner', async () => {
    const cfg = await getManualPaymentConfig.run(request(OWNER_UID, {}));
    assert.equal(cfg.ok, true);
    assert.equal(cfg.currency, 'UGX');
    assert.ok(cfg.mobileMoney && cfg.airtelMoney && cfg.bank && cfg.cash, 'all four method blocks present');
  });

  test('updateManualPaymentConfig persists a bank config + audits, and getManualPaymentConfig reads it back', async () => {
    await updateManualPaymentConfig.run(request(OWNER_UID, {
      bank: { bankName: 'Stanbic', branch: 'Kampala', accountName: 'School Pulse Ltd', accountNumber: '9030001234567' },
    }));
    const cfg = await getManualPaymentConfig.run(request(OWNER_UID, {}));
    assert.equal(cfg.bank.bankName, 'Stanbic');
    assert.equal(cfg.bank.accountNumber, '9030001234567');
    assert.ok((await auditActions()).some((a) => /CONFIG|MANUAL_PAYMENT/i.test(a)), 'a config-change audit row exists');
  });

  test('updateManualPaymentConfig rejects a half-filled bank block', async () => {
    await assert.rejects(
      updateManualPaymentConfig.run(request(OWNER_UID, { bank: { bankName: 'Stanbic' } })),
      /Bank name, account name and account number|invalid-argument/i,
    );
  });

  test('updateManualPaymentConfig rejects enabling cash with no instructions', async () => {
    await assert.rejects(
      updateManualPaymentConfig.run(request(OWNER_UID, { cash: { enabled: true } })),
      /Cash payment instructions|invalid-argument/i,
    );
  });

  test('updateManualPaymentConfig rejects a config with no usable method at all', async () => {
    await assert.rejects(
      updateManualPaymentConfig.run(request(OWNER_UID, {})),
      /invalid-argument|at least one/i,
    );
  });
});
