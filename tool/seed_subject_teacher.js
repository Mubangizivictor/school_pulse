#!/usr/bin/env node

/**
 * Seeds the data the Subject Teacher panel needs, on top of whatever the
 * demo school already has.
 *
 * Dry run: node tool/seed_subject_teacher.js
 * Apply:   node tool/seed_subject_teacher.js --apply
 *
 * Idempotent: every document is written to a deterministic id, so running it
 * twice produces the same state rather than a second copy of everything.
 *
 * Authentication comes from the active gcloud account, matching
 * tool/migrate_nurse_data.js. The access token stays in memory and is never
 * printed or written to disk.
 *
 * What it creates:
 *   academic_years/{year}, academic_terms/{year}-t{n}   - the calendar the
 *       panel scopes everything by. Nothing in the panel can be scoped
 *       without a current year, so its absence is why an unseeded project
 *       shows "No academic year set".
 *   schools/{school}/staff_role_assignments/...          - the responsibility
 *       rows. Without these every teacher sees "No teaching assignments",
 *       because the panel derives all access from them.
 *   schools/{school}/subject_enrollments/...             - who takes what.
 *   schools/{school}/lessons/...                         - a fortnight of
 *       timetabled periods either side of today.
 */

const { execFileSync } = require('node:child_process');

const projectId = process.env.FIREBASE_PROJECT_ID || 'school-pulse-3d95b';
const schoolId = process.env.SCHOOL_ID || 'school-pulse-academy';
const academicYearId = process.env.ACADEMIC_YEAR_ID || '2026';
const shouldApply = process.argv.includes('--apply');

const databaseRoot =
  `https://firestore.googleapis.com/v1/projects/${projectId}` +
  '/databases/(default)/documents';

const token = execFileSync(
  '/opt/homebrew/bin/gcloud',
  ['auth', 'print-access-token'],
  { encoding: 'utf8' },
).trim();

// ---------------------------------------------------------------------------
// Firestore REST helpers
// ---------------------------------------------------------------------------

function decodeValue(value) {
  if (!value) return null;
  if ('nullValue' in value) return null;
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('arrayValue' in value) {
    return (value.arrayValue.values || []).map(decodeValue);
  }
  if ('mapValue' in value) {
    return decodeFields(value.mapValue.fields || {});
  }
  return null;
}

function decodeFields(fields) {
  const out = {};
  for (const [key, value] of Object.entries(fields)) out[key] = decodeValue(value);
  return out;
}

function encodeValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(encodeValue) } };
  }
  if (typeof value === 'object') {
    return { mapValue: { fields: encodeFields(value) } };
  }
  throw new Error(`Cannot encode ${typeof value}`);
}

function encodeFields(data) {
  const out = {};
  for (const [key, value] of Object.entries(data)) out[key] = encodeValue(value);
  return out;
}

async function listAll(collectionPath) {
  const docs = [];
  let pageToken;
  do {
    const url = new URL(`${databaseRoot}/${collectionPath}`);
    url.searchParams.set('pageSize', '300');
    if (pageToken) url.searchParams.set('pageToken', pageToken);

    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!response.ok) {
      throw new Error(`GET ${collectionPath}: ${response.status} ${await response.text()}`);
    }
    const body = await response.json();
    for (const doc of body.documents || []) {
      docs.push({
        id: doc.name.split('/').pop(),
        ...decodeFields(doc.fields || {}),
      });
    }
    pageToken = body.nextPageToken;
  } while (pageToken);
  return docs;
}

let written = 0;
const plan = [];

async function setDoc(path, data) {
  plan.push(path);
  if (!shouldApply) return;

  const url = `${databaseRoot}/${path}`;
  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields: encodeFields(data) }),
  });
  if (!response.ok) {
    throw new Error(`PATCH ${path}: ${response.status} ${await response.text()}`);
  }
  written += 1;
}

