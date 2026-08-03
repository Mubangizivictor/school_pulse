const { after, before, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');

const projectId = 'demo-school-pulse-rules-test';
const rules = fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8',
);

let testEnv;

function dbFor(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

async function seed() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const users = {
      nurseA: { role: 'nurse', roles: ['nurse'], schoolId: 'schoolA', studentIds: [] },
      nurseB: { role: 'nurse', roles: ['nurse'], schoolId: 'schoolB', studentIds: [] },
      secondaryNurseA: {
        role: 'classTeacher',
        roles: ['classTeacher', 'nurse'],
        schoolId: 'schoolA',
        studentIds: [],
      },
      teacherA: { role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolA', studentIds: [] },
      storeA: { role: 'storeInventory', roles: ['storeInventory'], schoolId: 'schoolA', studentIds: [] },
      adminA: { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolA', studentIds: [] },
      ownerA: { role: 'superAdmin', roles: ['superAdmin'], schoolId: null, studentIds: [] },
      matronA: { role: 'boardingMatron', roles: ['boardingMatron'], schoolId: 'schoolA', studentIds: [] },
      parentA: { role: 'parent', roles: ['parent'], schoolId: 'schoolA', studentIds: ['studentA'] },
      parentOtherA: { role: 'parent', roles: ['parent'], schoolId: 'schoolA', studentIds: ['studentOther'] },
      parentWithInjectedNurseRole: {
        role: 'parent',
        roles: ['parent', 'nurse'],
        schoolId: 'schoolA',
        studentIds: ['studentA'],
      },
      studentUserA: { role: 'student', schoolId: 'schoolA', studentId: 'studentA', studentIds: [] },
      otherTeacherA: {
        role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolA', studentIds: [],
      },
      drafterA: {
        role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolA', studentIds: [],
      },
      teacherB: {
        role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolB', studentIds: [],
      },
    };

    await Promise.all(
      Object.entries(users).map(([uid, data]) => setDoc(doc(db, 'users', uid), data)),
    );

    await Promise.all([
      setDoc(doc(db, 'health_profiles', 'profileA'), {
        schoolId: 'schoolA', studentId: 'studentA', bloodGroup: 'O+',
      }),
      setDoc(doc(db, 'clinic_visits', 'visitA'), {
        schoolId: 'schoolA', studentId: 'studentA', recordedBy: 'nurseA', reason: 'Fever',
      }),
      setDoc(doc(db, 'clinic_visits', 'visitOtherA'), {
        schoolId: 'schoolA', studentId: 'studentOther', recordedBy: 'nurseA', reason: 'Cold',
      }),
      setDoc(doc(db, 'clinic_visits', 'visitB'), {
        schoolId: 'schoolB', studentId: 'studentB', recordedBy: 'nurseB', reason: 'Cough',
      }),
      setDoc(doc(db, 'emergency_incidents', 'incidentA'), {
        schoolId: 'schoolA', studentId: 'studentA', recordedBy: 'nurseA', incidentDetails: 'Fall',
      }),
      setDoc(doc(db, 'medical_inventory', 'itemA'), {
        schoolId: 'schoolA', name: 'Bandages', quantity: 10,
      }),
      setDoc(doc(db, 'medical_supply_requests', 'requestA'), {
        schoolId: 'schoolA', requestedBy: 'nurseA', status: 'SupplyRequestStatus.pending',
      }),
      setDoc(doc(db, 'welfare_records', 'publicA'), {
        schoolId: 'schoolA', studentId: 'studentA', isPrivate: false, note: 'Doing well',
      }),
      setDoc(doc(db, 'welfare_records', 'privateA'), {
        schoolId: 'schoolA', studentId: 'studentA', isPrivate: true, note: 'Private',
      }),
      setDoc(doc(db, 'school_contacts', 'nurseA'), {
        schoolId: 'schoolA', name: 'Nurse A', role: 'nurse', roles: ['nurse'], isActive: true,
      }),
      setDoc(doc(db, 'school_contacts', 'nurseB'), {
        schoolId: 'schoolB', name: 'Nurse B', role: 'nurse', roles: ['nurse'], isActive: true,
      }),
      setDoc(doc(db, 'schools', 'schoolA'), {
        name: 'School A', status: 'active', enabledFeatures: ['attendance'],
      }),
      setDoc(doc(db, 'super_admin_audit_logs', 'logA'), {
        ownerId: 'ownerA', action: 'CREATE_SCHOOL', schoolId: 'schoolA', device: 'Platform Dashboard',
      }),
      setDoc(doc(db, 'invoices', 'invoiceA'), {
        schoolId: 'schoolA', status: 'pending', amount: 100,
      }),

      // Class Teacher fixtures. teacherA holds P7 with the class.* grant;
      // otherTeacherA holds P6 and must never reach P7.
      setDoc(doc(db, 'schools/schoolA/staff_role_assignments/assignP7'), {
        schoolId: 'schoolA', campusId: 'main', staffId: 'teacherA', userId: 'teacherA',
        roleType: 'classTeacher', academicYearId: '2026', classId: 'p7', status: 'active',
        permissionScope: {
          permissions: [
            'class.attendance.take', 'class.attendance.edit',
            'class.homework.create', 'class.homework.publish',
            'class.behaviour.record', 'class.announcement.create',
            'class.announcement.publish', 'class.report.entry',
          ],
          classId: 'p7', academicYearId: '2026', termIds: [],
        },
      }),
      setDoc(doc(db, 'schools/schoolA/staff_role_assignments/assignP6'), {
        schoolId: 'schoolA', campusId: 'main', staffId: 'otherTeacherA', userId: 'otherTeacherA',
        roleType: 'classTeacher', academicYearId: '2026', classId: 'p6', status: 'active',
        permissionScope: {
          permissions: ['class.attendance.take', 'class.report.entry'],
          classId: 'p6', academicYearId: '2026', termIds: [],
        },
      }),
      // Drafting but not publishing - the pair the publish rule separates.
      setDoc(doc(db, 'schools/schoolA/staff_role_assignments/assignDrafter'), {
        schoolId: 'schoolA', campusId: 'main', staffId: 'drafterA', userId: 'drafterA',
        roleType: 'classTeacher', academicYearId: '2026', classId: 'p5', status: 'active',
        permissionScope: {
          permissions: ['class.homework.create', 'class.announcement.create'],
          classId: 'p5', academicYearId: '2026', termIds: [],
        },
      }),
      setDoc(doc(db, 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-06-01'), {
        schoolId: 'schoolA', classId: 'p7', academicYearId: '2026', termId: 't2',
        status: 'submitted', roleAssignmentId: 'assignP7', entries: [],
      }),
      setDoc(doc(db, 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-05-01'), {
        schoolId: 'schoolA', classId: 'p7', academicYearId: '2026', termId: 't2',
        status: 'locked', roleAssignmentId: 'assignP7', entries: [],
      }),
      setDoc(doc(db, 'schools/schoolA/class_report_entries/approvedEntry'), {
        schoolId: 'schoolA', classId: 'p7', academicYearId: '2026', termId: 't2',
        studentId: 'studentA', status: 'academicOfficeApproved',
        roleAssignmentId: 'assignP7',
      }),
      setDoc(doc(db, 'schools/schoolA/subject_audit_logs/auditA'), {
        schoolId: 'schoolA', userId: 'teacherA', action: 'attendance.submitted',
        classId: 'p7', academicYearId: '2026',
      }),
    ]);
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed();
});

after(async () => {
  await testEnv.cleanup();
});

describe('clinical records', () => {
  test('nurse and secondary nurse roles can write only inside their school', async () => {
    await assertSucceeds(setDoc(doc(dbFor('nurseA'), 'clinic_visits', 'newVisit'), {
      schoolId: 'schoolA', studentId: 'studentA', recordedBy: 'nurseA', reason: 'Headache',
    }));
    await assertSucceeds(setDoc(doc(dbFor('secondaryNurseA'), 'health_profiles', 'newProfile'), {
      schoolId: 'schoolA', studentId: 'studentA', bloodGroup: 'A+',
    }));
    await assertSucceeds(updateDoc(doc(dbFor('nurseA'), 'health_profiles', 'profileA'), {
      bloodGroup: 'A-',
    }));
    await assertFails(setDoc(doc(dbFor('nurseA'), 'clinic_visits', 'crossSchoolVisit'), {
      schoolId: 'schoolB', studentId: 'studentB', recordedBy: 'nurseA', reason: 'Headache',
    }));
    await assertFails(getDoc(doc(dbFor('nurseA'), 'clinic_visits', 'visitB')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'clinic_visits', 'visitA')));
  });

  test('parents and students can read only their own learner records', async () => {
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'clinic_visits', 'visitA')));
    await assertSucceeds(getDoc(doc(dbFor('studentUserA'), 'clinic_visits', 'visitA')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'clinic_visits', 'visitA')));
    await assertFails(updateDoc(doc(dbFor('parentA'), 'clinic_visits', 'visitA'), { reason: 'Changed' }));
  });

  test('parent query must be constrained to school and linked student', async () => {
    const allowedQuery = query(
      collection(dbFor('parentA'), 'clinic_visits'),
      where('schoolId', '==', 'schoolA'),
      where('studentId', '==', 'studentA'),
    );
    await assertSucceeds(getDocs(allowedQuery));
    await assertFails(getDocs(query(
      collection(dbFor('parentA'), 'clinic_visits'),
      where('schoolId', '==', 'schoolA'),
    )));
  });

  test('a parent secondary-role injection never grants clinical privileges', async () => {
    await assertFails(setDoc(doc(dbFor('parentWithInjectedNurseRole'), 'clinic_visits', 'forgedVisit'), {
      schoolId: 'schoolA',
      studentId: 'studentA',
      recordedBy: 'parentWithInjectedNurseRole',
      reason: 'Forged',
    }));
  });

  test('clinical record attribution is immutable', async () => {
    await assertFails(updateDoc(doc(dbFor('nurseA'), 'clinic_visits', 'visitA'), {
      recordedBy: 'secondaryNurseA',
    }));
    await assertFails(updateDoc(doc(dbFor('nurseA'), 'emergency_incidents', 'incidentA'), {
      recordedBy: 'secondaryNurseA',
    }));
  });
});

