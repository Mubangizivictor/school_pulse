/**
 * Seeds a complete demo school into the LOCAL EMULATOR ONLY, so every
 * Phase 1+ step has realistic data to test against:
 *
 *   1 school (+ institution_profile), 1 academic year with 2 terms,
 *   6 classes, 4 subjects, 10 staff (admin, headteacher, bursar, 6 class
 *   teachers, 1 subject teacher), 60 students (10 per class) with
 *   identities, 40 parents (parent_access_codes + parent_student_relationships,
 *   never more than 2 parents per student).
 *
 * Document shapes mirror seed_primary_demo.js / seed_empty_admin.js, which
 * mirror what the app reads, so screens resolve the same way they do there.
 *
 * Safety: refuses to run unless FIRESTORE_EMULATOR_HOST and
 * FIREBASE_AUTH_EMULATOR_HOST are both set, so the Admin SDK can never
 * reach a real project. Idempotent: fixed doc ids + set(), re-run freely.
 *
 * Run (emulators already up, e.g. `firebase emulators:start`):
 *   cd functions && npm run seed:demo-school
 * Sign in with any seeded email and password Demo@1234; parents use their
 * access code (DEMOP001..DEMOP040) with PIN 1234.
 */
const admin = require('firebase-admin');
const {
  CLASS_TEACHER_PERMISSIONS,
  SUBJECT_TEACHER_PERMISSIONS,
} = require('./demo_teacher_permissions');

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    'Refusing to seed: FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST ' +
    'must both be set (this script is emulator-only).'
  );
  process.exit(1);
}

// The app's firebase_options point at school-pulse-3d95b, and the emulator
// namespaces data by project id, so seed that namespace by default.
const PROJECT_ID = process.env.GCLOUD_PROJECT || 'school-pulse-3d95b';
admin.initializeApp({ projectId: PROJECT_ID });

const db = admin.firestore();
const auth = admin.auth();
const ts = (d) => admin.firestore.Timestamp.fromDate(d);

const SCHOOL_ID = 'demo-school';
const SCHOOL_NAME = 'Demo School';
const YEAR = new Date().getFullYear();
const ACADEMIC_YEAR_ID = `${SCHOOL_ID}-${YEAR}`;
const PASSWORD = 'Demo@1234';
const STUDENTS_PER_CLASS = 10;
const PARENT_COUNT = 40;

// Two terms around "now" so the current-term logic always has a live term.
const TERMS = [
  { id: `${ACADEMIC_YEAR_ID}-t1`, name: 'Term 1', order: 1,
    start: new Date(YEAR, 0, 15), end: new Date(YEAR, 5, 15) },
  { id: `${ACADEMIC_YEAR_ID}-t2`, name: 'Term 2', order: 2,
    start: new Date(YEAR, 6, 1), end: new Date(YEAR, 11, 10) },
];
const currentTermId = (() => {
  const now = new Date();
  const t = TERMS.find((x) => now >= x.start && now <= x.end);
  return (t || TERMS[TERMS.length - 1]).id;
})();

const CLASSES = [1, 2, 3, 4, 5, 6].map((n) => ({
  id: `${SCHOOL_ID}-p${n}`, name: `Primary ${n}`, code: `P${n}`,
}));
const SUBJECTS = ['Mathematics', 'English', 'Science', 'Social Studies'];

const FIRST = ['Amani', 'Brian', 'Clare', 'Daniel', 'Esther', 'Felix', 'Grace',
  'Henry', 'Irene', 'Joel', 'Ketty', 'Lucas', 'Mary', 'Nathan', 'Olivia',
  'Peter', 'Ruth', 'Samuel', 'Tracy', 'Victor'];
const LAST = ['Akello', 'Byaruhanga', 'Kato', 'Mugisha', 'Nakato', 'Ochieng',
  'Namukasa', 'Tumusiime', 'Wasswa', 'Achieng'];
const personName = (i) => `${FIRST[i % FIRST.length]} ${LAST[Math.floor(i / FIRST.length) % LAST.length]}`;

async function commitAll(writes) {
  // Firestore batches cap at 500 operations.
  for (let i = 0; i < writes.length; i += 450) {
    const batch = db.batch();
    for (const [ref, data] of writes.slice(i, i + 450)) batch.set(ref, data, { merge: true });
    await batch.commit();
  }
}

async function authUser(email, displayName, claims) {
  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    user = await auth.createUser({ email, password: PASSWORD, displayName, emailVerified: true });
  }
  await auth.setCustomUserClaims(user.uid, claims);
  return user.uid;
}

