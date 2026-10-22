const test = require('node:test');
const assert = require('node:assert/strict');
const { __test__ } = require('../school_counts');

test('active student statuses mirror kStatusGroups[StudentStatusGroup.active] in admin_students_dashboard_screen.dart', () => {
  // The one place "active enrollment" is already defined in this app - do
  // not let this list drift from that Dart map.
  assert.deepEqual(__test__.ACTIVE_STUDENT_STATUSES, ['active', 'enrolled']);
});

test('active student statuses exclude withdrawn/graduated/alumni/applicant', () => {
  for (const excluded of ['withdrawn', 'graduated', 'alumni', 'applicant', 'pendingAdmission', 'suspended']) {
    assert.equal(__test__.ACTIVE_STUDENT_STATUSES.includes(excluded), false);
  }
});

test('staff count excludes only parent and student, not superAdmin explicitly (superAdmin never has a schoolId to match)', () => {
  assert.deepEqual(__test__.NON_STAFF_ROLES, ['parent', 'student']);
});
