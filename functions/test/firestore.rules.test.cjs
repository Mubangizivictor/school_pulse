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
      bursarA: { role: 'bursar', roles: ['bursar'], schoolId: 'schoolA', studentIds: [] },
      bursarB: { role: 'bursar', roles: ['bursar'], schoolId: 'schoolB', studentIds: [] },
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
      teacherReadOnly: {
        role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolReadOnly', studentIds: [],
      },
      teacherBlocked: {
        role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolBlocked', studentIds: [],
      },
      teacherFull: {
        role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolFull', studentIds: [],
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
        // No accessMode field - the fail-open default case: a school this
        // rules deploy hasn't touched yet must still be fully writable.
      }),
      setDoc(doc(db, 'schools', 'schoolB'), {
        name: 'School B', status: 'active', enabledFeatures: [],
        contactEmail: 'admin@schoolb.example', subscription: { price: 4200 },
      }),
      // teacherA switched into School B as a secondary institution via
      // institution_switcher_sheet - a real, active membership distinct
      // from users/teacherA.schoolId (which stays schoolA).
      setDoc(doc(db, 'institution_memberships', 'teacherA_schoolB'), {
        userId: 'teacherA', institutionId: 'schoolB', status: 'active',
      }),
      setDoc(doc(db, 'schools', 'schoolReadOnly'), {
        name: 'School Read Only', status: 'active', enabledFeatures: [], accessMode: 'readOnly',
      }),
      setDoc(doc(db, 'schools', 'schoolBlocked'), {
        name: 'School Blocked', status: 'trial', enabledFeatures: [], accessMode: 'blocked',
      }),
      setDoc(doc(db, 'schools', 'schoolFull'), {
        name: 'School Full', status: 'active', enabledFeatures: [], accessMode: 'full',
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

describe('schools/{schoolId} read isolation', () => {
  test('a staff member can read their own school document', async () => {
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools', 'schoolA')));
  });

  test('a staff member cannot read another school\'s document by id '
    + '(billing/PII fields live on this doc, not just branding)', async () => {
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools', 'schoolA')));
  });

  test('a user with an active secondary institution membership can read '
    + 'that school\'s document', async () => {
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools', 'schoolB')));
  });

  test('a user with no membership in the target school cannot read it '
    + 'even with a guessed/known schoolId', async () => {
    await assertFails(getDoc(doc(dbFor('nurseA'), 'schools', 'schoolB')));
  });

  test('superAdmin can read any school document', async () => {
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'schools', 'schoolB')));
  });
});

