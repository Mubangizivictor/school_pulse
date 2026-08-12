// Run with: node __tests__/mtn_phone_utils.test.js
const assert = require('node:assert/strict');
const { normalizeUgandaMsisdn, maskMsisdn } = require('../phone_utils').__test__;

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

console.log('normalizeUgandaMsisdn()');

test('0-prefixed number normalizes to 256', () => {
  assert.equal(normalizeUgandaMsisdn('0793128137'), '256793128137');
});

test('+256-prefixed number normalizes to 256', () => {
  assert.equal(normalizeUgandaMsisdn('+256793128137'), '256793128137');
});

test('256-prefixed number passes through', () => {
  assert.equal(normalizeUgandaMsisdn('256793128137'), '256793128137');
});

test('number with spaces/punctuation is stripped and normalized', () => {
  assert.equal(normalizeUgandaMsisdn('+256 793-128-137'), '256793128137');
});

test('too short number is rejected', () => {
  assert.throws(() => normalizeUgandaMsisdn('0793128'), /invalid_msisdn/);
});

test('too long number is rejected', () => {
  assert.throws(() => normalizeUgandaMsisdn('0793128137999'), /invalid_msisdn/);
});

test('non-numeric input is rejected', () => {
  assert.throws(() => normalizeUgandaMsisdn('not-a-phone'), /invalid_msisdn/);
});

test('empty input is rejected', () => {
  assert.throws(() => normalizeUgandaMsisdn(''), /invalid_msisdn/);
});

test('null input is rejected', () => {
  assert.throws(() => normalizeUgandaMsisdn(null), /invalid_msisdn/);
});

console.log('\nmaskMsisdn()');

test('masks the middle digits, keeping prefix and last two', () => {
  assert.equal(maskMsisdn('256793128137'), '2567******37');
});

test('short input falls back to a fully-masked placeholder', () => {
  assert.equal(maskMsisdn('123'), '******');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
