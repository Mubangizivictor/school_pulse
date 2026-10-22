// Plain Node test runner (no framework dependency), matching the convention
// in approvals.test.js. Run with: node staff_default_permissions.test.js
//
// Regression guard for the bug where a Class Teacher account could be
// created successfully, have a correct classId assignment, and still see
// "Could not load dashboard - You do not have permission to perform this
// action" - because RESPONSIBILITY_DEFAULT_PERMISSIONS.classTeacher never
// granted class.students.view, which class_dashboard_repository_impl.dart
// and class_student_repository_impl.dart both require just to view the
// roster (not an elevated action - every permission here is scoped to the
// assignment's own classId/subjectId by PermissionScope).
const assert = require('node:assert/strict');
const { RESPONSIBILITY_DEFAULT_PERMISSIONS } = require('./index').__test__;

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

console.log('RESPONSIBILITY_DEFAULT_PERMISSIONS.classTeacher');

test('grants class.students.view - required just to load the dashboard/roster', () => {
  assert.ok(RESPONSIBILITY_DEFAULT_PERMISSIONS.classTeacher.includes('class.students.view'));
});

test('grants the full ordinary-teacher permission set the panel actually checks', () => {
  const required = [
    'class.students.view', 'class.attendance.take', 'class.attendance.view',
    'class.homework.create', 'class.behaviour.record', 'class.announcement.create',
    'class.report.entry', 'class.report.submit', 'class.resource.upload',
    'class.timetable.view',
  ];
  for (const permission of required) {
    assert.ok(
      RESPONSIBILITY_DEFAULT_PERMISSIONS.classTeacher.includes(permission),
      `missing ${permission}`,
    );
  }
});

test('does not grant Dean/Headteacher-tier report approval or the admin-only multi-assign override', () => {
  const excluded = [
    'class.report.approve.dean',
    'class.report.approve.headteacher',
    'class.teacher.multi_assign.override',
  ];
  for (const permission of excluded) {
    assert.ok(
      !RESPONSIBILITY_DEFAULT_PERMISSIONS.classTeacher.includes(permission),
      `should not grant ${permission} by default`,
    );
  }
});

console.log('RESPONSIBILITY_DEFAULT_PERMISSIONS.subjectTeacher');

test('grants subject.students.view - required just to load the roster', () => {
  assert.ok(RESPONSIBILITY_DEFAULT_PERMISSIONS.subjectTeacher.includes('subject.students.view'));
});

test('grants the full ordinary-teacher permission set the panel actually checks', () => {
  const required = [
    'subject.students.view', 'subject.attendance.take', 'subject.marks.enter',
    'subject.marks.view', 'subject.marks.submit', 'subject.lesson.view',
    'subject.resource.upload', 'subject.timetable.view',
  ];
  for (const permission of required) {
    assert.ok(
      RESPONSIBILITY_DEFAULT_PERMISSIONS.subjectTeacher.includes(permission),
      `missing ${permission}`,
    );
  }
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
