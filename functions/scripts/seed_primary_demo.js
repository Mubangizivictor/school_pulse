/**
 * Seeds a small, focused Primary-level demo directly via the Firebase Admin
 * SDK: school structure (levels, classes, subjects), 5 students, 3 parents
 * (as parent_access_codes), and 5 teachers.
 *
 * Mirrors the shapes AdminSeeder (lib/core/utils/admin_seeder.dart) writes,
 * scoped down. Uses gcloud application-default credentials, so it bypasses
 * Firestore security rules entirely - point it only at the demo project.
 *
 * Run: node functions/scripts/seed_primary_demo.js
 */
const admin = require('firebase-admin');

admin.initializeApp({ projectId: 'school-pulse-3d95b' });

const db = admin.firestore();
const auth = admin.auth();

const SCHOOL_ID = 'school-pulse-academy';
const ACADEMIC_YEAR_ID = '2026';
const DEFAULT_PASSWORD = 'Test@123';

const classSlug = (name) => name.toLowerCase().replace(/ /g, '-');
const subjectSlug = (name) => name.toLowerCase().replace(/[^a-z0-9]+/g, '-');

async function getOrCreateAuthUser(email, displayName) {
  try {
    return await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code === 'auth/user-not-found') {
      return await auth.createUser({
        email,
        password: DEFAULT_PASSWORD,
        displayName,
      });
    }
    throw e;
  }
}

async function seedTenantRoot() {
  // Every tenant-scoped screen (branding, subscription gate, Structure)
  // resolves through schools/{schoolId} - without it, GetSchoolBranding
  // fails with "School branding not found" and the missing subscriptionExpiry
  // defaults to DateTime.now() (see SchoolModel.fromJson), which
  // InstitutionContext.isRenewalLocked reads as already-expired.
  await db.collection('schools').doc(SCHOOL_ID).set({
    id: SCHOOL_ID,
    name: 'School Pulse Academy',
    schoolName: 'School Pulse Academy',
    schoolType: 'primary',
    initials: 'SPA',
    isActive: true,
    status: 'active',
    subscriptionExpiry: Date.now() + 365 * 24 * 60 * 60 * 1000,
    subscriptionPlanId: 'standard',
    metadata: {
      hasEverActivated: true,
      subscriptionStatus: 'active',
      source: 'seed_script',
    },
    enabledFeatures: [],
    classification: 'primary',
    tenantId: SCHOOL_ID,
    address: '',
    contactEmail: 'admin@gmail.com',
    contactPhone: '',
    createdAt: Date.now(),
  }, { merge: true });

  await db.collection('schools').doc(SCHOOL_ID)
    .collection('config').doc('institution_profile').set({
      displayName: 'School Pulse Academy',
      name: 'School Pulse Academy',
      initials: 'SPA',
      schoolType: 'primary',
      motto: 'Educate. Empower. Excel.',
      colors: ['#1565C0', '#FFA000'],
      brandingVersion: 1,
    }, { merge: true });

  console.log('Seeded tenant root: schools/%s + institution_profile', SCHOOL_ID);
}

async function seedAcademicCalendar() {
  await db.collection('academic_years').doc(ACADEMIC_YEAR_ID).set({
    schoolId: SCHOOL_ID,
    name: ACADEMIC_YEAR_ID,
    startDate: admin.firestore.Timestamp.fromDate(new Date(2026, 1, 1)),
    endDate: admin.firestore.Timestamp.fromDate(new Date(2026, 11, 4)),
    isCurrent: true,
    isArchived: false,
  });

  const terms = [
    ['2026-t1', 'Term 1', 1, new Date(2026, 1, 1), new Date(2026, 4, 1), false],
    ['2026-t2', 'Term 2', 2, new Date(2026, 4, 25), new Date(2026, 7, 28), true],
    ['2026-t3', 'Term 3', 3, new Date(2026, 8, 21), new Date(2026, 11, 4), false],
  ];
  for (const [id, name, order, start, end, isCurrent] of terms) {
    await db.collection('academic_terms').doc(id).set({
      schoolId: SCHOOL_ID,
      academicYearId: ACADEMIC_YEAR_ID,
      name,
      order,
      startDate: admin.firestore.Timestamp.fromDate(start),
      endDate: admin.firestore.Timestamp.fromDate(end),
      isCurrent,
    });
  }

  console.log('Seeded academic_years + academic_terms');
}

async function seedStructure() {
  await db.collection('educational_levels').doc('level-primary').set({
    schoolId: SCHOOL_ID,
    name: 'Primary',
    code: 'PRI',
    order: 1,
    description: 'Primary 1 to Primary 7',
    isActive: true,
  });

  const classNames = [
    'Primary 1', 'Primary 2', 'Primary 3', 'Primary 4',
    'Primary 5', 'Primary 6', 'Primary 7',
  ];
  for (const className of classNames) {
    await db.collection('classes').doc(classSlug(className)).set({
      schoolId: SCHOOL_ID,
      name: className,
      code: className.replace('Primary ', 'P'),
      levelId: 'level-primary',
      capacity: 40,
      description: '',
      isActive: true,
    });
  }

  const subjectNames = ['Mathematics', 'English', 'Science', 'SST', 'Religious Education'];
  for (const s of subjectNames) {
    await db.collection('subjects').doc(subjectSlug(s)).set({
      schoolId: SCHOOL_ID,
      name: s,
    });
  }

  console.log('Seeded structure: 1 level, 7 classes, 5 subjects');
}

