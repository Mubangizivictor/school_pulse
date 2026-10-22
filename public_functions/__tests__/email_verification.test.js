// Plain Node test runner (no framework dependency) for the email-verification
// callable's pure logic. Run with: node __tests__/email_verification.test.js
const assert = require('node:assert/strict');
const { buildVerificationEmailRequest, VERIFICATION_ACTION_SETTINGS, classifyLinkGenerationError } = require('../email_verification').__test__;
const { HOSTED_TEMPLATES, getHostedTemplate } = require('../email/hosted_templates');
const { isValidTemplateId, getTemplate } = require('../email/template_registry');
const { senderForTemplate } = require('../email/branding');

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

console.log('buildVerificationEmailRequest (idempotency key + display name)');

test('derives a display name from displayName when present', () => {
  const { userName } = buildVerificationEmailRequest({ uid: 'u1', email: 'jane@example.com', displayName: 'Jane Namono' });
  assert.equal(userName, 'Jane Namono');
});

test('falls back to the email local-part when displayName is missing', () => {
  const { userName } = buildVerificationEmailRequest({ uid: 'u1', email: 'jane.n@example.com', displayName: '' });
  assert.equal(userName, 'jane.n');
});

test('falls back to "there" when neither displayName nor email is usable', () => {
  const { userName } = buildVerificationEmailRequest({ uid: 'u1', email: '', displayName: '' });
  assert.equal(userName, 'there');
});

test('eventId is scoped per uid and per hour, not per request (idempotent within the same window)', () => {
  const now = new Date('2026-08-13T10:15:00.000Z');
  const first = buildVerificationEmailRequest({ uid: 'uid_123', email: 'a@b.com', displayName: '', now });
  const second = buildVerificationEmailRequest({ uid: 'uid_123', email: 'a@b.com', displayName: '', now: new Date('2026-08-13T10:45:00.000Z') });
  assert.equal(first.eventId, second.eventId, 'two requests in the same hour must share an eventId');
  assert.equal(first.eventId, 'email_verification_uid_123_2026-08-13T10');
});

test('eventId changes across the hour boundary (new idempotency window)', () => {
  const first = buildVerificationEmailRequest({ uid: 'uid_123', email: 'a@b.com', displayName: '', now: new Date('2026-08-13T10:59:00.000Z') });
  const second = buildVerificationEmailRequest({ uid: 'uid_123', email: 'a@b.com', displayName: '', now: new Date('2026-08-13T11:01:00.000Z') });
  assert.notEqual(first.eventId, second.eventId);
});

test('eventId is scoped per uid (two different users never collide)', () => {
  const now = new Date('2026-08-13T10:15:00.000Z');
  const a = buildVerificationEmailRequest({ uid: 'uid_a', email: 'a@b.com', displayName: '', now });
  const b = buildVerificationEmailRequest({ uid: 'uid_b', email: 'a@b.com', displayName: '', now });
  assert.notEqual(a.eventId, b.eventId);
});

console.log('\nActionCodeSettings');
test('verification action URL points at the real, already-existing School Pulse registration continue-URL', () => {
  // /auth/action.astro already handles ?mode=verifyEmail&oobCode=... via
  // applyActionCode() and then sends the user on to this exact continue
  // URL - matches the url every sendEmailVerification() call in
  // register.astro previously used, so existing users mid-registration see
  // identical post-verification behavior.
  assert.equal(VERIFICATION_ACTION_SETTINGS.url, 'https://schoolpulseapp.com/register-school?verified=1');
});
test('handleCodeInApp is false (the website\'s /auth/action page consumes the action code via applyActionCode, not an in-app deep link)', () => {
  assert.equal(VERIFICATION_ACTION_SETTINGS.handleCodeInApp, false);
});

