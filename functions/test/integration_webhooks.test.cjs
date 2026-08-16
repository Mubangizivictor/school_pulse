const test = require('node:test');
const assert = require('node:assert/strict');
const { signPayload, verifySignature, hashSecret, REPLAY_WINDOW_MS } = require('../integration_webhooks').__test__;

test('verifySignature accepts a correctly signed, fresh payload', () => {
  const secret = 'test-secret';
  const timestamp = Date.now();
  const body = JSON.stringify({ event: 'attendance.marked' });
  const signature = signPayload(secret, timestamp, body);
  assert.ok(verifySignature(secret, timestamp, body, signature));
});

test('verifySignature rejects a tampered body', () => {
  const secret = 'test-secret';
  const timestamp = Date.now();
  const signature = signPayload(secret, timestamp, 'original');
  assert.ok(!verifySignature(secret, timestamp, 'tampered', signature));
});

test('verifySignature rejects a wrong secret', () => {
  const timestamp = Date.now();
  const body = 'payload';
  const signature = signPayload('secret-a', timestamp, body);
  assert.ok(!verifySignature('secret-b', timestamp, body, signature));
});

test('verifySignature rejects a stale timestamp outside the replay window', () => {
  const secret = 'test-secret';
  const timestamp = Date.now() - (REPLAY_WINDOW_MS + 60_000);
  const body = 'payload';
  const signature = signPayload(secret, timestamp, body);
  assert.ok(!verifySignature(secret, timestamp, body, signature));
});

test('verifySignature rejects a future timestamp', () => {
  const secret = 'test-secret';
  const timestamp = Date.now() + (REPLAY_WINDOW_MS + 60_000);
  const body = 'payload';
  const signature = signPayload(secret, timestamp, body);
  assert.ok(!verifySignature(secret, timestamp, body, signature));
});

test('hashSecret is deterministic and never returns the raw secret', () => {
  const secret = 'super-secret-value';
  const hashed = hashSecret(secret);
  assert.notEqual(hashed, secret);
  assert.equal(hashed, hashSecret(secret));
});

test('createIntegrationWebhook source stores only a secretHash, returns raw secret once', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_webhooks.js'), 'utf8');
  assert.match(source, /secretHash: hashSecret\(secret\)/);
  assert.doesNotMatch(source, /secret,\s*\n\s*status: 'active'/);
});

test('listIntegrationWebhooks source strips secretHash before returning to client', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_webhooks.js'), 'utf8');
  assert.match(source, /const \{ secretHash, \.\.\.rest \} = doc\.data\(\)/);
});
