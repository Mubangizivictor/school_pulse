// Firebase Emulator integration tests for the School Admin self-service
// subdomain-change flow in portal_domains.js:
//   * requestPortalSubdomainChange - schoolAdmin requests a new
//     <slug>.schoolpulseapp.com subdomain (pending owner review)
//   * approvePortalSubdomainChange - owner approves: moves the
//     portal_slug_reservations/portal_domains projection to the new slug
//   * rejectPortalSubdomainChange  - owner rejects: no slug/domain writes
//
// Same convention as school_workspace_callables.emulator.test.cjs: real
// onCall CloudFunction objects invoked via `.run(request)` against a plain
// {auth, data} request, backed by real Firestore/Auth emulators.
//
// Run:
//   firebase emulators:exec --only firestore,auth,functions \
//     --project demo-school-workspace-callables-test \
//     "node --test test/portal_subdomain_change.emulator.test.cjs"
const { after, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-school-workspace-callables-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const {
  requestPortalSubdomainChange,
  approvePortalSubdomainChange,
  rejectPortalSubdomainChange,
} = require('../portal_domains');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const SCHOOL_A = 'schoolA';
const SCHOOL_B = 'schoolB';
const ADMIN_A = 'adminA';
const ADMIN_B = 'adminB';

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

  await db.doc(`schools/${SCHOOL_A}`).set({
    id: SCHOOL_A, name: 'School A', status: 'active', slug: 'schoola',
    portalSubdomain: 'schoola.schoolpulseapp.com', branding: { schoolName: 'School A' },
  });
  await db.doc(`schools/${SCHOOL_B}`).set({
    id: SCHOOL_B, name: 'School B', status: 'active', slug: 'schoolb',
    portalSubdomain: 'schoolb.schoolpulseapp.com', branding: { schoolName: 'School B' },
  });
  await db.doc('portal_slug_reservations/schoola').set({ schoolId: SCHOOL_A, slug: 'schoola' });
  await db.doc('portal_slug_reservations/schoolb').set({ schoolId: SCHOOL_B, slug: 'schoolb' });
  await db.doc('portal_domains/schoola.schoolpulseapp.com').set({ schoolId: SCHOOL_A, slug: 'schoola', status: 'active' });
  await db.doc('portal_domains/schoolb.schoolpulseapp.com').set({ schoolId: SCHOOL_B, slug: 'schoolb', status: 'active' });

  await db.doc(`users/${ADMIN_A}`).set({ role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: SCHOOL_A, isActive: true });
  await db.doc(`users/${ADMIN_B}`).set({ role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: SCHOOL_B, isActive: true });
}

