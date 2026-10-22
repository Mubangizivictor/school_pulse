// Pure-logic unit tests for public_functions/subscription_cycle_billing.js's
// `decideCycleAction` - the state-machine decision function the hourly sweep
// calls per cycle. Does NOT require the Firebase emulator, mirroring how
// functions/academic_calendar_billing.test.js tests `_validateTerms` in
// isolation. Emulator-backed integration coverage (actual Firestore writes,
// suspendSchoolCore parity, approveManualPayment cycle-marking) lives in
// public_functions/test/subscription_cycle_billing.emulator.test.cjs.
const test = require('node:test');
const assert = require('node:assert/strict');
const { _decideCycleAction, DEFAULT_INVOICE_LEAD_DAYS } = require('../subscription_cycle_billing');

const DAY_MS = 24 * 60 * 60 * 1000;

function cycle(overrides) {
  const termStart = new Date('2026-05-01T00:00:00Z');
  const paymentDueAt = termStart; // paymentDueAt derives from termStart per Phase 1
  const graceEndsAt = new Date(termStart.getTime() + 7 * DAY_MS);
  return {
    cycleStatus: 'upcoming',
    termStart,
    paymentDueAt,
    graceEndsAt,
    ...overrides,
  };
}

test('upcoming: no transition before the invoice lead window opens', () => {
  const c = cycle();
  const nowMs = c.termStart.getTime() - (DEFAULT_INVOICE_LEAD_DAYS + 1) * DAY_MS;
  const action = _decideCycleAction(c, nowMs, { invoiceLeadDays: DEFAULT_INVOICE_LEAD_DAYS });
  assert.equal(action.transition, null);
  assert.deepEqual(action.reminders, []);
  assert.equal(action.suspend, false);
});

test('upcoming: invoices exactly at the lead-time boundary (not before)', () => {
  const c = cycle();
  const boundaryMs = c.termStart.getTime() - DEFAULT_INVOICE_LEAD_DAYS * DAY_MS;
  const justBefore = _decideCycleAction(c, boundaryMs - 1, { invoiceLeadDays: DEFAULT_INVOICE_LEAD_DAYS });
  assert.equal(justBefore.transition, null);
  const atBoundary = _decideCycleAction(c, boundaryMs, { invoiceLeadDays: DEFAULT_INVOICE_LEAD_DAYS });
  assert.equal(atBoundary.transition, 'invoiced');
});

test('invoiced: due_minus_3 reminder tier fires in its window', () => {
  const c = cycle({ cycleStatus: 'invoiced' });
  const nowMs = c.paymentDueAt.getTime() - 2 * DAY_MS;
  const action = _decideCycleAction(c, nowMs, {});
  assert.ok(action.reminders.includes('due_minus_3'));
  assert.ok(!action.reminders.includes('due_today'));
});

test('invoiced: due_today reminder fires on/after paymentDueAt', () => {
  const c = cycle({ cycleStatus: 'invoiced' });
  const action = _decideCycleAction(c, c.paymentDueAt.getTime(), {});
  assert.ok(action.reminders.includes('due_today'));
});

test('invoiced -> gracePeriod: transitions the moment paymentDueAt has passed, within grace window', () => {
  const c = cycle({ cycleStatus: 'invoiced' });
  const nowMs = c.paymentDueAt.getTime() + DAY_MS;
  const action = _decideCycleAction(c, nowMs, {});
  assert.equal(action.transition, 'gracePeriod');
});

test('paymentPending behaves identically to invoiced (documented synonym)', () => {
  const invoicedCycle = cycle({ cycleStatus: 'invoiced' });
  const pendingCycle = cycle({ cycleStatus: 'paymentPending' });
  const nowMs = invoicedCycle.paymentDueAt.getTime() + DAY_MS;
  const invoicedAction = _decideCycleAction(invoicedCycle, nowMs, {});
  const pendingAction = _decideCycleAction(pendingCycle, nowMs, {});
  assert.equal(pendingAction.transition, invoicedAction.transition);
});

test('gracePeriod: grace_minus_2 reminder tier fires in its window', () => {
  const c = cycle({ cycleStatus: 'gracePeriod' });
  const nowMs = c.graceEndsAt.getTime() - DAY_MS;
  const action = _decideCycleAction(c, nowMs, {});
  assert.ok(action.reminders.includes('grace_minus_2'));
});

test('gracePeriod -> overdue: transitions the moment graceEndsAt has passed, and requests suspension', () => {
  const c = cycle({ cycleStatus: 'gracePeriod' });
  const nowMs = c.graceEndsAt.getTime() + DAY_MS;
  const action = _decideCycleAction(c, nowMs, {});
  assert.equal(action.transition, 'overdue');
  assert.equal(action.suspend, true);
});

test('gracePeriod: does not transition to overdue before graceEndsAt', () => {
  const c = cycle({ cycleStatus: 'gracePeriod' });
  const nowMs = c.graceEndsAt.getTime() - 1;
  const action = _decideCycleAction(c, nowMs, {});
  assert.equal(action.transition, null);
});

test('overdue: keeps requesting suspension every pass (idempotency lives in suspendSchoolCore, not here)', () => {
  const c = cycle({ cycleStatus: 'overdue' });
  const nowMs = c.graceEndsAt.getTime() + 30 * DAY_MS;
  const action = _decideCycleAction(c, nowMs, {});
  assert.equal(action.transition, null); // cycleStatus stays 'overdue' - no new transition value
  assert.equal(action.suspend, true);
});

test('paid/cancelled/expired cycles are always skipped entirely, regardless of dates', () => {
  for (const status of ['paid', 'cancelled', 'expired']) {
    const c = cycle({ cycleStatus: status, graceEndsAt: new Date('2020-01-01') });
    const action = _decideCycleAction(c, Date.now(), {});
    assert.equal(action.transition, null, `${status} must not transition`);
    assert.deepEqual(action.reminders, [], `${status} must not get reminders`);
    assert.equal(action.suspend, false, `${status} must not suspend`);
  }
});

test('reminder tiers each fire independently and do not duplicate across separate decision calls with the same now', () => {
  const c = cycle({ cycleStatus: 'gracePeriod' });
  // Right at the boundary where both due_today and grace_minus_2 windows could overlap.
  const nowMs = c.graceEndsAt.getTime() - 2 * DAY_MS;
  const action = _decideCycleAction(c, nowMs, {});
  // due_today should also be true here since paymentDueAt (== termStart) is long past.
  assert.ok(action.reminders.includes('due_today'));
  assert.ok(action.reminders.includes('grace_minus_2'));
  // No duplicate entries within the same tier.
  assert.equal(action.reminders.filter((t) => t === 'grace_minus_2').length, 1);
});
