// Run with: node __tests__/mtn_config.test.js
const assert = require('node:assert/strict');
const { getMtnConfig } = require('../mtn_config');

let passed = 0;
let failed = 0;

function test(name, fn) {
  const savedEnv = { ...process.env };
  try {
    fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  } finally {
    for (const key of Object.keys(process.env)) {
      if (!(key in savedEnv)) delete process.env[key];
    }
    Object.assign(process.env, savedEnv);
  }
}

console.log('getMtnConfig()');

test('defaults to sandbox when MTN_MOMO_TARGET_ENVIRONMENT is unset', () => {
  delete process.env.MTN_MOMO_TARGET_ENVIRONMENT;
  delete process.env.MTN_MOMO_BASE_URL;
  const config = getMtnConfig();
  assert.equal(config.targetEnvironment, 'sandbox');
  assert.equal(config.currency, 'EUR');
  assert.equal(config.baseUrl, 'https://sandbox.momodeveloper.mtn.com');
  assert.ok(config.sandboxTestMsisdn);
  assert.ok(config.sandboxTestAmount);
});

test('sandbox never returns UGX currency', () => {
  process.env.MTN_MOMO_TARGET_ENVIRONMENT = 'sandbox';
  const config = getMtnConfig();
  assert.notEqual(config.currency, 'UGX');
});

test('production_uganda branch returns UGX and no sandbox MSISDN', () => {
  process.env.MTN_MOMO_TARGET_ENVIRONMENT = 'production_uganda';
  process.env.MTN_MOMO_BASE_URL = 'https://example-production.mtn.com';
  const config = getMtnConfig();
  assert.equal(config.targetEnvironment, 'mtnuganda');
  assert.equal(config.currency, 'UGX');
  assert.equal(config.baseUrl, 'https://example-production.mtn.com');
  assert.equal(config.sandboxTestMsisdn, null);
});

test('mtnuganda alias is also recognized as production', () => {
  process.env.MTN_MOMO_TARGET_ENVIRONMENT = 'mtnuganda';
  const config = getMtnConfig();
  assert.equal(config.targetEnvironment, 'mtnuganda');
  assert.equal(config.currency, 'UGX');
});

test('MTN_MOMO_BASE_URL override is respected in sandbox', () => {
  process.env.MTN_MOMO_TARGET_ENVIRONMENT = 'sandbox';
  process.env.MTN_MOMO_BASE_URL = 'https://custom-sandbox.example.com';
  const config = getMtnConfig();
  assert.equal(config.baseUrl, 'https://custom-sandbox.example.com');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
