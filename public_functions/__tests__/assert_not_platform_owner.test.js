// Plain Node test runner (no framework dependency), matching the
// convention already used across public_functions/__tests__. The actual
// UID-vs-seed logic is covered behaviorally (fake Firestore, no emulator)
// by shared/owner-auth/__tests__/requirePlatformOwner.test.js, since
// `assertNotPlatformOwner` is a thin onCall wrapper around
// rejectIfPlatformOwner() from that same canonical package. This file only
// proves the wrapper itself is wired correctly: real auth requirement, real
// rate limiting, and delegation to the canonical (never re-implemented)
// check - structurally, since exercising a live `onCall` handler here would
// require a real/emulated Firestore + Admin SDK this test suite otherwise
// avoids.
// Run with: node __tests__/assert_not_platform_owner.test.js
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

const source = fs.readFileSync(path.join(__dirname, '..', 'owner_auth.js'), 'utf8');

function extractFunctionBody(exportName) {
  const start = source.indexOf(`exports.${exportName} = onCall(`);
  assert.ok(start !== -1, `exports.${exportName} not found in owner_auth.js`);
  const nextExportIdx = source.indexOf('\nexports.', start + 1);
  return nextExportIdx === -1 ? source.slice(start) : source.slice(start, nextExportIdx);
}

console.log('assertNotPlatformOwner - onCall wrapper wiring');

test('is deployed to europe-west1, same region as assertPlatformOwnerAccess and every other owner-auth callable', () => {
  const body = extractFunctionBody('assertNotPlatformOwner');
  assert.ok(body.includes("region: 'europe-west1'"), 'must be deployed to europe-west1');
});

test('rejects an unauthenticated caller before touching Firestore', () => {
  const body = extractFunctionBody('assertNotPlatformOwner');
  assert.ok(body.includes('request.auth?.uid'), 'must read the authenticated UID from request.auth');
  assert.ok(body.includes("'unauthenticated'"), 'must throw unauthenticated for a missing UID');
});

test('is rate-limited per authenticated UID, like assertPlatformOwnerAccess', () => {
  const body = extractFunctionBody('assertNotPlatformOwner');
  assert.ok(body.includes('ownerRateLimit(uid,'), 'must call ownerRateLimit keyed on the caller UID');
});

test('delegates to the canonical rejectIfPlatformOwner() from the vendored shared package - never re-implements the UID/seed comparison inline', () => {
  const body = extractFunctionBody('assertNotPlatformOwner');
  assert.ok(body.includes('await rejectIfPlatformOwner('), 'must call rejectIfPlatformOwner');
  assert.ok(!body.includes('seed.ownerUid'), 'must not re-implement the seed-UID comparison inline');
});

test('translates OwnerAuthorizationError into HttpsError, matching assertPlatformOwnerAccess error-shape conventions', () => {
  const body = extractFunctionBody('assertNotPlatformOwner');
  assert.ok(body.includes('instanceof OwnerAuthorizationError'), 'must catch and translate OwnerAuthorizationError');
  assert.ok(body.includes('new HttpsError(error.code, error.message)'), 'must preserve the shared package\'s error code/message');
});

test('owner_auth.js imports rejectIfPlatformOwner from the same vendored package requirePlatformOwner already uses', () => {
  assert.ok(
    source.includes('rejectIfPlatformOwner') && source.includes("require('./vendor/owner-auth')"),
    'must import rejectIfPlatformOwner from the vendored shared package, not a local reimplementation'
  );
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
