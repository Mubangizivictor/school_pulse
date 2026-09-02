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
const { approveSchoolApplication } = require('../payments');

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
});