describe('subscription access enforcement', () => {
  test('a readOnly school cannot create a student', async () => {
    await assertFails(setDoc(doc(dbFor('teacherReadOnly'), 'students', 'roStudent'), {
      schoolId: 'schoolReadOnly', firstName: 'Ro', lastName: 'Student',
    }));
  });

  test('superAdmin bypasses the write-lock on a collection that already admits superAdmin (schools doc itself)', async () => {
    // students/{id} requires isSameSchool(), which is staff-membership-based
    // and was never superAdmin-reachable even before this change - the
    // owner manages billing state via the schools/{id} doc directly, not by
    // impersonating a school's own student-record writes. schoolCanWrite's
    // isSuperAdmin() bypass matters for collections the owner can already
    // reach, like schools/{schoolId} itself.
    await assertSucceeds(updateDoc(doc(dbFor('ownerA'), 'schools', 'schoolReadOnly'), {
      accessMode: 'full',
    }));
  });

  test('a blocked school cannot create a student', async () => {
    await assertFails(setDoc(doc(dbFor('teacherBlocked'), 'students', 'blockedStudent'), {
      schoolId: 'schoolBlocked', firstName: 'Blocked', lastName: 'Student',
    }));
  });

  test('a school with no accessMode field at all can still create a student (fail-open default)', async () => {
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'students', 'legacyStudent'), {
      schoolId: 'schoolA', firstName: 'Legacy', lastName: 'Student',
    }));
  });

  test('a full-access school can create a student normally', async () => {
    await assertSucceeds(setDoc(doc(dbFor('teacherFull'), 'students', 'fullStudent'), {
      schoolId: 'schoolFull', firstName: 'Full', lastName: 'Student',
    }));
  });

  test('reads succeed regardless of accessMode - read-only quarantine, not deletion', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'students', 'roExistingStudent'), {
        schoolId: 'schoolReadOnly', firstName: 'Existing', lastName: 'Student',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherReadOnly'), 'students', 'roExistingStudent')));
  });

  test('the write-lock generalizes to other threaded collections (staff_attendance)', async () => {
    await assertFails(setDoc(doc(dbFor('teacherReadOnly'), 'staff_attendance', 'roAttendance'), {
      schoolId: 'schoolReadOnly', staffId: 'teacherReadOnly', date: '2026-08-12',
    }));
    await assertSucceeds(setDoc(doc(dbFor('teacherFull'), 'staff_attendance', 'fullAttendance'), {
      schoolId: 'schoolFull', staffId: 'teacherFull', date: '2026-08-12',
    }));
  });

  test('a readOnly school cannot be bypassed by forging a different, writable schoolId on the request', async () => {
    // teacherReadOnly's own users/{uid}.schoolId is schoolReadOnly, so
    // isSameSchool('schoolFull') already fails before schoolCanWrite is
    // ever evaluated - the tenant check and the billing check are
    // independent gates, not a single point of failure.
    await assertFails(setDoc(doc(dbFor('teacherReadOnly'), 'students', 'forgedStudent'), {
      schoolId: 'schoolFull', firstName: 'Forged', lastName: 'Student',
    }));
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

describe('Phase 3.5 tenant-lock hardening', () => {
  // One representative per group of structurally identical rule blocks
  // (they all share the exact same allow-create/update/delete lines) -
  // exhaustively re-testing all 29 would just repeat this same case.
  const lockedCollections = ['classes', 'academic_years', 'departments', 'campuses', 'grade_bands'];

  for (const collectionName of lockedCollections) {
    test(`${collectionName}: same-school staff cannot re-parent a doc to another school via update`, async () => {
      const ref = doc(dbFor('adminA'), collectionName, 'doc1');
      await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', name: 'Original' }));

      // The core Phase 3.5 attack: an update() that only changes schoolId,
      // attempted by a staff member who is legitimately same-school on
      // schoolA (the before value) - isSameSchool(request.resource.data.schoolId)
      // alone would have let this through since it only checks the
      // incoming value, never the existing one.
      await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));

      await assertSucceeds(getDoc(doc(dbFor('adminA'), collectionName, 'doc1')));
    });

    test(`${collectionName}: an unrelated field can still be updated without touching schoolId`, async () => {
      const ref = doc(dbFor('adminA'), collectionName, 'doc2');
      await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', name: 'Original' }));
      await assertSucceeds(updateDoc(ref, { name: 'Renamed' }));
    });

    test(`${collectionName}: a staff member from the target school cannot pull a doc into their own school either`, async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), collectionName, 'doc3'), {
          schoolId: 'schoolA', name: 'Belongs to A',
        });
      });
      // teacherB is schoolB staff - can't touch a schoolA doc at all, let
      // alone reassign it to schoolB (the isSameSchool(resource.data...)
      // guard on update should already deny this before schoolIdUnchanged()
      // is even reached).
      await assertFails(updateDoc(
        doc(dbFor('teacherB'), collectionName, 'doc3'),
        { schoolId: 'schoolB' },
      ));
    });

    test(`${collectionName}: a doc cannot be created directly into a different school than the caller's`, async () => {
      await assertFails(setDoc(
        doc(dbFor('teacherB'), collectionName, 'doc4'),
        { schoolId: 'schoolA', name: 'Cross-tenant create' },
      ));
    });
  }

  test('subjects has exactly one matching rule block left - the second, unscoped duplicate was removed', async () => {
    // Before the fix, a second unscoped `match /subjects/{id}` block meant
    // Firestore's rule union silently granted cross-tenant access
    // regardless of the first block's tenant lock. This proves the removal
    // held: schoolId immutability and tenant isolation both apply exactly
    // as they do for every other Structure collection.
    const ref = doc(dbFor('adminA'), 'subjects', 'subjectA');
    await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', name: 'Mathematics' }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'subjects', 'subjectA')));
    await assertFails(setDoc(
      doc(dbFor('teacherB'), 'subjects', 'subjectB'),
      { schoolId: 'schoolA', name: 'Cross-tenant subject' },
    ));
  });
});