describe('medical supplies', () => {
  test('inventory is limited to supply roles in the same school', async () => {
    await assertSucceeds(getDoc(doc(dbFor('storeA'), 'medical_inventory', 'itemA')));
    await assertSucceeds(updateDoc(doc(dbFor('nurseA'), 'medical_inventory', 'itemA'), {
      quantity: 9,
    }));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'medical_inventory', 'itemA')));
    await assertFails(getDoc(doc(dbFor('nurseB'), 'medical_inventory', 'itemA')));
  });

  test('nurse creates an own pending request and cannot approve it', async () => {
    await assertSucceeds(setDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'newRequest'), {
      schoolId: 'schoolA',
      requestedBy: 'nurseA',
      status: 'SupplyRequestStatus.pending',
    }));
    await assertFails(setDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'forgedRequest'), {
      schoolId: 'schoolA',
      requestedBy: 'secondaryNurseA',
      status: 'SupplyRequestStatus.pending',
    }));
    await assertFails(updateDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'requestA'), {
      status: 'SupplyRequestStatus.approved',
      updatedAt: new Date(),
    }));
  });

  test('store role can perform only a valid, field-limited transition', async () => {
    await assertSucceeds(updateDoc(doc(dbFor('storeA'), 'medical_supply_requests', 'requestA'), {
      status: 'SupplyRequestStatus.approved',
      bursaReviewNotes: 'Approved',
      updatedAt: new Date(),
    }));
    await assertFails(updateDoc(doc(dbFor('storeA'), 'medical_supply_requests', 'requestA'), {
      requestedBy: 'storeA',
      status: 'SupplyRequestStatus.approved',
      updatedAt: new Date(),
    }));
    await assertFails(updateDoc(doc(dbFor('storeA'), 'medical_supply_requests', 'requestA'), {
      status: 'SupplyRequestStatus.delivered',
      updatedAt: new Date(),
    }));
  });
});