describe('portal subdomain change requests', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seed();
  });
  after(async () => {
    await clearFirestore();
  });

  describe('requestPortalSubdomainChange', () => {
    test('a school admin can request a free slug', async () => {
      const result = await requestPortalSubdomainChange.run(
        request(ADMIN_A, { slug: 'greenhill' }),
      );
      assert.equal(result.status, 'pending');
      const doc = await db.doc(`portal_subdomain_change_requests/${SCHOOL_A}`).get();
      assert.equal(doc.data().requestedSlug, 'greenhill');
      assert.equal(doc.data().currentSlug, 'schoola');
      assert.equal(doc.data().status, 'pending');
    });

    test('requesting the school\'s own current slug is rejected as a no-op', async () => {
      await assert.rejects(
        requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'schoola' })),
        (err) => err.code === 'invalid-argument',
      );
    });

    test('requesting a slug already reserved by another school is rejected', async () => {
      await assert.rejects(
        requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'schoolb' })),
        (err) => err.code === 'already-exists',
      );
    });

    test('an unauthenticated caller is rejected', async () => {
      await assert.rejects(
        requestPortalSubdomainChange.run(request(null, { slug: 'greenhill' })),
        (err) => err.code === 'unauthenticated',
      );
    });

    test('a non-schoolAdmin (e.g. a teacher) is rejected', async () => {
      await db.doc('users/teacherX').set({ role: 'classTeacher', roles: ['classTeacher'], schoolId: SCHOOL_A, isActive: true });
      await assert.rejects(
        requestPortalSubdomainChange.run(request('teacherX', { slug: 'greenhill' })),
        (err) => err.code === 'permission-denied',
      );
    });

    test('an invalid/reserved slug is rejected', async () => {
      await assert.rejects(
        requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'Not Valid' })),
        (err) => err.code === 'invalid-argument',
      );
    });
  });

  describe('approvePortalSubdomainChange', () => {
    test('owner approval moves the reservation and portal_domains projection to the new slug', async () => {
      await requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'greenhill' }));
      const result = await approvePortalSubdomainChange.run(request(OWNER_UID, { schoolId: SCHOOL_A }));
      assert.equal(result.status, 'approved');
      assert.equal(result.slug, 'greenhill');

      const school = await db.doc(`schools/${SCHOOL_A}`).get();
      assert.equal(school.data().slug, 'greenhill');
      assert.equal(school.data().portalSubdomain, 'greenhill.schoolpulseapp.com');

      const oldReservation = await db.doc('portal_slug_reservations/schoola').get();
      assert.equal(oldReservation.exists, false);
      const newReservation = await db.doc('portal_slug_reservations/greenhill').get();
      assert.equal(newReservation.exists, true);
      assert.equal(newReservation.data().schoolId, SCHOOL_A);

      const oldDomain = await db.doc('portal_domains/schoola.schoolpulseapp.com').get();
      assert.equal(oldDomain.exists, false);
      const newDomain = await db.doc('portal_domains/greenhill.schoolpulseapp.com').get();
      assert.equal(newDomain.exists, true);
      assert.equal(newDomain.data().status, 'active');

      const req = await db.doc(`portal_subdomain_change_requests/${SCHOOL_A}`).get();
      assert.equal(req.data().status, 'approved');
      assert.equal(req.data().reviewedBy, OWNER_UID);
    });

    test('a non-owner cannot approve', async () => {
      await requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'greenhill' }));
      await assert.rejects(
        approvePortalSubdomainChange.run(request(ADMIN_B, { schoolId: SCHOOL_A })),
        (err) => err.code === 'permission-denied' || err.code === 'unauthenticated',
      );
    });

    test('approving a slug that got claimed by another school in the meantime fails', async () => {
      await requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'greenhill' }));
      // Simulate a race: another school grabs "greenhill" after the request
      // was filed but before the owner approves it.
      await db.doc('portal_slug_reservations/greenhill').set({ schoolId: SCHOOL_B, slug: 'greenhill' });
      await assert.rejects(
        approvePortalSubdomainChange.run(request(OWNER_UID, { schoolId: SCHOOL_A })),
        (err) => err.code === 'already-exists',
      );
    });

    test('approving an unknown request is rejected', async () => {
      await assert.rejects(
        approvePortalSubdomainChange.run(request(OWNER_UID, { schoolId: SCHOOL_A })),
        (err) => err.code === 'not-found',
      );
    });

    test('approving an already-reviewed request is rejected', async () => {
      await requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'greenhill' }));
      await approvePortalSubdomainChange.run(request(OWNER_UID, { schoolId: SCHOOL_A }));
      await assert.rejects(
        approvePortalSubdomainChange.run(request(OWNER_UID, { schoolId: SCHOOL_A })),
        (err) => err.code === 'failed-precondition',
      );
    });
  });

  describe('rejectPortalSubdomainChange', () => {
    test('owner rejection marks the request rejected and leaves the slug untouched', async () => {
      await requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'greenhill' }));
      const result = await rejectPortalSubdomainChange.run(
        request(OWNER_UID, { schoolId: SCHOOL_A, reason: 'Too similar to an existing school' }),
      );
      assert.equal(result.status, 'rejected');

      const school = await db.doc(`schools/${SCHOOL_A}`).get();
      assert.equal(school.data().slug, 'schoola');

      const req = await db.doc(`portal_subdomain_change_requests/${SCHOOL_A}`).get();
      assert.equal(req.data().status, 'rejected');
      assert.equal(req.data().rejectionReason, 'Too similar to an existing school');
    });

    test('a non-owner cannot reject', async () => {
      await requestPortalSubdomainChange.run(request(ADMIN_A, { slug: 'greenhill' }));
      await assert.rejects(
        rejectPortalSubdomainChange.run(request(ADMIN_B, { schoolId: SCHOOL_A, reason: 'no' })),
        (err) => err.code === 'permission-denied' || err.code === 'unauthenticated',
      );
    });
  });
});
