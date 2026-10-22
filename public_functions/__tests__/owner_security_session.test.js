// Plain Node test runner (no framework dependency), matching this
// directory's existing convention. Covers the pure isSessionValid
// predicate - the exact conditions under which the unified
// OwnerSecuritySession is treated as valid - plus structural checks that
// establish/validate/revoke are wired correctly. No Firestore-emulator
// harness exists in this repo, so actual Admin SDK/Firestore transaction
// behavior is not exercised here.
// Run with: node __tests__/owner_security_session.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { isSessionValid, VALID_METHODS, SESSION_TTL_MS } = require('../owner_security_session').__test__;

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

const OWNER_UID = 'owner-uid-123';
const OTHER_UID = 'some-other-account-uid';
const NOW = 1_700_000_000_000;

function freshSession(overrides = {}) {
  return {
    ownerUid: OWNER_UID,
    revoked: false,
    expiresAt: { toMillis: () => NOW + 60_000 },
    ...overrides,
  };
}

console.log('isSessionValid()');

test('a fresh, unrevoked, unexpired session for the right owner is valid', () => {
  assert.equal(isSessionValid(freshSession(), OWNER_UID, NOW), true);
});

test('a null/missing session is rejected', () => {
  assert.equal(isSessionValid(null, OWNER_UID, NOW), false);
});

test('a session belonging to a DIFFERENT owner UID is rejected', () => {
  assert.equal(isSessionValid(freshSession({ ownerUid: OTHER_UID }), OWNER_UID, NOW), false);
});

test('CRITICAL: a revoked session is rejected even if not yet expired - revocation must take effect immediately', () => {
  assert.equal(isSessionValid(freshSession({ revoked: true }), OWNER_UID, NOW), false);
});

test('an expired session is rejected', () => {
  const expired = freshSession({ expiresAt: { toMillis: () => NOW - 1 } });
  assert.equal(isSessionValid(expired, OWNER_UID, NOW), false);
});

test('a session expiring exactly at the current instant is still accepted', () => {
  const atBoundary = freshSession({ expiresAt: { toMillis: () => NOW } });
  assert.equal(isSessionValid(atBoundary, OWNER_UID, NOW), true);
});

test('a plain numeric expiresAt (not a Firestore Timestamp-like object) is also handled', () => {
  const plainNumber = freshSession({ expiresAt: NOW + 60_000 });
  assert.equal(isSessionValid(plainNumber, OWNER_UID, NOW), true);
});

console.log('\nSession model constants');

test('exactly four converged authentication methods are recognized: password_totp, google_totp, apple_totp, recovery_code', () => {
  assert.deepEqual([...VALID_METHODS].sort(), ['apple_totp', 'google_totp', 'password_totp', 'recovery_code']);
});

test('session TTL is null - valid until explicit sign-out/revoke, not time-limited', () => {
  assert.equal(SESSION_TTL_MS, null);
});

test('a null expiresAt (no TTL) never expires', () => {
  const noTtl = freshSession({ expiresAt: null });
  assert.equal(isSessionValid(noTtl, OWNER_UID, NOW), true);
  assert.equal(isSessionValid(noTtl, OWNER_UID, NOW + 999 * 24 * 60 * 60 * 1000), true);
});

console.log('\nSource-level safety checks');

function moduleSource() {
  return fs.readFileSync(path.join(__dirname, '..', 'owner_security_session.js'), 'utf8');
}

test('establishOwnerSecuritySession requires the authoritative requireOwner() check before creating any session', () => {
  const source = moduleSource();
  const fnStart = source.indexOf('exports.establishOwnerSecuritySession');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  assert.ok(fnBody.includes('await requireOwner(request)'), 'must call requireOwner before establishing a session');
  // The session's authenticationMethod must be validated against a known
  // set, not accepted verbatim from the client.
  assert.ok(fnBody.includes('VALID_METHODS.has(authenticationMethod)'), 'must validate authenticationMethod against a known set');
});

test('validateOwnerSecuritySession requires requireOwner() too - a session ID alone is never sufficient without a live authenticated+asserted caller', () => {
  const source = moduleSource();
  const fnStart = source.indexOf('exports.validateOwnerSecuritySession');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  assert.ok(fnBody.includes('await requireOwner(request)'), 'must call requireOwner before validating any session');
  assert.ok(fnBody.includes('isSessionValid(') && fnBody.includes('owner.uid'), 'must check the session against the CALLER\'s own owner.uid, not a client-supplied one');
});

test('validateOwnerSecuritySession never returns sensitive fields - only safe booleans/labels', () => {
  const source = moduleSource();
  const fnStart = source.indexOf('exports.validateOwnerSecuritySession');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  for (const forbidden of ['password', 'customToken', 'idToken', 'mfaPendingCredential', 'nonceHash']) {
    assert.ok(!fnBody.includes(forbidden), `must never reference ${forbidden} in validateOwnerSecuritySession`);
  }
});

test('revokeAllOwnerSecuritySessions is exported for revokeOwnerSessions to call, and revokeOwnerSessions actually calls it', () => {
  const source = moduleSource();
  assert.ok(source.includes('exports.revokeAllOwnerSecuritySessions = revokeAllOwnerSecuritySessions;'));

  const eventsSource = fs.readFileSync(path.join(__dirname, '..', 'owner_sign_in_events.js'), 'utf8');
  assert.ok(eventsSource.includes('revokeAllOwnerSecuritySessions'), 'revokeOwnerSessions must invalidate OwnerSecuritySession records too, not just Firebase refresh tokens');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
