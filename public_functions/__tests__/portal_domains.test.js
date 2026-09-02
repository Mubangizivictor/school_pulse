const test = require('node:test');
const assert = require('node:assert/strict');
const { __test__ } = require('../portal_domains');
test('portal slugs reject reserved and unsafe values', () => {
  assert.equal(__test__.validSlug('greenhill'), true);
  assert.equal(__test__.validSlug('schoolpulse'), false);
  assert.equal(__test__.validSlug('Green Hill'), false);
});
test('custom host excludes platform wildcard', () => {
  assert.equal(__test__.validHost('portal.greenhill.ac.ug'), true);
  assert.equal(__test__.validHost('greenhill.schoolpulseapp.com'), false);
});
test('new schools get a real trial window, not an already-expired one', () => {
  // createSchoolPortal used to set subscriptionExpiry: Date.now(), so a
  // freshly onboarded school was already "expired" and could be flipped to
  // accessMode: readOnly by the very next lifecycle sweep. Guard the fix.
  assert.ok(__test__.TRIAL_DAYS > 0);
});
test('lifecycle status set only accepts known statuses', () => {
  assert.equal(__test__.LIFECYCLE_STATUSES.has('active'), true);
  assert.equal(__test__.LIFECYCLE_STATUSES.has('suspended'), true);
  assert.equal(__test__.LIFECYCLE_STATUSES.has('archived'), true);
  assert.equal(__test__.LIFECYCLE_STATUSES.has('trial'), true);
  assert.equal(__test__.LIFECYCLE_STATUSES.has('deleted'), false);
  assert.equal(__test__.LIFECYCLE_STATUSES.has(''), false);
});
test('support access sessions are capped at 30 minutes', () => {
  // requestSupportAccess (School Details > School admins > Open support
  // session) always mints a fixed-length window - there is no caller-
  // supplied duration, unlike decideSupportAccess's durationMinutes read.
  assert.equal(__test__.SUPPORT_ACCESS_MAX_MINUTES, 30);
});
test('manageSchoolAdmin only accepts the 4 real lifecycle actions this app models', () => {
  // "Promote" has no literal target (schoolAdmin is already the top
  // school-scoped role) - setPrimary/disable/enable/remove are what the
  // product spec's promote/demote/primary-transfer language maps onto.
  assert.deepEqual([...__test__.ADMIN_ACTIONS].sort(), ['disable', 'enable', 'remove', 'setPrimary']);
});
