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

test('source precedence puts suspension first and system last', () => {
  const p = factory.SOURCE_PRECEDENCE;
  assert.equal(p[0], 'suspension');
  assert.equal(p[p.length - 1], 'system');
  assert(p.indexOf('bursarTemporaryOverride') < p.indexOf('waiver'));
  assert(p.indexOf('waiver') < p.indexOf('scholarship'));
  assert(p.indexOf('scholarship') < p.indexOf('paymentPlan'));
  assert(p.indexOf('paymentPlan') < p.indexOf('feePolicy'));
});

test('financialSummary derives pct/balance from totals and nets scholarship + discount', () => {
  const s = factory.financialSummary({ totalBilled: 1000000, totalPaid: 400000, scholarshipAmount: 300000, discountAmount: 100000 });
  // net = 600k, paid 400k -> ~67%
  assert.equal(s.overallPct, 67);
  assert.equal(s.balance, 200000);
  assert.equal(s.scholarship, 300000);
  assert.equal(s.discount, 100000);
});

test('reliefSource is null unless the policy explicitly honours the source', () => {
  const fin = { totalBilled: 1000000, totalPaid: 0, scholarshipAmount: 0, discountAmount: 1000000 };
  assert.equal(factory.reliefSource({ enabled: true, minimumPaymentPercentage: 100, maximumBalance: 0 }, fin), null);
  assert.equal(factory.reliefSource({ enabled: true, minimumPaymentPercentage: 100, maximumBalance: 0, honorWaiver: true }, fin), 'waiver');
});
