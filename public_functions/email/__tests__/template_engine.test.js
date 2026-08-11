// Plain Node test runner (no framework dependency) for the email template
// engine. Run with: node email/__tests__/template_engine.test.js
const assert = require('node:assert/strict');
const { TEMPLATES, TEMPLATE_IDS, getTemplate, isValidTemplateId } = require('../template_registry');
const { renderBaseTemplate, renderPlainText } = require('../base_template');
const { escapeHtml, humanReference, sanitizeHeaderValue } = require('../email_helpers');

const REQUIRED_TEMPLATE_IDS = [
  'application_received', 'application_approved', 'application_rejected', 'application_more_info_required',
  'payment_proof_received', 'manual_payment_approved', 'manual_payment_rejected',
  'mobile_money_payment_success', 'mobile_money_payment_failed', 'payment_reversed', 'payment_receipt',
  'subscription_activated', 'subscription_renewed', 'subscription_expiring', 'subscription_expired',
  'subscription_suspended', 'subscription_reactivated', 'payment_overdue',
  'school_admin_account_created', 'staff_account_created', 'password_reset', 'password_changed',
  'new_login_alert', 'suspicious_login_alert', 'sessions_revoked', 'account_locked', 'account_reactivated',
  'appointment_requested', 'appointment_confirmed', 'appointment_rescheduled', 'appointment_cancelled', 'appointment_reminder',
  'report_available', 'report_published',
  'important_announcement', 'support_update', 'billing_action_required',
];

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

console.log('Registry coverage');
test('all required template ids are registered', () => {
  for (const id of REQUIRED_TEMPLATE_IDS) {
    assert.ok(isValidTemplateId(id), `missing template id "${id}"`);
  }
});
test('registry exposes exactly the required ids (no silent extras/omissions)', () => {
  const registered = new Set(TEMPLATE_IDS);
  const required = new Set(REQUIRED_TEMPLATE_IDS);
  for (const id of required) assert.ok(registered.has(id), `required id "${id}" not registered`);
  assert.equal(registered.size, required.size, `registry has ${registered.size} ids, expected ${required.size}`);
});
test('unknown template id throws', () => {
  assert.throws(() => getTemplate('not_a_real_template'), /Unknown email template id/);
});

console.log('\nRender: every template renders html + plain text without throwing');
for (const id of TEMPLATE_IDS) {
  test(`${id} renders complete output`, () => {
    const renderer = TEMPLATES[id];
    const sampleData = {
      schoolName: 'Kampala Junior School', applicationId: 'app_123', paymentId: 'pay_456',
      appointmentId: 'apt_789', reportId: 'rpt_101', reportName: 'Term 1 Report',
      email: 'admin@example.com', amount: 150000, amountLabel: 'UGX 150,000',
      methodLabel: 'MTN Mobile Money', planLabel: 'Growth', expiryLabel: '1 January 2027',
      reason: 'Missing documents', message: 'This is an announcement.', title: 'Heads up',
      withLabel: 'Mrs. Nakato', requestedTimeLabel: '10:00 AM', timeLabel: '10:00 AM',
      newTimeLabel: '11:00 AM', previousTimeLabel: '10:00 AM', locationLabel: 'Main office',
      deviceLabel: 'iPhone 17 Pro Max', locationLabel2: 'Kampala, Uganda', whenLabel: '11 August 2026',
      roleLabel: 'Class Teacher', dueDateLabel: '20 August 2026', periodLabel: 'Term 1 2026',
      publishedByLabel: 'System', ticketReference: 'SP-TCK-000001', statusLabel: 'In progress',
    };
    const rendered = renderer(sampleData);
    assert.ok(rendered.subject && rendered.subject.length > 0, 'subject missing');
    assert.ok(rendered.title && rendered.title.length > 0, 'title missing');
    const html = renderBaseTemplate(rendered);
    assert.match(html, /<!doctype html>/i);
    assert.match(html, /School Pulse/);
    const plain = renderPlainText(rendered);
    assert.ok(plain.length > 0, 'plain text empty');
  });
}