// ---------------------------------------------------------------------------
// The permissions each kind of responsibility carries.
//
// Deliberately not "everything": the panel is meant to be exercised with
// realistic scopes, so a Subject Teacher here can enter and submit marks but
// cannot approve them, and cannot edit a mark once it has been submitted.
// ---------------------------------------------------------------------------

const subjectTeacherPermissions = [
  'subject.students.view',
  'subject.student.enroll',
  'subject.lesson.view',
  'subject.lesson.start',
  'subject.lesson.complete',
  'subject.attendance.take',
  'subject.attendance.edit',
  'subject.lesson_note.create',
  'subject.lesson_note.edit',
  'subject.resource.upload',
  'subject.resource.share',
  'subject.marks.view',
  'subject.marks.enter',
  'subject.marks.submit',
  'subject.marks.import',
  'subject.report.view',
  'subject.analytics.view',
  'subject.timetable.view',
  'subject.parent.message',
];

const classTeacherPermissions = [
  ...subjectTeacherPermissions,
  'subject.student.remove',
  'subject.report.generate',
  'subject.announcement.send',
];

// ---------------------------------------------------------------------------

function isoDate(year, month, day) {
  return new Date(Date.UTC(year, month - 1, day));
}

function startOfDay(date) {
  const copy = new Date(date);
  copy.setUTCHours(0, 0, 0, 0);
  return copy;
}

/** Deterministic pseudo-random so repeated runs give identical data. */
function seededPick(list, seed) {
  return list[Math.abs(hash(seed)) % list.length];
}

function hash(str) {
  let h = 0;
  for (let i = 0; i < str.length; i += 1) {
    h = (h * 31 + str.charCodeAt(i)) | 0;
  }
  return h;
}

