// Plain Node test runner (no framework dependency) for the
// submitSchoolApplication validation logic. Run with:
// node __tests__/submit_school_application.test.js
//
// Regression coverage for the registration bug where a selected autocomplete
// location resolved to an empty location.address, causing a fully-completed
// registration to fail with "Required registration information is missing
// or invalid."
const assert = require('node:assert/strict');
const { validateSchoolApplicationBody } = require('../index').__test__;

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

const IDENTITY_EMAIL = 'admin@sunrisehigh.example';

function validBody(overrides = {}) {
  return {
    school: {
      name: 'Sunrise High School',
      shortName: 'SHS',
      email: 'school@sunrisehigh.example',
      phone: '0771234567',
      category: 'Private',
      prefix: 'SHS',
      studentCapacity: 650,
    },
    location: {
      region: 'Central',
      district: 'Kampala',
      address: 'Kampala, Central Region, Uganda',
      locationName: 'Kampala',
      country: 'Uganda',
    },
    plan: 'Growth',
    selectedModules: ['Students', 'Attendance', 'Academics', 'Administration'],
    administrator: {
      firstName: 'Jane',
      lastName: 'Namono',
      gender: 'Female',
      phone: '0779876543',
      email: IDENTITY_EMAIL,
      username: 'admin',
    },
    marketingOptIn: false,
    termsAccepted: true,
    ...overrides,
  };
}

console.log('validateSchoolApplicationBody() - happy paths');

test('a fully valid autocomplete-location application has no invalid fields', () => {
  const invalidFields = validateSchoolApplicationBody(validBody(), IDENTITY_EMAIL);
  assert.deepEqual(invalidFields, []);
});

test('legacy payloads that only ever sent location.address (no formattedAddress) still pass', () => {
  const body = validBody({ location: { region: 'Central', district: 'Kampala', address: 'Old Kampala Road', locationName: 'Old Kampala' } });
  const invalidFields = validateSchoolApplicationBody(body, IDENTITY_EMAIL);
  assert.deepEqual(invalidFields, []);
});

test('manual location entry (address === area) still passes', () => {
  const body = validBody({ location: { region: 'Western', district: 'Kabarole', address: 'Kanyanya', locationName: 'Kanyanya' } });
  const invalidFields = validateSchoolApplicationBody(body, IDENTITY_EMAIL);
  assert.deepEqual(invalidFields, []);
});

console.log('\nvalidateSchoolApplicationBody() - the regressed bug: empty location.address');

test('a location selected via autocomplete with no resolvable address fails validation with location.address flagged', () => {
  // This is the exact shape that caused the production bug: the location
  // object had formattedAddress but the frontend only read loc.address,
  // so the submitted location.address ended up as ''.
  const body = validBody({ location: { region: 'Central', district: 'Kampala', address: '', locationName: 'Kampala' } });
  const invalidFields = validateSchoolApplicationBody(body, IDENTITY_EMAIL);
  assert.ok(invalidFields.includes('location.address'));
});

console.log('\nvalidateSchoolApplicationBody() - field-level diagnostics');

test('each missing required field is individually identifiable', () => {
  const body = validBody({
    school: { name: '', shortName: '', email: '', phone: '', category: '', prefix: '', studentCapacity: 0 },
    location: { region: '', district: '', address: '', locationName: '' },
    administrator: { firstName: '', lastName: '', gender: '', phone: '', email: 'mismatch@example.com', username: '' },
    plan: 'NotAPlan',
    termsAccepted: false,
  });
  const invalidFields = validateSchoolApplicationBody(body, IDENTITY_EMAIL);
  for (const field of [
    'school.name', 'school.email', 'school.phone', 'school.prefix', 'school.category', 'school.studentCapacity',
    'location.region', 'location.district', 'location.address',
    'administrator.firstName', 'administrator.lastName', 'administrator.phone', 'administrator.email',
    'plan', 'termsAccepted',
  ]) {
    assert.ok(invalidFields.includes(field), `expected ${field} to be flagged`);
  }
});

test('administrator email must match the verified Firebase identity email', () => {
  const body = validBody({ administrator: { firstName: 'Jane', lastName: 'Namono', phone: '0779876543', email: 'someone-else@example.com', username: 'admin' } });
  const invalidFields = validateSchoolApplicationBody(body, IDENTITY_EMAIL);
  assert.ok(invalidFields.includes('administrator.email'));
});

test('no invalid fields list is ever exposed in a way that leaks passwords or tokens (sanity: field names only)', () => {
  const body = validBody({ location: { region: '', district: '', address: '', locationName: '' } });
  const invalidFields = validateSchoolApplicationBody(body, IDENTITY_EMAIL);
  const serialized = JSON.stringify(invalidFields);
  assert.ok(!/password|token|secret/i.test(serialized));
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
