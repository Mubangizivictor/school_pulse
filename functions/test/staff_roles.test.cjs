const assert = require('node:assert/strict');
const test = require('node:test');

// index.js calls admin.initializeApp() unconditionally on load - unlike the
// submodule test files in this directory, don't pre-initialize here.
const { __test__ } = require('../index');

test('STAFF_ROLES accepts admissions and registrar, matching the client UserRole enum addition', () => {
  assert.ok(__test__.STAFF_ROLES.includes('admissions'));
  assert.ok(__test__.STAFF_ROLES.includes('registrar'));
});

test('admissions/registrar are not staff-inviting ADMIN_ROLES', () => {
  assert.ok(!__test__.ADMIN_ROLES.includes('admissions'));
  assert.ok(!__test__.ADMIN_ROLES.includes('registrar'));
});
