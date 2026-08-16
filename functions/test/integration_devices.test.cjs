const test = require('node:test');
const assert = require('node:assert/strict');
const { assertOwnedByCaller, ALLOWED_STATUS } = require('../integration_devices').__test__;
const { HttpsError } = require('firebase-functions/v2/https');

test('assertOwnedByCaller allows a device that belongs to the caller school', () => {
  assert.doesNotThrow(() => assertOwnedByCaller({ institutionId: 'school_a' }, 'school_a'));
});

test('assertOwnedByCaller rejects a device belonging to another institution', () => {
  assert.throws(() => assertOwnedByCaller({ institutionId: 'school_b' }, 'school_a'), HttpsError);
});

test('assertOwnedByCaller rejects a missing device record', () => {
  assert.throws(() => assertOwnedByCaller(null, 'school_a'), HttpsError);
});

test('device status transitions are restricted to a known set', () => {
  assert.ok(ALLOWED_STATUS.has('online'));
  assert.ok(ALLOWED_STATUS.has('offline'));
  assert.ok(ALLOWED_STATUS.has('revoked'));
  assert.ok(!ALLOWED_STATUS.has('deleted'));
});

test('registerIntegrationDevice source never accepts a client-supplied institutionId', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_devices.js'), 'utf8');
  assert.doesNotMatch(source, /institutionId:\s*d\.institutionId/);
  assert.doesNotMatch(source, /institutionId:\s*request\.data\.institutionId/);
});

test('integration_devices source stores no secret/credential fields', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_devices.js'), 'utf8');
  assert.doesNotMatch(source, /apiKey\s*:/i);
  assert.doesNotMatch(source, /credentialReference\s*:/i);
  assert.doesNotMatch(source, /secret\s*:/i);
});
