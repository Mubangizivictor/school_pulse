/**
 * Additive Structure/Curriculum/Timetable seed for exactly ONE school:
 * schoolId = "sch_vhs_RMPeR39b" (Victor High School).
 *
 * Only ADDS new documents (fresh UUIDs) on top of the verified baseline
 * captured in functions/scripts/backups/sch_vhs_RMPeR39b_1787401752368.json.
 * Never deletes or overwrites existing docs. Config singletons
 * (timetable_config/attendance_defaults/communication_defaults) are written
 * with merge:true; feature_toggles/institution_profile are left untouched.
 *
 * Field shapes were read directly from:
 *  - lib/features/structure/data/datasources/structure_remote_data_source.dart
 *    (_xToMap functions for every collection below)
 *  - lib/features/structure/data/datasources/timetable_remote_data_source.dart
 *  - lib/features/structure/data/repositories/{curriculum,teaching}_assignment_repository_impl.dart
 *  - lib/features/structure/domain/entities/{teaching_assignment,assessment_grading_entities,
 *    attendance_defaults_config,communication_defaults_config}.dart
 *
 * Run: node scripts/seed_school_structure.js   (from functions/)
 */
const admin = require('firebase-admin');
const { randomUUID } = require('crypto');

const SCHOOL_ID = 'sch_vhs_RMPeR39b';
const OWNER_UID = 'RMPeR39bL6VkbBgV3Ae2PtBfGYa2';

admin.initializeApp({ projectId: 'school-pulse-3d95b' });
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

// Known baseline counts (from the verified backup). If a collection already
// has MORE docs than this for our schoolId, abort — looks like a previous
// seed run already happened.
const BASELINE_COUNTS = {
  educational_levels: 1,
  academic_years: 1,
  academic_terms: 1,
  classes: 1,
  class_streams: 1,
  subjects: 1,
  departments: 1,
  staff_designations: 0,
  campuses: 0,
  houses: 0,
  clubs: 0,
  facilities: 1,
  structure_fee_categories: 0,
  structure_assessment_types: 0,
  structure_grading_systems: 0,
  grade_bands: 0,
  attendance_types: 0,
  attendance_sessions: 0,
  announcement_categories: 0,
  notification_categories: 0,
  message_templates: 0,
  document_templates: 0,
  custom_fields: 0,
  structure_curriculum_assignments: 1,
  structure_teaching_assignments: 1,
};

// Known IDs from the baseline.
const LEVEL_PRIMARY = 'e76439f5-5205-4a8f-a233-c36185b62e1d';
const YEAR_2026 = 'ee37cee6-9015-4856-af4a-3f6bdedde602';
const TERM_1 = '98fb7da2-df62-468b-8d8d-92a008262b01';
const CLASS_P1 = '953bf6d2-ce36-4287-9ee6-5c90cd91ee5c';
const STREAM_P1_EAST = '57ce674c-65d5-4fdd-b4a3-30bf4db91b9b';
const SUBJECT_ENGLISH = '21226243-0e3c-4525-8242-f26c7fbce1aa';
const DEPT_SCIENCE = 'b73114b6-99e5-4cb2-91e9-59359e38ef62';
const FACILITY_LIBRARY = '63a3926b-05e1-424e-b5ba-18d7c11c1fe7';

const created = {}; // collection -> [{id, label}]
function log(collection, id, label) {
  if (!created[collection]) created[collection] = [];
  created[collection].push({ id, label });
  console.log(`  + ${collection}/${id}  ${label}`);
}

function ts(dateStr) {
  return Timestamp.fromDate(new Date(dateStr));
}

async function safetyCheck() {
  console.log('Running pre-seed safety check (baseline count guard)...\n');
  for (const [name, baseline] of Object.entries(BASELINE_COUNTS)) {
    const snap = await db.collection(name).where('schoolId', '==', SCHOOL_ID).get();
    if (snap.size > baseline) {
      console.error(
        `ABORT: collection "${name}" already has ${snap.size} docs for ${SCHOOL_ID}, ` +
          `expected baseline of ${baseline}. This looks like seeding already ran. ` +
          `Refusing to continue to avoid duplicate data.`,
      );
      process.exit(1);
    }
  }
  console.log('Safety check passed: no collection exceeds its known baseline count.\n');
}

