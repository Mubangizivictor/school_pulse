// Plain Node test runner (no framework dependency) for owner sign-in email
// selection. Run with: node __tests__/owner_sign_in_email.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { classifySignInEmail } = require('../owner_sign_in_events').__test__;

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

console.log('classifySignInEmail()');

test('a normal (non-suspicious) sign-in fires new_login_alert exactly once, keyed to the sign-in event id', () => {
  const decision = classifySignInEmail(false, 'evt_1');
  assert.deepEqual(decision, { templateId: 'new_login_alert', eventId: 'new_login_evt_1' });
});

test('a suspicious sign-in fires suspicious_login_alert instead, never both', () => {
  const decision = classifySignInEmail(true, 'evt_1');
  assert.deepEqual(decision, { templateId: 'suspicious_login_alert', eventId: 'suspicious_login_evt_1' });
});

test('eventIds for the two outcomes never collide for the same sign-in event id', () => {
  const normal = classifySignInEmail(false, 'evt_1');
  const suspicious = classifySignInEmail(true, 'evt_1');
  assert.notEqual(normal.eventId, suspicious.eventId);
});

test('different sign-in events produce different eventIds - one email per actual sign-in, not per owner', () => {
  const a = classifySignInEmail(false, 'evt_1');
  const b = classifySignInEmail(false, 'evt_2');
  assert.notEqual(a.eventId, b.eventId);
});

console.log('\nRaw IP is never used as location in the email payload');
test('emailData construction never references `ip` — only email/deviceLabel/platform/whenLabel', () => {
  // Source-level check rather than a mock: the previous incident (caught in
  // an earlier task) was `locationLabel: ip` being passed straight through
  // to the hosted template. Grepping the actual source for the emailData
  // literal proves it structurally cannot happen again, not just that a
  // particular test input didn't trigger it.
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_sign_in_events.js'), 'utf8');
  const match = source.match(/const emailData = (\{[^}]*\});/);
  assert.ok(match, 'could not locate the emailData object literal in owner_sign_in_events.js');
  assert.ok(!match[1].includes('ip'), `emailData literal must never reference ip: ${match[1]}`);
  assert.ok(!match[1].includes('locationLabel'), 'emailData must not set locationLabel to anything but the hosted template\'s own safe fallback');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
