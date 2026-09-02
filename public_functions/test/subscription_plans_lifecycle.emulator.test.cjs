// Firebase Emulator integration tests for the Super Admin "Manage Plans"
// surface - the 5 owner-only callables that PlanEditorPage + the
// Subscription Plans screen drive through ManualPaymentService:
//   createSubscriptionPlan, updateSubscriptionPlan,
//   updateSubscriptionPlanPricing, archiveSubscriptionPlan,
//   reactivateSubscriptionPlan   (all in public_functions/payments.js,
//   region europe-west1)
//
// Same convention as owner_console_callables.emulator.test.cjs: the exported
// symbols are real onCall CloudFunction objects, invoked via `.run(request)`
// against a plain {auth, data} request. Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-subscription-plans-lifecycle-test \
//     "node --test test/subscription_plans_lifecycle.emulator.test.cjs"
const { beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-subscription-plans-lifecycle-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const {
  createSubscriptionPlan,
  updateSubscriptionPlan,
  updateSubscriptionPlanPricing,
  archiveSubscriptionPlan,
  reactivateSubscriptionPlan,
} = require('../payments');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_UID = 'notTheOwnerUid';

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => deleteCollectionRecursive(c)));
}
async function deleteCollectionRecursive(ref) {
  const docs = await ref.listDocuments();
  await Promise.all(
    docs.map(async (d) => {
      const subs = await d.listCollections();
      await Promise.all(subs.map((s) => deleteCollectionRecursive(s)));
      await d.delete();
    }),
  );
}

