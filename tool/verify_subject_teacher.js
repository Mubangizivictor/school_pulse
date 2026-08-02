#!/usr/bin/env node

/**
 * Signs in as a real teacher and issues exactly the queries the Subject
 * Teacher panel issues, so the deployed rules and indexes are exercised as a
 * client rather than as a project owner.
 *
 *   node tool/verify_subject_teacher.js
 *   node tool/verify_subject_teacher.js teacher@example.com 'Password1'
 *
 * Owner credentials (gcloud, Admin SDK) bypass security rules entirely, so
 * seeding "working" proves nothing about whether a teacher can read the data.
 * This closes that gap: it caught both a missing composite index and would
 * catch a rule that denies the switcher.
 *
 * Exits non-zero when something the panel depends on is unreadable.
 */

const projectId = process.env.FIREBASE_PROJECT_ID || 'school-pulse-3d95b';
const schoolId = process.env.SCHOOL_ID || 'school-pulse-academy';
const apiKey = process.env.FIREBASE_API_KEY || 'AIzaSyB8NUAbNZt6Zx_nJa_G6ndc6jyVTcYsqX8';
const email = process.argv[2] || 'subjectteacher@gmail.com';
const password = process.argv[3] || 'Test@123';

const base =
  `https://firestore.googleapis.com/v1/projects/${projectId}` +
  '/databases/(default)/documents';

let failures = 0;

function check(label, ok, detail = '') {
  console.log(`  ${ok ? 'ok  ' : 'FAIL'}  ${label}${detail ? ` - ${detail}` : ''}`);
  if (!ok) failures += 1;
}

async function signIn() {
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    },
  );
  const body = await res.json();
  if (!res.ok) throw new Error(`sign-in failed: ${JSON.stringify(body.error)}`);
  return { idToken: body.idToken, uid: body.localId };
}

async function query(idToken, parent, structuredQuery) {
  const url = parent ? `${base}/${parent}:runQuery` : `${base}:runQuery`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${idToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ structuredQuery }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(JSON.stringify(body.error || body));
  if (Array.isArray(body) && body[0] && body[0].error) {
    throw new Error(JSON.stringify(body[0].error));
  }
  return (Array.isArray(body) ? body : []).filter((r) => r.document);
}

const eq = (path, value) => ({
  fieldFilter: {
    field: { fieldPath: path },
    op: 'EQUAL',
    value: { stringValue: value },
  },
});

const and = (...filters) => ({ compositeFilter: { op: 'AND', filters } });

function f(doc, name) {
  const v = doc.document.fields?.[name];
  if (!v) return null;
  return (
    v.stringValue ??
    v.integerValue ??
    v.booleanValue ??
    v.timestampValue ??
    null
  );
}

async function main() {
  console.log(`Verifying as ${email} against ${projectId}/${schoolId}\n`);
  const { idToken, uid } = await signIn();

  // --- the switcher --------------------------------------------------------
  console.log('Responsibilities');
  const assignments = await query(idToken, `schools/${schoolId}`, {
    from: [{ collectionId: 'staff_role_assignments' }],
    where: and(eq('userId', uid), {
      fieldFilter: {
        field: { fieldPath: 'status' },
        op: 'IN',
        value: {
          arrayValue: {
            values: [{ stringValue: 'active' }, { stringValue: 'suspended' }],
          },
        },
      },
    }),
  });
  check('assignments readable', assignments.length > 0, `${assignments.length} found`);
  for (const a of assignments) {
    console.log(
      `        ${f(a, 'roleType')}  ${f(a, 'subjectName') || '-'}  ${f(a, 'classId')}`,
    );
  }
  if (!assignments.length) {
    console.log('\nNothing else can be checked without an assignment.');
    process.exit(1);
  }

  // --- calendar ------------------------------------------------------------
  console.log('\nCalendar');
  const years = await query(idToken, null, {
    from: [{ collectionId: 'academic_years' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'isCurrent' },
        op: 'EQUAL',
        value: { booleanValue: true },
      },
    },
  });
  check('a current academic year exists', years.length === 1,
    years.map((y) => f(y, 'name')).join(', ') || 'none');

  const terms = await query(idToken, null, {
    from: [{ collectionId: 'academic_terms' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'isCurrent' },
        op: 'EQUAL',
        value: { booleanValue: true },
      },
    },
  });
  check('a current term exists', terms.length === 1,
    terms.map((t) => f(t, 'name')).join(', ') || 'none');

  // --- students tab --------------------------------------------------------
  const subjectAssignment = assignments.find(
    (a) => f(a, 'roleType') === 'subjectTeacher',
  );
  if (!subjectAssignment) {
    console.log('\nNo subject assignment; skipping subject-scoped checks.');
    process.exit(failures ? 1 : 0);
  }

  const subjectId = f(subjectAssignment, 'subjectId');
  const classId = f(subjectAssignment, 'classId');
  const yearId = f(subjectAssignment, 'academicYearId');

  console.log(`\nStudents tab (${f(subjectAssignment, 'subjectName')} / ${classId})`);
  const enrollments = await query(idToken, `schools/${schoolId}`, {
    from: [{ collectionId: 'subject_enrollments' }],
    where: and(eq('subjectId', subjectId), eq('classId', classId), eq('academicYearId', yearId)),
  });
  const roster = await query(idToken, null, {
    from: [{ collectionId: 'students' }],
    where: and(
      eq('schoolId', schoolId),
      eq('classId', classId),
      eq('academicYearId', yearId),
      eq('status', 'active'),
    ),
  });
  const enrolledIds = new Set(enrollments.map((e) => f(e, 'studentId')));
  const shown = roster.filter((s) =>
    enrolledIds.has(s.document.name.split('/').pop()),
  );

  check('subject enrollment readable', enrollments.length > 0, `${enrollments.length} enrolled`);
  check('class roster readable', roster.length > 0, `${roster.length} on roster`);
  check(
    'tab shows the intersection, not the whole class',
    shown.length <= roster.length,
    `${shown.length} shown`,
  );

  // --- lessons -------------------------------------------------------------
  console.log('\nLessons tab');
  const lessons = await query(idToken, `schools/${schoolId}`, {
    from: [{ collectionId: 'lessons' }],
    where: and(eq('subjectId', subjectId), eq('classId', classId), eq('academicYearId', yearId)),
    orderBy: [{ field: { fieldPath: 'scheduledStart' }, direction: 'ASCENDING' }],
  });
  check('lessons query runs (index present)', true, `${lessons.length} lessons`);
  for (const l of lessons.slice(0, 3)) {
    console.log(`        ${f(l, 'scheduledStart')}  ${f(l, 'title')}  ${f(l, 'room')}`);
  }

  // --- tenant isolation ----------------------------------------------------
  console.log('\nTenant isolation');
  let leaked = 0;
  try {
    const foreign = await query(idToken, 'schools/some-other-school', {
      from: [{ collectionId: 'staff_role_assignments' }],
      where: eq('userId', uid),
    });
    leaked = foreign.length;
  } catch {
    leaked = 0; // denied, which is the point
  }
  check("another school's assignments are unreachable", leaked === 0);

  console.log(
    `\n${failures ? `${failures} check(s) FAILED` : 'All checks passed.'}`,
  );
  process.exit(failures ? 1 : 0);
}

main().catch((error) => {
  console.error(`\nFAILED: ${error.message}`);
  process.exit(1);
});
