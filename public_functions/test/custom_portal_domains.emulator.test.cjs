// Firebase Emulator integration tests for the Super Admin "Custom Domains"
// surface - the owner-only callables CustomDomainService drives (all in
// public_functions/portal_domains.js, region europe-west1):
//   recheckCustomPortalDomain, verifyAndActivateCustomPortalDomain,
//   rejectCustomPortalDomain
//
// recheck/verifyAndActivate call dns.resolveCname(); this test stubs
// `require('node:dns').promises.resolveCname` BEFORE loading the module so
// both the CNAME-ok and CNAME-not-ok branches are deterministic.
//
// Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-custom-portal-domains-test \
//     "node --test test/custom_portal_domains.emulator.test.cjs"
const { beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-custom-portal-domains-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

// ---- DNS stub, installed before portal_domains.js captures `.promises` ----
const dnsPromises = require('node:dns').promises;
const TARGET = 'ghs.googlehosted.com';
// Per-hostname canned answers. Default: NXDOMAIN-style throw (no CNAME).
let cnameAnswers = {};
dnsPromises.resolveCname = async (host) => {
  if (host in cnameAnswers) {
    const v = cnameAnswers[host];
    if (v instanceof Error) throw v;
    return v;
  }
  const err = new Error(`queryCname ENOTFOUND ${host}`);
  err.code = 'ENOTFOUND';
  throw err;
};

const {
  recheckCustomPortalDomain,
  verifyAndActivateCustomPortalDomain,
  rejectCustomPortalDomain,
} = require('../portal_domains');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_UID = 'notTheOwnerUid';
const SCHOOL_ID = 'schoolA';
const HOST = 'portal.exampleschool.com';

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
async function seedSchool() {
  await db.doc(`schools/${SCHOOL_ID}`).set({
    id: SCHOOL_ID, name: 'Example School', slug: 'example',
    branding: { schoolName: 'Example School', primaryColor: '#123456' },
    customDomains: [],
  });
}
async function seedRequest(status = 'pending', overrides = {}) {
  await db.doc(`portal_domain_requests/${HOST}`).set({
    hostname: HOST, schoolId: SCHOOL_ID, status, cnameTarget: TARGET, ...overrides,
  });
}
async function req() {
  return (await db.doc(`portal_domain_requests/${HOST}`).get()).data();
}
async function auditActions() {
  const snap = await db.collection('super_admin_audit_logs').get();
  return snap.docs.map((d) => d.data().action).sort();
}

describe('Super Admin - Custom Domains', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedOwner();
    await seedSchool();
    cnameAnswers = {};
  });

  // --- AUTH GATE -------------------------------------------------------

  test('unauthenticated is rejected by every custom-domain callable', async () => {
    await assert.rejects(recheckCustomPortalDomain.run(request(null, { hostname: HOST })), /sign in|unauthenticated/i);
    await assert.rejects(verifyAndActivateCustomPortalDomain.run(request(null, { hostname: HOST })), /sign in|unauthenticated/i);
    await assert.rejects(rejectCustomPortalDomain.run(request(null, { hostname: HOST, reason: 'x' })), /sign in|unauthenticated/i);
  });

  test('a non-owner superAdmin is denied every custom-domain callable', async () => {
    await assert.rejects(recheckCustomPortalDomain.run(request(OTHER_UID, { hostname: HOST })), /access denied|permission-denied/i);
    await assert.rejects(verifyAndActivateCustomPortalDomain.run(request(OTHER_UID, { hostname: HOST })), /access denied|permission-denied/i);
    await assert.rejects(rejectCustomPortalDomain.run(request(OTHER_UID, { hostname: HOST, reason: 'because' })), /access denied|permission-denied/i);
  });

  // --- input validation ---------------------------------------------

  test('an invalid hostname is rejected before any Firestore work', async () => {
    await assert.rejects(recheckCustomPortalDomain.run(request(OWNER_UID, { hostname: 'not a host' })), /invalid hostname|invalid-argument/i);
    await assert.rejects(verifyAndActivateCustomPortalDomain.run(request(OWNER_UID, { hostname: 'nodots' })), /invalid hostname|invalid-argument/i);
    // a *.schoolpulseapp.com host is reserved for platform subdomains
    await assert.rejects(recheckCustomPortalDomain.run(request(OWNER_UID, { hostname: 'x.schoolpulseapp.com' })), /invalid hostname|invalid-argument/i);
  });

  test('a missing domain request is not-found', async () => {
    await assert.rejects(recheckCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST })), /not found|not-found/i);
    await assert.rejects(verifyAndActivateCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST })), /not found|not-found/i);
    await assert.rejects(rejectCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST, reason: 'gone' })), /not found|not-found/i);
  });

  // --- recheckCustomPortalDomain ----------------------------------

  test('recheck with a wrong/absent CNAME -> verification_failed + lastError + checkedBy', async () => {
    await seedRequest('pending');
    // cnameAnswers empty -> resolveCname throws ENOTFOUND
    const res = await recheckCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST }));
    assert.deepEqual(res, { hostname: HOST, status: 'verification_failed', cnameOk: false });

    const r = await req();
    assert.equal(r.status, 'verification_failed');
    assert.equal(r.lastError, `CNAME must point to ${TARGET}`);
    assert.equal(r.checkedBy, OWNER_UID);
    assert.ok(r.checkedAt, 'checkedAt stamped');
  });

  test('recheck with the correct CNAME -> verified, lastError cleared', async () => {
    await seedRequest('verification_failed', { lastError: 'old error' });
    cnameAnswers[HOST] = [`${TARGET}.`]; // trailing dot tolerated
    const res = await recheckCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST }));
    assert.deepEqual(res, { hostname: HOST, status: 'verified', cnameOk: true });

    const r = await req();
    assert.equal(r.status, 'verified');
    assert.equal(r.lastError, null);
    assert.equal(r.checkedBy, OWNER_UID);
  });

  test('recheck on an already-active request short-circuits without touching DNS or the doc', async () => {
    await seedRequest('active', { approvedBy: 'someone' });
    // If this hit DNS it would fail (no cnameAnswers) and flip to failed.
    const res = await recheckCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST }));
    assert.deepEqual(res, { hostname: HOST, status: 'active', cnameOk: true });
    assert.equal((await req()).status, 'active', 'unchanged');
  });

  // --- verifyAndActivateCustomPortalDomain -----------------------

  test('activate with a wrong CNAME -> sets verification_failed AND throws failed-precondition', async () => {
    await seedRequest('verified'); // even a 'verified' row is re-checked at activate time
    await assert.rejects(
      verifyAndActivateCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST })),
      /CNAME must point to|failed-precondition/i,
    );
    assert.equal((await req()).status, 'verification_failed', 're-check result persisted');
    assert.deepEqual(await auditActions(), [], 'no activation audit on a failed check');
  });

  test('activate with the correct CNAME -> portal_domains projection, request active, school.customDomains, audit', async () => {
    await seedRequest('verified');
    cnameAnswers[HOST] = [TARGET];
    const res = await verifyAndActivateCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST }));
    assert.deepEqual(res, { hostname: HOST, status: 'active' });

    const r = await req();
    assert.equal(r.status, 'active');
    assert.equal(r.approvedBy, OWNER_UID);
    assert.equal(r.lastError, null);

    const projection = (await db.doc(`portal_domains/${HOST}`).get()).data();
    assert.equal(projection.schoolId, SCHOOL_ID);
    assert.equal(projection.status, 'active');
    assert.equal(projection.hostname, HOST);
    assert.equal(projection.primaryColor, '#123456', 'branding carried onto the public projection');

    const s = (await db.doc(`schools/${SCHOOL_ID}`).get()).data();
    assert.deepEqual(s.customDomains, [HOST]);

    assert.deepEqual(await auditActions(), ['ACTIVATE_CUSTOM_PORTAL_DOMAIN']);
  });

  test('activate when the linked school no longer exists -> not-found (after DNS passes)', async () => {
    await seedRequest('verified', { schoolId: 'ghostSchool' });
    cnameAnswers[HOST] = [TARGET];
    await assert.rejects(
      verifyAndActivateCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST })),
      /School not found|not-found/i,
    );
  });

  // --- rejectCustomPortalDomain ---------------------------------

  test('reject a pending request -> rejected + reason + rejectedBy + audit', async () => {
    await seedRequest('pending');
    await rejectCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST, reason: 'Domain not owned by the school' }));
    const r = await req();
    assert.equal(r.status, 'rejected');
    assert.equal(r.rejectionReason, 'Domain not owned by the school');
    assert.equal(r.rejectedBy, OWNER_UID);
    assert.ok((await auditActions()).some((a) => /DOMAIN/i.test(a)));
  });

  test('rejecting an ACTIVE domain tears down its public projection and removes it from the school', async () => {
    await seedRequest('active');
    await db.doc(`portal_domains/${HOST}`).set({ schoolId: SCHOOL_ID, hostname: HOST, status: 'active' });
    await db.doc(`schools/${SCHOOL_ID}`).set({ customDomains: [HOST] }, { merge: true });

    await rejectCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST, reason: 'School downgraded' }));

    assert.equal((await db.doc(`portal_domains/${HOST}`).get()).exists, false, 'projection deleted');
    const s = (await db.doc(`schools/${SCHOOL_ID}`).get()).data();
    assert.deepEqual(s.customDomains, [], 'removed from school.customDomains');
    assert.equal((await req()).status, 'rejected');
  });

  test('reject with no reason still records "No reason provided"', async () => {
    await seedRequest('pending');
    await rejectCustomPortalDomain.run(request(OWNER_UID, { hostname: HOST }));
    assert.equal((await req()).rejectionReason, 'No reason provided');
  });
});
