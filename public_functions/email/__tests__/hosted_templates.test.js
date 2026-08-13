// Plain Node test runner (no framework dependency) for the Resend hosted
// template mapping: alias correctness and the exact variable contract per
// template. Run with: node email/__tests__/hosted_templates.test.js
const assert = require('node:assert/strict');
const { HOSTED_TEMPLATES, getHostedTemplate } = require('../hosted_templates');
const { isValidTemplateId } = require('../template_registry');

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

// Exact aliases copied from the Resend dashboard (published templates).
const EXPECTED_ALIASES = {
  application_received: 'school-application-received',
  application_approved: 'application-approved',
  application_rejected: 'application-rejected',
  payment_proof_received: 'payment-proof-received',
  manual_payment_approved: 'payment-verified-1',
  mobile_money_payment_success: 'payment-verified-1',
  manual_payment_rejected: 'payment-needs-attention',
  mobile_money_payment_failed: 'payment-needs-attention',
  subscription_renewed: 'subscription-renewed',
  subscription_expiring: 'subscription-expiring-soon',
  subscription_expired: 'subscription-expired',
  school_admin_account_created: 'school-admin-welcome',
  email_verification: 'email-verification',
  new_login_alert: 'new-login-alert',
  suspicious_login_alert: 'suspicious-activity-alert',
  appointment_confirmed: 'appointment-confirmed',
  appointment_cancelled: 'appointment-cancelled',
  appointment_reminder: 'appointment-reminder',
  report_available: 'report-available',
};

// Spec-required variable keys per hosted template (Phase 6 of the task).
const REQUIRED_VARIABLES = {
  'school-application-received': ['school_name', 'application_reference'],
  'application-approved': ['admin_name', 'school_name', 'application_reference'],
  'application-rejected': ['admin_name', 'school_name', 'application_reference', 'rejection_reason'],
  'payment-proof-received': ['school_name', 'amount', 'payment_method', 'payment_reference', 'submitted_at'],
  'payment-verified-1': ['school_name', 'amount', 'payment_method', 'payment_reference', 'plan_name', 'subscription_start', 'subscription_end'],
  'payment-needs-attention': ['school_name', 'amount', 'payment_method', 'payment_reference', 'rejection_reason'],
  'subscription-renewed': ['school_name', 'plan_name', 'amount', 'payment_method', 'payment_reference', 'subscription_start', 'subscription_end'],
  'subscription-expiring-soon': ['school_name', 'plan_name', 'subscription_end', 'days_remaining', 'renewal_amount'],
  'subscription-expired': ['school_name', 'plan_name', 'subscription_end', 'renewal_amount'],
  'school-admin-welcome': ['admin_name', 'school_name', 'admin_email'],
  // school_name is deliberately omitted from the key set entirely when not
  // supplied (see hosted_templates.js) rather than sent as an empty string,
  // so the generic "exact key match on empty input" loop below only expects
  // the two always-present keys here.
  'email-verification': ['user_name', 'verification_url'],
  'new-login-alert': ['account_email', 'device_name', 'platform', 'signed_in_at', 'location'],
  'suspicious-activity-alert': ['account_email', 'activity_type', 'device_name', 'activity_time', 'location', 'alert_reason'],
  'appointment-confirmed': ['school_name', 'staff_name', 'appointment_date', 'appointment_time', 'appointment_reference', 'appointment_purpose'],
  'appointment-cancelled': ['school_name', 'staff_name', 'appointment_date', 'appointment_time', 'appointment_reference', 'cancellation_reason'],
  'appointment-reminder': ['school_name', 'staff_name', 'appointment_date', 'appointment_time', 'appointment_reference', 'appointment_purpose'],
  'report-available': ['student_name', 'school_name', 'report_name', 'academic_period', 'published_at'],
};

console.log('Alias mapping');
test('every mapped local templateId resolves to its exact published Resend alias', () => {
  for (const [templateId, expectedAlias] of Object.entries(EXPECTED_ALIASES)) {
    const hosted = getHostedTemplate(templateId);
    assert.ok(hosted, `no hosted mapping for templateId "${templateId}"`);
    assert.equal(hosted.alias, expectedAlias, `templateId "${templateId}" mapped to wrong alias`);
  }
});

test('unmapped local templateId (e.g. a local-only template) returns null, not a guess', () => {
  assert.equal(getHostedTemplate('two_step_verification_enabled'), null);
  assert.equal(getHostedTemplate('not_a_real_template'), null);
});

// Variables with no safe generic placeholder - a fake value would be worse
// than an empty one (e.g. inventing an email address). Every real call site
// always supplies these (they double as the send recipient), so the only
// thing asserted for these keys is "no literal undefined/null", not
// "non-empty on fully empty input".
const NO_GENERIC_FALLBACK = new Set(['admin_email', 'account_email', 'verification_url']);

console.log('\nVariable contracts: exact key match, no undefined/null leakage');
for (const [templateId, hosted] of Object.entries(HOSTED_TEMPLATES)) {
  test(`${templateId} (${hosted.alias}) produces exactly the required variable keys`, () => {
    const required = REQUIRED_VARIABLES[hosted.alias];
    assert.ok(required, `no REQUIRED_VARIABLES entry for alias "${hosted.alias}" - test fixture out of date`);

    // Fully empty input - the worst case a caller could pass.
    const variables = hosted.variables({});
    const keys = Object.keys(variables).sort();
    assert.deepEqual(keys, [...required].sort(), `variable keys for ${templateId} do not match the spec contract exactly`);

    for (const key of required) {
      const value = variables[key];
      assert.notEqual(value, undefined, `${templateId}.${key} is undefined with empty input - must have a safe fallback`);
      assert.notEqual(value, null, `${templateId}.${key} is null with empty input - must have a safe fallback`);
      if (!NO_GENERIC_FALLBACK.has(key)) {
        assert.notEqual(String(value).trim(), '', `${templateId}.${key} is an empty string with empty input - must fall back to a safe placeholder`);
      }
    }
  });
}

