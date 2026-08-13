// Plain Node test runner (no framework dependency) for Uganda location
// normalization. Run with: node __tests__/location.test.js
//
// Regression coverage for the registration bug where a selected autocomplete
// location produced `formattedAddress` but no `address`, so the frontend's
// hidden `address` field silently became empty and submitSchoolApplication
// rejected an otherwise-complete application.
const assert = require('node:assert/strict');
const { normalizeNominatimResult } = require('../location').__test__;

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

function kampalaRaw(overrides = {}) {
  return {
    place_id: 12345,
    display_name: 'Kampala, Central Region, Uganda',
    lat: '0.3476',
    lon: '32.5825',
    address: { county: 'Kampala', country_code: 'ug' },
    ...overrides,
  };
}

console.log('normalizeNominatimResult()');

test('returns both address and formattedAddress, and they match the display_name', () => {
  const result = normalizeNominatimResult(kampalaRaw());
  assert.ok(result, 'expected a normalized result for a valid Uganda location');
  assert.equal(result.formattedAddress, 'Kampala, Central Region, Uganda');
  assert.equal(result.address, 'Kampala, Central Region, Uganda');
  assert.equal(result.address, result.formattedAddress, 'address and formattedAddress must never diverge');
});

test('address is non-empty for a typical Uganda search result', () => {
  const result = normalizeNominatimResult(kampalaRaw({ display_name: 'Ntinda, Kampala, Central Region, Uganda' }));
  assert.ok(result.address && result.address.length > 0);
});

test('non-Uganda country codes are rejected (returns null)', () => {
  const result = normalizeNominatimResult(kampalaRaw({ address: { county: 'Nairobi', country_code: 'ke' } }));
  assert.equal(result, null);
});

test('missing coordinates are rejected (returns null)', () => {
  const result = normalizeNominatimResult(kampalaRaw({ lat: 'not-a-number' }));
  assert.equal(result, null);
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