function schoolDocs() {
  return [
    [db.collection('schools').doc(SCHOOL_ID), {
      id: SCHOOL_ID, name: SCHOOL_NAME, schoolName: SCHOOL_NAME,
      schoolType: 'primary', classification: 'primary', initials: 'DS',
      isActive: true, status: 'active', accessMode: 'full',
      subscriptionExpiry: Date.now() + 365 * 24 * 60 * 60 * 1000,
      subscriptionPlanId: 'standard',
      metadata: { hasEverActivated: true, subscriptionStatus: 'active', source: 'seed_demo_school_emulator' },
      enabledFeatures: [], tenantId: SCHOOL_ID,
      contactEmail: 'admin@demo-school.test', createdAt: Date.now(),
    }],
    [db.collection('schools').doc(SCHOOL_ID).collection('config').doc('institution_profile'), {
      displayName: SCHOOL_NAME, name: SCHOOL_NAME, initials: 'DS',
      schoolType: 'primary', colors: ['#1565C0', '#FFA000'], brandingVersion: 1,
    }],
    [db.collection('academic_years').doc(ACADEMIC_YEAR_ID), {
      schoolId: SCHOOL_ID, name: String(YEAR),
      startDate: ts(TERMS[0].start), endDate: ts(TERMS[TERMS.length - 1].end),
      isCurrent: true, isArchived: false,
    }],
    ...TERMS.map((t) => [db.collection('academic_terms').doc(t.id), {
      schoolId: SCHOOL_ID, academicYearId: ACADEMIC_YEAR_ID, name: t.name,
      order: t.order, startDate: ts(t.start), endDate: ts(t.end),
      isCurrent: t.id === currentTermId,
    }]),
    [db.collection('educational_levels').doc(`${SCHOOL_ID}-level-primary`), {
      schoolId: SCHOOL_ID, name: 'Primary', code: 'PRI', order: 1, isActive: true,
    }],
    ...CLASSES.map((c) => [db.collection('classes').doc(c.id), {
      schoolId: SCHOOL_ID, name: c.name, code: c.code,
      levelId: `${SCHOOL_ID}-level-primary`, capacity: 40, description: '', isActive: true,
    }]),
    ...SUBJECTS.map((s) => [db.collection('subjects').doc(`${SCHOOL_ID}-${s.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`), {
      schoolId: SCHOOL_ID, name: s,
    }]),
  ];
}

async function seedStaff() {
  const staff = [
    { email: 'admin@demo-school.test', name: 'Demo Admin', role: 'schoolAdmin' },
    { email: 'head@demo-school.test', name: 'Demo Headteacher', role: 'headteacher' },
    { email: 'bursar@demo-school.test', name: 'Demo Bursar', role: 'bursar' },
    ...CLASSES.map((c, i) => ({
      email: `teacher.p${i + 1}@demo-school.test`, name: personName(100 + i),
      role: 'classTeacher', classIndex: i,
    })),
    { email: 'subject@demo-school.test', name: personName(120), role: 'subjectTeacher', subject: SUBJECTS[0] },
  ];

  const writes = [];
  for (const s of staff) {
    const uid = await authUser(s.email, s.name, { role: s.role, schoolId: SCHOOL_ID });
    const user = {
      id: uid, name: s.name, email: s.email, role: s.role, roles: [s.role],
      schoolId: SCHOOL_ID, status: 'active', isActive: true,
      mustChangePassword: false, studentIds: [],
    };
    const assignments = db.collection('schools').doc(SCHOOL_ID).collection('staff_role_assignments');
    if (s.role === 'classTeacher') {
      const c = CLASSES[s.classIndex];
      user.assignedClass = c.name;
      writes.push([assignments.doc(`demo-class-teacher-${c.id}`), {
        schoolId: SCHOOL_ID, campusId: 'main', staffId: uid, userId: uid,
        roleType: 'classTeacher', academicYearId: ACADEMIC_YEAR_ID,
        subjectId: null, subjectName: null, classId: c.id, className: c.name,
        startDate: ts(TERMS[0].start), endDate: null, status: 'active',
        permissionScope: { permissions: CLASS_TEACHER_PERMISSIONS, subjectId: null, classId: c.id,
          academicYearId: ACADEMIC_YEAR_ID, termIds: TERMS.map((t) => t.id) },
        assignedBy: 'seed_demo_school_emulator',
        assignedAt: admin.firestore.FieldValue.serverTimestamp(),
      }]);
    }
    if (s.role === 'subjectTeacher') {
      const subjectId = `${SCHOOL_ID}-${s.subject.toLowerCase()}`;
      writes.push([assignments.doc(`demo-subject-teacher-${subjectId}-${CLASSES[0].id}`), {
        schoolId: SCHOOL_ID, campusId: 'main', staffId: uid, userId: uid,
        roleType: 'subjectTeacher', academicYearId: ACADEMIC_YEAR_ID,
        subjectId, subjectName: s.subject, classId: CLASSES[0].id, className: CLASSES[0].name,
        startDate: ts(TERMS[0].start), endDate: null, status: 'active',
        permissionScope: { permissions: SUBJECT_TEACHER_PERMISSIONS, subjectId, classId: CLASSES[0].id,
          academicYearId: ACADEMIC_YEAR_ID, termIds: TERMS.map((t) => t.id) },
        assignedBy: 'seed_demo_school_emulator',
        assignedAt: admin.firestore.FieldValue.serverTimestamp(),
      }]);
    }
    writes.push([db.collection('users').doc(uid), user]);
    writes.push([db.collection('school_contacts').doc(uid), {
      name: s.name, role: s.role, roles: [s.role], schoolId: SCHOOL_ID, isActive: true,
    }]);
  }
  return { writes, adminEmail: staff[0].email, count: staff.length };
}