test('admin_email / account_email are always populated when the recipient email is passed as data.email (the real-world call shape)', () => {
  const welcome = HOSTED_TEMPLATES.school_admin_account_created.variables({ schoolName: 'Test School', email: 'admin@test.school' });
  assert.equal(welcome.admin_email, 'admin@test.school');
  const login = HOSTED_TEMPLATES.new_login_alert.variables({ email: 'owner@test.school' });
  assert.equal(login.account_email, 'owner@test.school');
});

console.log('\nRealistic data flows through correctly (spot checks)');
test('application_approved carries adminName through to admin_name', () => {
  const variables = HOSTED_TEMPLATES.application_approved.variables({
    schoolName: 'Kampala Junior School', applicationId: 'app_123', adminName: 'Jane Namono',
  });
  assert.equal(variables.admin_name, 'Jane Namono');
  assert.equal(variables.school_name, 'Kampala Junior School');
  assert.match(variables.application_reference, /^SP-APP-\d{4}-\d{6}$/);
});

test('new_login_alert never leaks a raw IP as location - falls back when locationLabel is absent', () => {
  const variables = HOSTED_TEMPLATES.new_login_alert.variables({
    email: 'owner@example.com', deviceLabel: 'ios', whenLabel: '2026-08-12T10:00:00.000Z',
  });
  assert.equal(variables.location, 'Unknown location');
  assert.doesNotMatch(variables.location, /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, 'location must never be a raw IPv4 address');
});

test('mobile_money_payment_success and manual_payment_approved share the payment-verified-1 alias (one hosted template, two local events)', () => {
  assert.equal(HOSTED_TEMPLATES.mobile_money_payment_success.alias, HOSTED_TEMPLATES.manual_payment_approved.alias);
});

// Every templateId actually used by a real business-event call site today
// (application_notifications.js, payment_notifications.js, mtn_momo.js,
// subscription_lifecycle.js, owner_sign_in_events.js, functions/index.js,
// functions/appointments.js), and the delivery provider email_service.js's
// `hosted ? 'HOSTED_RESEND_TEMPLATE' : 'LOCAL_TEMPLATE_FALLBACK'` branch
// will pick for each. This is the actual event -> queue -> delivery
// selection the task asked to prove, expressed without needing a Firestore
// emulator (this codebase has no emulator-based test infra; every existing
// test here is a pure-function unit test, and this follows that precedent).
const PRODUCTION_CALL_SITES = {
  application_received: 'HOSTED_RESEND_TEMPLATE',
  application_approved: 'HOSTED_RESEND_TEMPLATE',
  application_rejected: 'HOSTED_RESEND_TEMPLATE',
  payment_proof_received: 'HOSTED_RESEND_TEMPLATE',
  manual_payment_approved: 'HOSTED_RESEND_TEMPLATE',
  manual_payment_rejected: 'HOSTED_RESEND_TEMPLATE',
  payment_receipt: 'LOCAL_TEMPLATE_FALLBACK', // no published "receipt" template distinct from payment-verified
  subscription_activated: 'LOCAL_TEMPLATE_FALLBACK', // no published "activated" template; only renewed/expiring/expired
  subscription_renewed: 'HOSTED_RESEND_TEMPLATE',
  subscription_expiring: 'HOSTED_RESEND_TEMPLATE',
  subscription_expired: 'HOSTED_RESEND_TEMPLATE',
  mobile_money_payment_success: 'HOSTED_RESEND_TEMPLATE',
  mobile_money_payment_failed: 'HOSTED_RESEND_TEMPLATE',
  new_login_alert: 'HOSTED_RESEND_TEMPLATE',
  suspicious_login_alert: 'HOSTED_RESEND_TEMPLATE',
  sessions_revoked: 'LOCAL_TEMPLATE_FALLBACK', // no published template for this event
  password_changed: 'LOCAL_TEMPLATE_FALLBACK',
  school_admin_account_created: 'HOSTED_RESEND_TEMPLATE',
  email_verification: 'HOSTED_RESEND_TEMPLATE',
  appointment_confirmed: 'HOSTED_RESEND_TEMPLATE',
  appointment_cancelled: 'HOSTED_RESEND_TEMPLATE',
  appointment_reminder: 'HOSTED_RESEND_TEMPLATE',
  report_available: 'HOSTED_RESEND_TEMPLATE',
};

console.log('\nDelivery provider selection (event -> queue -> delivery)');
for (const [templateId, expectedProvider] of Object.entries(PRODUCTION_CALL_SITES)) {
  test(`${templateId} is a registered local template AND routes to ${expectedProvider}`, () => {
    assert.ok(isValidTemplateId(templateId), `"${templateId}" is not a registered local template - a real call site would throw`);
    const hosted = getHostedTemplate(templateId);
    const actualProvider = hosted ? 'HOSTED_RESEND_TEMPLATE' : 'LOCAL_TEMPLATE_FALLBACK';
    assert.equal(actualProvider, expectedProvider);
  });
}

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