console.log('\nEscaping');
test('escapeHtml neutralizes script tags and quotes', () => {
  const malicious = '<script>alert("xss")</script>';
  const escaped = escapeHtml(malicious);
  assert.ok(!escaped.includes('<script>'), 'raw <script> tag leaked through');
  assert.ok(escaped.includes('&lt;script&gt;'));
});
test('user-supplied schoolName cannot inject markup into rendered html', () => {
  const malicious = '<img src=x onerror=alert(1)>Evil School';
  const rendered = TEMPLATES.application_received({ schoolName: malicious, applicationId: 'app_1' });
  const html = renderBaseTemplate(rendered);
  assert.ok(!html.includes('<img src=x onerror=alert(1)>'), 'unescaped injection payload found in output html');
  assert.ok(html.includes('&lt;img'), 'expected escaped payload in output html');
});
test('info card values are escaped', () => {
  const rendered = TEMPLATES.manual_payment_rejected({
    schoolName: 'Test School',
    paymentId: 'pay_1',
    amountLabel: 'UGX 1,000',
    reason: '"><script>alert(1)</script>',
  });
  const html = renderBaseTemplate(rendered);
  assert.ok(!html.includes('<script>alert(1)</script>'), 'reason field injected raw script tag');
});
test('CTA url is attribute-escaped', () => {
  const html = renderBaseTemplate({
    title: 'Test', bodyHtml: '<p>hi</p>',
    cta: { label: 'Click', url: '"><script>alert(1)</script>' },
  });
  assert.ok(!html.includes('<script>alert(1)</script>'), 'cta url injected raw script tag');
});

console.log('\nMissing data handling');
test('template with entirely empty data does not throw', () => {
  for (const id of TEMPLATE_IDS) {
    assert.doesNotThrow(() => TEMPLATES[id]({}), `${id} threw on empty data`);
  }
});
test('info card rows with missing values are silently dropped, not rendered blank', () => {
  const rendered = TEMPLATES.application_rejected({ schoolName: 'Test School' });
  const html = renderBaseTemplate(rendered);
  assert.ok(!html.includes('Reason</td>\n      <td'), 'blank reason row should be dropped');
});
test('renderBaseTemplate handles fully missing optional params', () => {
  assert.doesNotThrow(() => renderBaseTemplate({ title: 'Only a title' }));
});

console.log('\nPlain text output');
test('plain text includes title and support email, excludes html tags', () => {
  const rendered = TEMPLATES.password_reset({ email: 'user@example.com', resetUrl: 'https://schoolpulse.victorbee.com/reset' });
  const plain = renderPlainText(rendered);
  assert.ok(plain.includes('Reset your password'));
  assert.ok(plain.includes('support@schoolpulse.victorbee.com'));
  assert.ok(!/<[a-z][\s\S]*>/i.test(plain), 'plain text should not contain html tags');
});

console.log('\nGmail-safe HTML');
test('html uses only table-based layout and inline styles (no <style> blocks, no external assets)', () => {
  const rendered = TEMPLATES.subscription_activated({ schoolName: 'Test School', planLabel: 'Pro', expiryLabel: '1 Jan 2027' });
  const html = renderBaseTemplate(rendered);
  assert.ok(!/<style[\s>]/i.test(html), 'style blocks are stripped by Gmail; must not rely on them');
  assert.ok(!/<link[\s>]/i.test(html), 'external stylesheet links are stripped by Gmail');
  assert.match(html, /<table/i);
});

console.log('\nHuman reference generation');
test('humanReference produces stable SP-XXX-YYYY-NNNNNN format', () => {
  const ref = humanReference('application', 'app_123', new Date('2026-01-01'));
  assert.match(ref, /^SP-APP-2026-\d{6}$/);
});
test('humanReference is deterministic for the same input', () => {
  const a = humanReference('payment', 'pay_abc', new Date('2026-01-01'));
  const b = humanReference('payment', 'pay_abc', new Date('2026-01-01'));
  assert.equal(a, b);
});
test('raw internal Firestore id never appears in rendered application email', () => {
  const internalId = 'firestore_internal_doc_id_98765';
  const rendered = TEMPLATES.application_received({ schoolName: 'Test School', applicationId: internalId });
  const html = renderBaseTemplate(rendered);
  assert.ok(!html.includes(internalId), 'internal id leaked into applicant-facing email');
});

console.log('\nSubject header injection');
test('sanitizeHeaderValue strips CR/LF so a caller cannot inject extra email headers', () => {
  const malicious = 'Hi\r\nBcc: attacker@evil.com\r\nX-Injected: true';
  const sanitized = sanitizeHeaderValue(malicious);
  assert.ok(!sanitized.includes('\r') && !sanitized.includes('\n'), 'newline survived sanitization');
  assert.ok(!/^Bcc:/m.test(sanitized), 'injected header line survived sanitization');
});
test('important_announcement subject override cannot inject headers once sanitized', () => {
  const rendered = TEMPLATES.important_announcement({
    subject: 'Hi\r\nBcc: attacker@evil.com',
    message: 'test',
  });
  const sanitized = sanitizeHeaderValue(rendered.subject);
  assert.ok(!sanitized.includes('\r') && !sanitized.includes('\n'));
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
