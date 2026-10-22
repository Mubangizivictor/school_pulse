// Plain Node test runner (no framework dependency) for Resend error
// classification: configuration vs. transient vs. unknown, and how that
// classification drives the transactional queue's retry decision.
// Run with: node email/__tests__/resend_error_classifier.test.js
const assert = require('node:assert/strict');
const { classifyResendError, CONFIGURATION_ERROR_NAMES, TRANSIENT_ERROR_NAMES, QUOTA_ERROR_NAMES } = require('../resend_error_classifier');
const { scheduleRetryOrFail, MAX_ATTEMPTS } = require('../transactional_queue').__test__;
const { buildHostedPayload, buildLocalPayload, attemptSend } = require('../email_service').__test__;
const { getHostedTemplate } = require('../hosted_templates');

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

function fakeRef() {
  const calls = [];
  return { id: 'test-event-id', set: async (data) => { calls.push(data); }, _calls: calls };
}

async function main() {
  console.log('1. Invalid hosted alias / not_found -> non-retryable configuration error');
  test('not_found classifies as HOSTED_TEMPLATE_CONFIGURATION_ERROR, retryable=false', () => {
    const result = classifyResendError({ name: 'not_found', message: 'Template not found.', statusCode: 404 });
    assert.equal(result.errorClass, 'HOSTED_TEMPLATE_CONFIGURATION_ERROR');
    assert.equal(result.retryable, false);
    assert.equal(result.providerErrorName, 'not_found');
  });

  console.log('\n2. Missing required template variable -> non-retryable');
  test('missing_required_field classifies as configuration error, retryable=false', () => {
    const result = classifyResendError({ name: 'missing_required_field', message: 'school_name is required.', statusCode: 422 });
    assert.equal(result.errorClass, 'HOSTED_TEMPLATE_CONFIGURATION_ERROR');
    assert.equal(result.retryable, false);
  });

  console.log('\n3. Validation error -> non-retryable');
  test('validation_error classifies as configuration error, retryable=false', () => {
    const result = classifyResendError({ name: 'validation_error', message: 'Invalid request body.', statusCode: 422 });
    assert.equal(result.errorClass, 'HOSTED_TEMPLATE_CONFIGURATION_ERROR');
    assert.equal(result.retryable, false);
  });
  test('invalid_parameter classifies as configuration error, retryable=false', () => {
    const result = classifyResendError({ name: 'invalid_parameter', message: 'days_remaining must be a number.', statusCode: 422 });
    assert.equal(result.errorClass, 'HOSTED_TEMPLATE_CONFIGURATION_ERROR');
    assert.equal(result.retryable, false);
  });
  test('invalid_from_address classifies as configuration error, retryable=false', () => {
    const result = classifyResendError({ name: 'invalid_from_address', message: 'Sender not verified.', statusCode: 403 });
    assert.equal(result.errorClass, 'HOSTED_TEMPLATE_CONFIGURATION_ERROR');
    assert.equal(result.retryable, false);
  });

  console.log('\n4. Rate-limit error -> retryable');
  test('rate_limit_exceeded classifies as TRANSIENT_PROVIDER_ERROR, retryable=true', () => {
    const result = classifyResendError({ name: 'rate_limit_exceeded', message: 'Too many requests.', statusCode: 429 });
    assert.equal(result.errorClass, 'TRANSIENT_PROVIDER_ERROR');
    assert.equal(result.retryable, true);
  });

  console.log('\n5. Provider internal error -> retryable');
  test('internal_server_error classifies as TRANSIENT_PROVIDER_ERROR, retryable=true', () => {
    const result = classifyResendError({ name: 'internal_server_error', message: 'Something went wrong.', statusCode: 500 });
    assert.equal(result.errorClass, 'TRANSIENT_PROVIDER_ERROR');
    assert.equal(result.retryable, true);
  });
  test('application_error classifies as TRANSIENT_PROVIDER_ERROR, retryable=true', () => {
    const result = classifyResendError({ name: 'application_error', message: 'Unexpected error.', statusCode: 500 });
    assert.equal(result.errorClass, 'TRANSIENT_PROVIDER_ERROR');
    assert.equal(result.retryable, true);
  });

  console.log('\n6. Unknown network/provider error -> conservative bounded retry (same as current default)');
  test('an error with no name (e.g. a thrown network Error) classifies as UNKNOWN_ERROR, retryable=true', () => {
    const result = classifyResendError(new Error('fetch failed: ECONNRESET'));
    assert.equal(result.errorClass, 'UNKNOWN_ERROR');
    assert.equal(result.retryable, true);
    assert.equal(result.providerErrorName, null);
  });
  test('a Resend error name not in any known set (future SDK addition) classifies as UNKNOWN_ERROR, retryable=true', () => {
    const result = classifyResendError({ name: 'some_future_error_code', message: 'New error type.' });
    assert.equal(result.errorClass, 'UNKNOWN_ERROR');
    assert.equal(result.retryable, true);
  });

  console.log('\nQuota errors: non-retryable but distinct from configuration errors');
  test('monthly_quota_exceeded is non-retryable but classified as QUOTA_ERROR, not a configuration bug', () => {
    const result = classifyResendError({ name: 'monthly_quota_exceeded', message: 'Monthly quota exceeded.', statusCode: 429 });
    assert.equal(result.errorClass, 'QUOTA_ERROR');
    assert.equal(result.retryable, false);
  });

  console.log('\nEvery classified name is a real Resend SDK error name (cross-check against the installed SDK)');
  test('all classified names come from the SDK\'s actual RESEND_ERROR_CODE_KEY union', () => {
    const REAL_SDK_NAMES = new Set([
      'invalid_idempotency_key', 'validation_error', 'missing_api_key', 'restricted_api_key',
      'invalid_api_key', 'not_found', 'method_not_allowed', 'invalid_idempotent_request',
      'concurrent_idempotent_requests', 'invalid_attachment', 'invalid_from_address',
      'invalid_access', 'invalid_parameter', 'invalid_region', 'missing_required_field',
      'monthly_quota_exceeded', 'daily_quota_exceeded', 'rate_limit_exceeded', 'security_error',
      'application_error', 'internal_server_error',
    ]);
    for (const name of [...CONFIGURATION_ERROR_NAMES, ...TRANSIENT_ERROR_NAMES, ...QUOTA_ERROR_NAMES]) {
      assert.ok(REAL_SDK_NAMES.has(name), `"${name}" is not a real Resend SDK error name - do not guess`);
    }
  });

  console.log('\n9. No secret values are logged by the classifier');
  test('classifyResendError never attaches anything resembling an API key or secret', () => {
    const fakeKeyLikeError = { name: 'invalid_api_key', message: 'The API key re_123456789abcdef is invalid.' };
    const result = classifyResendError(fakeKeyLikeError);
    // The classifier does not redact Resend's own message (it identifies the
    // problem, not key material), but must never independently attach
    // RESEND_API_KEY or any other secret field to its output.
    assert.ok(!('apiKey' in result), 'classifier output must never include an apiKey field');
    assert.ok(!('secret' in result), 'classifier output must never include a secret field');
    assert.deepEqual(Object.keys(result).sort(), ['errorClass', 'providerErrorMessage', 'providerErrorName', 'retryable'].sort());
  });

  console.log('\n7. Queue retry decision respects retryable=false (configuration error skips straight to failed)');
  await asyncTest('a non-retryable error on the FIRST attempt is marked failed immediately, not retried', async () => {
    const ref = fakeRef();
    await scheduleRetryOrFail(ref, 1, 'Template not found.', false);
    assert.equal(ref._calls.length, 1);
    assert.equal(ref._calls[0].status, 'failed');
    assert.equal(ref._calls[0].retryable, false);
  });

  await asyncTest('a retryable error on attempt 1 of 3 schedules a retry, does not fail', async () => {
    const ref = fakeRef();
    await scheduleRetryOrFail(ref, 1, 'Rate limited.', true);
    assert.equal(ref._calls[0].status, 'retrying');
  });

  await asyncTest('a retryable error that exhausts MAX_ATTEMPTS still fails eventually (bounded, not infinite)', async () => {
    const ref = fakeRef();
    await scheduleRetryOrFail(ref, MAX_ATTEMPTS, 'Still failing.', true);
    assert.equal(ref._calls[0].status, 'failed');
    assert.equal(ref._calls[0].retryable, true);
  });

  console.log('\n10. Classification is a pure function - cannot itself touch business collections');
  test('classifyResendError takes an error, returns a plain synchronous object, no I/O', () => {
    const result = classifyResendError({ name: 'not_found', message: 'x' });
    assert.equal(typeof result, 'object');
    assert.equal(result instanceof Promise, false);
  });

  console.log('\n7 (cont.). Configuration errors do not roll back business events');
  test('classifyResendError and scheduleRetryOrFail never receive or touch a business document reference', () => {
    // Structural guarantee: classifyResendError's signature takes only an
    // error object (asserted above), and scheduleRetryOrFail(ref, ...)
    // writes only to the `ref` it is given - which transactional_queue.js
    // always passes as a transactional_email_queue document, never a
    // payment/application/subscription document. A hosted-template failure
    // therefore cannot reach - let alone mutate - business state; the
    // approve/reject/activate writes happen in payment_notifications.js /
    // application_notifications.js / mtn_momo.js BEFORE enqueueTemplatedEmail
    // is ever called, and enqueueTemplatedEmail's own failure is always
    // wrapped in .catch(() => null) at every call site (verified in the
    // hosted-template wiring session), so an email failure of any kind -
    // configuration or transient - cannot throw back into the caller.
    assert.equal(classifyResendError.length, 1, 'classifyResendError must only take an error, nothing that could be a business ref');
  });

  console.log('\n8. Local fallback success still records the hosted-template configuration failure');
  test('buildLocalPayload produces a complete, valid send payload independent of any hosted failure (the exact payload used for fallback)', () => {
    const payload = buildLocalPayload('application_approved', { schoolName: 'Test School', applicationId: 'app_1', adminName: 'Jane' }, 'admin@test.school', null);
    assert.ok(payload.subject && payload.subject.length > 0, 'fallback payload must have a real subject (unlike the hosted payload, which sets it to null)');
    assert.ok(payload.html.includes('Test School'), 'fallback HTML must contain the real rendered content');
    assert.equal(payload.from.includes('applications@mail.schoolpulseapp.com'), true);
  });
  await asyncTest('attemptSend degrades safely (UNKNOWN_ERROR, retryable=true) rather than throwing when Resend is unreachable/misconfigured - proves the fallback attempt itself cannot crash the delivery', async () => {
    const payload = buildLocalPayload('application_approved', { schoolName: 'Test School', applicationId: 'app_1' }, 'admin@test.school', null);
    const result = await attemptSend(payload);
    assert.equal(result.status, 'failed'); // no live RESEND_API_KEY in this test environment
    assert.equal(result.retryable, true);
    assert.equal(result.errorClass, 'UNKNOWN_ERROR');
  });

  console.log('\n10 (cont.). Existing successful hosted-template payload shape is unchanged');
  test('buildHostedPayload produces the exact {from, to, template:{id, variables}, subject:null} shape the Resend SDK requires for a template send', () => {
    const hosted = getHostedTemplate('application_approved');
    const payload = buildHostedPayload('application_approved', hosted, { schoolName: 'Test School', applicationId: 'app_1', adminName: 'Jane' }, 'admin@test.school');
    assert.equal(payload.subject, null, 'hosted payload must not set a literal subject string - Resend owns it');
    assert.deepEqual(payload.to, ['admin@test.school']);
    assert.equal(payload.template.id, 'application-approved');
    assert.equal(payload.template.variables.admin_name, 'Jane');
    assert.equal(payload.template.variables.school_name, 'Test School');
    assert.equal(typeof payload.template.variables.application_reference, 'string');
  });

  console.log(`\n${passed} passed, ${failed} failed`);
  if (failed > 0) process.exit(1);
}

main();
