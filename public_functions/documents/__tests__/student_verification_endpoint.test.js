const assert = require('node:assert/strict');
const admin = require('firebase-admin');
if (!admin.apps.length) admin.initializeApp({ projectId: 'school-pulse-test' });
const { __test__ } = require('../student_verification_endpoint');

// Token format guard - cheap DoS defense before any Firestore read.
assert.equal(__test__.TOKEN_PATTERN.test('SPQR1.' + 'a'.repeat(43)), true);
assert.equal(__test__.TOKEN_PATTERN.test('not-a-token'), false);
assert.equal(__test__.TOKEN_PATTERN.test('SPQR1.short'), false);
assert.equal(__test__.TOKEN_PATTERN.test("SPQR1.'; DROP TABLE students;--"), false);

assert.equal(__test__.token('  abc  '), 'abc');

assert.deepEqual(__test__.statusLabel('active'), { valid: true, label: 'Valid credential' });
assert.equal(__test__.statusLabel('revoked').valid, false);
assert.equal(__test__.statusLabel('lost').valid, false);
assert.equal(__test__.statusLabel('stolen').valid, false);
assert.equal(__test__.statusLabel('replaced').valid, false);
assert.equal(__test__.statusLabel('unknown-status').valid, false);

// The rendered page must never leak anything beyond the documented safe
// field set, even when passed a valid result - guards against a future
// edit accidentally interpolating a new field into the template.
const validHtml = __test__.page({
  valid: true,
  statusText: 'Valid credential',
  name: 'Jane Doe',
  schoolName: 'Test School',
  level: 'P6',
  photoUrl: '',
  logoUrl: '',
});
assert.match(validHtml, /Jane Doe/);
assert.match(validHtml, /Valid credential/);
assert.doesNotMatch(validHtml, /parent|fee|balance|mark|attendance|medical|discipline|SPQR1/i);

const invalidHtml = __test__.page({ valid: false, statusText: 'Card not verified' });
assert.doesNotMatch(invalidHtml, /Firestore|credentialValue|studentId|token/i);

// resolveStudentCredential against the emulator/no-network default client
// short-circuits on the format guard without ever touching Firestore.
(async () => {
  const result = await __test__.resolveStudentCredential('garbage');
  assert.equal(result, null);
  console.log('Student credential verification endpoint: 12 passed');
})();