async function main() {
  await safetyCheck();

  const batch1 = db.batch(); // small deterministic writes, batched per section

  // ---------------------------------------------------------------------
  // 2. Academic terms: Term 2 and Term 3 under 2026
  // ---------------------------------------------------------------------
  const term2Id = randomUUID();
  const term3Id = randomUUID();
  const termsCol = db.collection('academic_terms');
  await termsCol.doc(term2Id).set({
    schoolId: SCHOOL_ID,
    academicYearId: YEAR_2026,
    name: 'Term 2',
    order: 1,
    startDate: ts('2026-05-04'),
    endDate: ts('2026-08-14'),
    isCurrent: false,
    periodType: 'term',
    isArchived: false,
  });
  log('academic_terms', term2Id, 'Term 2 (2026)');
  await termsCol.doc(term3Id).set({
    schoolId: SCHOOL_ID,
    academicYearId: YEAR_2026,
    name: 'Term 3',
    order: 2,
    startDate: ts('2026-09-07'),
    endDate: ts('2026-12-04'),
    isCurrent: false,
    periodType: 'term',
    isArchived: false,
  });
  log('academic_terms', term3Id, 'Term 3 (2026)');

  // ---------------------------------------------------------------------
  // 3. Classes P2-P7
  // ---------------------------------------------------------------------
  const classesCol = db.collection('classes');
  const classDefs = [
    { name: 'P2', capacity: 30 },
    { name: 'P3', capacity: 32 },
    { name: 'P4', capacity: 30 },
    { name: 'P5', capacity: 28 },
    { name: 'P6', capacity: 27 },
    { name: 'P7', capacity: 25 },
  ];
  const classIds = { P1: CLASS_P1 };
  for (const def of classDefs) {
    const id = randomUUID();
    classIds[def.name] = id;
    await classesCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      code: '',
      levelId: LEVEL_PRIMARY,
      capacity: def.capacity,
      description: '',
      isActive: true,
    });
    log('classes', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 4. Class streams for P1 (existing) through P7
  // ---------------------------------------------------------------------
  const streamsCol = db.collection('class_streams');
  const streamIds = {}; // className -> [streamId,...]
  streamIds.P1 = [STREAM_P1_EAST]; // existing East kept, add West
  const streamPlan = {
    P1: [{ name: 'West', capacity: 22 }],
    P2: [
      { name: 'East', capacity: 28 },
      { name: 'West', capacity: 26 },
    ],
    P3: [
      { name: 'East', capacity: 30 },
      { name: 'West', capacity: 28 },
    ],
    P4: [
      { name: 'A', capacity: 29 },
      { name: 'B', capacity: 27 },
    ],
    P5: [{ name: 'A', capacity: 28 }],
    P6: [{ name: 'A', capacity: 26 }],
    P7: [{ name: 'A', capacity: 25 }],
  };
  for (const [className, streams] of Object.entries(streamPlan)) {
    if (!streamIds[className]) streamIds[className] = [];
    for (const s of streams) {
      const id = randomUUID();
      streamIds[className].push(id);
      await streamsCol.doc(id).set({
        schoolId: SCHOOL_ID,
        name: s.name,
        code: '',
        classId: classIds[className],
        capacity: s.capacity,
        isActive: true,
      });
      log('class_streams', id, `${className} - ${s.name}`);
    }
  }

  // ---------------------------------------------------------------------
  // 5. Departments: Languages, Mathematics, Humanities
  // ---------------------------------------------------------------------
  const deptCol = db.collection('departments');
  const deptDefs = ['Languages', 'Mathematics', 'Humanities'];
  const deptIds = { Science: DEPT_SCIENCE };
  for (const name of deptDefs) {
    const id = randomUUID();
    deptIds[name] = id;
    await deptCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name,
      code: '',
      description: '',
      headOfDepartmentStaffId: '',
      isActive: true,
    });
    log('departments', id, name);
  }

  // ---------------------------------------------------------------------
  // 6. Subjects
  // ---------------------------------------------------------------------
  const subjectsCol = db.collection('subjects');
  const subjectDefs = [
    { name: 'Mathematics', color: '#E53935', dept: 'Mathematics', elective: false, practical: false },
    { name: 'Science', color: '#43A047', dept: 'Science', elective: false, practical: true },
    { name: 'Social Studies', color: '#FB8C00', dept: 'Humanities', elective: false, practical: false },
    { name: 'Christian Religious Education', color: '#8E24AA', dept: 'Humanities', elective: false, practical: false },
    { name: 'Kiswahili', color: '#3949AB', dept: 'Languages', elective: false, practical: true },
    { name: 'Physical Education', color: '#00897B', dept: '', elective: true, practical: true },
    { name: 'Art', color: '#D81B60', dept: '', elective: true, practical: true },
    { name: 'Music', color: '#6D4C41', dept: '', elective: true, practical: true },
  ];
  const subjectIds = { English: SUBJECT_ENGLISH };
  const now = FieldValue.serverTimestamp();
  for (const def of subjectDefs) {
    const id = randomUUID();
    subjectIds[def.name] = id;
    await subjectsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      code: '',
      codeLower: '',
      departmentId: deptIds[def.dept] || '',
      color: def.color,
      description: '',
      subjectType: def.elective ? 'Elective' : 'Core',
      isElective: def.elective,
      isPractical: def.practical,
      creditUnits: 0,
      isActive: true,
      assignedLevelIds: [],
      assignedClassIds: [],
      createdAt: now,
      updatedAt: now,
    });
    log('subjects', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 7. Curriculum assignments for P1(partial)-P7
  // ---------------------------------------------------------------------
  const curriculumCol = db.collection('structure_curriculum_assignments');
  const coreSubjects = ['Mathematics', 'Science', 'Social Studies', 'Christian Religious Education'];
  const otherSubjects = ['Kiswahili', 'Physical Education', 'Art', 'Music'];
  // English already assigned for P1; assign it fresh for P2-P7.
  const allClassNames = ['P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'];
  let displayOrder = 1;
  for (const className of allClassNames) {
    const classId = classIds[className];
    // English: skip for P1 (already exists), add for P2-P7.
    if (className !== 'P1') {
      const id = randomUUID();
      await curriculumCol.doc(id).set({
        schoolId: SCHOOL_ID,
        academicYearId: YEAR_2026,
        levelId: LEVEL_PRIMARY,
        classId,
        streamId: '',
        subjectId: subjectIds['English'],
        periodsPerWeek: 5,
        isCompulsory: true,
        isActive: true,
        displayOrder: displayOrder++,
        updatedAt: now,
      });
      log('structure_curriculum_assignments', id, `English - ${className}`);
    }
    for (const subj of coreSubjects) {
      const id = randomUUID();
      await curriculumCol.doc(id).set({
        schoolId: SCHOOL_ID,
        academicYearId: YEAR_2026,
        levelId: LEVEL_PRIMARY,
        classId,
        streamId: '',
        subjectId: subjectIds[subj],
        periodsPerWeek: 5,
        isCompulsory: true,
        isActive: true,
        displayOrder: displayOrder++,
        updatedAt: now,
      });
      log('structure_curriculum_assignments', id, `${subj} - ${className}`);
    }
    for (const subj of otherSubjects) {
      const id = randomUUID();
      await curriculumCol.doc(id).set({
        schoolId: SCHOOL_ID,
        academicYearId: YEAR_2026,
        levelId: LEVEL_PRIMARY,
        classId,
        streamId: '',
        subjectId: subjectIds[subj],
        periodsPerWeek: 2,
        isCompulsory: false,
        isActive: true,
        displayOrder: displayOrder++,
        updatedAt: now,
      });
      log('structure_curriculum_assignments', id, `${subj} - ${className}`);
    }
  }

  // ---------------------------------------------------------------------
  // 8. One new ACTIVE teaching assignment (owner as placeholder teacher)
  // ---------------------------------------------------------------------
  const teachingCol = db.collection('structure_teaching_assignments');
  const teachId = randomUUID();
  await teachingCol.doc(teachId).set({
    schoolId: SCHOOL_ID,
    academicYearId: YEAR_2026,
    classId: classIds['P2'],
    streamId: '',
    subjectId: subjectIds['Mathematics'],
    departmentId: deptIds['Mathematics'],
    staffId: OWNER_UID,
    responsibilityType: 'classTeacher',
    isPrimary: true,
    isActive: true,
    startDate: ts('2026-01-01'),
    endDate: null,
    updatedAt: now,
  });
  log('structure_teaching_assignments', teachId, 'Owner as Class Teacher - P2 (Mathematics)');

  // ---------------------------------------------------------------------
  // 9. Staff designations
  // ---------------------------------------------------------------------
  const designationsCol = db.collection('staff_designations');
  const designationDefs = [
    { name: 'Head Teacher', category: 'Leadership', scopeType: 'wholeSchool', roleNature: 'Leadership', iconName: 'school', colorHex: '#1E88E5', order: 0 },
    { name: 'Deputy Head Teacher', category: 'Leadership', scopeType: 'wholeSchool', roleNature: 'Leadership', iconName: 'supervisor_account', colorHex: '#3949AB', order: 1 },
    { name: 'Class Teacher', category: 'Academic', scopeType: 'class', roleNature: 'Standard', iconName: 'groups', colorHex: '#43A047', order: 2 },
    { name: 'Subject Teacher', category: 'Academic', scopeType: 'subject', roleNature: 'Standard', iconName: 'menu_book', colorHex: '#FB8C00', order: 3 },
    { name: 'Bursar', category: 'Administration', scopeType: 'wholeSchool', roleNature: 'Standard', iconName: 'account_balance_wallet', colorHex: '#8E24AA', order: 4 },
    { name: 'Librarian', category: 'Support', scopeType: 'wholeSchool', roleNature: 'Standard', iconName: 'local_library', colorHex: '#00897B', order: 5 },
  ];
  for (const def of designationDefs) {
    const id = randomUUID();
    await designationsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      code: '',
      category: def.category,
      description: '',
      displayOrder: def.order,
      isActive: true,
      scopeType: def.scopeType,
      roleNature: def.roleNature,
      requiresScope: def.scopeType !== 'wholeSchool',
      allowMultipleStaff: true,
      allowConcurrentAssignments: true,
      allowTemporaryAssignments: true,
      isSystemPreset: false,
      isArchived: false,
      iconName: def.iconName,
      colorHex: def.colorHex,
      permissions: [],
    });
    log('staff_designations', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 10. Campus (1, main campus)
  // ---------------------------------------------------------------------
  const campusesCol = db.collection('campuses');
  const campusId = randomUUID();
  await campusesCol.doc(campusId).set({
    schoolId: SCHOOL_ID,
    name: 'Victor High School - Main Campus',
    code: 'MAIN',
    address: 'Nyakasharu, Rubirizi',
    district: 'Rubirizi',
    contactPhone: '0793128137',
    contactEmail: 'support@victorbee.com',
    headStaffId: OWNER_UID,
    isPrimary: true,
    isActive: true,
    order: 0,
    archivedAt: null,
  });
  log('campuses', campusId, 'Main Campus');

  // ---------------------------------------------------------------------
  // 11. Houses
  // ---------------------------------------------------------------------
  const housesCol = db.collection('houses');
  const houseDefs = [
    { name: 'Red House', colorHex: '#E53935' },
    { name: 'Blue House', colorHex: '#1E88E5' },
    { name: 'Green House', colorHex: '#43A047' },
    { name: 'Yellow House', colorHex: '#FDD835' },
  ];
  for (const def of houseDefs) {
    const id = randomUUID();
    await housesCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      colorHex: def.colorHex,
      description: '',
      isActive: true,
    });
    log('houses', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 12. Clubs
  // ---------------------------------------------------------------------
  const clubsCol = db.collection('clubs');
  const clubDefs = ['Debate Club', 'Wildlife Club', 'Music Club', 'Sports Club'];
  for (const name of clubDefs) {
    const id = randomUUID();
    await clubsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name,
      category: 'Co-curricular',
      description: '',
      patronName: '',
      isActive: true,
    });
    log('clubs', id, name);
  }

  // ---------------------------------------------------------------------
  // 13. Facilities (additional)
  // ---------------------------------------------------------------------
  const facilitiesCol = db.collection('facilities');
  const facilityDefs = [
    { name: 'Science Lab', type: 'Laboratory', capacity: 40 },
    { name: 'Computer Lab', type: 'Laboratory', capacity: 35 },
    { name: 'Assembly Hall', type: 'Hall', capacity: 600 },
    { name: 'Sports Field', type: 'Sports', capacity: 0 },
    { name: 'Staff Room', type: 'Office', capacity: 40 },
    { name: 'Sick Bay', type: 'Medical', capacity: 6 },
  ];
  for (const def of facilityDefs) {
    const id = randomUUID();
    await facilitiesCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      facilityType: def.type,
      location: '',
      capacity: def.capacity,
      description: '',
      isActive: true,
    });
    log('facilities', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 14. Fee categories
  // ---------------------------------------------------------------------
  const feeCol = db.collection('structure_fee_categories');
  const feeDefs = [
    { name: 'Tuition', mandatory: true },
    { name: 'Boarding', mandatory: false },
    { name: 'Uniform', mandatory: false },
    { name: 'Development Fund', mandatory: false },
  ];
  for (const def of feeDefs) {
    const id = randomUUID();
    await feeCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      code: '',
      description: '',
      isMandatory: def.mandatory,
      isActive: true,
    });
    log('structure_fee_categories', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 15. Assessment types (weights sum to 100)
  // ---------------------------------------------------------------------
  const assessCol = db.collection('structure_assessment_types');
  const assessDefs = [
    { name: 'Beginning of Term', weight: 20 },
    { name: 'Mid Term', weight: 30 },
    { name: 'End of Term', weight: 50 },
  ];
  for (const def of assessDefs) {
    const id = randomUUID();
    await assessCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      weightPercentage: def.weight,
      description: '',
      isActive: true,
    });
    log('structure_assessment_types', id, `${def.name} (${def.weight}%)`);
  }

  // ---------------------------------------------------------------------
  // 16. Grading system + grade bands (Ugandan primary D1-D9 style letter/div)
  // ---------------------------------------------------------------------
  const gradingCol = db.collection('structure_grading_systems');
  const gradeBandsCol = db.collection('grade_bands');
  const gradingSystemId = randomUUID();
  await gradingCol.doc(gradingSystemId).set({
    schoolId: SCHOOL_ID,
    name: 'Standard Primary Grading',
    type: 'Letter',
    isDefault: true,
    isActive: true,
    description: 'Default whole-school grading scale for Primary.',
    scaleType: 'Range Based',
    gradeFormat: 'Letter',
    decimalPlaces: 0,
    passingScore: 40,
    passingGradeCode: 'C',
    allowIncomplete: false,
    appliesTo: 'school',
    levelIds: [],
    classIds: [],
    academicYearIds: [],
    version: 1,
  });
  log('structure_grading_systems', gradingSystemId, 'Standard Primary Grading (default, school-wide)');

  const bandDefs = [
    { grade: 'A', min: 80, max: 100, remarks: 'Excellent', order: 0, passing: true, color: '#2E7D32' },
    { grade: 'B', min: 70, max: 79, remarks: 'Very Good', order: 1, passing: true, color: '#43A047' },
    { grade: 'C', min: 60, max: 69, remarks: 'Good', order: 2, passing: true, color: '#FBC02D' },
    { grade: 'D', min: 50, max: 59, remarks: 'Satisfactory', order: 3, passing: true, color: '#FB8C00' },
    { grade: 'E', min: 40, max: 49, remarks: 'Pass', order: 4, passing: true, color: '#F57C00' },
    { grade: 'F', min: 0, max: 39, remarks: 'Fail', order: 5, passing: false, color: '#E53935' },
  ];
  for (const def of bandDefs) {
    const id = randomUUID();
    await gradeBandsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      gradingSystemId,
      grade: def.grade,
      minScore: def.min,
      maxScore: def.max,
      remarks: def.remarks,
      order: def.order,
      label: def.remarks,
      gradePoint: null,
      isPassing: def.passing,
      colorHex: def.color,
      hasNumericBoundary: true,
    });
    log('grade_bands', id, `${def.grade} (${def.min}-${def.max})`);
  }

  // ---------------------------------------------------------------------
  // 17. Attendance types
  // ---------------------------------------------------------------------
  const attTypesCol = db.collection('attendance_types');
  const attTypeDefs = [
    { name: 'Present', colorHex: '#43A047' },
    { name: 'Absent', colorHex: '#E53935' },
    { name: 'Late', colorHex: '#FB8C00' },
  ];
  for (const def of attTypeDefs) {
    const id = randomUUID();
    await attTypesCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      colorHex: def.colorHex,
      isActive: true,
    });
    log('attendance_types', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 18. Attendance sessions
  // ---------------------------------------------------------------------
  const attSessionsCol = db.collection('attendance_sessions');
  const sessionIds = {};
  for (const name of ['Morning Session', 'Afternoon Session']) {
    const id = randomUUID();
    sessionIds[name] = id;
    await attSessionsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name,
      isActive: true,
    });
    log('attendance_sessions', id, name);
  }

  // ---------------------------------------------------------------------
  // 19. Announcement / notification categories
  // ---------------------------------------------------------------------
  const annCol = db.collection('announcement_categories');
  const notifCol = db.collection('notification_categories');
  const categoryNames = ['General', 'Academic', 'Emergency', 'Event'];
  for (const name of categoryNames) {
    const id = randomUUID();
    await annCol.doc(id).set({ schoolId: SCHOOL_ID, name, isActive: true });
    log('announcement_categories', id, name);
  }
  for (const name of categoryNames) {
    const id = randomUUID();
    await notifCol.doc(id).set({ schoolId: SCHOOL_ID, name, isActive: true });
    log('notification_categories', id, name);
  }

  // ---------------------------------------------------------------------
  // 20. Message / document templates
  // ---------------------------------------------------------------------
  const msgCol = db.collection('message_templates');
  const msgDefs = [
    {
      name: 'Fee Reminder',
      channel: 'sms',
      subject: '',
      body: 'Dear parent, this is a reminder that school fees for {{studentName}} are due. Thank you.',
    },
    {
      name: 'Absence Notice',
      channel: 'sms',
      subject: '',
      body: '{{studentName}} was marked absent today at Victor High School. Please contact the school if unexpected.',
    },
  ];
  for (const def of msgDefs) {
    const id = randomUUID();
    await msgCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      channel: def.channel,
      subject: def.subject,
      body: def.body,
      isActive: true,
    });
    log('message_templates', id, def.name);
  }

  const docCol = db.collection('document_templates');
  const docDefs = [
    { name: 'Report Card', templateType: 'report_card', description: 'End of term academic report card.' },
    { name: 'Admission Letter', templateType: 'admission_letter', description: 'Letter confirming admission to Victor High School.' },
  ];
  for (const def of docDefs) {
    const id = randomUUID();
    await docCol.doc(id).set({
      schoolId: SCHOOL_ID,
      name: def.name,
      templateType: def.templateType,
      description: def.description,
      isActive: true,
    });
    log('document_templates', id, def.name);
  }

  // ---------------------------------------------------------------------
  // 21. Custom fields
  // ---------------------------------------------------------------------
  const customCol = db.collection('custom_fields');
  const customDefs = [
    { fieldName: 'Blood Group', fieldType: 'select', appliesTo: 'student', options: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'] },
    { fieldName: 'Emergency Contact 2', fieldType: 'text', appliesTo: 'student', options: [] },
  ];
  for (const def of customDefs) {
    const id = randomUUID();
    await customCol.doc(id).set({
      schoolId: SCHOOL_ID,
      appliesTo: def.appliesTo,
      fieldName: def.fieldName,
      fieldType: def.fieldType,
      options: def.options,
      isRequired: false,
      isActive: true,
    });
    log('custom_fields', id, def.fieldName);
  }

  // ---------------------------------------------------------------------
  // 22. Timetable config (merge:true singleton doc)
  // ---------------------------------------------------------------------
  const teachingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  const weekendDays = ['Saturday', 'Sunday'];
  const slotDefs = [
    { name: 'Period 1', start: '08:00', end: '08:40', type: 'period' },
    { name: 'Period 2', start: '08:40', end: '09:20', type: 'period' },
    { name: 'Period 3', start: '09:20', end: '10:00', type: 'period' },
    { name: 'Break', start: '10:00', end: '10:20', type: 'break' },
    { name: 'Period 4', start: '10:20', end: '11:00', type: 'period' },
    { name: 'Period 5', start: '11:00', end: '11:40', type: 'period' },
    { name: 'Lunch', start: '11:40', end: '12:40', type: 'lunch' },
    { name: 'Period 6', start: '12:40', end: '13:20', type: 'period' },
    { name: 'Period 7', start: '13:20', end: '14:00', type: 'period' },
    { name: 'Period 8', start: '14:00', end: '14:40', type: 'period' },
  ];
  const slotIds = {};
  const slots = slotDefs.map((s, idx) => {
    const id = randomUUID();
    slotIds[s.name] = id;
    return {
      id,
      name: s.name,
      startTime: s.start,
      endTime: s.end,
      type: s.type,
      displayOrder: idx,
      isActive: true,
      days: teachingDays,
      colorHex: '',
      notes: '',
    };
  });
  const timetableConfigDoc = db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('config')
    .doc('timetable_config');
  await timetableConfigDoc.set(
    {
      teachingDays,
      weekendDays,
      defaultPeriodDurationMinutes: 40,
      periodsPerDay: 8,
      schoolStartTime: '08:00',
      schoolEndTime: '17:00',
      slots,
      specialSchedules: [],
    },
    { merge: true },
  );
  log('config', 'timetable_config', `${slots.length} slots, 08:00-17:00`);

  // ---------------------------------------------------------------------
  // 23. Attendance defaults / communication defaults (merge:true)
  // ---------------------------------------------------------------------
  const attDefaultsDoc = db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('config')
    .doc('attendance_defaults');
  await attDefaultsDoc.set(
    {
      attendanceMode: 'Daily',
      markingWindow: 'Until End of School Day',
      allowBackdatedAttendance: false,
      autoPresentOnAdmission: false,
    },
    { merge: true },
  );
  log('config', 'attendance_defaults', 'Daily / Until End of School Day');

  const commDefaultsDoc = db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('config')
    .doc('communication_defaults');
  await commDefaultsDoc.set(
    {
      defaultChannels: ['app'],
      defaultLanguage: 'English',
    },
    { merge: true },
  );
  log('config', 'communication_defaults', 'app channel, English');

  // ---------------------------------------------------------------------
  // 24. Timetables + timetable_lessons for P1 (existing stream) and P2
  // ---------------------------------------------------------------------
  const timetablesCol = db.collection('schools').doc(SCHOOL_ID).collection('timetables');
  const lessonsCol = db.collection('schools').doc(SCHOOL_ID).collection('timetable_lessons');

  const timetableP1Id = randomUUID();
  await timetablesCol.doc(timetableP1Id).set({
    schoolId: SCHOOL_ID,
    academicYearId: YEAR_2026,
    termId: TERM_1,
    classId: CLASS_P1,
    streamId: STREAM_P1_EAST,
    name: 'P1 East - Term 1 2026',
    description: 'Weekly timetable for P1 East, Term 1 2026.',
    status: 'active',
    version: 1,
    configSnapshotId: '',
    createdAt: Timestamp.now(),
    createdBy: OWNER_UID,
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: OWNER_UID,
    publishedAt: Timestamp.now(),
    publishedBy: OWNER_UID,
    archivedAt: null,
    archivedBy: null,
  });
  log('timetables', timetableP1Id, 'P1 East - Term 1 2026');

  const timetableP2Id = randomUUID();
  const p2StreamId = streamIds['P2'][0];
  await timetablesCol.doc(timetableP2Id).set({
    schoolId: SCHOOL_ID,
    academicYearId: YEAR_2026,
    termId: TERM_1,
    classId: classIds['P2'],
    streamId: p2StreamId,
    name: 'P2 East - Term 1 2026',
    description: 'Weekly timetable for P2 East, Term 1 2026.',
    status: 'active',
    version: 1,
    configSnapshotId: '',
    createdAt: Timestamp.now(),
    createdBy: OWNER_UID,
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: OWNER_UID,
    publishedAt: Timestamp.now(),
    publishedBy: OWNER_UID,
    archivedAt: null,
    archivedBy: null,
  });
  log('timetables', timetableP2Id, 'P2 East - Term 1 2026');

  // Build a small non-conflicting weekly schedule for each timetable using
  // Period 1-5 slots on Monday-Friday, one subject per day (no double
  // booking of the same class/day/slot).
  const weekdayPlanP1 = [
    { day: 'Monday', slot: 'Period 1', subject: 'English' },
    { day: 'Tuesday', slot: 'Period 1', subject: 'Mathematics' },
    { day: 'Wednesday', slot: 'Period 1', subject: 'Science' },
    { day: 'Thursday', slot: 'Period 1', subject: 'Social Studies' },
    { day: 'Friday', slot: 'Period 1', subject: 'Physical Education' },
  ];
  const weekdayPlanP2 = [
    { day: 'Monday', slot: 'Period 2', subject: 'English' },
    { day: 'Tuesday', slot: 'Period 2', subject: 'Mathematics' },
    { day: 'Wednesday', slot: 'Period 2', subject: 'Science' },
    { day: 'Thursday', slot: 'Period 2', subject: 'Kiswahili' },
    { day: 'Friday', slot: 'Period 2', subject: 'Art' },
  ];

  for (const entry of weekdayPlanP1) {
    const id = randomUUID();
    await lessonsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      timetableId: timetableP1Id,
      academicYearId: YEAR_2026,
      termId: TERM_1,
      classId: CLASS_P1,
      className: 'P1',
      streamId: STREAM_P1_EAST,
      streamName: 'East',
      subjectId: subjectIds[entry.subject],
      subjectName: entry.subject,
      teacherId: OWNER_UID,
      teacherName: '',
      roomId: null,
      roomName: null,
      groupId: null,
      notes: '',
      occurrences: [{ day: entry.day, slotId: slotIds[entry.slot] }],
      createdAt: Timestamp.now(),
      createdBy: OWNER_UID,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: OWNER_UID,
    });
    log('timetable_lessons', id, `P1 ${entry.day} ${entry.slot} - ${entry.subject}`);
  }

  for (const entry of weekdayPlanP2) {
    const id = randomUUID();
    await lessonsCol.doc(id).set({
      schoolId: SCHOOL_ID,
      timetableId: timetableP2Id,
      academicYearId: YEAR_2026,
      termId: TERM_1,
      classId: classIds['P2'],
      className: 'P2',
      streamId: p2StreamId,
      streamName: 'East',
      subjectId: subjectIds[entry.subject],
      subjectName: entry.subject,
      teacherId: OWNER_UID,
      teacherName: '',
      roomId: null,
      roomName: null,
      groupId: null,
      notes: '',
      occurrences: [{ day: entry.day, slotId: slotIds[entry.slot] }],
      createdAt: Timestamp.now(),
      createdBy: OWNER_UID,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: OWNER_UID,
    });
    log('timetable_lessons', id, `P2 ${entry.day} ${entry.slot} - ${entry.subject}`);
  }

  // ---------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------
  console.log('\n===== SEED SUMMARY =====');
  let totalDocs = 0;
  for (const [collection, docs] of Object.entries(created)) {
    console.log(`${collection}: ${docs.length} docs`);
    totalDocs += docs.length;
  }
  console.log(`\nTotal docs created: ${totalDocs}`);
  console.log('Seeding complete for schoolId=' + SCHOOL_ID);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('SEED FAILED', e);
    process.exit(1);
  });
