// Firebase Emulator integration tests for Phase 2A term-based billing:
//   * public_functions/subscription_cycle_billing.js - the hourly sweep
//     (checkSubscriptionCycleBilling), invoked directly as a plain async
//     function rather than through the Scheduler trigger wrapper (same
//     convention as school_workspace_callables.emulator.test.cjs invoking
//     onCall exports via `.run(request)` - here the exported onSchedule
//     handler is invoked directly since there is no scheduler emulator).
//   * public_functions/payments.js - approveManualPayment's new
//     subscription_cycles integration (marks earliest eligible cycle paid,
//     restores a suspended school's access, no-ops when no cycle exists).
//   * public_functions/portal_domains.js - suspendSchoolCore parity between
//     the owner-invoked setSchoolLifecycleStatus path and the scheduled
//     job's automatic path (same transaction body, different audit action
//     tag, same idempotency).
//
// STATUS AS OF WRITING: NOT RUN. This environment's Java is 17.0.19
// (Homebrew OpenJDK); firebase-tools requires JDK 21+ for
// `firebase emulators:exec` (confirmed by a direct emulator boot attempt
// here, which failed with "firebase-tools no longer supports Java version
// before 21"). This is the SAME blocker documented against Phase 1
// (functions/test/academic_calendar_billing.emulator.test.cjs's header) -
// it has not been resolved in this environment. This file is written to the
// same structural/assertion standard as its siblings and has been read
// through carefully against the real onSchedule/onCall/suspendSchoolCore
// implementations, but has not been executed against a live emulator.
// Whoever next has JDK 21 available should run:
//   firebase emulators:exec --only firestore,auth,functions \
//     --project demo-subscription-cycle-billing-test \
//     "node --test test/subscription_cycle_billing.emulator.test.cjs"
// and fix up anything a real Firestore/Admin SDK round-trip surfaces that a
// careful read did not (composite index requirements in particular - the
// approveManualPayment query added here needs the schoolId+cycleStatus+
// termStart index this change also adds to firestore.indexes.json; the
// emulator does not enforce indexes the way production does, so a missing-
// index bug specifically would NOT be caught by this suite even once JDK 21
// is available - deploy-time or production testing is still needed for that).
const { after, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-subscription-cycle-billing-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });
// The scheduled job requires RESEND_API_KEY as a declared secret; in the
// emulator this resolves via defineSecret's local fallback - set a dummy
// value so email_service.js's Resend client construction doesn't throw
// before enqueueTemplatedEmail (which only writes a Firestore queue doc,
// never actually calls Resend in tests) is reached.
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 'test-dummy-key';

const admin = require('firebase-admin');

// payments.js and portal_domains.js call admin.initializeApp() as a module
// load side effect (guarded by `if (!admin.apps.length)`); they must be
// required before admin.firestore() below or the default app does not
// exist yet (matches the require-then-db-init order already used in
// school_workspace_callables.emulator.test.cjs).
const { approveManualPayment } = require('../payments');
const { setSchoolLifecycleStatus, suspendSchoolCore } = require('../portal_domains');

const db = admin.firestore();
// checkSubscriptionCycleBilling is an onSchedule CloudFunction object; its
// underlying handler is invoked the same way onCall exports are invoked in
// school_workspace_callables.emulator.test.cjs (`.run(...)`), but
// onSchedule handlers take a ScheduledEvent, not a {auth,data} request - an
// empty object is sufficient since the handler never reads its argument.
const { checkSubscriptionCycleBilling } = require('../subscription_cycle_billing');

const OWNER_UID = 'ownerUid';
const SCHOOL_A = 'schoolA';
const ADMIN_A = 'adminA';

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

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function seedSchoolAndOwner(overrides = {}) {
  await db.doc('platform_config/owner_seed').set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({ role: 'superAdmin', roles: ['superAdmin'], isActive: true });
  await db.doc(`users/${ADMIN_A}`).set({ schoolId: SCHOOL_A, role: 'schoolAdmin', email: 'admin@schoola.test', isActive: true });
  await db.doc(`schools/${SCHOOL_A}`).set({
    id: SCHOOL_A,
    name: 'School A',
    status: 'active',
    accessMode: 'full',
    subscriptionExpiry: 0,
    metadata: {},
    ...overrides,
  });
}