describe('welfare records', () => {
  test('parents and nurses see public records but not private records', async () => {
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'welfare_records', 'publicA')));
    await assertSucceeds(getDoc(doc(dbFor('nurseA'), 'welfare_records', 'publicA')));
    await assertFails(getDoc(doc(dbFor('parentA'), 'welfare_records', 'privateA')));
    await assertFails(getDoc(doc(dbFor('nurseA'), 'welfare_records', 'privateA')));
  });

  test('boarding staff can manage same-school records but cannot delete them', async () => {
    await assertSucceeds(setDoc(doc(dbFor('matronA'), 'welfare_records', 'newRecord'), {
      schoolId: 'schoolA', studentId: 'studentA', isPrivate: false, note: 'Settled',
    }));
    await assertSucceeds(updateDoc(doc(dbFor('matronA'), 'welfare_records', 'publicA'), {
      note: 'Updated',
    }));
    await assertFails(deleteDoc(doc(dbFor('matronA'), 'welfare_records', 'publicA')));
  });
});

describe('school contact directory', () => {
  test('same-school users can query contacts without seeing another school', async () => {
    const contacts = query(
      collection(dbFor('parentA'), 'school_contacts'),
      where('schoolId', '==', 'schoolA'),
    );
    const snapshot = await assertSucceeds(getDocs(contacts));
    assert.equal(snapshot.size, 1);
    await assertFails(getDoc(doc(dbFor('parentA'), 'school_contacts', 'nurseB')));
  });

  test('contact updates cannot move tenants or introduce sensitive fields', async () => {
    await assertFails(updateDoc(doc(dbFor('adminA'), 'school_contacts', 'nurseA'), {
      schoolId: 'schoolB',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'school_contacts', 'nurseA'), {
      email: 'private@example.com',
      fcmToken: 'secret-token',
    }));
  });
});

