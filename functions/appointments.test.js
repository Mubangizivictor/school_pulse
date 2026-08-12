// Plain Node test runner (no framework dependency), matching the convention
// already used in public_functions/. Run with: node appointments.test.js
//
// This codebase has no unit-test harness of its own (only a Firestore-rules
// emulator target in package.json) and no existing precedent to extend, so
// this is a new, minimal, focused file - not new shared test infrastructure.
const assert = require('node:assert/strict');
const { classifyAppointmentStatusChange } = require('./appointments').__test__;

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

console.log('classifyAppointmentStatusChange()');

test('pending -> approved fires appointment_confirmed with a stable, appointmentId-keyed eventId', () => {
  const decision = classifyAppointmentStatusChange('appt_1', 'pending', 'approved');
  assert.deepEqual(decision, { templateId: 'appointment_confirmed', eventId: 'appointment_confirmed_appt_1' });
});

test('pending -> cancelled fires appointment_cancelled', () => {
  const decision = classifyAppointmentStatusChange('appt_1', 'pending', 'cancelled');
  assert.deepEqual(decision, { templateId: 'appointment_cancelled', eventId: 'appointment_cancelled_appt_1' });
});

test('approved -> rejected also fires appointment_cancelled (a decline after approval is still a cancellation to the requester)', () => {
  const decision = classifyAppointmentStatusChange('appt_1', 'approved', 'rejected');
  assert.deepEqual(decision, { templateId: 'appointment_cancelled', eventId: 'appointment_cancelled_appt_1' });
});

test('no status change (same before/after) fires nothing - an unrelated field write must not re-send', () => {
  assert.equal(classifyAppointmentStatusChange('appt_1', 'approved', 'approved'), null);
});

test('a transition to an unmapped status (e.g. completed) fires nothing', () => {
  assert.equal(classifyAppointmentStatusChange('appt_1', 'approved', 'completed'), null);
});

test('the SAME transition replayed twice produces the SAME eventId both times - this is what makes the queue idempotent, not a separate dedup mechanism here', () => {
  const first = classifyAppointmentStatusChange('appt_1', 'pending', 'approved');
  const second = classifyAppointmentStatusChange('appt_1', 'pending', 'approved');
  assert.equal(first.eventId, second.eventId);
});

test('different appointments produce different eventIds - never collide across appointments', () => {
  const a = classifyAppointmentStatusChange('appt_1', 'pending', 'approved');
  const b = classifyAppointmentStatusChange('appt_2', 'pending', 'approved');
  assert.notEqual(a.eventId, b.eventId);
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
