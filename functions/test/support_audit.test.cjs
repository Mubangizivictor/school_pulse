const assert = require('node:assert/strict');
const test = require('node:test');

// The factory exposes pure redaction so the most important privacy boundary
// is exercised without requiring emulator credentials.
const moduleFactory = require('../support_audit');
const admin = { firestore: () => ({}) };
const api = moduleFactory({ admin, onCall: (handler) => handler, HttpsError: class extends Error {} });

test('support and audit redaction removes nested secrets before persistence', () => {
  const result = api.__test__.redact({ password: 'nope', profile: { accessToken: 'secret', safe: 'yes' }, list: [{ otp: '123456' }] });
  assert.equal(result.password, '[REDACTED]');
  assert.equal(result.profile.accessToken, '[REDACTED]');
  assert.equal(result.profile.safe, 'yes');
  assert.equal(result.list[0].otp, '[REDACTED]');
});
