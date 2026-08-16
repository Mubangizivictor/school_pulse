// Plain Node test runner (no framework dependency), matching the convention
// in appointments.test.js. Run with: node approvals.test.js
const assert = require('node:assert/strict');
const { isDelegationValid } = require('./index').__test__;

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

console.log('isDelegationValid()');

const now = Date.parse('2026-06-15T00:00:00Z');
const active = { start: Date.parse('2026-06-01T00:00:00Z'), end: Date.parse('2026-06-30T00:00:00Z'), modules: [], requestTypes: [] };

test('a delegation within its date range with no scope restriction is valid', () => {
  assert.equal(isDelegationValid(active, 'finance', 'expenditure', now), true);
});

test('a delegation before its start date is invalid', () => {
  const future = { ...active, start: Date.parse('2026-07-01T00:00:00Z'), end: Date.parse('2026-07-30T00:00:00Z') };
  assert.equal(isDelegationValid(future, 'finance', 'expenditure', now), false);
});

test('an expired delegation is invalid', () => {
  const expired = { ...active, start: Date.parse('2026-01-01T00:00:00Z'), end: Date.parse('2026-01-31T00:00:00Z') };
  assert.equal(isDelegationValid(expired, 'finance', 'expenditure', now), false);
});

test('a delegation scoped to specific modules denies an out-of-scope module', () => {
  const scoped = { ...active, modules: ['finance'] };
  assert.equal(isDelegationValid(scoped, 'academics', 'grade_override', now), false);
  assert.equal(isDelegationValid(scoped, 'finance', 'expenditure', now), true);
});

test('a delegation scoped to specific request types denies an out-of-scope type - cannot exceed delegator authority', () => {
  const scoped = { ...active, requestTypes: ['fee_waiver'] };
  assert.equal(isDelegationValid(scoped, 'finance', 'expenditure', now), false);
  assert.equal(isDelegationValid(scoped, 'finance', 'fee_waiver', now), true);
});

test('Firestore Timestamp-shaped start/end (with toMillis()) are handled the same as raw millis', () => {
  const tsShaped = {
    start: { toMillis: () => Date.parse('2026-06-01T00:00:00Z') },
    end: { toMillis: () => Date.parse('2026-06-30T00:00:00Z') },
    modules: [],
    requestTypes: [],
  };
  assert.equal(isDelegationValid(tsShaped, 'finance', 'expenditure', now), true);
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