describe('subscription_cycle_billing + approveManualPayment cycle integration', () => {
  beforeEach(clearFirestore);
  after(() => process.exit(0));

  test('approveManualPayment marks the earliest eligible cycle paid and restores a suspended school', async () => {
    await seedSchoolAndOwner({ status: 'suspended', accessMode: 'blocked' });

    const now = Date.now();
    // Two cycles: an earlier 'invoiced' one (should be picked) and a later
    // 'gracePeriod' one (should be left untouched).
    await db.doc(`subscription_cycles/${SCHOOL_A}_term1`).set({
      schoolId: SCHOOL_A,
      termId: 'term1',
      termStart: admin.firestore.Timestamp.fromMillis(now),
      cycleStatus: 'invoiced',
      paymentStatus: 'unpaid',
    });
    await db.doc(`subscription_cycles/${SCHOOL_A}_term2`).set({
      schoolId: SCHOOL_A,
      termId: 'term2',
      termStart: admin.firestore.Timestamp.fromMillis(now + 100 * 24 * 60 * 60 * 1000),
      cycleStatus: 'gracePeriod',
      paymentStatus: 'unpaid',
    });

    const paymentId = 'payment1';
    await db.doc(`manual_subscription_payments/${paymentId}`).set({
      schoolId: SCHOOL_A,
      status: 'pending_verification',
      submittedAmount: 500000,
      expectedAmount: 500000,
      termLengthDays: 120,
      planId: 'starter',
      planName: 'Starter',
      paymentType: 'renewal',
    });

    const result = await approveManualPayment.run(request(OWNER_UID, { paymentId }));
    assert.equal(result.status, 'approved');

    const cycle1 = (await db.doc(`subscription_cycles/${SCHOOL_A}_term1`).get()).data();
    assert.equal(cycle1.cycleStatus, 'paid');
    assert.equal(cycle1.paymentStatus, 'paid');
    assert.equal(cycle1.paidPaymentId, paymentId);

    const cycle2 = (await db.doc(`subscription_cycles/${SCHOOL_A}_term2`).get()).data();
    assert.equal(cycle2.cycleStatus, 'gracePeriod', 'later cycle must be left untouched');

    const school = (await db.doc(`schools/${SCHOOL_A}`).get()).data();
    assert.equal(school.status, 'active', 'suspended school must be restored to active');
    assert.equal(school.accessMode, 'full');
  });

  test('approveManualPayment with no matching cycle does not throw and leaves flat-expiry flow unchanged', async () => {
    await seedSchoolAndOwner();
    const paymentId = 'payment2';
    await db.doc(`manual_subscription_payments/${paymentId}`).set({
      schoolId: SCHOOL_A,
      status: 'pending_verification',
      submittedAmount: 300000,
      expectedAmount: 300000,
      termLengthDays: 120,
      planId: 'starter',
      planName: 'Starter',
      paymentType: 'initial',
    });

    const result = await approveManualPayment.run(request(OWNER_UID, { paymentId }));
    assert.equal(result.status, 'approved');
    assert.ok(result.subscriptionExpiry > Date.now());

    const school = (await db.doc(`schools/${SCHOOL_A}`).get()).data();
    assert.equal(school.status, 'active');
    assert.equal(school.subscriptionPlanId, 'starter');
  });

  test('suspendSchoolCore parity: owner-invoked and scheduled-job paths produce the same suspended state, tagged with different audit actions', async () => {
    await seedSchoolAndOwner();

    // Owner-invoked path via setSchoolLifecycleStatus.
    await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'Owner test' }));
    let school = (await db.doc(`schools/${SCHOOL_A}`).get()).data();
    assert.equal(school.status, 'suspended');
    assert.equal(school.accessMode, 'blocked');

    let auditSnap = await db.collection('super_admin_audit_logs').where('schoolId', '==', SCHOOL_A).get();
    assert.ok(auditSnap.docs.some((d) => d.data().action === 'UPDATE_SCHOOL_STATUS'));

    // Reset to active, then suspend via the scheduled-job code path directly.
    await db.doc(`schools/${SCHOOL_A}`).set({ status: 'active', accessMode: 'full' }, { merge: true });
    await suspendSchoolCore(db, SCHOOL_A, 'Auto test', 'system:subscription_cycle_billing', 'AUTO_SUSPEND_UNPAID_CYCLE');
    school = (await db.doc(`schools/${SCHOOL_A}`).get()).data();
    assert.equal(school.status, 'suspended');
    assert.equal(school.accessMode, 'blocked');

    auditSnap = await db.collection('super_admin_audit_logs').where('schoolId', '==', SCHOOL_A).get();
    assert.ok(auditSnap.docs.some((d) => d.data().action === 'AUTO_SUSPEND_UNPAID_CYCLE'));

    // Idempotency: calling suspendSchoolCore again on an already-suspended
    // school must not write a second audit log entry.
    const auditCountBefore = auditSnap.size;
    await suspendSchoolCore(db, SCHOOL_A, 'Auto test again', 'system:subscription_cycle_billing', 'AUTO_SUSPEND_UNPAID_CYCLE');
    const auditSnapAfter = await db.collection('super_admin_audit_logs').where('schoolId', '==', SCHOOL_A).get();
    assert.equal(auditSnapAfter.size, auditCountBefore, 'no duplicate audit log on re-suspend of an already-suspended school');
  });

  test('checkSubscriptionCycleBilling sweep: upcoming cycle within lead window is invoiced; overdue cycle triggers suspension', async () => {
    await seedSchoolAndOwner();

    const now = Date.now();
    const DAY_MS = 24 * 60 * 60 * 1000;
    // Cycle A: upcoming, termStart within the default 14-day invoice lead window.
    await db.doc(`subscription_cycles/${SCHOOL_A}_termUpcoming`).set({
      schoolId: SCHOOL_A,
      termId: 'termUpcoming',
      termStart: admin.firestore.Timestamp.fromMillis(now + 10 * DAY_MS),
      paymentDueAt: admin.firestore.Timestamp.fromMillis(now + 10 * DAY_MS),
      graceEndsAt: admin.firestore.Timestamp.fromMillis(now + 17 * DAY_MS),
      cycleStatus: 'upcoming',
      paymentStatus: 'unpaid',
    });

    await checkSubscriptionCycleBilling.run({});

    const cycleA = (await db.doc(`subscription_cycles/${SCHOOL_A}_termUpcoming`).get()).data();
    assert.equal(cycleA.cycleStatus, 'invoiced');
    assert.ok(cycleA.invoiceIssuedAt);

    const queueDoc = await db.doc('transactional_email_queue/cycle_invoice_issued_' + `${SCHOOL_A}_termUpcoming`).get();
    assert.ok(queueDoc.exists, 'cycle_invoice_issued email should be queued');

    // Cycle B: gracePeriod, past graceEndsAt -> overdue + auto-suspend.
    await db.doc(`subscription_cycles/${SCHOOL_A}_termOverdue`).set({
      schoolId: SCHOOL_A,
      termId: 'termOverdue',
      termStart: admin.firestore.Timestamp.fromMillis(now - 60 * DAY_MS),
      paymentDueAt: admin.firestore.Timestamp.fromMillis(now - 60 * DAY_MS),
      graceEndsAt: admin.firestore.Timestamp.fromMillis(now - 53 * DAY_MS),
      cycleStatus: 'gracePeriod',
      paymentStatus: 'unpaid',
    });

    await checkSubscriptionCycleBilling.run({});

    const cycleB = (await db.doc(`subscription_cycles/${SCHOOL_A}_termOverdue`).get()).data();
    assert.equal(cycleB.cycleStatus, 'overdue', 'cycleStatus must stay overdue, never become "suspended"');

    const school = (await db.doc(`schools/${SCHOOL_A}`).get()).data();
    assert.equal(school.status, 'suspended', 'school must be suspended as the side-effect, not the cycle');
  });
});