async function main() {
  console.log(`${shouldApply ? 'APPLYING' : 'DRY RUN'} - project ${projectId}, school ${schoolId}\n`);

  const [students, subjects, classes, users] = await Promise.all([
    listAll('students'),
    listAll('subjects'),
    listAll('classes'),
    listAll('users'),
  ]);

  const schoolStudents = students.filter(
    (s) => s.schoolId === schoolId && s.status === 'active',
  );
  const teachers = users.filter(
    (u) =>
      u.schoolId === schoolId &&
      (u.role === 'subjectTeacher' || u.role === 'classTeacher'),
  );

  console.log(`Found ${schoolStudents.length} active students, ${subjects.length} subjects, ` +
    `${classes.length} classes, ${teachers.length} teachers.`);

  if (!teachers.length) {
    console.error('\nNo subjectTeacher/classTeacher users found - nothing to assign. ' +
      'Run the in-app AdminSeeder first.');
    process.exit(1);
  }

  // Students carry classId as the class *name* ("Primary 5"), while the
  // classes collection uses generated ids. The panel matches students by
  // whatever is on the student row, so assignments are keyed the same way -
  // otherwise every roster query would come back empty.
  const classNames = [...new Set(schoolStudents.map((s) => s.classId))].sort();
  console.log(`Class keys in use on student rows: ${classNames.join(', ')}\n`);

  // --- calendar -----------------------------------------------------------
  // Nothing in the panel can be scoped without a current year and term.
  const yearStart = isoDate(2026, 1, 5);
  const yearEnd = isoDate(2026, 12, 4);

  await setDoc(`academic_years/${academicYearId}`, {
    name: '2026',
    startDate: yearStart,
    endDate: yearEnd,
    isCurrent: true,
    isArchived: false,
  });

  const terms = [
    { n: 1, name: 'Term 1', start: isoDate(2026, 1, 5), end: isoDate(2026, 4, 10) },
    { n: 2, name: 'Term 2', start: isoDate(2026, 5, 4), end: isoDate(2026, 8, 14) },
    { n: 3, name: 'Term 3', start: isoDate(2026, 9, 7), end: isoDate(2026, 12, 4) },
  ];
  const now = new Date();
  const currentTerm =
    terms.find((t) => now >= t.start && now <= t.end) || terms[1];

  for (const term of terms) {
    await setDoc(`academic_terms/${academicYearId}-t${term.n}`, {
      academicYearId,
      name: term.name,
      order: term.n,
      startDate: term.start,
      endDate: term.end,
      isCurrent: term.n === currentTerm.n,
    });
  }
  const currentTermId = `${academicYearId}-t${currentTerm.n}`;
  console.log(`Calendar: ${academicYearId}, current term ${currentTerm.name}`);

  // --- responsibilities ---------------------------------------------------
  // Every teacher gets several subject assignments across several classes,
  // because the panel's whole point is one account holding many
  // responsibilities. Class teachers additionally keep their existing class.
  const assignments = [];
  const coreSubjects = subjects.filter((s) =>
    ['Mathematics', 'English', 'Science', 'SST'].includes(s.name),
  );
  const subjectPool = coreSubjects.length ? coreSubjects : subjects;

  for (const teacher of teachers) {
    // Two subjects x two classes each, picked deterministically so a re-run
    // does not reshuffle who teaches what.
    const primarySubject = seededPick(subjectPool, `${teacher.id}-primary`);
    const secondSubject =
      subjectPool.find((s) => s.id !== primarySubject.id) || primarySubject;

    const teacherClasses = [
      seededPick(classNames, `${teacher.id}-c1`),
      seededPick(classNames, `${teacher.id}-c2`),
    ];
    const uniqueClasses = [...new Set(teacherClasses)];

    for (const subject of [primarySubject, secondSubject]) {
      for (const className of uniqueClasses) {
        const id = `${teacher.id}_${subject.id}_${className}`.replace(/[^\w-]/g, '-');
        assignments.push({
          id,
          teacher,
          subjectId: subject.id,
          subjectName: subject.name,
          classId: className,
          className,
          roleType: 'subjectTeacher',
        });
      }
    }

    if (teacher.role === 'classTeacher' && teacher.assignedClass) {
      const id = `${teacher.id}_classteacher_${teacher.assignedClass}`.replace(/[^\w-]/g, '-');
      assignments.push({
        id,
        teacher,
        subjectId: null,
        subjectName: null,
        classId: teacher.assignedClass,
        className: teacher.assignedClass,
        roleType: 'classTeacher',
      });
    }
  }

  for (const a of assignments) {
    await setDoc(`schools/${schoolId}/staff_role_assignments/${a.id}`, {
      schoolId,
      campusId: '',
      // staffId and userId are the same value in this demo data; the model
      // keeps them separate because a staff profile outlives a login.
      staffId: a.teacher.id,
      userId: a.teacher.id,
      roleType: a.roleType,
      academicYearId,
      subjectId: a.subjectId,
      subjectName: a.subjectName,
      classId: a.classId,
      className: a.className,
      streamId: null,
      streamName: null,
      startDate: yearStart,
      endDate: null,
      status: 'active',
      permissionScope: {
        permissions:
          a.roleType === 'classTeacher'
            ? classTeacherPermissions
            : subjectTeacherPermissions,
        termIds: [],
      },
      assignedBy: 'seed',
      assignedAt: new Date(),
    });
  }
  console.log(`Assignments: ${assignments.length}`);

  // --- subject enrollment -------------------------------------------------
  // Core subjects are mandatory for everyone in the class; the rest are
  // electives taken by roughly two thirds, so the Students tab genuinely
  // differs from the class list - which is the behaviour worth testing.
  const mandatoryNames = new Set(['Mathematics', 'English', 'Science', 'SST']);
  let enrollmentCount = 0;

  const assignedPairs = new Set(
    assignments
      .filter((a) => a.subjectId)
      .map((a) => `${a.subjectId}|${a.classId}`),
  );

  for (const pair of assignedPairs) {
    const [subjectId, className] = pair.split('|');
    const subject = subjects.find((s) => s.id === subjectId);
    const mandatory = mandatoryNames.has(subject?.name);
    const cohort = schoolStudents.filter((s) => s.classId === className);

    for (const student of cohort) {
      const takesIt =
        mandatory || Math.abs(hash(`${student.id}${subjectId}`)) % 3 !== 0;
      if (!takesIt) continue;

      await setDoc(
        `schools/${schoolId}/subject_enrollments/${student.id}_${subjectId}_${academicYearId}`,
        {
          schoolId,
          campusId: '',
          studentId: student.id,
          subjectId,
          classId: className,
          streamId: null,
          academicYearId,
          status: 'active',
          roleAssignmentId: 'seed',
          isMandatory: mandatory,
          enrolledAt: yearStart,
          enrolledBy: 'seed',
          effectiveFrom: yearStart,
        },
      );
      enrollmentCount += 1;
    }
  }
  console.log(`Enrollments: ${enrollmentCount}`);

  // --- lessons ------------------------------------------------------------
  // A fortnight either side of today, so the dashboard has a lesson to show
  // now, some history behind it and something upcoming.
  const periods = [
    { hour: 8, minute: 0 },
    { hour: 10, minute: 0 },
    { hour: 14, minute: 0 },
  ];
  let lessonCount = 0;
  const today = startOfDay(now);

  for (const a of assignments.filter((x) => x.subjectId)) {
    for (let offset = -7; offset <= 7; offset += 1) {
      const day = new Date(today);
      day.setUTCDate(day.getUTCDate() + offset);
      // Weekdays only.
      if (day.getUTCDay() === 0 || day.getUTCDay() === 6) continue;

      // Each assignment gets one period per weekday, chosen deterministically
      // so the timetable is stable across runs.
      const period = periods[Math.abs(hash(`${a.id}${day.getUTCDay()}`)) % periods.length];
      // Roughly two periods a week per assignment rather than one a day.
      if (Math.abs(hash(`${a.id}-${offset}`)) % 5 > 1) continue;

      const start = new Date(day);
      start.setUTCHours(period.hour, period.minute, 0, 0);
      const end = new Date(start);
      end.setUTCMinutes(end.getUTCMinutes() + 45);

      const lessonId = `${a.id}_${start.toISOString().slice(0, 10)}_${period.hour}`;
      const isPast = end < now;

      await setDoc(`schools/${schoolId}/lessons/${lessonId}`, {
        schoolId,
        campusId: '',
        academicYearId,
        termId: currentTermId,
        subjectId: a.subjectId,
        subjectName: a.subjectName,
        classId: a.classId,
        className: a.className,
        streamId: null,
        streamName: null,
        timetableSlotId: `${a.id}-p${period.hour}`,
        teacherStaffId: a.teacher.id,
        substituteStaffId: null,
        title: `${a.subjectName} - ${a.className}`,
        topic: null,
        subtopic: null,
        scheduledStart: start,
        scheduledEnd: end,
        actualStart: null,
        actualEnd: null,
        room: `Room ${(Math.abs(hash(a.id)) % 12) + 1}`,
        // Past periods are left 'scheduled' rather than pre-completed, so the
        // start-lesson and register flows are actually exercisable on them.
        status: 'scheduled',
        statusReason: null,
        enrolledCount: 0,
        attendanceSubmitted: false,
        lessonNoteCount: 0,
        resourceCount: 0,
        relatedAssessmentId: null,
        seededPast: isPast,
      });
      lessonCount += 1;
    }
  }
  console.log(`Lessons: ${lessonCount}`);

  console.log(`\n${plan.length} documents ${shouldApply ? `written (${written} confirmed)` : 'would be written'}.`);
  if (!shouldApply) {
    console.log('Re-run with --apply to write them.');
  } else {
    console.log('\nSign in as one of:');
    for (const t of teachers) console.log(`  ${t.email}  (${t.role})`);
  }
}

main().catch((error) => {
  console.error(`\nFailed: ${error.message}`);
  process.exit(1);
});