describe('SaaS owner / platform layer', () => {
  test('any signed-in user can read a school profile, but only the owner can write it', async () => {
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools', 'schoolA')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'schools', 'schoolA')));
    await assertSucceeds(updateDoc(doc(dbFor('ownerA'), 'schools', 'schoolA'), { status: 'suspended' }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'schools', 'schoolA'), { status: 'suspended' }));
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools', 'schoolB'), { name: 'Forged School' }));
  });

  test('only the owner can manage tenants and the subscription plan catalog', async () => {
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'tenants', 'tenantA'), { schoolId: 'schoolA' }));
    await assertFails(setDoc(doc(dbFor('adminA'), 'tenants', 'tenantB'), { schoolId: 'schoolA' }));
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'subscription_plans', 'planA'), { name: 'Pro' }));
    await assertFails(getDoc(doc(dbFor('adminA'), 'subscription_plans', 'planA')));
  });

  test('school admin invitations can be created by the owner but never read back by anyone', async () => {
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'school_admin_invitations', 'inviteA'), {
      email: 'admin@school-a.test', schoolId: 'schoolA', tempPassword: 'temp-secret',
    }));
    await assertFails(getDoc(doc(dbFor('ownerA'), 'school_admin_invitations', 'inviteA')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'school_admin_invitations', 'inviteB'), {
      email: 'x@test.com', schoolId: 'schoolA', tempPassword: 'temp-secret',
    }));
  });

  test('audit logs are owner-readable and append-only', async () => {
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'super_admin_audit_logs', 'logA')));
    await assertFails(getDoc(doc(dbFor('adminA'), 'super_admin_audit_logs', 'logA')));
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'super_admin_audit_logs', 'logB'), {
      ownerId: 'ownerA', action: 'CREATE_SCHOOL', schoolId: 'schoolA', device: 'Platform Dashboard',
    }));
    await assertFails(updateDoc(doc(dbFor('ownerA'), 'super_admin_audit_logs', 'logA'), {
      action: 'TAMPERED',
    }));
    await assertFails(deleteDoc(doc(dbFor('ownerA'), 'super_admin_audit_logs', 'logA')));
  });

  test('billing collections are owner-only', async () => {
    await assertSucceeds(updateDoc(doc(dbFor('ownerA'), 'invoices', 'invoiceA'), { status: 'completed' }));
    await assertFails(getDoc(doc(dbFor('adminA'), 'invoices', 'invoiceA')));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'invoices', 'invoiceA'), { status: 'completed' }));
  });

  test('platform_config is owner-readable and never client-writable, even by the owner', async () => {
    await assertFails(setDoc(doc(dbFor('ownerA'), 'platform_config', 'ownerSeed'), { seeded: true }));
    await assertFails(getDoc(doc(dbFor('adminA'), 'platform_config', 'ownerSeed')));
  });

  describe('Class Teacher panel', () => {
    const p7Session = 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-06-02';
    const p6Session = 'schools/schoolA/class_attendance_sessions/p6_all_daily_2026-06-02';

    function register(overrides = {}) {
      return {
        schoolId: 'schoolA', classId: 'p7', academicYearId: '2026', termId: 't2',
        status: 'draft', roleAssignmentId: 'assignP7', entries: [], counts: {},
        ...overrides,
      };
    }

    test('a teacher may write the register of the class they hold', async () => {
      await assertSucceeds(setDoc(doc(dbFor('teacherA'), p7Session), register()));
    });

    test('a teacher cannot write the register of another class', async () => {
      // Holding class.attendance.take says nothing about *which* class.
      await assertFails(setDoc(doc(dbFor('teacherA'), p6Session), register({
        classId: 'p6',
      })));
    });

    test('a teacher cannot borrow another teacher\'s assignment id', async () => {
      await assertFails(setDoc(doc(dbFor('otherTeacherA'), p7Session), register()));
    });

    test('a submitted register needs the edit permission to change', async () => {
      // otherTeacherA has take but not edit, and it is not their class either.
      await assertFails(updateDoc(
        doc(dbFor('otherTeacherA'), 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-06-01'),
        { status: 'submitted', roleAssignmentId: 'assignP6' },
      ));
    });

    test('a locked register has no teacher path at all', async () => {
      await assertFails(updateDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-05-01'),
        { status: 'submitted', roleAssignmentId: 'assignP7' },
      ));
    });

    test('registers are corrected, never deleted', async () => {
      await assertFails(deleteDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-06-01'),
      ));
    });

    test('a teacher who may draft homework cannot publish it', async () => {
      const drafter = dbFor('drafterA');
      await assertSucceeds(setDoc(doc(drafter, 'schools/schoolA/class_homework/hwDraft'), {
        schoolId: 'schoolA', classId: 'p5', academicYearId: '2026',
        title: 'Reading', status: 'draft', roleAssignmentId: 'assignDrafter',
      }));
      await assertFails(setDoc(doc(drafter, 'schools/schoolA/class_homework/hwLive'), {
        schoolId: 'schoolA', classId: 'p5', academicYearId: '2026',
        title: 'Reading', status: 'published', roleAssignmentId: 'assignDrafter',
      }));
    });

    test('a teacher holding publish may publish to their own class', async () => {
      await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'schools/schoolA/class_homework/hwP7'), {
        schoolId: 'schoolA', classId: 'p7', academicYearId: '2026',
        title: 'Fractions', status: 'published', roleAssignmentId: 'assignP7',
      }));
    });

    test('the same split applies to announcements', async () => {
      await assertFails(setDoc(doc(dbFor('drafterA'), 'schools/schoolA/class_announcements/annLive'), {
        schoolId: 'schoolA', classId: 'p5', academicYearId: '2026',
        title: 'Meeting', status: 'published', roleAssignmentId: 'assignDrafter',
      }));
    });

    test('a teacher cannot write themselves into an approved report state', async () => {
      await assertFails(setDoc(doc(dbFor('teacherA'), 'schools/schoolA/class_report_entries/newEntry'), {
        schoolId: 'schoolA', classId: 'p7', academicYearId: '2026', termId: 't2',
        studentId: 'studentB', status: 'published', roleAssignmentId: 'assignP7',
      }));
    });

    test('a report already approved upstream is out of the teacher\'s hands', async () => {
      await assertFails(updateDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/class_report_entries/approvedEntry'),
        { status: 'inProgress', roleAssignmentId: 'assignP7' },
      ));
    });

    test('report entries are never deleted', async () => {
      await assertFails(deleteDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/class_report_entries/approvedEntry'),
      ));
    });

    test('another school never reaches these collections', async () => {
      await assertFails(getDoc(
        doc(dbFor('teacherB'), 'schools/schoolA/class_attendance_sessions/p7_all_daily_2026-06-01'),
      ));
      await assertFails(setDoc(doc(dbFor('teacherB'), p7Session), register()));
    });

    test('a teacher reads only their own responsibilities', async () => {
      await assertSucceeds(getDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/staff_role_assignments/assignP7'),
      ));
      await assertFails(getDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/staff_role_assignments/assignP6'),
      ));
    });

    test('a teacher cannot grant themselves a responsibility', async () => {
      await assertFails(setDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/staff_role_assignments/selfGranted'),
        {
          schoolId: 'schoolA', staffId: 'teacherA', userId: 'teacherA',
          roleType: 'classTeacher', academicYearId: '2026', classId: 'p6',
          status: 'active',
          permissionScope: { permissions: ['class.attendance.take'], classId: 'p6' },
        },
      ));
    });

    test('audit rows cannot be edited or deleted, by anyone', async () => {
      await assertFails(updateDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/subject_audit_logs/auditA'),
        { action: 'nothing.happened' },
      ));
      await assertFails(deleteDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/subject_audit_logs/auditA'),
      ));
      await assertFails(deleteDoc(
        doc(dbFor('adminA'), 'schools/schoolA/subject_audit_logs/auditA'),
      ));
    });

    test('a correction request cannot be raised pre-approved', async () => {
      await assertFails(setDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/class_attendance_corrections/selfApproved'),
        {
          schoolId: 'schoolA', sessionId: 'p7_all_daily_2026-05-01', classId: 'p7',
          academicYearId: '2026', studentId: 'studentA',
          requestedByUserId: 'teacherA', status: 'approved',
        },
      ));
      await assertSucceeds(setDoc(
        doc(dbFor('teacherA'), 'schools/schoolA/class_attendance_corrections/pendingOne'),
        {
          schoolId: 'schoolA', sessionId: 'p7_all_daily_2026-05-01', classId: 'p7',
          academicYearId: '2026', studentId: 'studentA',
          requestedByUserId: 'teacherA', status: 'pending',
        },
      ));
    });
  });
});