describe('Phase 3 people/roles/permissions', () => {
  test('a non-admin staff member cannot edit another staff member\'s roles', async () => {
    await assertFails(updateDoc(
      doc(dbFor('teacherA'), 'users', 'otherTeacherA'),
      { roles: ['schoolAdmin'] },
    ));
  });

  test('an admin-console role (schoolAdmin/headTeacher/director) can edit another staff member\'s roles', async () => {
    await assertSucceeds(updateDoc(
      doc(dbFor('adminA'), 'users', 'otherTeacherA'),
      { roles: ['classTeacher', 'nurse'] },
    ));
  });

  test('an admin-console role cannot edit or delete another school\'s staff profile', async () => {
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'users', 'teacherB'),
      { roles: ['schoolAdmin'] },
    ));
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'users', 'teacherB')));
  });

  test('deputyHead is not granted staff-role-editing authority (matches ADMIN_ROLES in Cloud Functions)', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'users', 'deputyA'), {
        role: 'deputyHead', roles: ['deputyHead'], schoolId: 'schoolA', studentIds: [],
      });
    });
    await assertFails(updateDoc(
      doc(dbFor('deputyA'), 'users', 'otherTeacherA'),
      { roles: ['schoolAdmin'] },
    ));
  });

  test('an admin still cannot edit a parent\'s profile through this path', async () => {
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'users', 'parentA'),
      { roles: ['schoolAdmin'] },
    ));
  });

  test('a non-teaching (nurse) staff_role_assignments doc behaves like a teaching one under the same rules', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/staff_role_assignments/assignNurse'), {
        schoolId: 'schoolA', campusId: 'main', staffId: 'nurseA', userId: 'nurseA',
        roleType: 'nurse', academicYearId: '2026', status: 'active',
        permissionScope: { permissions: ['health.clinicVisit.record'], termIds: [] },
      });
    });

    await assertSucceeds(getDoc(
      doc(dbFor('nurseA'), 'schools/schoolA/staff_role_assignments/assignNurse'),
    ));
    await assertFails(getDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/staff_role_assignments/assignNurse'),
    ));
    await assertFails(setDoc(
      doc(dbFor('nurseA'), 'schools/schoolA/staff_role_assignments/selfGrantedNurse'),
      {
        schoolId: 'schoolA', staffId: 'nurseA', userId: 'nurseA',
        roleType: 'nurse', academicYearId: '2026', status: 'active',
        permissionScope: { permissions: ['health.clinicVisit.record'] },
      },
    ));
  });

  test('role_permission_overrides: schoolAcademicAdmin can write, other staff can only read, cross-school denied', async () => {
    await assertSucceeds(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/role_permission_overrides/nurse'),
      { role: 'nurse', permissions: ['health.clinicVisit.record'], updatedBy: 'adminA' },
    ));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/role_permission_overrides/nurse')));
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/role_permission_overrides/nurse'),
      { role: 'nurse', permissions: ['everything'], updatedBy: 'teacherA' },
    ));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/role_permission_overrides/nurse')));
  });

  test('role_permission_overrides can never be deleted', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/role_permission_overrides/nurse'), {
        role: 'nurse', permissions: ['health.clinicVisit.record'], updatedBy: 'adminA',
      });
    });
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'schools/schoolA/role_permission_overrides/nurse')));
  });

  test('student_access_codes: only tenant administrators can list/write, direct-by-id get is public', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'student_access_codes', 'STU123'), {
      schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
      phoneNumber: '+256700000000', pin: '1234', isActive: true,
    }));
    await assertSucceeds(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'student_access_codes', 'STU123')));
    await assertFails(getDocs(collection(dbFor('teacherA'), 'student_access_codes')));
    await assertSucceeds(getDocs(query(
      collection(dbFor('adminA'), 'student_access_codes'),
      where('schoolId', '==', 'schoolA'),
    )));
  });
});