console.log('\nclassifyLinkGenerationError (generateEmailVerificationLink failure mapping)');
test('Firebase Auth own abuse quota (auth/too-many-requests) maps to a friendly 429, not an unhandled 500', () => {
  // Reproduces the exact real production error observed: Firebase Auth's
  // Admin SDK throws this when its own project-level TOO_MANY_ATTEMPTS_TRY_LATER
  // quota on link generation is hit - a real, confirmed-live failure mode.
  const error = { errorInfo: { code: 'auth/too-many-requests', message: 'TOO_MANY_ATTEMPTS_TRY_LATER' } };
  const { status, body } = classifyLinkGenerationError(error);
  assert.equal(status, 429);
  assert.equal(body.error, 'rate_limited');
});
test('an unrecognized Admin SDK error maps to a generic 500, never leaking the raw error to the client', () => {
  const error = new Error('some unexpected internal failure with a stack trace and internal details');
  const { status, body } = classifyLinkGenerationError(error);
  assert.equal(status, 500);
  assert.equal(body.error, 'link_generation_failed');
  assert.ok(!JSON.stringify(body).includes('stack trace'), 'raw error message must never reach the client response');
});
test('a top-level .code (not nested under errorInfo) is also recognized', () => {
  const error = { code: 'auth/too-many-requests' };
  const { status } = classifyLinkGenerationError(error);
  assert.equal(status, 429);
});

console.log('\nemail_verification template registration');
test('email_verification is a registered local template (fallback renderer exists)', () => {
  assert.ok(isValidTemplateId('email_verification'));
  assert.doesNotThrow(() => getTemplate('email_verification')({}));
});

test('email_verification maps to the published Resend hosted alias "email-verification"', () => {
  const hosted = getHostedTemplate('email_verification');
  assert.ok(hosted, 'no hosted mapping for email_verification');
  assert.equal(hosted.alias, 'email-verification');
});

test('email_verification variable contract is exactly user_name + verification_url (+ optional school_name)', () => {
  const variables = HOSTED_TEMPLATES.email_verification.variables({
    userName: 'Jane', verificationUrl: 'https://example.com/verify?oobCode=abc',
  });
  const keys = Object.keys(variables).sort();
  assert.deepEqual(keys, ['user_name', 'verification_url']);
  assert.equal(variables.user_name, 'Jane');
  assert.equal(variables.verification_url, 'https://example.com/verify?oobCode=abc');
});

test('school_name is included only when actually supplied', () => {
  const withSchool = HOSTED_TEMPLATES.email_verification.variables({
    userName: 'Jane', verificationUrl: 'https://example.com/verify', schoolName: 'Kampala Junior School',
  });
  assert.deepEqual(Object.keys(withSchool).sort(), ['school_name', 'user_name', 'verification_url']);
  assert.equal(withSchool.school_name, 'Kampala Junior School');
});

test('undefined/null verification data never leaks as literal undefined/null into variables', () => {
  const variables = HOSTED_TEMPLATES.email_verification.variables({});
  assert.notEqual(variables.user_name, undefined);
  assert.notEqual(variables.user_name, null);
  assert.equal(variables.user_name, 'there');
  assert.equal(variables.verification_url, '', 'no safe fake URL should ever be invented - empty rather than a placeholder link');
});

test('verification_url is present as a key even with empty input (never entirely dropped)', () => {
  const variables = HOSTED_TEMPLATES.email_verification.variables({});
  assert.ok(Object.prototype.hasOwnProperty.call(variables, 'verification_url'));
});

console.log('\nSender mapping');
test('email_verification sends from the security@ sender, matching other account-security emails', () => {
  assert.equal(senderForTemplate('email_verification'), 'School Pulse <security@mail.schoolpulseapp.com>');
});

console.log('\nNo secret/credential leakage');
test('email_verification renderer output never includes the literal string RESEND_API_KEY', () => {
  const rendered = getTemplate('email_verification')({ userName: 'Jane', verificationUrl: 'https://example.com/verify?oobCode=SECRETCODE' });
  const serialized = JSON.stringify(rendered);
  assert.ok(!serialized.includes('RESEND_API_KEY'));
});
test('local fallback renderer never prints a raw Firebase oobCode/UID as visible label text (only inside the CTA url)', () => {
  const rendered = getTemplate('email_verification')({ userName: 'Jane', verificationUrl: 'https://example.com/verify?oobCode=SECRETCODE&uid=abc123' });
  assert.ok(!rendered.bodyHtml.includes('SECRETCODE'), 'oobCode leaked into visible body text');
  assert.ok(!rendered.bodyText.includes('SECRETCODE'), 'oobCode leaked into visible body text');
  assert.equal(rendered.cta.url, 'https://example.com/verify?oobCode=SECRETCODE&uid=abc123', 'raw url is expected ONLY behind the CTA link, never printed inline');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
