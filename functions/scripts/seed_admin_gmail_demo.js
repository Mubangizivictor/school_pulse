#!/usr/bin/env node
/**
 * Seeds students, staff, and parents for the admin@gmail.com school
 * (school-pulse-academy), linked via the current Parents & Access data
 * model (parent_access_code_invites + parent_learner_links), so the module
 * can be exercised end-to-end for admin@gmail.com.
 *
 * Assumes admin@gmail.com already exists (see seed_empty_admin.js).
 *
 * Run: node functions/scripts/seed_admin_gmail_demo.js
 */
const admin = require('firebase-admin');

const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'school-pulse-3d95b';
admin.initializeApp({ projectId });

const db = admin.firestore();
const auth = admin.auth();

const SCHOOL_ID = 'school-pulse-academy';
const ACADEMIC_YEAR_ID = '2026';
const DEFAULT_PASSWORD = 'Test@123';

const classSlug = (name) => name.toLowerCase().replace(/ /g, '-');

async function getOrCreateAuthUser(email, displayName) {
  try {
    return await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code === 'auth/user-not-found') {
      return auth.createUser({ email, password: DEFAULT_PASSWORD, displayName });
    }
    throw e;
  }
}

async function seedStructure() {
  await db.collection('educational_levels').doc('level-primary').set({
    schoolId: SCHOOL_ID,
    name: 'Primary',
    code: 'PRI',
    order: 1,
    isActive: true,
  }, { merge: true });

  for (const className of ['Primary 1', 'Primary 2', 'Primary 3']) {
    await db.collection('classes').doc(classSlug(className)).set({
      schoolId: SCHOOL_ID,
      name: className,
      code: className.replace('Primary ', 'P'),
      levelId: 'level-primary',
      capacity: 40,
      isActive: true,
    }, { merge: true });
  }
  console.log('Seeded structure: 1 level, 3 classes');
}

async function seedStudents() {
  const students = [
    { id: 'ag-s1', name: 'Nantongo Diana', className: 'Primary 1', gender: 'female' },
    { id: 'ag-s2', name: 'Ssali Brian', className: 'Primary 2', gender: 'male' },
    { id: 'ag-s3', name: 'Auma Rebecca', className: 'Primary 3', gender: 'female' },
    { id: 'ag-s4', name: 'Mukasa Ivan', className: 'Primary 1', gender: 'male' },
  ];
  for (let i = 0; i < students.length; i++) {
    const s = students[i];
    const studentCode = `SPA/2026/AG${String(i + 1).padStart(3, '0')}`;
    await db.collection('students').doc(s.id).set({
      id: s.id,
      schoolId: SCHOOL_ID,
      name: s.name,
      className: s.className,
      classId: s.className,
      studentId: studentCode,
      studentCode,
      admissionNumber: studentCode,
      gender: s.gender,
      dateOfBirth: admin.firestore.Timestamp.fromDate(new Date(2017, 0, 1)),
      academicYearId: ACADEMIC_YEAR_ID,
      status: 'active',
      level: 'primary',
      isBoarder: false,
      residency: 'day',
      hasHealthAlert: false,
    }, { merge: true });

    await db.collection('student_identities').doc(s.id).set({
      studentId: s.id,
      uniqueSystemId: `SP-${s.id}`,
      schoolStudentId: studentCode,
      qrCodeData: `SP-${s.id}`,
      nfcStatus: 'unassigned',
    }, { merge: true });
  }
  console.log(`Seeded ${students.length} students + identities`);
  return students;
}

