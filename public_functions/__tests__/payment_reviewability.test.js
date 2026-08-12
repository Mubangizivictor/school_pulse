// Plain Node test runner (no framework dependency) for manual payment
// reviewability gating and the notify-once transition check.
// Run with: node __tests__/payment_reviewability.test.js
const assert = require('node:assert/strict');
const { reviewable } = require('../payment_notifications').__test__;

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

console.log('reviewable()');

test('pending_verification + proofStoragePath is reviewable', () => {
  assert.equal(reviewable({ status: 'pending_verification', proofStoragePath: 'proofs/a.jpg' }), true);
});

test('pending_verification without proof is not reviewable', () => {
  assert.equal(reviewable({ status: 'pending_verification' }), false);
});

test('approved + proofStoragePath is not reviewable', () => {
  assert.equal(reviewable({ status: 'approved', proofStoragePath: 'proofs/a.jpg' }), false);
});

test('rejected + proofStoragePath is not reviewable', () => {
  assert.equal(reviewable({ status: 'rejected', proofStoragePath: 'proofs/a.jpg' }), false);
});

test('pending_verification with legacy proofUrl field is reviewable', () => {
  assert.equal(reviewable({ status: 'pending_verification', proofUrl: 'https://x/y.jpg' }), true);
});

console.log('\nTransition semantics (mirrors onDocumentWritten guard: reviewable(after) && !reviewable(before))');

test('pending_verification transition (was not reviewable, now is) fires exactly once', () => {
  const before = { status: 'draft' };
  const after = { status: 'pending_verification', proofStoragePath: 'proofs/a.jpg' };
  assert.equal(reviewable(after) && !reviewable(before), true);
});

test('unrelated update while already pending_verification does not re-fire', () => {
  const before = { status: 'pending_verification', proofStoragePath: 'proofs/a.jpg', note: 'old' };
  const after = { status: 'pending_verification', proofStoragePath: 'proofs/a.jpg', note: 'updated' };
  assert.equal(reviewable(after) && !reviewable(before), false);
});

console.log('\nMethod labels');

test('mtn, airtel, bank, cash all resolve to distinct labels', () => {
  const { paymentMethod } = require('../payment_notifications').__test__;
  assert.equal(paymentMethod('mtn').label, 'MTN Mobile Money');
  assert.equal(paymentMethod('airtel').label, 'Airtel Money');
  assert.equal(paymentMethod('bank').label, 'Bank transfer');
  assert.equal(paymentMethod('cash').label, 'Cash');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