async function seedStudents() {
  const students = [
    { id: 'demo-s1', name: 'Mugisha Samuel', className: 'Primary 1', gender: 'male' },
    { id: 'demo-s2', name: 'Nakamya Sarah', className: 'Primary 2', gender: 'female' },
    { id: 'demo-s3', name: 'Okello John', className: 'Primary 3', gender: 'male' },
    { id: 'demo-s4', name: 'Babirye Grace', className: 'Primary 4', gender: 'female' },
    { id: 'demo-s5', name: 'Kato Emmanuel', className: 'Primary 5', gender: 'male' },
  ];

  for (let i = 0; i < students.length; i++) {
    const s = students[i];
    const studentCode = `KHA/2026/D${String(i + 1).padStart(3, '0')}`;
    await db.collection('students').doc(s.id).set({
      id: s.id,
      schoolId: SCHOOL_ID,
      name: s.name,
      className: s.className,
      classId: s.className,
      studentId: studentCode,
      studentCode: studentCode,
      admissionNumber: studentCode,
      gender: s.gender,
      dateOfBirth: admin.firestore.Timestamp.fromDate(new Date(2016, 0, 1)),
      academicYearId: ACADEMIC_YEAR_ID,
      status: 'active',
      level: 'primary',
      isBoarder: false,
      residency: 'day',
      hasHealthAlert: false,
    });

    const uniqueSystemId = `SP-${s.id}`;
    await db.collection('student_identities').doc(s.id).set({
      studentId: s.id,
      uniqueSystemId,
      schoolStudentId: studentCode,
      qrCodeData: uniqueSystemId,
      nfcStatus: 'unassigned',
    });
  }

  console.log('Seeded 5 students + identities');
  return students;
}

async function seedParents(students) {
  const byId = Object.fromEntries(students.map((s) => [s.id, s]));
  const parents = [
    { code: 'DEMO1001', parentName: 'Mr. Mugisha Peter', phoneNumber: '+256700000101', studentIds: ['demo-s1'] },
    { code: 'DEMO1002', parentName: 'Mrs. Nakamya Joan', phoneNumber: '+256700000102', studentIds: ['demo-s2', 'demo-s3'] },
    { code: 'DEMO1003', parentName: 'Mrs. Babirye Alice', phoneNumber: '+256700000103', studentIds: ['demo-s4', 'demo-s5'] },
  ];

  for (const p of parents) {
    await db.collection('parent_access_codes').doc(p.code).set({
      code: p.code,
      parentCode: p.code,
      schoolId: SCHOOL_ID,
      studentIds: p.studentIds,
      studentNames: p.studentIds.map((id) => byId[id].name),
      parentName: p.parentName,
      phoneNumber: p.phoneNumber,
      pin: '1234',
      mustChangePin: false,
      isActive: true,
    });
  }

  console.log('Seeded 3 parent access codes');
}

async function seedTeachers() {
  const teachers = [
    { name: 'Ms. Namuli Ruth', email: 'demo.teacher1@gmail.com', assignedClass: 'Primary 1' },
    { name: 'Mr. Ssekandi Paul', email: 'demo.teacher2@gmail.com', assignedClass: 'Primary 2' },
    { name: 'Ms. Tumusiime Grace', email: 'demo.teacher3@gmail.com', assignedClass: 'Primary 3' },
    { name: 'Mr. Okot John', email: 'demo.teacher4@gmail.com', assignedClass: 'Primary 4' },
    { name: 'Mrs. Nakiwala Grace', email: 'demo.teacher5@gmail.com', assignedClass: 'Primary 5' },
  ];

  for (const t of teachers) {
    const userRecord = await getOrCreateAuthUser(t.email, t.name);
    const uid = userRecord.uid;

    await db.collection('users').doc(uid).set({
      id: uid,
      name: t.name,
      email: t.email,
      role: 'classTeacher',
      roles: ['classTeacher'],
      schoolId: SCHOOL_ID,
      isActive: true,
      mustChangePassword: false,
      studentIds: [],
      assignedClass: t.assignedClass,
    }, { merge: true });

    await db.collection('school_contacts').doc(uid).set({
      name: t.name,
      role: 'classTeacher',
      roles: ['classTeacher'],
      schoolId: SCHOOL_ID,
      isActive: true,
    }, { merge: true });

    const assignmentId = `demo-class-teacher-${classSlug(t.assignedClass)}`;
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('staff_role_assignments')
      .doc(assignmentId)
      .set({
        schoolId: SCHOOL_ID,
        campusId: 'main',
        staffId: uid,
        userId: uid,
        roleType: 'classTeacher',
        academicYearId: ACADEMIC_YEAR_ID,
        subjectId: null,
        subjectName: null,
        classId: t.assignedClass,
        className: t.assignedClass,
        startDate: admin.firestore.Timestamp.fromDate(new Date(2026, 1, 1)),
        endDate: null,
        status: 'active',
        permissionScope: {
          permissions: [],
          subjectId: null,
          classId: t.assignedClass,
          academicYearId: ACADEMIC_YEAR_ID,
          termIds: [],
        },
        assignedBy: 'seed_primary_demo_node',
        assignedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`Seeded teacher: ${t.email} (${t.assignedClass})`);
  }
}

async function main() {
  console.log('Seeding primary-level demo into project school-pulse-3d95b...');
  await seedTenantRoot();
  await seedAcademicCalendar();
  await seedStructure();
  const students = await seedStudents();
  await seedParents(students);
  await seedTeachers();
  console.log('Done: structure, 5 students, 3 parents, 5 teachers seeded.');
}

main().catch((e) => {
  console.error('Seeding failed:', e);
  process.exit(1);
});