describe('Institution Context Phase 1', () => {
  test('institution_memberships are never client-writable, even by the owning user', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'institution_memberships', 'adminA_schoolA'), {
      userId: 'adminA', institutionId: 'schoolA', roles: ['schoolAdmin'],
      isPrimaryAdmin: true, status: 'active',
    }));
  });

  test('a user can only read their own institution_memberships, not another user\'s', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'institution_memberships', 'adminA_schoolA'), {
        userId: 'adminA', institutionId: 'schoolA', roles: ['schoolAdmin'],
        isPrimaryAdmin: true, status: 'active',
      });
    });

    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institution_memberships', 'adminA_schoolA')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'institution_memberships', 'adminA_schoolA')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'institution_memberships', 'adminA_schoolA')));
  });

  test('a user can create and update their own onboarding_state within their own institution', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'onboarding_state', 'adminA_schoolA'), {
      userId: 'adminA', institutionId: 'schoolA', currentStep: 'identityConfirm',
      completedSteps: [], mfaRequired: false,
    }));
    await assertSucceeds(updateDoc(doc(dbFor('adminA'), 'onboarding_state', 'adminA_schoolA'), {
      currentStep: 'passwordChange',
    }));
  });

  test('a user cannot create onboarding_state for a different institution than their own', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'onboarding_state', 'adminA_schoolB'), {
      userId: 'adminA', institutionId: 'schoolB', currentStep: 'identityConfirm',
      completedSteps: [], mfaRequired: false,
    }));
  });

  test('a user cannot read or update another user\'s onboarding_state', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'onboarding_state', 'adminA_schoolA'), {
        userId: 'adminA', institutionId: 'schoolA', currentStep: 'identityConfirm',
        completedSteps: [], mfaRequired: false,
      });
    });

    await assertFails(getDoc(doc(dbFor('teacherA'), 'onboarding_state', 'adminA_schoolA')));
    await assertFails(updateDoc(doc(dbFor('teacherA'), 'onboarding_state', 'adminA_schoolA'), {
      currentStep: 'completed',
    }));
  });

  test('onboarding_state can never be deleted by a client', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'onboarding_state', 'adminA_schoolA'), {
        userId: 'adminA', institutionId: 'schoolA', currentStep: 'identityConfirm',
        completedSteps: [], mfaRequired: false,
      });
    });

    await assertFails(deleteDoc(doc(dbFor('adminA'), 'onboarding_state', 'adminA_schoolA')));
  });
});

