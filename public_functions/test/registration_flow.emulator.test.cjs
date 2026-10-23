// Firebase Emulator end-to-end test of the school registration backend flow
// the /register-school wizard drives:
//   sign up -> verification email -> verify link -> submit -> duplicate refused
//   -> status = pending_review -> "received" email -> owner approves
//   -> 30-day trial school -> "approved" email.
//
// Handlers are run in-process (not through the Functions emulator): inside the
// Functions emulator admin.firestore.FieldValue is undefined (emulator shim),
// which is fine in plain Node and in production.
// Emails are only queued here; real delivery through Resend is not exercised.
// Firestore + Auth (+ Storage) emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth,storage \
//     --project demo-registration-flow-test \
//     "node --test test/registration_flow.emulator.test.cjs"
const { before, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-registration-flow-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';
process.env.FIREBASE_STORAGE_EMULATOR_HOST =
  process.env.FIREBASE_STORAGE_EMULATOR_HOST || '127.0.0.1:9199';
process.env.FIREBASE_CONFIG = JSON.stringify({
  projectId,
  storageBucket: `${projectId}.appspot.com`,
});

const admin = require('firebase-admin');
admin.initializeApp({ projectId, storageBucket: `${projectId}.appspot.com` });
const db = admin.firestore();

const pub = require('../index.js');
const ev = require('../email_verification.js');
const pay = require('../payments.js');
const own = require('../owner.js');
const notif = require('../application_notifications.js');

const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const AUTH = `http://${authHost}/identitytoolkit.googleapis.com/v1`;

const ownerEmail = 'owner@schoolpulse.example';
const ownerPassword = 'Own3r!Passw0rd';
const email = 'jane.namono@sunrisehigh.example';
const password = 'Str0ng!Passw0rd';

const post = (path, body) =>
  fetch(`${AUTH}/${path}?key=x`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  }).then((r) => r.json());

// Minimal Express-style req/res double for the onRequest handlers.
function http(fn, { method = 'POST', token, body } = {}) {
  return new Promise((resolve) => {
    const h = { origin: 'http://localhost:5055' };
    if (token) h.authorization = `Bearer ${token}`;
    const req = {
      method,
      headers: h,
      body: body || {},
      ip: '1.2.3.4',
      get: (k) => h[k.toLowerCase()],
      query: {},
    };
    const res = {
      code: 200,
      headers: {},
      set(k, v) {
        this.headers[k] = v;
        return this;
      },
      status(c) {
        this.code = c;
        return this;
      },
      json(o) {
        resolve({ ...o, status: this.code, appStatus: o.status });
      },
      send() {
        resolve({ status: this.code });
      },
      end() {
        resolve({ status: this.code });
      },
    };
    Promise.resolve(fn(req, res)).catch((e) =>
      resolve({ status: 500, thrown: String(e) }),
    );
  });
}

// "<templateId> -> <to>" for every doc in any email queue collection.
async function queuedMails() {
  const out = [];
  for (const { id } of await db.listCollections()) {
    if (!/queue|mail/i.test(id) || /rate/.test(id)) continue;
    (await db.collection(id).get()).docs.forEach((d) =>
      out.push(`${d.data().templateId} -> ${d.data().to}`),
    );
  }
  return out;
}

const body = {
  school: {
    name: 'Sunrise High School',
    shortName: 'SHS',
    email: 'school@sunrisehigh.example',
    phone: '0771234567',
    category: 'Private',
    prefix: 'SHS',
    studentCapacity: 650,
    slug: 'sunrise-high',
  },
  location: {
    region: 'Central',
    district: 'Kampala',
    address: 'Kampala, Central Region, Uganda',
    locationName: 'Kampala',
  },
  plan: 'Growth',
  selectedModules: ['Students', 'Attendance', 'Academics', 'Administration'],
  administrator: {
    firstName: 'Jane',
    lastName: 'Namono',
    gender: 'Female',
    phone: '0779876543',
    email,
    username: 'admin',
  },
  marketingOptIn: false,
  termsAccepted: true,
};

