const assert = require('node:assert/strict');
const test = require('node:test');
const admin = require('firebase-admin');
if (!admin.apps.length) admin.initializeApp({ projectId: 'school-pulse-test' });

const { __test__ } = require('../student_view');

test('identityView never leaks beyond the documented minimal field set', () => {
  const view = __test__.identityView({
    id: 's1', name: 'Jane', photoUrl: 'https://x/y.png', studentCode: 'SP001',
    classId: 'p6', streamId: 'east', status: 'active',
    // Sensitive fields that must NOT leak through identityView even though
    // they exist on the source student doc - this is the assertion that
    // matters: a future edit accidentally spreading `...student` into
    // identityView would fail this test immediately.
    parentIds: ['parent-1'], medicalInfo: { allergy: 'peanuts' },
    emergencyContacts: [{ phone: '0700000000' }],
  });
  assert.deepEqual(Object.keys(view).sort(), [
    'classId', 'id', 'name', 'photoUrl', 'status', 'streamId', 'studentCode',
  ].sort());
  assert.equal(view.parentIds, undefined);
  assert.equal(view.medicalInfo, undefined);
  assert.equal(view.emergencyContacts, undefined);
});

test('isClassTeacherFor requires a matching classId (and stream when both set)', () => {
  const student = { classId: 'p6', streamId: 'east' };
  assert.equal(__test__.isClassTeacherFor(
    [{ roleType: 'classTeacher', classId: 'p6', streamId: 'east' }], student,
  ), true);
  assert.equal(__test__.isClassTeacherFor(
    [{ roleType: 'classTeacher', classId: 'p5', streamId: 'east' }], student,
  ), false);
  assert.equal(__test__.isClassTeacherFor(
    [{ roleType: 'subjectTeacher', classId: 'p6', streamId: 'east' }], student,
  ), false, 'a subjectTeacher assignment must not satisfy the classTeacher check');
});

test('isSubjectTeacherFor is scoped to the class the subject is taught in, '
  + 'not "teaches this subject anywhere in the school"', () => {
  const student = { classId: 'p6', streamId: 'east' };
  assert.equal(__test__.isSubjectTeacherFor(
    [{ roleType: 'subjectTeacher', classId: 'p6', streamId: 'east', subjectId: 'math' }], student,
  ), true);
  assert.equal(__test__.isSubjectTeacherFor(
    // Same teacher, same subject, but a DIFFERENT class - the whole point
    // of the relationship check the spec asked for: holding
    // subject.marks.view generally must never let a teacher read every
    // student who happens to take that subject school-wide.
    [{ roleType: 'subjectTeacher', classId: 'p3', streamId: 'west', subjectId: 'math' }], student,
  ), false);
});

test('STAFF_ADMIN_ROLES is the exact admin-tier role set getStudentView '
  + 'grants AdminStudentView to, unconditionally', () => {
  assert.equal(__test__.STAFF_ADMIN_ROLES.has('schoolAdmin'), true);
  assert.equal(__test__.STAFF_ADMIN_ROLES.has('director'), true);
  assert.equal(__test__.STAFF_ADMIN_ROLES.has('headTeacher'), true);
  // A Bursar or Nurse must NOT be in this set - each is gated to their own
  // narrow section (finance/health) by role, not given the full admin view.
  assert.equal(__test__.STAFF_ADMIN_ROLES.has('bursar'), false);
  assert.equal(__test__.STAFF_ADMIN_ROLES.has('nurse'), false);
  assert.equal(__test__.STAFF_ADMIN_ROLES.has('classTeacher'), false);
});