describe('Phase 4 core people records', () => {
  test('students: cross-school staff write is now denied (previously isStaff() alone with no tenancy check)', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'students', 'studentX'), {
      schoolId: 'schoolA', name: 'Student X', classId: 'p6', status: 'active',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'students', 'studentX'), {
      schoolId: 'schoolA', name: 'Hacked', classId: 'p6', status: 'active',
    }));
  });

  test('students: a same-school staff update cannot re-parent the doc to another school', async () => {
    const ref = doc(dbFor('adminA'), 'students', 'studentY');
    await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', name: 'Student Y', classId: 'p6', status: 'active' }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
  });

  test('admission_applications: same-school staff can create/read, cross-school denied, no rule gap remains', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'admission_applications', 'app1'), {
      schoolId: 'schoolA', studentName: 'Applicant One', status: 'application',
    }));
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'admission_applications', 'app1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'admission_applications', 'app1')));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'admission_applications', 'app2'), {
      schoolId: 'schoolA', studentName: 'Cross-tenant', status: 'application',
    }));
  });

  test('admission_applications cannot be re-parented via update, and are never deleted', async () => {
    const ref = doc(dbFor('adminA'), 'admission_applications', 'app3');
    await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', studentName: 'App Three', status: 'application' }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
    await assertFails(deleteDoc(ref));
  });

  test('parent_student_relationships: admin can create, ordinary staff and parents cannot self-create', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'parent_student_relationships', 'rel1'), {
      schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'adminA',
    }));
    await assertFails(setDoc(doc(dbFor('teacherA'), 'parent_student_relationships', 'rel2'), {
      schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'teacherA',
    }));
    await assertFails(setDoc(doc(dbFor('parentA'), 'parent_student_relationships', 'rel3'), {
      schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'parentA',
    }));
  });

  test('parent_student_relationships: the linked parent and the linked student can read it, unrelated parties cannot', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'parent_student_relationships', 'rel4'), {
        schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'adminA',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'parent_student_relationships', 'rel4')));
    await assertSucceeds(getDoc(doc(dbFor('studentUserA'), 'parent_student_relationships', 'rel4')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'parent_student_relationships', 'rel4')));
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'parent_student_relationships', 'rel4')));
  });

  test('parent_student_relationships: reallocation requires a reason and can only move active -> superseded/revoked', async () => {
    const ref = doc(dbFor('adminA'), 'parent_student_relationships', 'rel5');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'adminA',
    }));
    // No reason supplied - denied.
    await assertFails(updateDoc(ref, { status: 'superseded' }));
    // Reason supplied - allowed.
    await assertSucceeds(updateDoc(ref, {
      status: 'superseded', supersessionReason: 'custody change', supersededBy: 'adminA',
    }));
    // Cannot move status back to active from superseded.
    await assertFails(updateDoc(ref, { status: 'active' }));
  });

  test('parent_student_relationships: schoolId and studentId are locked on update', async () => {
    const ref = doc(dbFor('adminA'), 'parent_student_relationships', 'rel6');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'adminA',
    }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB', status: 'superseded', supersessionReason: 'x' }));
    await assertFails(updateDoc(ref, { studentId: 'studentOther', status: 'superseded', supersessionReason: 'x' }));
  });

  test('parent_student_relationships are never deleted', async () => {
    const ref = doc(dbFor('adminA'), 'parent_student_relationships', 'rel7');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', userId: 'parentA', type: 'parent', status: 'active', createdBy: 'adminA',
    }));
    await assertFails(deleteDoc(ref));
  });

  test('student_enrolments: staff can create, cross-tenant denied, placement fields locked on update', async () => {
    const ref = doc(dbFor('adminA'), 'student_enrolments', 'enrol1');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', classId: 'p6', academicYearId: '2026', status: 'active',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'student_enrolments', 'enrol2'), {
      schoolId: 'schoolA', studentId: 'studentA', classId: 'p6', academicYearId: '2026', status: 'active',
    }));
    // Closing out status/endDate is fine.
    await assertSucceeds(updateDoc(ref, { status: 'ended' }));
    // Rewriting the placement itself is not.
    const ref2 = doc(dbFor('adminA'), 'student_enrolments', 'enrol3');
    await assertSucceeds(setDoc(ref2, {
      schoolId: 'schoolA', studentId: 'studentA', classId: 'p6', academicYearId: '2026', status: 'active',
    }));
    await assertFails(updateDoc(ref2, { classId: 'p7' }));
  });

  test('student_enrolments: readable by staff and the linked student/parent, denied to unrelated parties', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'student_enrolments', 'enrol4'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p6', academicYearId: '2026', status: 'active',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'student_enrolments', 'enrol4')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'student_enrolments', 'enrol4')));
    await assertSucceeds(getDoc(doc(dbFor('studentUserA'), 'student_enrolments', 'enrol4')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'student_enrolments', 'enrol4')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'student_enrolments', 'enrol4')));
  });

  test('student_enrolments are never deleted', async () => {
    const ref = doc(dbFor('adminA'), 'student_enrolments', 'enrol5');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', classId: 'p6', academicYearId: '2026', status: 'active',
    }));
    await assertFails(deleteDoc(ref));
  });

  test('people_policies: any same-school signed-in user can read, only top-tier admins can write', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'people_policies', 'schoolA'), {
      maxStandardGuardians: 2,
    }));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'people_policies', 'schoolA')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'people_policies', 'schoolA')));
    await assertFails(setDoc(doc(dbFor('teacherA'), 'people_policies', 'schoolA'), { maxStandardGuardians: 99 }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'people_policies', 'schoolA')));
  });
});