async function seedOwner() {
  await db.doc('platform_config/owner_seed').set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true, email: 'owner@example.com',
  });
  // A second superAdmin that is NOT the seeded owner - requireOwner rejects it.
  await db.doc(`users/${OTHER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true,
  });
}

async function auditActions() {
  const snap = await db.collection('super_admin_audit_logs').get();
  return snap.docs.map((d) => d.data().action).sort();
}
async function getPlan(planId) {
  const snap = await db.collection('subscription_plans').doc(planId).get();
  return snap.exists ? snap.data() : null;
}

const VALID_CREATE = {
  planId: 'campus_pro',
  name: 'Campus Pro',
  description: 'Everything a mid-size school needs.',
  price: 750000,
  billingCycle: 'termly',
  termLengthDays: 120,
  trialDays: 14,
  maxStudents: 1200,
  maxStaff: 150,
  storageLimitGb: 20,
  smsLimitPerMonth: 5000,
  includedFeatures: ['Priority support', 'Custom report cards'],
  // Only keys in ALLOWED_PLAN_MODULE_KEYS survive; 'students'/'academics'
  // are core/implicit and are intentionally NOT valid module keys.
  includedModules: ['attendance', 'reports', 'finance'],
  isPublic: true,
  isActive: true,
  isPopular: false,
  displayOrder: 3,
};

describe('Super Admin - Manage Plans lifecycle (public_functions/payments.js)', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedOwner();
  });

  // --- AUTH GATE ------------------------------------------------------------

  test('every plan callable rejects an unauthenticated request', async () => {
    await assert.rejects(createSubscriptionPlan.run(request(null, VALID_CREATE)), /Sign in first|unauthenticated/i);
    await assert.rejects(updateSubscriptionPlan.run(request(null, { planId: 'x' })), /Sign in first|unauthenticated/i);
    await assert.rejects(updateSubscriptionPlanPricing.run(request(null, { planId: 'x', price: 1 })), /Sign in first|unauthenticated/i);
    await assert.rejects(archiveSubscriptionPlan.run(request(null, { planId: 'x' })), /Sign in first|unauthenticated/i);
    await assert.rejects(reactivateSubscriptionPlan.run(request(null, { planId: 'x' })), /Sign in first|unauthenticated/i);
  });

  test('a non-owner superAdmin is denied every plan callable', async () => {
    await assert.rejects(createSubscriptionPlan.run(request(OTHER_UID, VALID_CREATE)), /Access denied|permission-denied/i);
    await assert.rejects(updateSubscriptionPlan.run(request(OTHER_UID, { planId: 'x' })), /Access denied|permission-denied/i);
    await assert.rejects(archiveSubscriptionPlan.run(request(OTHER_UID, { planId: 'x' })), /Access denied|permission-denied/i);
  });

  test('a deactivated owner profile is denied', async () => {
    await db.doc(`users/${OWNER_UID}`).set({ isActive: false }, { merge: true });
    await assert.rejects(createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE)), /Access denied|permission-denied/i);
  });

  // --- CREATE -------------------------------------------------------------

  test('createSubscriptionPlan writes a normalized plan doc + audit log', async () => {
    const res = await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    assert.deepEqual(res, { ok: true, planId: 'campus_pro' });

    const plan = await getPlan('campus_pro');
    assert.equal(plan.name, 'Campus Pro');
    assert.equal(plan.price, 750000);
    assert.equal(plan.billingCycle, 'termly');
    assert.equal(plan.termLengthDays, 120);
    assert.equal(plan.trialDays, 14);
    assert.equal(plan.maxStudents, 1200);
    assert.equal(plan.isArchived, false);
    assert.equal(plan.isDefault, false);
    assert.equal(plan.isPublic, true);
    assert.equal(plan.isActive, true);
    assert.equal(plan.billingModel, 'manual_v1');
    assert.equal(plan.createdBy, OWNER_UID);
    assert.deepEqual([...plan.includedModules].sort(), ['attendance', 'finance', 'reports']);
    assert.ok(plan.createdAt, 'createdAt server timestamp set');

    assert.deepEqual(await auditActions(), ['CREATE_SUBSCRIPTION_PLAN']);
  });

  test('createSubscriptionPlan rejects a duplicate plan code', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    await assert.rejects(
      createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE)),
      /already exists|already-exists/i,
    );
  });

  test('createSubscriptionPlan rejects a malformed plan code', async () => {
    await assert.rejects(
      createSubscriptionPlan.run(request(OWNER_UID, { ...VALID_CREATE, planId: '9bad-code' })),
      /Plan code must be|invalid-argument/i,
    );
  });

  test('createSubscriptionPlan rejects zero price for a non-enterprise plan', async () => {
    await assert.rejects(
      createSubscriptionPlan.run(request(OWNER_UID, { ...VALID_CREATE, price: 0 })),
      /greater than zero|invalid-argument/i,
    );
  });

  test('createSubscriptionPlan drops unknown includedModules keys rather than failing', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, {
      ...VALID_CREATE, planId: 'mods_test',
      // 'students' is core/not a module key, 'not_a_real_module' is unknown -
      // both silently dropped; only 'finance' survives.
      includedModules: ['students', 'not_a_real_module', 'finance'],
    }));
    const plan = await getPlan('mods_test');
    assert.deepEqual([...plan.includedModules].sort(), ['finance']);
  });

  // --- UPDATE (full editor) --------------------------------------------------

  test('updateSubscriptionPlan edits name/limits/visibility + audits, id immutable', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    const res = await updateSubscriptionPlan.run(request(OWNER_UID, {
      ...VALID_CREATE,
      name: 'Campus Pro (renamed)',
      maxStudents: 2000,
      isPopular: true,
      displayOrder: 1,
    }));
    assert.deepEqual(res, { ok: true, planId: 'campus_pro' });

    const plan = await getPlan('campus_pro');
    assert.equal(plan.name, 'Campus Pro (renamed)');
    assert.equal(plan.maxStudents, 2000);
    assert.equal(plan.isPopular, true);
    assert.equal(plan.displayOrder, 1);
    assert.equal(plan.updatedBy, OWNER_UID);
    assert.equal(plan.createdBy, OWNER_UID, 'createdBy preserved on update');

    assert.deepEqual(await auditActions(), ['CREATE_SUBSCRIPTION_PLAN', 'UPDATE_SUBSCRIPTION_PLAN']);
  });

  test('updateSubscriptionPlan on a missing plan is not-found', async () => {
    await assert.rejects(
      updateSubscriptionPlan.run(request(OWNER_UID, { ...VALID_CREATE, planId: 'ghost' })),
      /not found|not-found/i,
    );
  });

  test('updateSubscriptionPlan cannot silently un-archive a plan via isActive:true', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    await archiveSubscriptionPlan.run(request(OWNER_UID, { planId: 'campus_pro' }));

    await updateSubscriptionPlan.run(request(OWNER_UID, { ...VALID_CREATE, isActive: true }));
    const plan = await getPlan('campus_pro');
    assert.equal(plan.isArchived, true, 'still archived');
    assert.equal(plan.isActive, false, 'generic editor forced isActive back to false');
  });

  // --- UPDATE PRICING -----------------------------------------------------

  test('updateSubscriptionPlanPricing changes price/cycle/term + audits', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    const res = await updateSubscriptionPlanPricing.run(request(OWNER_UID, {
      planId: 'campus_pro', price: 900000, billingCycle: 'yearly', termLengthDays: 365,
    }));
    assert.equal(res.ok, true);
    assert.equal(res.price, 900000);

    const plan = await getPlan('campus_pro');
    assert.equal(plan.price, 900000);
    assert.equal(plan.billingCycle, 'yearly');
    assert.equal(plan.termLengthDays, 365);
    assert.ok((await auditActions()).includes('UPDATE_SUBSCRIPTION_PLAN_PRICING'));
  });

  test('updateSubscriptionPlanPricing rejects an invalid billing cycle', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    await assert.rejects(
      updateSubscriptionPlanPricing.run(request(OWNER_UID, {
        planId: 'campus_pro', price: 500000, billingCycle: 'weekly',
      })),
      /Invalid billing cycle|invalid-argument/i,
    );
  });

  // --- ARCHIVE / REACTIVATE ---------------------------------------------------

  test('archiveSubscriptionPlan flips isArchived/isActive without deleting, + audit', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    const res = await archiveSubscriptionPlan.run(request(OWNER_UID, { planId: 'campus_pro' }));
    assert.deepEqual(res, { ok: true, planId: 'campus_pro' });

    const plan = await getPlan('campus_pro');
    assert.ok(plan, 'doc still exists - archive is not delete');
    assert.equal(plan.isArchived, true);
    assert.equal(plan.isActive, false);
    assert.ok((await auditActions()).includes('ARCHIVE_SUBSCRIPTION_PLAN'));
  });

  test('reactivateSubscriptionPlan restores isArchived:false/isActive:true, + audit', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    await archiveSubscriptionPlan.run(request(OWNER_UID, { planId: 'campus_pro' }));
    const res = await reactivateSubscriptionPlan.run(request(OWNER_UID, { planId: 'campus_pro' }));
    assert.deepEqual(res, { ok: true, planId: 'campus_pro' });

    const plan = await getPlan('campus_pro');
    assert.equal(plan.isArchived, false);
    assert.equal(plan.isActive, true);
    assert.ok((await auditActions()).includes('REACTIVATE_SUBSCRIPTION_PLAN'));
  });

  test('archive / reactivate on a missing plan is not-found', async () => {
    await assert.rejects(archiveSubscriptionPlan.run(request(OWNER_UID, { planId: 'ghost' })), /not found|not-found/i);
    await assert.rejects(reactivateSubscriptionPlan.run(request(OWNER_UID, { planId: 'ghost' })), /not found|not-found/i);
  });

  // --- FULL ROUND TRIP ------------------------------------------------------

  test('create -> edit -> reprice -> archive -> reactivate leaves one coherent doc + 5 audit rows', async () => {
    await createSubscriptionPlan.run(request(OWNER_UID, VALID_CREATE));
    await updateSubscriptionPlan.run(request(OWNER_UID, { ...VALID_CREATE, name: 'Campus Pro v2' }));
    await updateSubscriptionPlanPricing.run(request(OWNER_UID, { planId: 'campus_pro', price: 820000, billingCycle: 'termly', termLengthDays: 120 }));
    await archiveSubscriptionPlan.run(request(OWNER_UID, { planId: 'campus_pro' }));
    await reactivateSubscriptionPlan.run(request(OWNER_UID, { planId: 'campus_pro' }));

    const plan = await getPlan('campus_pro');
    assert.equal(plan.name, 'Campus Pro v2');
    assert.equal(plan.price, 820000);
    assert.equal(plan.isArchived, false);
    assert.equal(plan.isActive, true);

    assert.deepEqual(await auditActions(), [
      'ARCHIVE_SUBSCRIPTION_PLAN',
      'CREATE_SUBSCRIPTION_PLAN',
      'REACTIVATE_SUBSCRIPTION_PLAN',
      'UPDATE_SUBSCRIPTION_PLAN',
      'UPDATE_SUBSCRIPTION_PLAN_PRICING',
    ]);

    // createSubscriptionPlan calls ensureBillingDefaults(), which seeds the
    // 4 standard catalog plans (starter/growth/pro/enterprise) if absent.
    // So: 4 defaults + our campus_pro, and campus_pro is present exactly once.
    const plansSnap = await db.collection('subscription_plans').get();
    assert.equal(
      plansSnap.docs.filter((d) => d.id === 'campus_pro').length, 1,
      'campus_pro exists exactly once - no orphans, no dupes',
    );
    assert.ok(plansSnap.size >= 1);
  });
});
