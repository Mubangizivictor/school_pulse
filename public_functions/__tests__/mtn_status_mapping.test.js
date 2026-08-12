// Run with: node __tests__/mtn_status_mapping.test.js
const assert = require('node:assert/strict');
const { mapMtnStatus } = require('../mtn_client').__test__;

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

console.log('mapMtnStatus()');

test('SUCCESSFUL maps to SUCCESSFUL', () => {
  assert.equal(mapMtnStatus('SUCCESSFUL'), 'SUCCESSFUL');
});

test('FAILED maps to FAILED', () => {
  assert.equal(mapMtnStatus('FAILED'), 'FAILED');
});

test('PENDING maps to PENDING', () => {
  assert.equal(mapMtnStatus('PENDING'), 'PENDING');
});

test('REJECTED maps to FAILED', () => {
  assert.equal(mapMtnStatus('REJECTED'), 'FAILED');
});

test('TIMEOUT maps to EXPIRED', () => {
  assert.equal(mapMtnStatus('TIMEOUT'), 'EXPIRED');
});

test('CANCELLED maps to CANCELLED', () => {
  assert.equal(mapMtnStatus('CANCELLED'), 'CANCELLED');
});

test('lowercase input is still mapped correctly', () => {
  assert.equal(mapMtnStatus('successful'), 'SUCCESSFUL');
});

test('unrecognized status maps to UNKNOWN, never throws', () => {
  assert.equal(mapMtnStatus('SOMETHING_NEW_FROM_MTN'), 'UNKNOWN');
});

test('undefined/null input maps to UNKNOWN, never throws', () => {
  assert.equal(mapMtnStatus(undefined), 'UNKNOWN');
  assert.equal(mapMtnStatus(null), 'UNKNOWN');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