async function seedStaff() {
  const staff = [
    { name: 'Ms. Namutebi Sarah', email: 'ag.teacher1@gmail.com', assignedClass: 'Primary 1' },
    { name: 'Mr. Kaggwa Robert', email: 'ag.teacher2@gmail.com', assignedClass: 'Primary 2' },
  ];
  const uids = [];
  for (const t of staff) {
    const userRecord = await getOrCreateAuthUser(t.email, t.name);
    uids.push(userRecord.uid);
    await db.collection('users').doc(userRecord.uid).set({
      id: userRecord.uid,
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

    await db.collection('school_contacts').doc(userRecord.uid).set({
      name: t.name,
      role: 'classTeacher',
      roles: ['classTeacher'],
      schoolId: SCHOOL_ID,
      isActive: true,
    }, { merge: true });

    const assignmentId = `ag-class-teacher-${classSlug(t.assignedClass)}`;
    await db.collection('schools').doc(SCHOOL_ID).collection('staff_role_assignments').doc(assignmentId).set({
      schoolId: SCHOOL_ID,
      campusId: 'main',
      staffId: userRecord.uid,
      userId: userRecord.uid,
      roleType: 'classTeacher',
      academicYearId: ACADEMIC_YEAR_ID,
      classId: t.assignedClass,
      className: t.assignedClass,
      startDate: admin.firestore.Timestamp.fromDate(new Date(2026, 1, 1)),
      endDate: null,
      status: 'active',
      assignedBy: 'seed_admin_gmail_demo',
      assignedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    console.log(`Seeded staff: ${t.email} (${t.assignedClass})`);
  }
  return uids;
}

/**
 * Mirrors the write shape of createParentAccessCode (functions/index.js
 * ~2578-2606): one parent_access_code_invites doc + one parent_learner_links
 * doc per learner, written directly via Admin SDK since both collections are
 * server-only (`allow read, write: if false` in firestore.rules).
 */
async function seedParents(students) {
  const byId = Object.fromEntries(students.map((s) => [s.id, s]));
  const parents = [
    {
      parentName: 'Mr. Nantongo Fred',
      phoneNumber: '+256700000201',
      email: 'ag.parent1@gmail.com',
      learners: [{ studentId: 'ag-s1', relationship: 'Father', isPrimaryContact: true }],
    },
    {
      // Two parents linked to the same student (ag-s2), respecting the
      // max-2-guardians cap per README.md / CLAUDE.md rule #2.
      parentName: 'Mrs. Ssali Grace',
      phoneNumber: '+256700000202',
      email: 'ag.parent2@gmail.com',
      learners: [{ studentId: 'ag-s2', relationship: 'Mother', isPrimaryContact: true }],
    },
    {
      parentName: 'Mr. Ssali Peter',
      phoneNumber: '+256700000203',
      email: 'ag.parent3@gmail.com',
      learners: [{ studentId: 'ag-s2', relationship: 'Father', isPrimaryContact: false }],
    },
    {
      // One parent linked to two students.
      parentName: 'Mrs. Auma Christine',
      phoneNumber: '+256700000204',
      email: 'ag.parent4@gmail.com',
      learners: [
        { studentId: 'ag-s3', relationship: 'Mother', isPrimaryContact: true },
        { studentId: 'ag-s4', relationship: 'Guardian', isPrimaryContact: true },
      ],
    },
  ];

  for (const p of parents) {
    const inviteRef = db.collection('parent_access_code_invites').doc();
    await inviteRef.set({
      schoolId: SCHOOL_ID,
      codeHash: `seed-${inviteRef.id}`,
      parentName: p.parentName,
      phoneNumber: p.phoneNumber,
      email: p.email,
      learnerIds: p.learners.map((l) => l.studentId),
      learnerRelationships: p.learners,
      status: 'active',
      createdBy: 'seed_admin_gmail_demo',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + 30 * 24 * 60 * 60 * 1000),
    });

    for (const learner of p.learners) {
      await db.collection('parent_learner_links').doc().set({
        schoolId: SCHOOL_ID,
        studentId: learner.studentId,
        parentInviteId: inviteRef.id,
        phoneNumber: p.phoneNumber,
        relationship: learner.relationship,
        isPrimaryContact: learner.isPrimaryContact,
        status: 'active',
        linkType: 'initial',
        createdBy: 'seed_admin_gmail_demo',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    console.log(`Seeded parent: ${p.parentName} -> [${p.learners.map((l) => byId[l.studentId].name).join(', ')}]`);
  }
}

async function main() {
  console.log(`Seeding admin@gmail.com demo data into ${SCHOOL_ID} (project ${projectId})...`);
  await seedStructure();
  const students = await seedStudents();
  await seedStaff();
  await seedParents(students);
  console.log('Done: 3 classes, 4 students, 2 staff, 4 parents (with a 2-guardian link on ag-s2).');
}

main().catch((e) => {
  console.error('Seeding failed:', e);
  process.exit(1);
});
