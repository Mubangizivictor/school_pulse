const test = require('node:test');
const assert = require('node:assert/strict');
const entitlements = require('./financial_entitlements');

const factory = entitlements({
  admin: { firestore: Object.assign(() => ({}), { FieldValue: {}, Timestamp: {} }) },
  onCall: (a, b) => (typeof a === "function" ? a : b),
  HttpsError: class HttpsError extends Error {},
});

test('safe defaults leave an unconfigured service not applicable', () => {
  assert.deepEqual(factory.policyStatus(undefined, { paymentPercentage: 100, balance: 0 }), {
    status: 'notApplicable', reasonCode: 'POLICY_DISABLED', source: 'feePolicy',
  });
});

test('policy payment bands and balance threshold are evaluated together', () => {
  const policy = { enabled: true, minimumPaymentPercentage: 75, maximumBalance: 5000 };
  assert.equal(factory.policyStatus(policy, { paymentPercentage: 75, balance: 5000 }).status, 'allowed');
  assert.equal(factory.policyStatus(policy, { paymentPercentage: 74, balance: 0 }).status, 'blocked');
  assert.equal(factory.policyStatus(policy, { paymentPercentage: 100, balance: 5001 }).status, 'blocked');
});

test('safety services are permanently outside financial policy scope', () => {
  assert(factory.SAFE_SERVICES.has('nationalExams'));
  assert(factory.SAFE_SERVICES.has('guardianRelease'));
  assert(!factory.SAFE_SERVICES.has('dining'));
});