describe('Phase 5 attendance security gate', () => {
  test('school_stats: staff can only access their own school statistics', async () => {
    const ref = doc(dbFor('adminA'), 'school_stats', 'teacher_teacherA');
    await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', totalStudents: 10 }));
    await assertSucceeds(getDoc(ref));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'school_stats', 'teacher_teacherA')));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'school_stats', 'teacher_teacherB'), {
      schoolId: 'schoolA', totalStudents: 999,
    }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
  });

  test('attendance_records: cross-school staff write denied, schoolId locked on update', async () => {
    const ref = doc(dbFor('adminA'), 'attendance_records', 'rec1');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', status: 'present',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'attendance_records', 'rec2'), {
      schoolId: 'schoolA', studentId: 'studentA', status: 'present',
    }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
  });

  test('attendance_records: readable by staff and the linked student/parent, cross-school denied', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'attendance_records', 'rec3'), {
        schoolId: 'schoolA', studentId: 'studentA', status: 'present',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'attendance_records', 'rec3')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'attendance_records', 'rec3')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'attendance_records', 'rec3')));
  });

  test('attendance: cross-school write denied, students subcollection scoped via parent lookup', async () => {
    const ref = doc(dbFor('adminA'), 'attendance', '2026-01-01');
    await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', studentId: 'studentA' }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'attendance', '2026-01-02'), {
      schoolId: 'schoolA', studentId: 'studentA',
    }));
    await assertSucceeds(setDoc(doc(ref, 'students', 'studentA'), { status: 'present' }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'attendance', '2026-01-01', 'students', 'studentA'), {
      status: 'present',
    }));
  });

  test('attendance_logs: cross-school read/write denied', async () => {
    const ref = doc(dbFor('adminA'), 'attendance_logs', 'log1');
    await assertSucceeds(setDoc(ref, { schoolId: 'schoolA', className: 'P6' }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'attendance_logs', 'log1')));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'attendance_logs', 'log2'), {
      schoolId: 'schoolA', className: 'P6',
    }));
  });

  test('staff_attendance: cross-school read/write denied, schoolId locked on update', async () => {
    const ref = doc(dbFor('adminA'), 'staff_attendance', 'teacherA_2026-01-01');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', staffId: 'teacherA', clockIn: new Date(), status: 'on_time', location: 'Main Gate',
    }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'staff_attendance', 'teacherA_2026-01-01')));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
  });

  test('boarding_attendance: hasAnyRole OR-branch still admits a matron with no assignment row', async () => {
    const ref = doc(dbFor('matronA'), 'boarding_attendance', 'roll1');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
      dormitoryId: 'dormA', date: new Date(), type: 'Evening', status: 'Present', recordedBy: 'matronA',
    }));
  });

  test('boarding_attendance: cross-school write denied even for a qualifying role', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'users', 'matronB'), {
        role: 'boardingMatron', roles: ['boardingMatron'], schoolId: 'schoolB', studentIds: [],
      });
    });
    await assertFails(setDoc(doc(dbFor('matronB'), 'boarding_attendance', 'roll2'), {
      schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
      dormitoryId: 'dormA', date: new Date(), type: 'Evening', status: 'Present', recordedBy: 'matronB',
    }));
  });

  test('boarding_attendance: readable by staff and the linked student/parent, cross-school denied', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'boarding_attendance', 'roll3'), {
        schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
        dormitoryId: 'dormA', date: new Date(), type: 'Evening', status: 'Present', recordedBy: 'matronA',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'boarding_attendance', 'roll3')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'boarding_attendance', 'roll3')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'boarding_attendance', 'roll3')));
  });

  test('boarding_attendance: an ordinary teacher with neither hasAnyRole nor an assignment is denied', async () => {
    await assertFails(setDoc(doc(dbFor('teacherA'), 'boarding_attendance', 'roll4'), {
      schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
      dormitoryId: 'dormA', date: new Date(), type: 'Evening', status: 'Present', recordedBy: 'teacherA',
    }));
  });
});

