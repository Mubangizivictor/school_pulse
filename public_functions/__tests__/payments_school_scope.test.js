const test = require('node:test');
const assert = require('node:assert/strict');
const { paymentsQueryFilters } = require('../payments').__internal;

test('schoolId is passed through as a real filter when present', () => {
  const filters = paymentsQueryFilters({ schoolId: 'school1' });
  assert.equal(filters.schoolId, 'school1');
});

test('missing schoolId means no school filter is applied (owner-wide Billing view)', () => {
  const filters = paymentsQueryFilters({});
  assert.equal(filters.schoolId, null);
});

test('date range only applies when both values are finite numbers', () => {
  const filters = paymentsQueryFilters({ startDateMs: 1000, endDateMs: 'not-a-number' });
  assert.equal(filters.startDateMs, 1000);
  assert.equal(filters.endDateMs, null);
});

test('schoolId is trimmed/length-capped like every other text() field in this file', () => {
  const filters = paymentsQueryFilters({ schoolId: '  school1  ' });
  assert.equal(filters.schoolId, 'school1');
});
