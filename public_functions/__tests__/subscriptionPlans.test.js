// Plain Node test runner (no framework dependency) for the subscription
// plan validation/normalization helpers used by createSubscriptionPlan,
// updateSubscriptionPlan, archiveSubscriptionPlan and
// reactivateSubscriptionPlan. Firestore-dependent behavior (uniqueness
// checks, audit log writes, atomic batch commits) is exercised via the
// existing firestore.rules emulator harness pattern (functions/test/) for
// access control; this file covers pure request-payload logic only,
// mirroring payment_reviewability.test.js's approach for this codebase.
// Run with: node __tests__/subscriptionPlans.test.js
const assert = require('node:assert/strict');
const {
  normalizedModuleList,
  parseAndValidatePlanFields,
  PLAN_CODE_RE,
  ALLOWED_PLAN_MODULE_KEYS,
} = require('../payments').__internal;

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

function expectThrows(fn, matcher) {
  try {
    fn();
  } catch (error) {
    if (matcher && !matcher.test(error.message)) {
      throw new Error(`threw, but message "${error.message}" did not match ${matcher}`);
    }
    return;
  }
  throw new Error('expected a throw, but none occurred');
}

console.log('PLAN_CODE_RE');

test('accepts a valid lowercase code', () => {
  assert.equal(PLAN_CODE_RE.test('growth_plus'), true);
});

test('rejects uppercase', () => {
  assert.equal(PLAN_CODE_RE.test('Growth'), false);
});

test('rejects a code starting with a digit', () => {
  assert.equal(PLAN_CODE_RE.test('2growth'), false);
});

test('rejects a single-character code', () => {
  assert.equal(PLAN_CODE_RE.test('g'), false);
});

test('rejects special characters', () => {
  assert.equal(PLAN_CODE_RE.test('growth-plus'), false);
});

console.log('\nnormalizedModuleList()');

test('keeps only allowed module keys', () => {
  const result = normalizedModuleList(['attendance', 'not_a_module', 'finance']);
  assert.deepEqual(result.sort(), ['attendance', 'finance']);
});

test('dedupes repeated keys', () => {
  const result = normalizedModuleList(['attendance', 'attendance', 'reports']);
  assert.deepEqual(result.sort(), ['attendance', 'reports']);
});

test('caps at 8 items even if more are somehow allowed-listed', () => {
  const result = normalizedModuleList(ALLOWED_PLAN_MODULE_KEYS);
  assert.equal(result.length, 8);
});

test('non-array input yields an empty list', () => {
  assert.deepEqual(normalizedModuleList(undefined), []);
  assert.deepEqual(normalizedModuleList('attendance'), []);
});

console.log('\nparseAndValidatePlanFields()');

function validPayload(overrides = {}) {
  return {
    name: 'Starter',
    description: 'A starter plan',
    price: 350000,
    billingCycle: 'termly',
    termLengthDays: 120,
    trialDays: 7,
    maxStudents: 500,
    maxStaff: 60,
    storageLimitGb: 10,
    smsLimitPerMonth: 1000,
    includedFeatures: ['Priority support'],
    includedModules: ['attendance', 'reports'],
    isPublic: true,
    isActive: true,
    isPopular: false,
    displayOrder: 0,
    ...overrides,
  };
}

test('accepts a fully valid payload and returns normalized fields', () => {
  const fields = parseAndValidatePlanFields(validPayload(), 'starter');
  assert.equal(fields.name, 'Starter');
  assert.equal(fields.price, 350000);
  assert.equal(fields.trialDays, 7);
  assert.equal(fields.smsLimitPerMonth, 1000);
  assert.deepEqual(fields.includedModules.sort(), ['attendance', 'reports']);
  assert.equal(fields.customPricing, false);
});

test('rejects a missing name', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ name: '' }), 'starter'),
    /name is required/i,
  );
});

test('rejects an invalid billing cycle', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ billingCycle: 'weekly' }), 'starter'),
    /billing cycle/i,
  );
});

test('rejects zero price for a non-enterprise plan', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ price: 0 }), 'starter'),
    /price must be greater than zero/i,
  );
});

test('allows zero price for the enterprise plan (custom pricing)', () => {
  const fields = parseAndValidatePlanFields(validPayload({ price: 0 }), 'enterprise');
  assert.equal(fields.customPricing, true);
});

test('rejects a negative enterprise price', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ price: -1 }), 'enterprise'),
    /cannot be negative/i,
  );
});

test('rejects trialDays out of the 0-90 range', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ trialDays: 91 }), 'starter'),
    /trial days/i,
  );
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ trialDays: -1 }), 'starter'),
    /trial days/i,
  );
});

test('rejects smsLimitPerMonth out of range', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ smsLimitPerMonth: -1 }), 'starter'),
    /sms limit/i,
  );
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ smsLimitPerMonth: 1000001 }), 'starter'),
    /sms limit/i,
  );
});

test('rejects negative maxStudents/maxStaff/storageLimitGb', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ maxStudents: -1 }), 'starter'),
    /cannot be negative/i,
  );
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ maxStaff: -1 }), 'starter'),
    /cannot be negative/i,
  );
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ storageLimitGb: -1 }), 'starter'),
    /cannot be negative/i,
  );
});

test('silently drops an unrecognized includedModules key rather than rejecting', () => {
  const fields = parseAndValidatePlanFields(
    validPayload({ includedModules: ['attendance', 'not_a_real_module'] }),
    'starter',
  );
  assert.deepEqual(fields.includedModules, ['attendance']);
});

test('termLengthDays out of the 1-730 range is rejected', () => {
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ termLengthDays: 0 }), 'starter'),
    /billing period length/i,
  );
  expectThrows(
    () => parseAndValidatePlanFields(validPayload({ termLengthDays: 731 }), 'starter'),
    /billing period length/i,
  );
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
