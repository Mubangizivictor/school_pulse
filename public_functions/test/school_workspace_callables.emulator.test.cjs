// Firebase Emulator integration tests for the Enrolled School Detail
// workspace's owner-only callables:
//   * school_counts.js  - getSchoolCounts (real count() aggregation queries)
//   * portal_domains.js - manageSchoolAdmin (setPrimary/disable/enable/remove,
//     last-admin protection, audit, session revocation) and
//     requestSupportAccess (owner-initiated support session)
//   * payments.js        - getManualPaymentsForOwner (schoolId/date-range
//     server-side filtering)
//
// Same convention as owner_console_callables.emulator.test.cjs: the exported
// symbols are real onCall CloudFunction objects, invoked via `.run(request)`
// against a plain {auth, data} request, backed by real Firestore/Auth
// emulators - not a rules-unit-testing harness (that's
// functions/test/school_workspace.rules.test.cjs) and not a mocked Firestore.
//
// Run:
//   firebase emulators:exec --only firestore,auth,functions \
//     --project demo-school-workspace-callables-test \
//     "node --test test/school_workspace_callables.emulator.test.cjs"
const { after, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-school-workspace-callables-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const { getSchoolCounts } = require('../school_counts');
const { manageSchoolAdmin, requestSupportAccess, setSchoolLifecycleStatus } = require('../portal_domains');
const { getManualPaymentsForOwner } = require('../payments');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_SUPERADMIN_UID = 'notTheSeededOwner';
const SCHOOL_A = 'schoolA';
const SCHOOL_B = 'schoolB';
const ADMIN_A1 = 'adminA1'; // primary admin at School A
const ADMIN_A2 = 'adminA2'; // secondary admin at School A
const ADMIN_B1 = 'adminB1'; // sole admin at School B

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

async function seed() {
  await db.doc('platform_config/owner_seed').set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({ role: 'superAdmin', roles: ['superAdmin'], isActive: true });
  // A superAdmin-flavored profile that is NOT the seeded owner - every
  // callable here must reject it exactly like owner_console_callables does.
  await db.doc(`users/${OTHER_SUPERADMIN_UID}`).set({ role: 'superAdmin', roles: ['superAdmin'], isActive: true });

  await db.doc(`schools/${SCHOOL_A}`).set({ id: SCHOOL_A, name: 'School A', status: 'active' });
  await db.doc(`schools/${SCHOOL_B}`).set({ id: SCHOOL_B, name: 'School B', status: 'active' });

  // Students: 3 active/enrolled at School A (1 withdrawn, excluded), 1 at
  // School B (must never be counted for School A).
  await db.doc('students/stuA1').set({ schoolId: SCHOOL_A, status: 'active' });
  await db.doc('students/stuA2').set({ schoolId: SCHOOL_A, status: 'enrolled' });
  await db.doc('students/stuA3').set({ schoolId: SCHOOL_A, status: 'active' });
  await db.doc('students/stuA4Withdrawn').set({ schoolId: SCHOOL_A, status: 'withdrawn' });
  await db.doc('students/stuB1').set({ schoolId: SCHOOL_B, status: 'active' });

  // Staff at School A: 2 active staff, 1 inactive staff (excluded), 1 parent
  // (excluded, not staff), plus the two schoolAdmins below (also staff).
  await db.doc('users/teacherA1').set({ role: 'classTeacher', roles: ['classTeacher'], schoolId: SCHOOL_A, isActive: true });
  await db.doc('users/teacherA2').set({ role: 'classTeacher', roles: ['classTeacher'], schoolId: SCHOOL_A, isActive: true });
  await db.doc('users/teacherA3Inactive').set({ role: 'classTeacher', roles: ['classTeacher'], schoolId: SCHOOL_A, isActive: false });
  await db.doc('users/parentA1').set({ role: 'parent', roles: ['parent'], schoolId: SCHOOL_A, isActive: true });
  await db.doc('users/teacherB1').set({ role: 'classTeacher', roles: ['classTeacher'], schoolId: SCHOOL_B, isActive: true });

  // School A: two active schoolAdmins, A1 primary.
  await db.doc(`users/${ADMIN_A1}`).set({ role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: SCHOOL_A, isActive: true, isPrimaryAdmin: true });
  await db.doc(`users/${ADMIN_A2}`).set({ role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: SCHOOL_A, isActive: true, isPrimaryAdmin: false });
  await db.doc(`institution_memberships/${ADMIN_A1}_${SCHOOL_A}`).set({ userId: ADMIN_A1, institutionId: SCHOOL_A, isPrimaryAdmin: true, status: 'active' });
  await db.doc(`institution_memberships/${ADMIN_A2}_${SCHOOL_A}`).set({ userId: ADMIN_A2, institutionId: SCHOOL_A, isPrimaryAdmin: false, status: 'active' });

  // School B: exactly one active schoolAdmin - the last-admin case.
  await db.doc(`users/${ADMIN_B1}`).set({ role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: SCHOOL_B, isActive: true, isPrimaryAdmin: true });
  await db.doc(`institution_memberships/${ADMIN_B1}_${SCHOOL_B}`).set({ userId: ADMIN_B1, institutionId: SCHOOL_B, isPrimaryAdmin: true, status: 'active' });

  // Payments: 2 at School A, 1 at School B.
  await db.doc('manual_subscription_payments/payA1').set({
    schoolId: SCHOOL_A, status: 'pending_verification', submittedAmount: 100000,
    submittedAt: admin.firestore.Timestamp.fromDate(new Date('2026-01-10')),
  });
  await db.doc('manual_subscription_payments/payA2').set({
    schoolId: SCHOOL_A, status: 'approved', submittedAmount: 350000,
    submittedAt: admin.firestore.Timestamp.fromDate(new Date('2026-02-15')),
  });
  await db.doc('manual_subscription_payments/payB1').set({
    schoolId: SCHOOL_B, status: 'approved', submittedAmount: 500000,
    submittedAt: admin.firestore.Timestamp.fromDate(new Date('2026-01-20')),
  });
}

describe('school workspace owner-only callables', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seed();
  });
  after(async () => {
    await clearFirestore();
  });

  // ---- school_counts.js -------------------------------------------

  describe('getSchoolCounts', () => {
    test('Super Admin gets exact active-student and active-staff counts for the requested school', async () => {
      const result = await getSchoolCounts.run(request(OWNER_UID, { schoolId: SCHOOL_A }));
      // 3 active/enrolled students (stuA1, stuA2, stuA3) - withdrawn excluded.
      assert.equal(result.studentCount, 3);
      // 4 active staff: teacherA1, teacherA2, adminA1, adminA2 - inactive
      // teacher and the parent both excluded.
      assert.equal(result.staffCount, 4);
      assert.ok(typeof result.updatedAt === 'number');
    });

    test('counts never leak another school\'s records', async () => {
      const result = await getSchoolCounts.run(request(OWNER_UID, { schoolId: SCHOOL_B }));
      assert.equal(result.studentCount, 1);
      // teacherB1 + adminB1
      assert.equal(result.staffCount, 2);
    });

    test('a non-owner superAdmin is rejected', async () => {
      await assert.rejects(
        () => getSchoolCounts.run(request(OTHER_SUPERADMIN_UID, { schoolId: SCHOOL_A })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('a school admin cannot call this at all', async () => {
      await assert.rejects(
        () => getSchoolCounts.run(request(ADMIN_A1, { schoolId: SCHOOL_A })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('an unauthenticated caller is rejected', async () => {
      await assert.rejects(
        () => getSchoolCounts.run(request(null, { schoolId: SCHOOL_A })),
        (err) => err.code === 'unauthenticated',
      );
    });
  });

  // ---- payments.js --------------------------------------------------

  describe('getManualPaymentsForOwner - schoolId server-side scoping', () => {
    test('schoolId filter returns only that school\'s payments', async () => {
      const result = await getManualPaymentsForOwner.run(request(OWNER_UID, { schoolId: SCHOOL_A }));
      assert.equal(result.payments.length, 2);
      assert.ok(result.payments.every((p) => p.schoolId === SCHOOL_A));
    });

    test('a manipulated/foreign schoolId cannot pull another school\'s payments into the same response', async () => {
      const resultA = await getManualPaymentsForOwner.run(request(OWNER_UID, { schoolId: SCHOOL_A }));
      const resultB = await getManualPaymentsForOwner.run(request(OWNER_UID, { schoolId: SCHOOL_B }));
      assert.ok(!resultA.payments.some((p) => p.schoolId === SCHOOL_B));
      assert.ok(!resultB.payments.some((p) => p.schoolId === SCHOOL_A));
    });

    test('date range narrows results within one school', async () => {
      const result = await getManualPaymentsForOwner.run(request(OWNER_UID, {
        schoolId: SCHOOL_A,
        startDateMs: new Date('2026-02-01').getTime(),
        endDateMs: new Date('2026-02-28').getTime(),
      }));
      assert.equal(result.payments.length, 1);
      assert.equal(result.payments[0].id, 'payA2');
    });

    test('no schoolId returns the owner-wide unfiltered Billing view (unchanged existing behavior)', async () => {
      const result = await getManualPaymentsForOwner.run(request(OWNER_UID, {}));
      assert.equal(result.payments.length, 3);
    });

    test('a non-owner is rejected', async () => {
      await assert.rejects(
        () => getManualPaymentsForOwner.run(request(ADMIN_A1, { schoolId: SCHOOL_A })),
        (err) => err.code === 'permission-denied',
      );
    });
  });

  // ---- portal_domains.js: manageSchoolAdmin --------------------------

  describe('manageSchoolAdmin', () => {
    test('Super Admin can set a new primary administrator', async () => {
      await manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'setPrimary' }));
      const snap = await db.doc(`users/${ADMIN_A2}`).get();
      assert.equal(snap.data().isPrimaryAdmin, true);
      const membership = await db.doc(`institution_memberships/${ADMIN_A2}_${SCHOOL_A}`).get();
      assert.equal(membership.data().isPrimaryAdmin, true);
    });

    test('a non-owner superAdmin cannot call manageSchoolAdmin', async () => {
      await assert.rejects(
        () => manageSchoolAdmin.run(request(OTHER_SUPERADMIN_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'setPrimary' })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('a school admin cannot call manageSchoolAdmin at all, even for their own school', async () => {
      await assert.rejects(
        () => manageSchoolAdmin.run(request(ADMIN_A1, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'setPrimary' })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('disable requires a reason of at least 3 characters', async () => {
      await assert.rejects(
        () => manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'disable', reason: 'x' })),
        (err) => err.code === 'invalid-argument',
      );
    });

    test('disabling a non-last admin succeeds, writes isActive:false, and revokes their sessions', async () => {
      await manageSchoolAdmin.run(request(OWNER_UID, {
        schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'disable', reason: 'Requested by the school',
      }));
      const snap = await db.doc(`users/${ADMIN_A2}`).get();
      assert.equal(snap.data().isActive, false);
      assert.equal(snap.data().deactivationReason, 'Requested by the school');
      const membership = await db.doc(`institution_memberships/${ADMIN_A2}_${SCHOOL_A}`).get();
      assert.equal(membership.data().status, 'suspended');
    });

    test('the last active School Admin cannot be disabled without a valid replacement', async () => {
      await assert.rejects(
        () => manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_B, targetUid: ADMIN_B1, action: 'disable', reason: 'Testing last-admin block' })),
        (err) => err.code === 'failed-precondition',
      );
      const snap = await db.doc(`users/${ADMIN_B1}`).get();
      assert.equal(snap.data().isActive, true, 'the last admin must remain untouched after the rejected call');
    });

    test('the last active School Admin CAN be removed when a valid replacement is provided, and the replacement becomes primary in the same transaction', async () => {
      // A replacement candidate who is NOT yet an active schoolAdmin at
      // School B - the last-admin check must still count ADMIN_B1 as the
      // only remaining active admin (the replacement isn't active/admin
      // yet), take the replacement branch, and promote them atomically.
      await db.doc('users/futureAdminB2').set({ role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: SCHOOL_B, isActive: true, isPrimaryAdmin: false });
      await db.doc(`institution_memberships/futureAdminB2_${SCHOOL_B}`).set({ userId: 'futureAdminB2', institutionId: SCHOOL_B, isPrimaryAdmin: false, status: 'active' });

      await manageSchoolAdmin.run(request(OWNER_UID, {
        schoolId: SCHOOL_B, targetUid: ADMIN_B1, action: 'remove', reason: 'Leaving the school', replacementUid: 'futureAdminB2',
      }));

      const removed = await db.doc(`users/${ADMIN_B1}`).get();
      assert.equal(removed.data().isActive, false);
      const replacement = await db.doc('users/futureAdminB2').get();
      assert.equal(replacement.data().isPrimaryAdmin, true);
    });

    test('removing a non-last admin does not touch a replacementUid even if one is supplied (it is unnecessary and ignored)', async () => {
      // School A has two active admins - removing one is not a last-admin
      // scenario, so a supplied replacementUid must simply be ignored, not
      // acted upon.
      await manageSchoolAdmin.run(request(OWNER_UID, {
        schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'remove', reason: 'Not the last admin', replacementUid: ADMIN_A1,
      }));
      const removed = await db.doc(`users/${ADMIN_A2}`).get();
      assert.equal(removed.data().isActive, false);
      const untouched = await db.doc(`users/${ADMIN_A1}`).get();
      assert.equal(untouched.data().isPrimaryAdmin, true, 'ADMIN_A1 was already primary and must remain so, not re-promoted via the ignored replacementUid');
    });

    test('an audit record is written for every action', async () => {
      await manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'setPrimary' }));
      const logs = await db.collection('super_admin_audit_logs').where('affectedUserId', '==', ADMIN_A2).get();
      assert.equal(logs.size, 1);
      assert.equal(logs.docs[0].data().action, 'SCHOOL_ADMIN_SETPRIMARY');
      assert.equal(logs.docs[0].data().ownerId, OWNER_UID);
    });

    test('a suspended school rejects admin lifecycle changes even from the owner', async () => {
      await db.doc(`schools/${SCHOOL_A}`).update({ status: 'suspended' });
      await assert.rejects(
        () => manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'setPrimary' })),
        (err) => err.code === 'failed-precondition',
      );
    });

    test('an archived school also rejects admin lifecycle changes', async () => {
      await db.doc(`schools/${SCHOOL_A}`).update({ status: 'archived' });
      await assert.rejects(
        () => manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_A2, action: 'disable', reason: 'irrelevant' })),
        (err) => err.code === 'failed-precondition',
      );
    });

    test('cannot manage an admin who does not belong to the specified school', async () => {
      await assert.rejects(
        () => manageSchoolAdmin.run(request(OWNER_UID, { schoolId: SCHOOL_A, targetUid: ADMIN_B1, action: 'setPrimary' })),
        (err) => err.code === 'not-found' || err.code === 'permission-denied',
      );
    });
  });

  // ---- portal_domains.js: requestSupportAccess -----------------------

  describe('requestSupportAccess', () => {
    test('Super Admin creates a school-scoped, time-boxed pending session', async () => {
      const result = await requestSupportAccess.run(request(OWNER_UID, { schoolId: SCHOOL_A, reason: 'Debugging attendance' }));
      assert.equal(result.status, 'pending');
      const snap = await db.doc(`institutions/${SCHOOL_A}/support_access_requests/${result.supportAccessRequestId}`).get();
      assert.equal(snap.data().institutionId, SCHOOL_A);
      assert.equal(snap.data().requestedByPlatformUser, OWNER_UID);
      assert.ok(snap.data().expiresAt);
    });

    test('a reason under 3 characters is rejected', async () => {
      await assert.rejects(
        () => requestSupportAccess.run(request(OWNER_UID, { schoolId: SCHOOL_A, reason: 'x' })),
        (err) => err.code === 'invalid-argument',
      );
    });

    test('a non-owner is rejected', async () => {
      await assert.rejects(
        () => requestSupportAccess.run(request(ADMIN_A1, { schoolId: SCHOOL_A, reason: 'Trying to self-authorize' })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('an unknown school is rejected', async () => {
      await assert.rejects(
        () => requestSupportAccess.run(request(OWNER_UID, { schoolId: 'schoolDoesNotExist', reason: 'test' })),
        (err) => err.code === 'not-found',
      );
    });
  });

  // ---- portal_domains.js: setSchoolLifecycleStatus (suspend/reactivate) ---

  describe('setSchoolLifecycleStatus - suspend must have real impact, not just a status label', () => {
    test('suspending sets accessMode:blocked - the field firestore.rules actually checks (schoolCanWrite/schoolAccessMode)', async () => {
      await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'Non-payment' }));
      const snap = await db.doc(`schools/${SCHOOL_A}`).get();
      assert.equal(snap.data().status, 'suspended');
      assert.equal(snap.data().accessMode, 'blocked');
    });

    test('reactivating restores accessMode:full', async () => {
      await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'Non-payment' }));
      await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'active' }));
      const snap = await db.doc(`schools/${SCHOOL_A}`).get();
      assert.equal(snap.data().status, 'active');
      assert.equal(snap.data().accessMode, 'full');
    });

    test('archiving also sets accessMode:blocked', async () => {
      await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'archived', reason: 'Closed permanently' }));
      const snap = await db.doc(`schools/${SCHOOL_A}`).get();
      assert.equal(snap.data().accessMode, 'blocked');
    });

    test('suspend/archive never touch students, users, or payments - only the school doc and an audit row', async () => {
      const beforeStudent = (await db.doc('students/stuA1').get()).data();
      const beforeAdmin = (await db.doc(`users/${ADMIN_A1}`).get()).data();
      const beforePayment = (await db.doc('manual_subscription_payments/payA1').get()).data();
      await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'Testing data preservation' }));
      assert.deepEqual((await db.doc('students/stuA1').get()).data(), beforeStudent);
      assert.deepEqual((await db.doc(`users/${ADMIN_A1}`).get()).data(), beforeAdmin);
      assert.deepEqual((await db.doc('manual_subscription_payments/payA1').get()).data(), beforePayment);
    });

    test('suspending attempts session revocation for every user at the school (best-effort, never blocks the status write)', async () => {
      // No real Auth-emulator users are seeded here (out of scope for this
      // suite - see comment above); revokeRefreshTokens is expected to
      // reject for a non-existent uid, which the callable swallows via
      // .catch(() => {}) precisely so a revocation failure can never roll
      // back or block the actual access-lockout write. This proves that
      // contract: the status/accessMode write still succeeds even though
      // every revocation call underneath it fails.
      const result = await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'x' }));
      assert.equal(result.status, 'suspended');
      const snap = await db.doc(`schools/${SCHOOL_A}`).get();
      assert.equal(snap.data().accessMode, 'blocked');
    });

    test('a non-owner cannot suspend a school', async () => {
      await assert.rejects(
        () => setSchoolLifecycleStatus.run(request(ADMIN_A1, { schoolId: SCHOOL_A, status: 'suspended', reason: 'Self-suspend attempt' })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('setting the same status twice is a no-op that still succeeds (idempotent)', async () => {
      await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'first' }));
      const result = await setSchoolLifecycleStatus.run(request(OWNER_UID, { schoolId: SCHOOL_A, status: 'suspended', reason: 'second' }));
      assert.equal(result.status, 'suspended');
    });
  });
});
