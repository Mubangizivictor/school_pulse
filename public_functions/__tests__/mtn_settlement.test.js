// Run with: node __tests__/mtn_settlement.test.js
const assert = require('node:assert/strict');
const { computeSettlement } = require('../mtn_momo').__test__;

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

const DAY_MS = 24 * 60 * 60 * 1000;

console.log('computeSettlement()');

test('activation starts from now, not from any stale existing expiry', () => {
  const nowMs = 1_000_000_000_000;
  const payment = { paymentType: 'activation', termLengthDays: 120 };
  const school = { subscriptionExpiry: 0 };
  const { startMs, expiryMs, termLengthDays } = computeSettlement(payment, school, nowMs);
  assert.equal(startMs, nowMs);
  assert.equal(termLengthDays, 120);
  assert.equal(expiryMs, nowMs + 120 * DAY_MS);
});

test('renewal before expiry extends from the existing expiry, not from now', () => {
  const nowMs = 1_000_000_000_000;
  const existingExpiry = nowMs + 10 * DAY_MS; // still 10 days of paid time left
  const payment = { paymentType: 'renewal', termLengthDays: 120 };
  const school = { subscriptionExpiry: existingExpiry };
  const { startMs, expiryMs } = computeSettlement(payment, school, nowMs);
  assert.equal(startMs, existingExpiry);
  assert.equal(expiryMs, existingExpiry + 120 * DAY_MS);
});

test('renewal after expiry (lapsed) starts from now, not from the stale expiry', () => {
  const nowMs = 1_000_000_000_000;
  const existingExpiry = nowMs - 30 * DAY_MS; // lapsed a month ago
  const payment = { paymentType: 'renewal', termLengthDays: 120 };
  const school = { subscriptionExpiry: existingExpiry };
  const { startMs, expiryMs } = computeSettlement(payment, school, nowMs);
  assert.equal(startMs, nowMs);
  assert.equal(expiryMs, nowMs + 120 * DAY_MS);
});

test('missing/invalid termLengthDays falls back to 120 and is clamped to at least 1', () => {
  const nowMs = 1_000_000_000_000;
  const payment = { paymentType: 'activation', termLengthDays: 0 };
  const school = {};
  const { termLengthDays } = computeSettlement(payment, school, nowMs);
  assert.equal(termLengthDays, 120);
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