describe('Structure Phase 2', () => {
  test('schools/{schoolId}/config/{document} is readable and writable by same-school staff, denied cross-school', async () => {
    await assertSucceeds(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/config/feature_toggles'),
      { transport: true },
    ));
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools/schoolA/config/feature_toggles')));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/config/feature_toggles')));

    await assertFails(setDoc(
      doc(dbFor('teacherB'), 'schools/schoolA/config/feature_toggles'),
      { transport: false },
    ));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/config/feature_toggles')));
  });

  test('a parent cannot write schools/{schoolId}/config/{document}', async () => {
    await assertFails(setDoc(
      doc(dbFor('parentA'), 'schools/schoolA/config/institution_profile'),
      { name: 'Hacked' },
    ));
  });

  test('an unauthenticated read of config is denied', async () => {
    await assertFails(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'schools/schoolA/config/feature_toggles')));
  });

  test('campuses are tenant-isolated: same-school staff can write, cross-school denied', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'campuses', 'campusA'), {
      schoolId: 'schoolA', name: 'Main Campus', isActive: true, order: 0,
    }));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'campuses', 'campusA')));

    await assertFails(setDoc(doc(dbFor('teacherB'), 'campuses', 'campusA'), {
      schoolId: 'schoolA', name: 'Hacked', isActive: true, order: 0,
    }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'campuses', 'campusA')));
  });

  test('a parent cannot write a campus', async () => {
    await assertFails(setDoc(doc(dbFor('parentA'), 'campuses', 'campusB'), {
      schoolId: 'schoolA', name: 'Parent Campus', isActive: true, order: 0,
    }));
  });
});