function studentDocs() {
  const students = [];
  CLASSES.forEach((c, ci) => {
    for (let k = 0; k < STUDENTS_PER_CLASS; k++) {
      const n = ci * STUDENTS_PER_CLASS + k;
      const id = `${SCHOOL_ID}-s${String(n + 1).padStart(3, '0')}`;
      const code = `DS/${YEAR}/${String(n + 1).padStart(3, '0')}`;
      students.push({ id, code, name: personName(n), classId: c.id, className: c.name,
        gender: n % 2 === 0 ? 'female' : 'male', birthYear: YEAR - 6 - ci });
    }
  });
  const writes = [];
  for (const s of students) {
    writes.push([db.collection('students').doc(s.id), {
      id: s.id, schoolId: SCHOOL_ID, name: s.name, className: s.className,
      classId: s.classId, studentId: s.code, studentCode: s.code,
      admissionNumber: s.code, gender: s.gender,
      dateOfBirth: ts(new Date(s.birthYear, 0, 1)),
      academicYearId: ACADEMIC_YEAR_ID, status: 'active', level: 'primary',
      isBoarder: false, residency: 'day', hasHealthAlert: false,
    }]);
    writes.push([db.collection('student_identities').doc(s.id), {
      studentId: s.id, schoolId: SCHOOL_ID, uniqueSystemId: `SP-${s.id}`,
      schoolStudentId: s.code, qrCodeData: `SP-${s.id}`, nfcStatus: 'unassigned',
    }]);
  }
  return { students, writes };
}

/** 40 parents over 60 students. Students 1-40 get parent 1-40; students
 *  41-60 are siblings of parents 1,3,5,...,39; students 1-10 also get a
 *  second guardian (parents 21-30). Every student ends up with 1 or 2
 *  parents - never more than the 2-parent limit. */
function parentDocs(students) {
  const links = new Map(); // parentIndex -> student[]
  const add = (p, s) => links.set(p, [...(links.get(p) || []), s]);
  students.forEach((s, i) => add(i < PARENT_COUNT ? i : (i - PARENT_COUNT) * 2, s));
  students.slice(0, 10).forEach((s, i) => add(20 + i, s));

  const perStudent = new Map();
  for (const kids of links.values()) for (const s of kids) perStudent.set(s.id, (perStudent.get(s.id) || 0) + 1);
  const over = [...perStudent.values()].filter((n) => n > 2).length;
  if (over) throw new Error(`${over} students would exceed the 2-parent limit`);

  const writes = [];
  for (const [p, kids] of links) {
    const code = `DEMOP${String(p + 1).padStart(3, '0')}`;
    const parentName = `${p % 2 === 0 ? 'Mrs.' : 'Mr.'} ${personName(200 + p)}`;
    writes.push([db.collection('parent_access_codes').doc(code), {
      code, parentCode: code, schoolId: SCHOOL_ID,
      studentIds: kids.map((s) => s.id), studentNames: kids.map((s) => s.name),
      parentName, phoneNumber: `+10000000${String(p + 1).padStart(3, '0')}`,
      pin: '1234', mustChangePin: false, isActive: true,
    }]);
    for (const s of kids) {
      writes.push([db.collection('parent_student_relationships').doc(`${code}_${s.id}`), {
        schoolId: SCHOOL_ID, studentId: s.id, userId: null, parentCode: code,
        type: p % 2 === 0 ? 'mother' : 'father',
        isLegalGuardian: true, isPrimaryGuardian: p < 20 || p >= 30,
        financialAccess: true, academicAccess: true, attendanceAccess: true,
        medicalAccess: false, emergencyContactAccess: true,
        pickupAuthorized: true, communicationPermission: true,
        status: 'active', createdBy: 'seed_demo_school_emulator', approvedBy: null,
        createdAt: admin.firestore.Timestamp.now(),
      }]);
    }
  }
  return { writes, count: links.size, perStudent };
}

async function main() {
  console.log(`Seeding demo school "${SCHOOL_ID}" into emulator project ${PROJECT_ID}...`);
  const staff = await seedStaff();
  const { students, writes: studentWrites } = studentDocs();
  const parents = parentDocs(students);
  await commitAll([...schoolDocs(), ...staff.writes, ...studentWrites, ...parents.writes]);
  const two = [...parents.perStudent.values()].filter((n) => n === 2).length;
  console.log(
    `Done: ${TERMS.length} terms (current ${currentTermId}), ${CLASSES.length} classes, ` +
    `${staff.count} staff, ${students.length} students, ${parents.count} parents ` +
    `(${two} students with 2 guardians). Admin login: ${staff.adminEmail} / ${PASSWORD}`
  );
}

main().catch((e) => {
  console.error('Seeding failed:', e);
  process.exit(1);
});
