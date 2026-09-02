// Unit tests for the data-only owner FCM payload builder
// (public_functions/owner_notification_engine.js `pushData`).
//
// The owner push path is deliberately data-only: every value in the map
// must be a trimmed string, and the builder must never emit a nested
// object, an undefined/null field, or an unbounded blob (a stack trace, a
// raw error object, a full payment record). These assertions lock that in
// without needing the Firestore/messaging emulator.
const { test } = require('node:test');
const assert = require('node:assert/strict');

// The module calls admin.initializeApp() on load; give it a project id so
// that does not throw in a bare unit-test process.
process.env.GCLOUD_PROJECT = process.env.GCLOUD_PROJECT || 'demo-owner-push-payload-test';
process.env.FIREBASE_CONFIG =
  process.env.FIREBASE_CONFIG || JSON.stringify({ projectId: 'demo-owner-push-payload-test' });

const { pushData } = require('../owner_notification_engine');

test('every value in the payload is a string', () => {
  const payload = pushData('evt_1', 'Payment verification required', 'A school submitted a proof', {
    schoolId: 'schoolA',
    paymentId: 'pay_123',
    amountUgx: 350000,
    category: 'billing',
  });
  for (const [key, value] of Object.entries(payload)) {
    assert.equal(typeof value, 'string', `${key} must be a string, got ${typeof value}`);
  }
});

test('null / undefined / empty fields are dropped, not stringified', () => {
  const payload = pushData('evt_2', 'Title', 'Body', {
    schoolId: undefined,
    paymentId: null,
    note: '',
    method: 'bank',
  });
  assert.ok(!('schoolId' in payload));
  assert.ok(!('paymentId' in payload));
  assert.ok(!('note' in payload));
  assert.equal(payload.method, 'bank');
});

test('a nested object in data is flattened to a bounded string, never passed through raw', () => {
  const payload = pushData('evt_3', 'Title', 'Body', {
    internalError: { message: 'boom', stack: 'x'.repeat(5000) },
    rawPaymentRecord: { pan: '4111111111111111', cvv: '123' },
  });
  // Whatever survives is a string and is length-capped by text(value, 1000).
  for (const value of Object.values(payload)) {
    assert.equal(typeof value, 'string');
    assert.ok(value.length <= 1000, 'no field may exceed the 1000-char cap');
  }
  // The builder must not surface a live object reference under these keys.
  assert.notEqual(typeof payload.internalError, 'object');
  assert.notEqual(typeof payload.rawPaymentRecord, 'object');
});

test('core routing fields are always present and stringified', () => {
  const payload = pushData('evt_4', 'T', 'B', {});
  assert.equal(payload.notificationId, 'evt_4');
  assert.equal(payload.id, 'evt_4');
  assert.equal(payload.collapseKey, 'evt_4');
  assert.equal(payload.isAutomated, 'true');
  assert.equal(payload.sourceModule, 'super_admin');
});

test('an oversized title/body is length-capped', () => {
  const payload = pushData('evt_5', 'T'.repeat(4000), 'B'.repeat(4000), {});
  assert.ok(payload.title.length <= 1000);
  assert.ok(payload.body.length <= 1000);
});
