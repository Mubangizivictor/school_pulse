const assert = require('node:assert/strict');
const test = require('node:test');

// Mirrors support_audit.test.cjs's approach: exercise the pure, credential-
// free parts of the factory (allow-list + redaction) without requiring
// emulator/Admin SDK credentials.
const moduleFactory = require('../enrollment_audit');
const admin = { firestore: () => ({}) };
const api = moduleFactory({
  admin,
  onCall: (handler) => handler,
  HttpsError: class extends Error {},
});

test('enrollment audit action allow-list only accepts known actions', () => {
  assert.ok(api.__test__.allowedActions.has('admission_approved'));
  assert.ok(api.__test__.allowedActions.has('enrollment_activated'));
  assert.ok(api.__test__.allowedActions.has('enrollment_bursary_assigned'));
  assert.ok(!api.__test__.allowedActions.has('made_up_action'));
});

test('enrollment audit action allow-list includes the Identity tab actions '
  + 'added for the credential lifecycle redesign', () => {
  assert.ok(api.__test__.allowedActions.has('identity_school_id_previewed'));
  assert.ok(api.__test__.allowedActions.has('identity_nfc_replaced'));
  assert.ok(api.__test__.allowedActions.has('identity_nfc_revoked'));
  assert.ok(api.__test__.allowedActions.has('identity_nfc_reactivated'));
  assert.ok(api.__test__.allowedActions.has('identity_qr_replaced'));
  // Issue/assign cases reuse the existing enrollment_* ids rather than
  // duplicating near-identical new ones.
  assert.ok(!api.__test__.allowedActions.has('identity_nfc_assigned'));
  assert.ok(!api.__test__.allowedActions.has('identity_qr_issued'));
});

test('enrollment audit redaction removes nested secrets before persistence', () => {
  const result = api.__test__.redact({
    password: 'nope',
    metadata: { apiKey: 'secret', safe: 'yes' },
    list: [{ pin: '1234' }],
  });
  assert.equal(result.password, '[REDACTED]');
  assert.equal(result.metadata.apiKey, '[REDACTED]');
  assert.equal(result.metadata.safe, 'yes');
  assert.equal(result.list[0].pin, '[REDACTED]');
});