// MTN Mobile Money payment tenant isolation. payment_transactions is the
// pre-existing audit-trail mirror (now also written by the automated MTN
// settlement path in public_functions/mtn_momo.js); mtn_payments is the new
// live-status collection Flutter polls while a payment is in flight. Both
// are Admin-SDK-write-only - every scenario here is about who may *read*
// which school's rows, and that no client write of any kind is ever
// permitted regardless of role.
describe('MTN Mobile Money payment tenant isolation', () => {
  async function seedPayments() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await Promise.all([
        setDoc(doc(db, 'payment_transactions', 'txnA'), {
          id: 'txnA', schoolId: 'schoolA', provider: 'mtn_momo_auto',
          phoneNumber: '2567******37', amountUgx: 550000, status: 'success',
          reference: 'financial-txn-a', paymentType: 'activation', planId: 'growth',
        }),
        setDoc(doc(db, 'payment_transactions', 'txnB'), {
          id: 'txnB', schoolId: 'schoolB', provider: 'mtn_momo_auto',
          phoneNumber: '2567******99', amountUgx: 350000, status: 'success',
          reference: 'financial-txn-b', paymentType: 'activation', planId: 'starter',
        }),
        setDoc(doc(db, 'mtn_payments', 'payA'), {
          id: 'payA', schoolId: 'schoolA', schoolName: 'School A', planId: 'growth',
          planName: 'Growth', paymentType: 'activation', provider: 'mtn_momo',
          status: 'PENDING', amount: '100', currency: 'EUR', realPlanPriceUgx: 550000,
          targetEnvironment: 'sandbox', phoneNumberMasked: '2567******37',
        }),
        setDoc(doc(db, 'mtn_payments', 'payB'), {
          id: 'payB', schoolId: 'schoolB', schoolName: 'School B', planId: 'starter',
          planName: 'Starter', paymentType: 'activation', provider: 'mtn_momo',
          status: 'PENDING', amount: '100', currency: 'EUR', realPlanPriceUgx: 350000,
          targetEnvironment: 'sandbox', phoneNumberMasked: '2567******99',
        }),
      ]);
    });
  }

  test('payment_transactions: School A cannot read School B transactions', async () => {
    await seedPayments();
    await assertFails(getDoc(doc(dbFor('adminA'), 'payment_transactions', 'txnB')));
    await assertFails(getDoc(doc(dbFor('bursarA'), 'payment_transactions', 'txnB')));
  });

  test('payment_transactions: School B cannot read School A transactions', async () => {
    await seedPayments();
    await assertFails(getDoc(doc(dbFor('teacherB'), 'payment_transactions', 'txnA')));
    await assertFails(getDoc(doc(dbFor('bursarB'), 'payment_transactions', 'txnA')));
  });

  test('payment_transactions: authorized School A staff (bursar/admin) can read School A transactions', async () => {
    await seedPayments();
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'payment_transactions', 'txnA')));
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'payment_transactions', 'txnA')));
  });

  test('payment_transactions: SaaS owner can read across schools, unauthenticated cannot read at all', async () => {
    await seedPayments();
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'payment_transactions', 'txnA')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'payment_transactions', 'txnB')));
    await assertFails(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'payment_transactions', 'txnA')));
  });

  test('payment_transactions: no client, including the owning school, can create a fake settled transaction', async () => {
    await assertFails(setDoc(doc(dbFor('bursarA'), 'payment_transactions', 'fakeTxn'), {
      id: 'fakeTxn', schoolId: 'schoolA', provider: 'mtn_momo_auto',
      amountUgx: 999999, status: 'success', reference: 'forged',
    }));
    await assertFails(setDoc(doc(dbFor('ownerA'), 'payment_transactions', 'fakeTxn2'), {
      id: 'fakeTxn2', schoolId: 'schoolA', provider: 'mtn_momo_auto',
      amountUgx: 1, status: 'success', reference: 'forged-by-owner',
    }));
  });

  test('payment_transactions: no client can mark an existing transaction successful or mutate its reference', async () => {
    await seedPayments();
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'payment_transactions', 'txnA'), {
      status: 'success', reference: 'tampered-reference',
    }));
    await assertFails(updateDoc(doc(dbFor('ownerA'), 'payment_transactions', 'txnA'), {
      amountUgx: 1,
    }));
  });

  test('mtn_payments: School A cannot read School B payment attempts, and vice versa', async () => {
    await seedPayments();
    await assertFails(getDoc(doc(dbFor('adminA'), 'mtn_payments', 'payB')));
    await assertFails(getDoc(doc(dbFor('bursarA'), 'mtn_payments', 'payB')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'mtn_payments', 'payA')));
  });

  test('mtn_payments: authorized School A billing role can read School A payment attempts', async () => {
    await seedPayments();
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'mtn_payments', 'payA')));
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'mtn_payments', 'payA')));
  });

  test('mtn_payments: a same-school role outside the billing allow-list (e.g. classTeacher) is denied', async () => {
    await seedPayments();
    await assertFails(getDoc(doc(dbFor('teacherA'), 'mtn_payments', 'payA')));
  });

  test('mtn_payments: SaaS owner can read across schools', async () => {
    await seedPayments();
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'mtn_payments', 'payA')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'mtn_payments', 'payB')));
  });

  test('mtn_payments: no client can create an arbitrary successful payment attempt', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'mtn_payments', 'fakePay'), {
      id: 'fakePay', schoolId: 'schoolA', status: 'SUCCESSFUL', realPlanPriceUgx: 1,
      provider: 'mtn_momo', targetEnvironment: 'sandbox',
    }));
  });

  test('mtn_payments: no client can flip status to SUCCESSFUL or change settlement/provider fields', async () => {
    await seedPayments();
    await assertFails(updateDoc(doc(dbFor('adminA'), 'mtn_payments', 'payA'), {
      status: 'SUCCESSFUL',
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'mtn_payments', 'payA'), {
      mtnFinancialTransactionId: 'forged-ftid', settledAt: new Date(), subscriptionExpiry: 0,
    }));
    await assertFails(updateDoc(doc(dbFor('ownerA'), 'mtn_payments', 'payA'), {
      status: 'SUCCESSFUL',
    }));
  });

  test('mtn_payments: no client can delete a payment attempt', async () => {
    await seedPayments();
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'mtn_payments', 'payA')));
    await assertFails(deleteDoc(doc(dbFor('ownerA'), 'mtn_payments', 'payA')));
  });
});
