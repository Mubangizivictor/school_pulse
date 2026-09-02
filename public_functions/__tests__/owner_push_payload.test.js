// Unit tests for the redacted, data-only owner FCM payload builder
// (public_functions/owner_notification_engine.js `pushData` /
// `redactedAlertLabel` / `ownerEventCategory`).
//
// The owner push path is data-only and redacted: `pushData` must never
// carry a tenant-private value (school name, amount, payment reference,
// plan name, raw title/body) - only routing identifiers - and every value
// in the map must be a trimmed string, never a nested object or an
// undefined/null field. `redactedAlertLabel` is the generic, category-only
// text shown as the actual push alert (what appears on the lock screen);
// it must never depend on or leak the real title/body either.
const { test } = require('node:test');
const assert = require('node:assert/strict');

// The module calls admin.initializeApp() on load; give it a project id so
// that does not throw in a bare unit-test process.
process.env.GCLOUD_PROJECT = process.env.GCLOUD_PROJECT || 'demo-owner-push-payload-test';
process.env.FIREBASE_CONFIG =
  process.env.FIREBASE_CONFIG || JSON.stringify({ projectId: 'demo-owner-push-payload-test' });

const { pushData, redactedAlertLabel, ownerEventCategory } = require('../owner_notification_engine');

test('every value in the payload is a string', () => {
  const payload = pushData('evt_1', 'billing', {
    schoolId: 'schoolA',
    paymentId: 'pay_123',
    amountUgx: 350000,
    category: 'billing',
  });
  for (const [key, value] of Object.entries(payload)) {
    assert.equal(typeof value, 'string', `${key} must be a string, got ${typeof value}`);
  }
});

test('never carries a tenant-private value - only routing identifiers', () => {
  const payload = pushData('evt_2', 'billing', {
    schoolId: 'schoolA',
    schoolName: 'Lakeside High',
    paymentId: 'pay_123',
    amountUgx: 350000,
    reference: 'MOMO 0700000000',
    planName: 'Premium',
  });
  for (const key of ['schoolId', 'schoolName', 'paymentId', 'amountUgx', 'reference', 'planName', 'title', 'body']) {
    assert.ok(!(key in payload), `${key} must never appear in the push data payload`);
  }
  assert.equal(payload.category, 'billing');
});

test('null / undefined / empty fields are dropped, not stringified', () => {
  const payload = pushData('evt_3', 'administrative', {
    priority: undefined,
    sourceModule: '',
    notificationType: 'custom',
  });
  assert.ok(!('priority' in payload) || payload.priority === 'high'); // default applies
  assert.equal(payload.type, 'custom');
});

test('a nested object in data is never passed through raw (dropped entirely)', () => {
  const payload = pushData('evt_4', 'administrative', {
    internalError: { message: 'boom', stack: 'x'.repeat(5000) },
    rawPaymentRecord: { pan: '4111111111111111', cvv: '123' },
  });
  assert.ok(!('internalError' in payload));
  assert.ok(!('rawPaymentRecord' in payload));
  for (const value of Object.values(payload)) {
    assert.equal(typeof value, 'string');
    assert.ok(value.length <= 1000, 'no field may exceed the 1000-char cap');
  }
});

test('core routing fields are always present and stringified', () => {
  const payload = pushData('evt_5', 'administrative', {});
  assert.equal(payload.notificationId, 'evt_5');
  assert.equal(payload.id, 'evt_5');
  assert.equal(payload.collapseKey, 'evt_5');
  assert.equal(payload.isAutomated, 'true');
  assert.equal(payload.sourceModule, 'super_admin');
});

test('redactedAlertLabel never echoes real content - generic per-category text only', () => {
  for (const category of ['billing', 'platform', 'schools', 'security', 'digest', 'administrative', 'unknown_thing']) {
    const alert = redactedAlertLabel(category);
    assert.equal(typeof alert.title, 'string');
    assert.equal(typeof alert.body, 'string');
    assert.ok(alert.title.length > 0);
    assert.ok(alert.body.length > 0);
    // Never a placeholder that could be mistaken for real interpolated data.
    assert.ok(!alert.body.includes('undefined'));
    assert.ok(!alert.body.includes('null'));
  }
});

test('ownerEventCategory mirrors the Dart client: paymentId/applicationId win over type text', () => {
  assert.equal(ownerEventCategory({ paymentId: 'p1', type: 'weekly_owner_digest' }), 'billing');
  assert.equal(ownerEventCategory({ applicationId: 'a1' }), 'schools');
  assert.equal(ownerEventCategory({ type: 'platform_health_incident' }), 'platform');
  assert.equal(ownerEventCategory({ type: 'security_alert_new_device' }), 'security');
  assert.equal(ownerEventCategory({ type: 'weekly_owner_digest' }), 'digest');
  assert.equal(ownerEventCategory({ type: 'something_else' }), 'administrative');
  assert.equal(ownerEventCategory({ category: 'security' }), 'security');
});