describe('school registration flow', () => {
  const s = {};

  before(async () => {
    const owner = await post('accounts:signUp', {
      email: ownerEmail,
      password: ownerPassword,
      returnSecureToken: true,
    });
    s.ownerUid = owner.localId;
    await db.doc('platform_config/owner_seed').set({
      seeded: true,
      ownerUid: owner.localId,
    });
    await db.doc(`users/${owner.localId}`).set({
      role: 'superAdmin',
      roles: ['superAdmin'],
      isActive: true,
      email: ownerEmail,
    });
  });

  test('wizard step 2 creates the applicant account', async () => {
    const u = await post('accounts:signUp', {
      email,
      password,
      returnSecureToken: true,
    });
    assert.ok(u.idToken);
    s.uid = u.localId;
    s.unverifiedToken = u.idToken;
  });

  test('an unverified account cannot submit', async () => {
    const r = await http(pub.submitSchoolApplication, {
      token: s.unverifiedToken,
      body,
    });
    assert.equal(r.status, 401);
  });

  test('verification email is queued and the link verifies the account', async () => {
    const r = await http(ev.requestEmailVerification, {
      token: s.unverifiedToken,
    });
    assert.equal(r.status, 200);
    assert.ok((await queuedMails()).some((m) => m.startsWith('email_verification')));

    const oob = await (
      await fetch(`http://${authHost}/emulator/v1/projects/${projectId}/oobCodes`)
    ).json();
    const code = oob.oobCodes
      .filter((o) => o.requestType === 'VERIFY_EMAIL' && o.email === email)
      .pop();
    assert.ok(code, 'verification link generated');
    await fetch(code.oobLink);

    const signedIn = await post('accounts:signInWithPassword', {
      email,
      password,
      returnSecureToken: true,
    });
    s.token = signedIn.idToken;
    assert.equal((await admin.auth().verifyIdToken(s.token)).email_verified, true);
  });

  test('submit succeeds once, then a duplicate is refused', async () => {
    let r = await http(pub.submitSchoolApplication, { token: s.token, body });
    assert.equal(r.status, 201, JSON.stringify(r));
    r = await http(pub.submitSchoolApplication, { token: s.token, body });
    assert.equal(r.status, 409);
  });

  test('status page shows pending_review and the application is stored', async () => {
    const r = await http(pub.getSchoolApplicationStatus, {
      method: 'GET',
      token: s.token,
    });
    assert.equal(r.status, 200);
    assert.equal(r.appStatus, 'pending_review');
    assert.equal(r.schoolName, 'Sunrise High School');

    s.app = (await db.doc(`public_school_applications/${s.uid}`).get()).data();
    assert.equal(s.app.status, 'pending_review');
    assert.equal(s.app.requiresCapacityReview, false);
  });

  const fire = (before, after) =>
    notif.notifyOwnerOfSchoolApplication.run({
      params: { applicationId: s.uid },
      data: {
        before: { exists: !!before, data: () => before },
        after: { exists: true, data: () => after },
      },
    });

  test('the applicant gets an application_received email', async () => {
    await fire(null, s.app);
    assert.ok(
      (await queuedMails()).some((m) =>
        m.startsWith(`application_received -> ${email}`),
      ),
    );
  });

  test('owner sees the application and approves it into a 30-day trial', async () => {
    const call = { auth: { uid: s.ownerUid, token: {} } };
    const list = await own.getSchoolApplicationsForOwner.run({ ...call, data: {} });
    assert.equal(list.applications.length, 1);
    assert.equal(list.applications[0].status, 'pending_review');

    await pay.approveSchoolApplication.run({
      ...call,
      data: { applicationId: s.uid },
    });
    s.approved = (
      await db.doc(`public_school_applications/${s.uid}`).get()
    ).data();
    assert.equal(s.approved.status, 'approved');

    const schools = await db.collection('schools').get();
    assert.equal(schools.size, 1);
    const school = schools.docs[0].data();
    assert.equal(school.status, 'trial');
    const days = Math.round((school.subscriptionExpiry - Date.now()) / 864e5);
    assert.ok(days >= 29, `trial length ${days} days`);
  });

  test('the applicant gets an application_approved email', async () => {
    await fire(s.app, s.approved);
    assert.ok(
      (await queuedMails()).some((m) =>
        m.startsWith(`application_approved -> ${email}`),
      ),
    );
  });
});
