// Unit tests for resend_webhook.js's request handling. onRequest-exported
// CloudFunctions are directly callable as (req, res) (unlike onCall's
// .run({auth, data})), so the handler is invoked with a mock req/res pair
// here - no emulator needed, since signature verification itself is pure
// (standardwebhooks + a fixed secret) and the handler makes no Firestore
// calls yet (the email.received branch is a logged TODO, not a write).
const test = require('node:test');
const assert = require('node:assert/strict');
const { Webhook } = require('standardwebhooks');

process.env.GCLOUD_PROJECT = 'demo-resend-webhook-test';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId: 'demo-resend-webhook-test' });

// defineSecret() params resolve via .value() - in a non-deployed test
// context that reads from process.env.<NAME>, matching how Firebase
// Functions test helpers commonly stub secrets.
const TEST_SECRET = 'whsec_' + Buffer.from('test-signing-secret-000000').toString('base64');
process.env.RESEND_WEBHOOK_SECRET = TEST_SECRET;
process.env.RESEND_API_KEY = 're_test_000000000000000000000000';

const { resendWebhook } = require('../resend_webhook');

function mockRes() {
  const res = {
    statusCode: null,
    body: null,
    headersSet: {},
    status(code) { this.statusCode = code; return this; },
    set(key, value) { this.headersSet[key] = value; return this; },
    send(body) { this.body = body; return this; },
  };
  return res;
}

function signedHeaders(payload, secret) {
  const wh = new Webhook(secret);
  const id = 'msg_test123';
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const signature = wh.sign(id, new Date(Number(timestamp) * 1000), payload);
  return { id, timestamp, signature };
}

function mockReq({ payload, headers }) {
  return {
    method: 'POST',
    rawBody: Buffer.from(payload, 'utf8'),
    get(name) {
      const key = name.toLowerCase();
      if (key === 'svix-id') return headers.id;
      if (key === 'svix-timestamp') return headers.timestamp;
      if (key === 'svix-signature') return headers.signature;
      return undefined;
    },
  };
}

test('a validly signed email.received event is accepted with 200 OK', async () => {
  const payload = JSON.stringify({ type: 'email.received', data: { email_id: 'em_1', from: 'a@b.com' } });
  const headers = signedHeaders(payload, TEST_SECRET);
  const req = mockReq({ payload, headers });
  const res = mockRes();
  await resendWebhook(req, res);
  assert.equal(res.statusCode, 200);
  assert.equal(res.body, 'OK');
});

test('a validly signed event of a different type is still accepted with 200 OK (no-op)', async () => {
  const payload = JSON.stringify({ type: 'email.sent', data: { email_id: 'em_2' } });
  const headers = signedHeaders(payload, TEST_SECRET);
  const req = mockReq({ payload, headers });
  const res = mockRes();
  await resendWebhook(req, res);
  assert.equal(res.statusCode, 200);
});

test('an invalid signature is rejected with 400', async () => {
  const payload = JSON.stringify({ type: 'email.received', data: {} });
  const headers = signedHeaders(payload, TEST_SECRET);
  // Tamper with the payload after signing - the raw bytes verified no
  // longer match what was signed.
  const req = mockReq({ payload: payload + 'tampered', headers });
  const res = mockRes();
  await resendWebhook(req, res);
  assert.equal(res.statusCode, 400);
});

test('missing svix headers are rejected with 400', async () => {
  const payload = JSON.stringify({ type: 'email.received', data: {} });
  const req = mockReq({ payload, headers: { id: undefined, timestamp: undefined, signature: undefined } });
  const res = mockRes();
  await resendWebhook(req, res);
  assert.equal(res.statusCode, 400);
});

test('a signature made with the wrong secret is rejected with 400', async () => {
  const payload = JSON.stringify({ type: 'email.received', data: {} });
  const wrongSecret = 'whsec_' + Buffer.from('wrong-secret-000000000000').toString('base64');
  const headers = signedHeaders(payload, wrongSecret);
  const req = mockReq({ payload, headers });
  const res = mockRes();
  await resendWebhook(req, res);
  assert.equal(res.statusCode, 400);
});

test('a non-POST request is rejected with 405', async () => {
  const req = { method: 'GET', rawBody: Buffer.from(''), get: () => undefined };
  const res = mockRes();
  await resendWebhook(req, res);
  assert.equal(res.statusCode, 405);
});
