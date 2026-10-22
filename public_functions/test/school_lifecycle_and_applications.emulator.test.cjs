// Firebase Emulator integration tests for the Super Admin "Schools" surface -
// the owner-only callables SuperAdminRemoteDataSource drives:
//   setSchoolLifecycleStatus, updateSchoolSubscriptionPlan   (portal_domains.js)
//   getSchoolApplicationsForOwner, rejectSchoolApplication    (owner.js)
//   createSchoolPortal, approveSchoolApplication              (auth-gate only -
//     full happy paths create Auth users / need verified applicants and are
//     covered structurally elsewhere; here we prove the owner gate + arg
//     validation without provisioning real accounts)
//
// Convention identical to owner_console_callables.emulator.test.cjs.
// Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-school-lifecycle-applications-test \
//     "node --test test/school_lifecycle_and_applications.emulator.test.cjs"
const { beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-school-lifecycle-applications-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const {
  setSchoolLifecycleStatus,
  updateSchoolSubscriptionPlan,
  createSchoolPortal,
} = require('../portal_domains');
const {
  getSchoolApplicationsForOwner,
  rejectSchoolApplication,
} = require('../owner');
// approveSchoolApplication is exported by BOTH owner.js and payments.js;
// bootstrap.js spreads payments last, so the payments.js one is what deploys.
const {
  approveSchoolApplication,
  approveManualPayment,
  rejectManualPayment,
} = require('../payments');
const { TRIAL_DAYS } = require('../portal_domains');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_UID = 'notTheOwnerUid';
const SCHOOL_ID = 'schoolA';

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}
async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => del(c)));
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
  await db.doc(`users/${OTHER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true,
  });
}
async function seedSchool(overrides = {}) {
  await db.doc(`schools/${SCHOOL_ID}`).set({
    id: SCHOOL_ID, name: 'School A', tenantId: 'SCHA',
    status: 'active', subscriptionPlanId: 'starter',
    subscriptionExpiry: Date.now(), ...overrides,
  });
}
async function auditActions() {
  const snap = await db.collection('super_admin_audit_logs').get();
  return snap.docs.map((d) => d.data().action).sort();
}
async function school() {
  return (await db.doc(`schools/${SCHOOL_ID}`).get()).data();
}

describe('Super Admin - Schools: lifecycle + applications', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedOwner();
  });

  // --- AUTH GATE (all six) -------------------------------------------------

  test('unauthenticated is rejected by every school callable', async () => {
    await assert.rejects(setSchoolLifecycleStatus.run(request(null, { schoolId: SCHOOL_ID, status: 'suspended' })), /sign in|unauthenticated/i);
    await assert.rejects(updateSchoolSubscriptionPlan.run(request(null, { schoolId: SCHOOL_ID, planId: 'pro', expiry: Date.now() })), /sign in|unauthenticated/i);
    await assert.rejects(getSchoolApplicationsForOwner.run(request(null, {})), /sign in|unauthenticated/i);
    await assert.rejects(rejectSchoolApplication.run(request(null, { applicationId: 'a', reason: 'no' })), /sign in|unauthenticated/i);
    await assert.rejects(createSchoolPortal.run(request(null, {})), /sign in|unauthenticated/i);
    await assert.rejects(approveSchoolApplication.run(request(null, { applicationId: 'a' })), /sign in|unauthenticated/i);
  });

  test('a non-owner superAdmin is denied every school callable', async () => {
    await assert.rejects(setSchoolLifecycleStatus.run(request(OTHER_UID, { schoolId: SCHOOL_ID, status: 'suspended' })), /access denied|permission-denied/i);
    await assert.rejects(updateSchoolSubscriptionPlan.run(request(OTHER_UID, { schoolId: SCHOOL_ID, planId: 'pro', expiry: Date.now() })), /access denied|permission-denied/i);
    await assert.rejects(getSchoolApplicationsForOwner.run(request(OTHER_UID, {})), /access denied|permission-denied/i);
    await assert.rejects(rejectSchoolApplication.run(request(OTHER_UID, { applicationId: 'a', reason: 'because' })), /access denied|permission-denied/i);
    await assert.rejects(createSchoolPortal.run(request(OTHER_UID, {})), /access denied|permission-denied/i);
    await assert.rejects(approveSchoolApplication.run(request(OTHER_UID, { applicationId: 'a' })), /access denied|permission-denied/i);
  });

  // --- setSchoolLifecycleStatus ------------------------------------------

  test('suspend -> reactivate -> archive each transactionally updates status + audits', async () => {
    await seedSchool();

    let res = await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_ID, status: 'suspended', reason: 'Non-payment' }));
    assert.deepEqual(res, { schoolId: SCHOOL_ID, status: 'suspended' });
    let s = await school();
    assert.equal(s.status, 'suspended');
    assert.equal(s.metadata.suspensionReason, 'Non-payment');

    res = await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_ID, status: 'active' }));
    assert.equal((await school()).status, 'active');

    await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_ID, status: 'archived', reason: 'Closed down' }));
    s = await school();
    assert.equal(s.status, 'archived');
    assert.equal(s.metadata.archivedReason, 'Closed down');

    const actions = await auditActions();
    assert.equal(actions.filter((a) => a === 'UPDATE_SCHOOL_STATUS').length, 3);
  });

  test('setSchoolLifecycleStatus rejects an unknown status', async () => {
    await seedSchool();
    await assert.rejects(
      setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_ID, status: 'frozen' })),
      /valid status|invalid-argument/i,
    );
  });

  test('setSchoolLifecycleStatus on a missing school is not-found', async () => {
    await assert.rejects(
      setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: 'ghost', status: 'suspended' })),
      /not found|not-found/i,
    );
  });

  test('setSchoolLifecycleStatus is a no-op (no audit) when status is unchanged', async () => {
    await seedSchool({ status: 'active' });
    await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_ID, status: 'active' }));
    assert.deepEqual(await auditActions(), []);
  });

  // --- updateSchoolSubscriptionPlan -------------------------------------

  test('updateSchoolSubscriptionPlan sets plan + expiry, records previous plan, audits', async () => {
    await seedSchool({ subscriptionPlanId: 'starter' });
    const expiry = Date.now() + 365 * 24 * 3600 * 1000;
    const res = await updateSchoolSubscriptionPlan.run(request(OWNER_UID, { schoolId: SCHOOL_ID, planId: 'pro', expiry }));
    assert.deepEqual(res, { schoolId: SCHOOL_ID, planId: 'pro', expiry });

    const s = await school();
    assert.equal(s.subscriptionPlanId, 'pro');
    assert.equal(s.subscriptionExpiry, expiry);

    const log = (await db.collection('super_admin_audit_logs').get()).docs
      .map((d) => d.data()).find((d) => d.action === 'UPDATE_SUBSCRIPTION');
    assert.ok(log);
    assert.equal(log.metadata.previousPlanId, 'starter');
    assert.equal(log.metadata.planId, 'pro');
  });

  test('updateSchoolSubscriptionPlan rejects a non-finite expiry / missing planId', async () => {
    await seedSchool();
    await assert.rejects(updateSchoolSubscriptionPlan.run(request(OWNER_UID, { schoolId: SCHOOL_ID, planId: 'pro', expiry: 'soon' })), /required|invalid-argument/i);
    await assert.rejects(updateSchoolSubscriptionPlan.run(request(OWNER_UID, { schoolId: SCHOOL_ID, planId: '', expiry: Date.now() })), /required|invalid-argument/i);
  });

  test('updateSchoolSubscriptionPlan on a missing school is not-found', async () => {
    await assert.rejects(
      updateSchoolSubscriptionPlan.run(request(OWNER_UID, { schoolId: 'ghost', planId: 'pro', expiry: Date.now() })),
      /not found|not-found/i,
    );
  });

  // --- getSchoolApplicationsForOwner -----------------------------------

  test('getSchoolApplicationsForOwner returns applications newest-first for the owner', async () => {
    await db.doc('public_school_applications/appOld').set({
      status: 'pending_review', createdAt: 1000,
      school: { name: 'Old School' }, administrator: { email: 'a@old.test' },
    });
    await db.doc('public_school_applications/appNew').set({
      status: 'pending_review', createdAt: 2000,
      school: { name: 'New School' }, administrator: { email: 'a@new.test' },
    });
    const res = await getSchoolApplicationsForOwner.run(request(OWNER_UID, {}));
    assert.equal(res.applications.length, 2);
    assert.equal(res.applications[0].id, 'appNew', 'newest first');
    assert.equal(res.applications[1].id, 'appOld');
  });

  // --- rejectSchoolApplication ------------------------------------------

  test('rejectSchoolApplication marks rejected + reason + audit, only from pending', async () => {
    await db.doc('public_school_applications/app1').set({
      status: 'pending_review', authUid: 'applicantUid',
      school: { name: 'Rejected School' },
    });
    const res = await rejectSchoolApplication.run(request(OWNER_UID, { applicationId: 'app1', reason: 'Incomplete documents' }));
    assert.deepEqual(res, { ok: true, status: 'rejected' });

    const app = (await db.doc('public_school_applications/app1').get()).data();
    assert.equal(app.status, 'rejected');
    assert.equal(app.rejectionReason, 'Incomplete documents');
    assert.equal(app.reviewedBy, OWNER_UID);
    assert.ok((await auditActions()).includes('REJECT_SCHOOL_APPLICATION'));
  });

  test('rejectSchoolApplication needs a real reason', async () => {
    await db.doc('public_school_applications/app1').set({ status: 'pending_review' });
    await assert.rejects(
      rejectSchoolApplication.run(request(OWNER_UID, { applicationId: 'app1', reason: 'x' })),
      /clear rejection reason|invalid-argument/i,
    );
  });

  test('rejectSchoolApplication refuses a non-pending application', async () => {
    await db.doc('public_school_applications/app1').set({ status: 'approved', schoolId: 'schX' });
    await assert.rejects(
      rejectSchoolApplication.run(request(OWNER_UID, { applicationId: 'app1', reason: 'too late' })),
      /Only pending|failed-precondition/i,
    );
  });

  test('rejectSchoolApplication on a missing application is not-found', async () => {
    await assert.rejects(
      rejectSchoolApplication.run(request(OWNER_UID, { applicationId: 'ghost', reason: 'nope' })),
      /not found|not-found/i,
    );
  });

  // --- approveSchoolApplication (validation, no account provisioning) ----

  test('approveSchoolApplication is not-found for a missing application', async () => {
    await assert.rejects(
      approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'ghost' })),
      /not found|not-found/i,
    );
  });

  test('approveSchoolApplication refuses a non-pending application', async () => {
    await db.doc('public_school_applications/app1').set({ status: 'rejected' });
    await assert.rejects(
      approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'app1' })),
      /Only pending|failed-precondition/i,
    );
  });

  test('approveSchoolApplication refuses when terms were not accepted', async () => {
    await db.doc('public_school_applications/app1').set({
      status: 'pending_review', termsAccepted: false, authUid: 'someUid',
      school: { name: 'S', prefix: 'S1' }, administrator: { email: 'a@s.test' },
    });
    await assert.rejects(
      approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'app1' })),
      /not accepted the School Pulse terms|failed-precondition/i,
    );
  });
  // --- approveSchoolApplication happy path: free trial -----------------------

  const DAY_MS = 24 * 60 * 60 * 1000;
  const APPLICANT_UID = 'applicantUid1';

  async function seedPendingApplication() {
    await admin.auth().deleteUser(APPLICANT_UID).catch(() => {});
    await admin.auth().createUser({
      uid: APPLICANT_UID, email: 'head@trial.test', emailVerified: true, password: 'Passw0rd!',
    });
    await db.doc('public_school_applications/appTrial').set({
      id: APPLICANT_UID, authUid: APPLICANT_UID, status: 'pending_review', termsAccepted: true,
      plan: 'Growth', studentCount: 450,
      school: { name: 'Trial High School', prefix: 'THS', slug: 'trial-high', email: 'info@trial.test', phone: '+256700000001', category: 'Secondary' },
      location: { region: 'Central', district: 'Wakiso', address: 'Plot 1' },
      administrator: { firstName: 'Ada', lastName: 'Head', email: 'head@trial.test', phone: '+256700000002' },
    });
  }

  test('approveSchoolApplication starts a 30-day free trial with full access and no payment', async () => {
    await seedPendingApplication();
    const before = Date.now();
    const result = await approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'appTrial' }));
    assert.equal(TRIAL_DAYS, 30);
    assert.equal(result.paymentStatus, 'trial');
    assert.equal(result.appReady, true);

    const schoolDoc = (await db.doc(`schools/${result.schoolId}`).get()).data();
    assert.equal(schoolDoc.status, 'trial');
    assert.equal(schoolDoc.accessMode, 'full');
    assert.equal(schoolDoc.subscriptionPlanId, 'growth');
    assert.equal(schoolDoc.metadata.subscriptionStatus, 'trial');
    assert.equal(schoolDoc.metadata.hasEverActivated, false);
    assert.ok(schoolDoc.subscriptionExpiry >= before + 30 * DAY_MS - 1000);
    assert.ok(schoolDoc.subscriptionExpiry <= Date.now() + 30 * DAY_MS);

    const app = (await db.doc('public_school_applications/appTrial').get()).data();
    assert.equal(app.status, 'approved');
    assert.equal(app.paymentStatus, 'trial');
    assert.equal(app.appReady, true);
    assert.equal(app.trialEndsAt, schoolDoc.subscriptionExpiry);
    // Required by the official approval document behind the approval email.
    assert.ok(app.approvedAt, 'approvedAt must be set');

    const user = (await db.doc(`users/${APPLICANT_UID}`).get()).data();
    assert.equal(user.role, 'schoolAdmin');
    assert.equal(user.schoolId, result.schoolId);
    const membership = (await db.doc(`institution_memberships/${APPLICANT_UID}_${result.schoolId}`).get()).data();
    assert.equal(membership.status, 'active');
    assert.ok((await auditActions()).includes('APPROVE_SCHOOL_APPLICATION_TRIAL'));
  });

  async function seedTrialPayment(schoolId, overrides = {}) {
    await db.doc('manual_subscription_payments/pay1').set({
      schoolId, applicationId: 'appTrial', status: 'pending_verification', paymentType: 'activation',
      planId: 'growth', planName: 'Growth', expectedAmount: 550000, submittedAmount: 550000,
      termLengthDays: 120, method: 'mtn', reference: 'REF1', submittedByUid: APPLICANT_UID, ...overrides,
    });
  }

  test('a rejected payment during the trial leaves the trial running', async () => {
    await seedPendingApplication();
    const { schoolId } = await approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'appTrial' }));
    await seedTrialPayment(schoolId);
    await rejectManualPayment.run(request(OWNER_UID, { paymentId: 'pay1', reason: 'Reference not found' }));

    const schoolDoc = (await db.doc(`schools/${schoolId}`).get()).data();
    assert.equal(schoolDoc.accessMode, 'full');
    assert.equal(schoolDoc.metadata.subscriptionStatus, 'trial');
    const app = (await db.doc('public_school_applications/appTrial').get()).data();
    assert.equal(app.paymentStatus, 'rejected');
    assert.equal(app.appReady, true);
  });

  test('paying during the trial starts the paid term when the trial ends', async () => {
    await seedPendingApplication();
    const { schoolId } = await approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'appTrial' }));
    const trialEnds = (await db.doc(`schools/${schoolId}`).get()).data().subscriptionExpiry;
    await seedTrialPayment(schoolId);
    await approveManualPayment.run(request(OWNER_UID, { paymentId: 'pay1' }));

    const schoolDoc = (await db.doc(`schools/${schoolId}`).get()).data();
    assert.equal(schoolDoc.status, 'active');
    assert.equal(schoolDoc.accessMode, 'full');
    assert.equal(schoolDoc.metadata.hasEverActivated, true);
    assert.equal(schoolDoc.subscriptionExpiry, trialEnds + 120 * DAY_MS);
  });

  test('rejectSchoolApplication after submission sends no school into existence', async () => {
    await seedPendingApplication();
    await rejectSchoolApplication.run(request(OWNER_UID, { applicationId: 'appTrial', reason: 'Could not verify the school' }));
    const app = (await db.doc('public_school_applications/appTrial').get()).data();
    assert.equal(app.status, 'rejected');
    assert.equal((await db.collection('schools').get()).size, 0);
    await assert.rejects(
      approveSchoolApplication.run(request(OWNER_UID, { applicationId: 'appTrial' })),
      /Only pending|failed-precondition/i,
    );
  });
});
