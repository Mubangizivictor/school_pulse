// Run with: node __tests__/mtn_token_refresh.test.js
//
// Exercises the 401 -> invalidate cached token -> refresh once -> retry once
// -> give up guard in mtn_client.js's withMtnAuthRetry, using a mocked
// global fetch so no real network/MTN sandbox call is made. Confirms the
// exact three requirements: one refresh, one retry, no infinite loop.
const assert = require('node:assert/strict');

process.env.MTN_MOMO_API_USER = 'test-user';
process.env.MTN_MOMO_API_KEY = 'test-key';
process.env.MTN_MOMO_SUBSCRIPTION_KEY = 'test-sub-key';
process.env.MTN_MOMO_TARGET_ENVIRONMENT = 'sandbox';

// mtn_config.js reads secrets via defineSecret(...).value(), which falls
// back to process.env locally - matches the existing mtn_config.test.js
// pattern for exercising this module outside the Cloud Functions runtime.
const mtnClient = require('../mtn_client');

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

async function asyncTest(name, fn) {
  try {
    await fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  }
}

function fakeTokenResponse() {
  return {
    ok: true,
    status: 200,
    json: async () => ({ access_token: `token-${Date.now()}-${Math.random()}`, expires_in: 3600 }),
  };
}

async function run() {
  console.log('withMtnAuthRetry() - 401 refresh/retry guard');

  await asyncTest('a 401 on first attempt triggers exactly one token refresh and one retry, then succeeds', async () => {
    mtnClient.invalidateTokenCache();
    const originalFetch = global.fetch;

    // Pre-warm the cache with a valid-looking token first, isolating the
    // 401 test from the unrelated "cache was empty" first-fetch case.
    global.fetch = async (url) => {
      if (String(url).includes('/collection/token/')) return fakeTokenResponse();
      throw new Error(`unexpected fetch to ${url}`);
    };
    await mtnClient.getMtnAccessToken();

    let tokenFetchCount = 0;
    let callAttempt = 0;
    global.fetch = async (url) => {
      if (String(url).includes('/collection/token/')) {
        tokenFetchCount += 1;
        return fakeTokenResponse();
      }
      throw new Error(`unexpected fetch to ${url}`);
    };
    try {
      const result = await mtnClient.__test__.withMtnAuthRetry(async () => {
        callAttempt += 1;
        // First attempt: the cached (still "valid" per its expiry) token
        // turns out to be rejected by MTN with 401 anyway.
        // Second attempt (after forced refresh): simulate success.
        if (callAttempt === 1) return { status: 401 };
        return { status: 200 };
      });
      assert.equal(result.status, 200);
      assert.equal(callAttempt, 2, 'fn should be called exactly twice: original + one retry');
      assert.equal(tokenFetchCount, 1, 'exactly one forced token refresh - the cached token was used for free on the first attempt');
    } finally {
      global.fetch = originalFetch;
    }
  });

  await asyncTest('a 401 that persists after refresh does not retry a second time (no infinite loop)', async () => {
    mtnClient.invalidateTokenCache();
    let callAttempt = 0;
    const originalFetch = global.fetch;
    global.fetch = async (url) => {
      if (String(url).includes('/collection/token/')) return fakeTokenResponse();
      throw new Error(`unexpected fetch to ${url}`);
    };
    try {
      const result = await mtnClient.__test__.withMtnAuthRetry(async () => {
        callAttempt += 1;
        return { status: 401 }; // always 401, even after refresh
      });
      assert.equal(result.status, 401, 'gives up and returns the still-401 response rather than looping');
      assert.equal(callAttempt, 2, 'exactly two attempts total: original + exactly one retry, never more');
    } finally {
      global.fetch = originalFetch;
    }
  });

  await asyncTest('a non-401 response is returned as-is with no refresh/retry at all', async () => {
    mtnClient.invalidateTokenCache();
    let callAttempt = 0;
    let tokenFetchCount = 0;
    const originalFetch = global.fetch;
    global.fetch = async (url) => {
      if (String(url).includes('/collection/token/')) {
        tokenFetchCount += 1;
        return fakeTokenResponse();
      }
      throw new Error(`unexpected fetch to ${url}`);
    };
    try {
      const result = await mtnClient.__test__.withMtnAuthRetry(async () => {
        callAttempt += 1;
        return { status: 202 };
      });
      assert.equal(result.status, 202);
      assert.equal(callAttempt, 1, 'no retry for a non-401 response');
      assert.equal(tokenFetchCount, 1, 'exactly one token fetch (the initial cache miss), not a refresh');
    } finally {
      global.fetch = originalFetch;
    }
  });

  console.log(`\n${passed} passed, ${failed} failed`);
  if (failed > 0) process.exit(1);
}

run();
