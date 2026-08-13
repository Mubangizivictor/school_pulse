// Plain Node test runner (no framework dependency), matching this
// directory's existing convention. verifyGoogleIdToken's real path makes a
// network call (Google's token verification infrastructure) this repo has
// no mocking/emulator harness for, so that part is covered structurally.
// verifyOwnerPassword's behavior IS fully testable by mocking the global
// `fetch` it calls - no real network dependency in the function itself,
// just an HTTP call this test can intercept.
// Run with: node __tests__/owner_first_factor_verify.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  }
}

async function asyncTest(name, fn) {
  try {
    await fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  }
}

function moduleSource() {
  return fs.readFileSync(path.join(__dirname, '..', 'owner_first_factor_verify.js'), 'utf8');
}

function withMockedFetch(response, fn) {
  const originalFetch = global.fetch;
  global.fetch = async () => response;
  try {
    return fn();
  } finally {
    global.fetch = originalFetch;
  }
}

function jsonResponse(ok, body) {
  return { ok, json: async () => body };
}

async function run() {
  // Re-require fresh each time within a mocked-fetch scope, since the
  // module captures `fetch` as a free variable (global) rather than an
  // injected dependency - requiring it once at top level would bind to
  // whichever fetch was global at that moment. Node's require cache means
  // we only need one require; global.fetch is swapped around each call
  // instead of the module itself.
  const { verifyOwnerPassword, verifyGoogleIdToken } = require('../owner_first_factor_verify');

  console.log('verifyOwnerPassword() - MFA-pending evidence checking');

  await asyncTest('a non-ok response (wrong password) returns localId: null, mfaEnrolled: false, mfaAnomaly: false', async () => {
    const result = await withMockedFetch(jsonResponse(false, { error: { message: 'INVALID_LOGIN_CREDENTIALS' } }), () =>
      verifyOwnerPassword('owner@example.com', 'wrong-password')
    );
    assert.deepEqual(result, { localId: null, mfaEnrolled: false, mfaAnomaly: false });
  });

  await asyncTest('CRITICAL: a 200 response with a correct localId but NO mfaPendingCredential/mfaInfo is flagged as mfaAnomaly, not treated as a normal success', async () => {
    const result = await withMockedFetch(
      jsonResponse(true, { localId: 'owner-uid-123', email: 'owner@example.com' }),
      () => verifyOwnerPassword('owner@example.com', 'correct-password')
    );
    assert.equal(result.localId, 'owner-uid-123');
    assert.equal(result.mfaEnrolled, false);
    assert.equal(result.mfaAnomaly, true, 'a correct password for an MFA-required account with no MFA signal must be flagged as an anomaly');
  });

  await asyncTest('a correct password WITH mfaPendingCredential + non-empty mfaInfo is accepted as mfaEnrolled, not an anomaly', async () => {
    const result = await withMockedFetch(
      jsonResponse(true, {
        localId: 'owner-uid-123',
        email: 'owner@example.com',
        mfaPendingCredential: 'opaque-proof-token-not-a-real-secret-in-this-test',
        mfaInfo: [{ mfaEnrollmentId: 'totp-1' }],
      }),
      () => verifyOwnerPassword('owner@example.com', 'correct-password')
    );
    assert.equal(result.localId, 'owner-uid-123');
    assert.equal(result.mfaEnrolled, true);
    assert.equal(result.mfaAnomaly, false);
  });

  await asyncTest('mfaInfo present but EMPTY array is still treated as no real MFA signal (anomaly), not accepted', async () => {
    const result = await withMockedFetch(
      jsonResponse(true, {
        localId: 'owner-uid-123',
        mfaPendingCredential: 'opaque-token',
        mfaInfo: [],
      }),
      () => verifyOwnerPassword('owner@example.com', 'correct-password')
    );
    assert.equal(result.mfaEnrolled, false);
    assert.equal(result.mfaAnomaly, true);
  });

  await asyncTest('mfaPendingCredential present but mfaInfo missing entirely is still an anomaly (requires BOTH signals)', async () => {
    const result = await withMockedFetch(
      jsonResponse(true, { localId: 'owner-uid-123', mfaPendingCredential: 'opaque-token' }),
      () => verifyOwnerPassword('owner@example.com', 'correct-password')
    );
    assert.equal(result.mfaAnomaly, true);
  });

  console.log('\nverifyGoogleIdToken() - fails closed with no configured audience');

  await asyncTest('rejects with no audience list at all (undefined)', async () => {
    await assert.rejects(() => verifyGoogleIdToken('any-token', undefined));
  });

  await asyncTest('rejects with an empty audience array - MUST NOT silently accept any validly-signed token', async () => {
    await assert.rejects(() => verifyGoogleIdToken('any-token', []));
  });

  console.log('\nSource-level safety checks');

  test('verifyOwnerPassword never writes the password to Firestore/logs - only sends it in the fetch body to Identity Toolkit', () => {
    const source = moduleSource();
    const fnStart = source.indexOf('async function verifyOwnerPassword');
    const fnBody = source.slice(fnStart, source.indexOf('\nasync function', fnStart + 40));
    assert.ok(!fnBody.includes('console.log') && !fnBody.includes('console.error'), 'must never log anything inside verifyOwnerPassword (could leak the password via arguments)');
    assert.ok(!fnBody.includes('.collection('), 'must never write to Firestore inside verifyOwnerPassword');
    assert.ok(fnBody.includes('body: JSON.stringify({ email, password'), 'must send the password only in the Identity Toolkit request body');
  });

  test('verifyOwnerPassword uses the real Identity Toolkit signInWithPassword REST endpoint, not a custom/invented one', () => {
    const source = moduleSource();
    assert.ok(source.includes('identitytoolkit.googleapis.com/v1/accounts:signInWithPassword'), 'must call the documented Identity Toolkit endpoint');
  });

  test('verifyOwnerPassword never returns mfaPendingCredential itself to its caller - only booleans derived from its presence', () => {
    const source = moduleSource();
    const fnStart = source.indexOf('async function verifyOwnerPassword');
    const fnBody = source.slice(fnStart, source.indexOf('\nasync function', fnStart + 40));
    // The only place mfaPendingCredential's VALUE is touched is a typeof
    // check; it must never appear in a returned object literal.
    const returnStatements = fnBody.match(/return \{[^}]*\}/g) || [];
    for (const stmt of returnStatements) {
      assert.ok(!stmt.includes('mfaPendingCredential'), `mfaPendingCredential must never appear in a return value: ${stmt}`);
    }
  });

  test('verifyGoogleIdToken uses google-auth-library\'s OAuth2Client.verifyIdToken - the officially documented Google ID token verification mechanism', () => {
    const source = moduleSource();
    assert.ok(source.includes("require('google-auth-library')"), 'must use google-auth-library');
    assert.ok(source.includes('oauth2Client.verifyIdToken'), 'must call verifyIdToken');
  });

  test('verifyGoogleIdToken requires email_verified before returning an identity', () => {
    const source = moduleSource();
    const fnStart = source.indexOf('async function verifyGoogleIdToken');
    const fnBody = source.slice(fnStart, source.indexOf('\n}', fnStart + 40));
    assert.ok(fnBody.includes('payload.email_verified'), 'must check email_verified on the token payload');
  });

  console.log(`\n${passed} passed, ${failed} failed`);
  if (failed > 0) process.exit(1);
}

run();
