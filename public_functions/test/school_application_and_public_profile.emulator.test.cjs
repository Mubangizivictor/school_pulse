// Firebase Emulator integration tests covering:
//   - exports.submitSchoolApplication (public_functions/index.js), an
//     onRequest (plain Express-style) endpoint — invoked directly as a
//     function(req, res) with a minimal mock req/res, since onRequest
//     CloudFunction objects don't expose a .run() helper the way onCall
//     ones do (see portal_domains_lifecycle.emulator.test.cjs for that
//     convention; this file adapts it for the REST shape instead).
//   - exports.getPublicSchoolProfile (public_functions/portal_domains.js),
//     a public unauthenticated onCall added for the v1 branded school page,
//     invoked via .run() the normal way.
//
// Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-school-application-public-profile-test \
//     "node --test test/school_application_and_public_profile.emulator.test.cjs"
const { after, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-school-application-public-profile-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const { submitSchoolApplication } = require('../index');
const { getPublicSchoolProfile } = require('../portal_domains');

const admin = require('firebase-admin');
const db = admin.firestore();
const auth = admin.auth();

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map(del));
}
async function del(ref) {
  const docs = await ref.listDocuments();
  await Promise.all(docs.map(async (d) => {
    const subs = await d.listCollections();
    await Promise.all(subs.map(del));
    await d.delete();
  }));
}
async function clearAuthUsers() {
  const list = await auth.listUsers(1000);
  await Promise.all(list.users.map((u) => auth.deleteUser(u.uid).catch(() => {})));
}

// Mock req/res for the onRequest handler. submitSchoolApplication reads
// req.method, req.get(header), req.ip, req.body — and calls res.status(n)
// .json(obj) exactly once per path. We capture the final status/body pair.
function mockRes() {
  const res = { statusCode: null, body: null };
  res.status = (code) => { res.statusCode = code; return res; };
  res.json = (obj) => { res.body = obj; return res; };
  res.set = () => res;
  res.send = (obj) => { res.body = obj; return res; };
  return res;
}
function mockReq({ method = 'POST', token = null, body = {}, ip = '127.0.0.1' } = {}) {
  return {
    method,
    ip,
    body,
    get(header) {
      const h = String(header).toLowerCase();
      if (h === 'authorization') return token ? `Bearer ${token}` : undefined;
      if (h === 'origin') return undefined;
      return undefined;
    },
  };
}

function validBody(overrides = {}) {
  return {
    school: {
      name: 'Sunrise High School',
      shortName: 'SHS',
      email: 'school@sunrisehigh.example',
      phone: '0771234567',
      category: 'Private',
      prefix: 'SHS',
      studentCapacity: 650,
      slug: 'sunrise-high',
      ...(overrides.school || {}),
    },
    location: {
      region: 'Central',
      district: 'Kampala',
      address: 'Kampala, Central Region, Uganda',
      locationName: 'Kampala',
      ...(overrides.location || {}),
    },
    plan: overrides.plan ?? 'Growth',
    selectedModules: ['Students', 'Attendance', 'Academics', 'Administration'],
    administrator: {
      firstName: 'Jane',
      lastName: 'Namono',
      gender: 'Female',
      phone: '0779876543',
      email: overrides.identityEmail || 'admin@sunrisehigh.example',
      username: 'admin',
      ...(overrides.administrator || {}),
    },
    marketingOptIn: false,
    termsAccepted: overrides.termsAccepted ?? true,
  };
}

async function createVerifiedUser(email) {
  const user = await auth.createUser({ email, emailVerified: true });
  const token = await auth.createCustomToken(user.uid);
  // createCustomToken produces a custom token, not an ID token — the
  // emulator's verifyIdToken only accepts real ID tokens. We instead mint
  // an ID token directly via the Auth emulator's REST sign-in-with-custom
  // token exchange, matching how the client SDK would end up with one.
  const host = process.env.FIREBASE_AUTH_EMULATOR_HOST;
  const resp = await fetch(
    `http://${host}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=fake-api-key`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token, returnSecureToken: true }),
    }
  );
  const json = await resp.json();
  return { uid: user.uid, idToken: json.idToken };
}
async function createUnverifiedUser(email) {
  const user = await auth.createUser({ email, emailVerified: false });
  const token = await auth.createCustomToken(user.uid);
  const host = process.env.FIREBASE_AUTH_EMULATOR_HOST;
  const resp = await fetch(
    `http://${host}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=fake-api-key`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token, returnSecureToken: true }),
    }
  );
  const json = await resp.json();
  return { uid: user.uid, idToken: json.idToken };
}

describe('submitSchoolApplication (onRequest)', () => {
  beforeEach(async () => {
    await clearFirestore();
    await clearAuthUsers();
  });
  after(async () => {
    await clearFirestore();
    await clearAuthUsers();
  });

  test('rejects when no Bearer token is present', async () => {
    const req = mockReq({ body: validBody() });
    const res = mockRes();
    await submitSchoolApplication(req, res);
    assert.equal(res.statusCode, 401);
    assert.equal(res.body.error, 'verified_auth_required');
  });

  test('rejects an unverified-email token', async () => {
    const email = 'unverified-admin@example.com';
    const { idToken } = await createUnverifiedUser(email);
    const req = mockReq({ token: idToken, body: validBody({ identityEmail: email }) });
    const res = mockRes();
    await submitSchoolApplication(req, res);
    assert.equal(res.statusCode, 401);
    assert.equal(res.body.error, 'verified_auth_required');
  });

  test('rejects a reserved slug', async () => {
    const email = 'admin-reserved@example.com';
    const { idToken } = await createVerifiedUser(email);
    const req = mockReq({
      token: idToken,
      body: validBody({ identityEmail: email, school: { slug: 'admin' } }),
    });
    const res = mockRes();
    await submitSchoolApplication(req, res);
    assert.equal(res.statusCode, 400);
    assert.equal(res.body.error, 'invalid_application');
  });

  test('rejects a plan value outside the allowed enum', async () => {
    const email = 'admin-badplan@example.com';
    const { idToken } = await createVerifiedUser(email);
    const req = mockReq({
      token: idToken,
      body: validBody({ identityEmail: email, plan: 'Standard' }),
    });
    const res = mockRes();
    await submitSchoolApplication(req, res);
    assert.equal(res.statusCode, 400);
    assert.equal(res.body.error, 'invalid_application');
  });

  test('succeeds with a fully valid payload and creates the expected doc shape', async () => {
    const email = 'admin-valid@example.com';
    const { uid, idToken } = await createVerifiedUser(email);
    const req = mockReq({
      token: idToken,
      body: validBody({ identityEmail: email, school: { slug: 'valid-school-1' } }),
    });
    const res = mockRes();
    await submitSchoolApplication(req, res);
    assert.equal(res.statusCode, 201);
    assert.equal(res.body.ok, true);
    assert.equal(res.body.applicationId, uid);
    assert.equal(res.body.status, 'pending_review');
    assert.equal(res.body.slug, 'valid-school-1');

    const doc = await db.doc(`public_school_applications/${uid}`).get();
    assert.equal(doc.exists, true);
    const data = doc.data();
    assert.equal(data.status, 'pending_review');
    assert.equal(data.school.slug, 'valid-school-1');
    assert.equal(data.school.prefix, 'SHS');
    assert.equal(data.administrator.email, email);
    assert.equal(data.administrator.emailVerified, true);
  });

  test('rejects a duplicate slug across two applications', async () => {
    const email1 = 'admin-dup1@example.com';
    const { idToken: token1 } = await createVerifiedUser(email1);
    const req1 = mockReq({
      token: token1,
      body: validBody({ identityEmail: email1, school: { slug: 'dup-slug' } }),
    });
    const res1 = mockRes();
    await submitSchoolApplication(req1, res1);
    assert.equal(res1.statusCode, 201);

    const email2 = 'admin-dup2@example.com';
    const { idToken: token2 } = await createVerifiedUser(email2);
    const req2 = mockReq({
      token: token2,
      body: validBody({
        identityEmail: email2,
        school: { slug: 'dup-slug', prefix: 'OTH', email: 'other@school.example', phone: '0700111222' },
        administrator: { phone: '0700333444' },
      }),
    });
    const res2 = mockRes();
    await submitSchoolApplication(req2, res2);
    assert.equal(res2.statusCode, 409);
    assert.equal(res2.body.error, 'slug_in_use');
  });
});

describe('getPublicSchoolProfile (onCall)', () => {
  beforeEach(async () => {
    await clearFirestore();
  });
  after(async () => {
    await clearFirestore();
  });

  test('returns only public-safe fields for an active school', async () => {
    await db.doc('portal_domains/brightpath.schoolpulseapp.com').set({
      schoolId: 'schoolX',
      slug: 'brightpath',
      hostname: 'brightpath.schoolpulseapp.com',
      status: 'active',
      schoolName: 'Bright Path Academy',
      logoUrl: 'https://example.com/logo.png',
      primaryColor: '#112233',
      secondaryColor: '#445566',
      address: '123 Main Street, Kampala',
      phone: '0771234567',
      email: 'info@brightpath.example',
    });
    const result = await getPublicSchoolProfile.run({ auth: null, data: { slug: 'brightpath' } });
    assert.equal(result.found, true);
    assert.equal(result.schoolName, 'Bright Path Academy');
    assert.equal(result.address, '123 Main Street, Kampala');
    assert.equal(result.phone, '0771234567');
    assert.equal(result.email, 'info@brightpath.example');
    // Only the documented public-safe keys — nothing else leaks through
    // (no schoolId, no domainStatus, no subscription/financial info).
    const allowedKeys = new Set([
      'found', 'slug', 'schoolName', 'logoUrl', 'primaryColor',
      'secondaryColor', 'address', 'phone', 'email',
    ]);
    for (const key of Object.keys(result)) {
      assert.ok(allowedKeys.has(key), `unexpected key leaked: ${key}`);
    }
  });

  test('returns found:false for an unknown slug', async () => {
    const result = await getPublicSchoolProfile.run({ auth: null, data: { slug: 'does-not-exist-school' } });
    assert.equal(result.found, false);
  });

  test('returns found:false for a suspended school (status hidden, not leaked)', async () => {
    await db.doc('portal_domains/suspended.schoolpulseapp.com').set({
      slug: 'suspended', hostname: 'suspended.schoolpulseapp.com',
      status: 'suspended', schoolName: 'Suspended School',
    });
    const result = await getPublicSchoolProfile.run({ auth: null, data: { slug: 'suspended' } });
    assert.equal(result.found, false);
  });

  test('returns found:false when neither slug nor hostname is given', async () => {
    const result = await getPublicSchoolProfile.run({ auth: null, data: {} });
    assert.equal(result.found, false);
  });
});
