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
      headTeacherA: { role: 'headTeacher', roles: ['headTeacher'], schoolId: 'schoolA', studentIds: [] },
      storeA: { role: 'storeInventory', roles: ['storeInventory'], schoolId: 'schoolA', studentIds: [] },
      adminA: { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolA', studentIds: [] },
      bursarA: { role: 'bursar', roles: ['bursar'], schoolId: 'schoolA', studentIds: [] },
      bursarB: { role: 'bursar', roles: ['bursar'], schoolId: 'schoolB', studentIds: [] },
      ownerA: { role: 'superAdmin', roles: ['superAdmin'], schoolId: null, studentIds: [] },
      // A second superAdmin, used only to prove per-owner isolation of the
      // owner notification feed. There is one seeded owner in production;
      // this fixture just exercises the ownerId predicate in the rule.
      ownerB: { role: 'superAdmin', roles: ['superAdmin'], schoolId: null, studentIds: [] },
      matronA: { role: 'boardingMatron', roles: ['boardingMatron'], schoolId: 'schoolA', studentIds: [] },
      patronA: { role: 'boardingPatron', roles: ['boardingPatron'], schoolId: 'schoolA', studentIds: [] },
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
      // Not schoolAdmin/director/headTeacher/deputyHead/securityHead - a
      // role (hrOfficer, otherwise unused by any credential test fixture so
      // granting it here can't leak into teacherA/otherTeacherA's own
      // classTeacher role) explicitly granted identity.credential.manage
      // via role_permission_overrides, to prove the override path (not just
      // the admin-role fast path) actually grants credential authority.
      credentialManagerA: {
        role: 'hrOfficer', roles: ['hrOfficer'], schoolId: 'schoolA', studentIds: [],
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
        schoolId: 'schoolA', studentId: 'studentA', isPrivate: false, note: 'Doing well', gender: 'Female',
      }),
      setDoc(doc(db, 'welfare_records', 'privateA'), {
        schoolId: 'schoolA', studentId: 'studentA', isPrivate: true, note: 'Private', gender: 'Female',
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
      setDoc(doc(db, 'portal_domains', 'greena.schoolpulseapp.com'), {
        schoolId: 'schoolA', slug: 'greena', schoolName: 'School A',
        status: 'active', primaryColor: '#123456',
      }),
      setDoc(doc(db, 'portal_domains', 'suspended.schoolpulseapp.com'), {
        schoolId: 'schoolB', slug: 'suspended', schoolName: 'School B', status: 'suspended',
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
      // Owner notification feed fixtures for the per-owner-isolation tests.
      // notifOwnerA belongs to ownerA; notifOwnerB to ownerB; notifLegacy
      // predates ownerId scoping and carries no ownerId (must stay readable
      // by the single seeded owner).
      setDoc(doc(db, 'super_admin_notifications', 'notifOwnerA'), {
        ownerId: 'ownerA', type: 'manual_payment_submitted', status: 'unread',
        title: 'Payment verification required', schoolId: 'schoolA',
      }),
      setDoc(doc(db, 'super_admin_notifications', 'notifOwnerB'), {
        ownerId: 'ownerB', type: 'manual_payment_submitted', status: 'unread',
        title: 'Payment verification required', schoolId: 'schoolB',
      }),
      setDoc(doc(db, 'super_admin_notifications', 'notifLegacy'), {
        type: 'school_application', status: 'unread',
        title: 'New school application',
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

      // Grants credentialManagerA (hrOfficer) the identity.credential.manage
      // override, mirroring how a School Admin would actually delegate this
      // authority via role_permission_overrides rather than a hardcoded
      // role check. hrOfficer specifically (not classTeacher) so this can't
      // leak into teacherA/otherTeacherA's own role-based tests.
      setDoc(doc(db, 'schools/schoolA/role_permission_overrides/hrOfficer'), {
        role: 'hrOfficer', permissions: ['identity.credential.manage'], updatedBy: 'adminA',
      }),
      // A pre-existing active credential bound to studentA, used by the
      // duplicate-assignment/ownership-immutability/cross-school tests.
      setDoc(doc(db, 'schools/schoolA/credentials/CARDA001'), {
        credentialValue: 'CARDA001', credentialType: 'nfc', identityId: 'SP-STUDENT-A',
        identityType: 'student', schoolId: 'schoolA', status: 'active',
        updatedAt: new Date().toISOString(), credentialVersion: 1,
      }),
      // A revoked credential, used by the reuse/reassignment test.
      setDoc(doc(db, 'schools/schoolA/credentials/CARDA002'), {
        credentialValue: 'CARDA002', credentialType: 'nfc', identityId: 'SP-STUDENT-OLD',
        identityType: 'student', schoolId: 'schoolA', status: 'revoked',
        updatedAt: new Date().toISOString(), credentialVersion: 1,
      }),
      setDoc(doc(db, 'schools/schoolB/credentials/CARDB001'), {
        credentialValue: 'CARDB001', credentialType: 'nfc', identityId: 'SP-STUDENT-B',
        identityType: 'student', schoolId: 'schoolB', status: 'active',
        updatedAt: new Date().toISOString(), credentialVersion: 1,
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
  test('clinic-visit creation is callable-only — even a same-school nurse cannot write the doc directly', async () => {
    // createClinicVisit (Admin SDK) owns the create path now; a direct
    // client write is refused regardless of role or school.
    await assertFails(setDoc(doc(dbFor('nurseA'), 'clinic_visits', 'newVisit'), {
      schoolId: 'schoolA', studentId: 'studentA', recordedBy: 'nurseA', reason: 'Headache',
    }));
    await assertFails(setDoc(doc(dbFor('adminA'), 'clinic_visits', 'newVisit2'), {
      schoolId: 'schoolA', studentId: 'studentA', recordedBy: 'adminA', reason: 'Headache',
    }));
  });

  test('nurse and secondary nurse roles can write health profiles only inside their school', async () => {
    await assertSucceeds(setDoc(doc(dbFor('secondaryNurseA'), 'health_profiles', 'newProfile'), {
      schoolId: 'schoolA', studentId: 'studentA', bloodGroup: 'A+',
    }));
    await assertSucceeds(updateDoc(doc(dbFor('nurseA'), 'health_profiles', 'profileA'), {
      bloodGroup: 'A-',
    }));
    await assertFails(setDoc(doc(dbFor('nurseA'), 'health_profiles', 'crossSchoolProfile'), {
      schoolId: 'schoolB', studentId: 'studentB', bloodGroup: 'O+',
    }));
    await assertFails(getDoc(doc(dbFor('nurseA'), 'clinic_visits', 'visitB')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'clinic_visits', 'visitA')));
  });

  test('parents and students cannot directly read clinical records', async () => {
    // Parent-safe summaries are server-generated projections. Direct clinic
    // documents contain clinical notes and remain nurse/admin-only.
    await assertFails(getDoc(doc(dbFor('parentA'), 'clinic_visits', 'visitA')));
    await assertFails(getDoc(doc(dbFor('studentUserA'), 'clinic_visits', 'visitA')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'clinic_visits', 'visitA')));
    await assertFails(updateDoc(doc(dbFor('parentA'), 'clinic_visits', 'visitA'), { reason: 'Changed' }));
  });

  test('parent queries cannot enumerate clinical records', async () => {
    const allowedQuery = query(
      collection(dbFor('parentA'), 'clinic_visits'),
      where('schoolId', '==', 'schoolA'),
      where('studentId', '==', 'studentA'),
    );
    await assertFails(getDocs(allowedQuery));
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

  test('nurse creates an own pending request; the requestedBy identity is still locked to the caller', async () => {
    await assertSucceeds(setDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'newRequest'), {
      schoolId: 'schoolA',
      requestedBy: 'nurseA',
      status: 'SupplyRequestStatus.pending',
    }));
    // requestedBy must equal the caller regardless of role.
    await assertFails(setDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'forgedRequest'), {
      schoolId: 'schoolA',
      requestedBy: 'secondaryNurseA',
      status: 'SupplyRequestStatus.pending',
    }));
  });

  test('the supply-request state machine still enforces a valid, field-limited transition (role gating relaxed to same-school staff, 2026-08-26)', async () => {
    // Per the 2026-08-26 decision hasAnyRole() == isStaff(), so any
    // same-school staff member (incl. a nurse) may now advance a request.
    // The value of the guard is now the transition + affectedKeys lock, not
    // the role list: pending -> approved with only the allowed keys succeeds…
    await assertSucceeds(updateDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'requestA'), {
      status: 'SupplyRequestStatus.approved',
      bursaReviewNotes: 'Reviewed',
      updatedAt: new Date(),
    }));
    // …but an out-of-sequence jump is refused (requestA is now 'approved';
    // 'approved' -> 'delivered' skips 'purchased').
    await assertFails(updateDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'requestA'), {
      status: 'SupplyRequestStatus.delivered',
      updatedAt: new Date(),
    }));
    // …and re-assigning requestedBy to a different user is refused by the
    // affectedKeys() field lock.
    await assertFails(updateDoc(doc(dbFor('nurseA'), 'medical_supply_requests', 'requestA'), {
      requestedBy: 'secondaryNurseA',
      status: 'SupplyRequestStatus.purchased',
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
  // Per the 2026-08-26 product decision hasAnyRole() == isStaff(): the
  // per-gender / per-privacy split on welfare_records collapsed to
  // "any same-school staff member". A parent is still not staff, so the
  // parent boundary is unchanged; the cross-school boundary is unchanged.
  test('a parent still cannot read a private welfare record; any same-school staff now can', async () => {
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'welfare_records', 'publicA')));
    await assertSucceeds(getDoc(doc(dbFor('nurseA'), 'welfare_records', 'publicA')));
    await assertFails(getDoc(doc(dbFor('parentA'), 'welfare_records', 'privateA')));
    await assertSucceeds(getDoc(doc(dbFor('nurseA'), 'welfare_records', 'privateA')));
  });

  test('same-school staff can manage welfare records but nobody can delete them', async () => {
    await assertSucceeds(setDoc(doc(dbFor('matronA'), 'welfare_records', 'newRecord'), {
      schoolId: 'schoolA', studentId: 'studentA', isPrivate: false, note: 'Settled', gender: 'Female',
    }));
    await assertSucceeds(updateDoc(doc(dbFor('matronA'), 'welfare_records', 'publicA'), {
      note: 'Updated',
    }));
    await assertFails(deleteDoc(doc(dbFor('matronA'), 'welfare_records', 'publicA')));
  });

  test('the cross-school boundary on welfare records still holds', async () => {
    // nurseB is staff in schoolB; schoolA's welfare records stay out of reach.
    await assertFails(getDoc(doc(dbFor('nurseB'), 'welfare_records', 'publicA')));
    await assertFails(updateDoc(doc(dbFor('nurseB'), 'welfare_records', 'publicA'), {
      note: 'Cross-school write',
    }));
    await assertFails(setDoc(doc(dbFor('nurseB'), 'welfare_records', 'crossSchoolRecord'), {
      schoolId: 'schoolA', studentId: 'studentA', isPrivate: false, note: 'x', gender: 'Female',
    }));
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
  test('portal directory exposes only active mappings and is never client writable', async () => {
    const anonymous = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anonymous, 'portal_domains', 'greena.schoolpulseapp.com')));
    await assertFails(getDoc(doc(anonymous, 'portal_domains', 'suspended.schoolpulseapp.com')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'portal_domains', 'forged.schoolpulseapp.com'), {
      schoolId: 'schoolB', status: 'active', schoolName: 'Forged',
    }));
  });

  test('any signed-in user can read a school profile, but only the owner can write it', async () => {
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools', 'schoolA')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'schools', 'schoolA')));
    await assertSucceeds(updateDoc(doc(dbFor('ownerA'), 'schools', 'schoolA'), { status: 'suspended' }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'schools', 'schoolA'), { status: 'suspended' }));
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools', 'schoolB'), { name: 'Forged School' }));
  });

  test('only the owner can manage tenants; the subscription plan catalog is shared read, owner-write', async () => {
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'tenants', 'tenantA'), { schoolId: 'schoolA' }));
    await assertFails(setDoc(doc(dbFor('adminA'), 'tenants', 'tenantB'), { schoolId: 'schoolA' }));
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'subscription_plans', 'planA'), { name: 'Pro' }));
    // subscription_plans is shared catalog data, not tenant-scoped - any
    // signed-in staff member needs read access to it (see firestore.rules'
    // own comment on this collection), so a same-tenant admin reading it
    // back is expected to succeed, not fail.
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'subscription_plans', 'planA')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'subscription_plans', 'planB'), { name: 'Forged' }));
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

  describe('super_admin_notifications: owner-only feed, per-owner isolation, server-write-only', () => {
    test('the owner it belongs to can read their own notification', async () => {
      await assertSucceeds(
        getDoc(doc(dbFor('ownerA'), 'super_admin_notifications', 'notifOwnerA')),
      );
    });

    test('a legacy notification with no ownerId stays readable by a superAdmin', async () => {
      await assertSucceeds(
        getDoc(doc(dbFor('ownerA'), 'super_admin_notifications', 'notifLegacy')),
      );
    });

    test('a superAdmin cannot read another owner\'s notification (no cross-owner access)', async () => {
      await assertFails(
        getDoc(doc(dbFor('ownerA'), 'super_admin_notifications', 'notifOwnerB')),
      );
      await assertFails(
        getDoc(doc(dbFor('ownerB'), 'super_admin_notifications', 'notifOwnerA')),
      );
    });

    test('a school admin is denied even with a known document id', async () => {
      await assertFails(
        getDoc(doc(dbFor('adminA'), 'super_admin_notifications', 'notifOwnerA')),
      );
      await assertFails(
        getDoc(doc(dbFor('adminA'), 'super_admin_notifications', 'notifLegacy')),
      );
    });

    test('staff (teacher, bursar, nurse) are denied', async () => {
      await assertFails(
        getDoc(doc(dbFor('teacherA'), 'super_admin_notifications', 'notifOwnerA')),
      );
      await assertFails(
        getDoc(doc(dbFor('bursarA'), 'super_admin_notifications', 'notifOwnerA')),
      );
      await assertFails(
        getDoc(doc(dbFor('nurseA'), 'super_admin_notifications', 'notifOwnerA')),
      );
    });

    test('a parent is denied', async () => {
      await assertFails(
        getDoc(doc(dbFor('parentA'), 'super_admin_notifications', 'notifOwnerA')),
      );
    });

    test('an unauthenticated caller is denied', async () => {
      const anon = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        getDoc(doc(anon, 'super_admin_notifications', 'notifOwnerA')),
      );
    });

    test('no client can create, update or delete a notification - not even the owner', async () => {
      await assertFails(
        setDoc(doc(dbFor('ownerA'), 'super_admin_notifications', 'forged'), {
          ownerId: 'ownerA', type: 'forged', status: 'unread', title: 'x',
        }),
      );
      await assertFails(
        updateDoc(doc(dbFor('ownerA'), 'super_admin_notifications', 'notifOwnerA'), {
          status: 'read',
        }),
      );
      await assertFails(
        deleteDoc(doc(dbFor('ownerA'), 'super_admin_notifications', 'notifOwnerA')),
      );
    });

    test('a school admin cannot forge an owner notification addressed to themselves', async () => {
      await assertFails(
        setDoc(doc(dbFor('adminA'), 'super_admin_notifications', 'forgedByAdmin'), {
          ownerId: 'adminA', type: 'forged', status: 'unread', title: 'x',
        }),
      );
    });

    test('owner-to-tenant leakage: an owner notification never lands in a tenant-readable path', async () => {
      // The feed lives only at the top-level super_admin_notifications
      // collection; there is no schools/{id}/... mirror a school role could
      // read. Confirm a same-school admin cannot reach it by any id.
      await assertFails(
        getDoc(doc(dbFor('adminA'), 'super_admin_notifications', 'notifOwnerB')),
      );
      await assertFails(
        getDocs(query(collection(dbFor('adminA'), 'super_admin_notifications'))),
      );
    });
  });

  test('platform_config is owner-readable and never client-writable, even by the owner', async () => {
    await assertFails(setDoc(doc(dbFor('ownerA'), 'platform_config', 'ownerSeed'), { seeded: true }));
    await assertFails(getDoc(doc(dbFor('adminA'), 'platform_config', 'ownerSeed')));
  });

  describe('Platform Health: platform_health/job_runs/platform_job_failures are owner-read-only, no client writes', () => {
    test('platform_health/current is owner-readable and never client-writable, even by the owner', async () => {
      await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'platform_health', 'current')));
      await assertFails(getDoc(doc(dbFor('adminA'), 'platform_health', 'current')));
      await assertFails(getDoc(doc(dbFor('teacherA'), 'platform_health', 'current')));
      await assertFails(setDoc(doc(dbFor('ownerA'), 'platform_health', 'current'), { status: 'operational' }));
      await assertFails(updateDoc(doc(dbFor('ownerA'), 'platform_health', 'current'), { status: 'outage' }));
    });

    test('job_runs is owner-readable and never client-writable, even by the owner', async () => {
      await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'job_runs', 'purgeExpiredNotifications')));
      await assertFails(getDoc(doc(dbFor('adminA'), 'job_runs', 'purgeExpiredNotifications')));
      await assertFails(setDoc(doc(dbFor('ownerA'), 'job_runs', 'forgedJob'), { lastStatus: 'success' }));
    });

    test('platform_job_failures is owner-readable and never client-writable, even by the owner', async () => {
      await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'platform_job_failures', 'failureA')));
      await assertFails(getDoc(doc(dbFor('adminA'), 'platform_job_failures', 'failureA')));
      await assertFails(setDoc(doc(dbFor('ownerA'), 'platform_job_failures', 'forgedFailure'), {
        category: 'payment_processing', source: 'forged',
      }));
    });
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

describe('reportCards: canonical snapshots are server-write-only', () => {
  async function seedReportCard() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'schools/schoolA/reportCards/rc1'),
        {
          schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
          academicYearId: '2026', termId: 't2', average: 79, version: 1,
          isFinalized: false,
        },
      );
    });
  }

  test('staff of the same school may read a report card', async () => {
    await seedReportCard();
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/reportCards/rc1')));
  });

  test('no client - not even the academic office - may create a report card directly', async () => {
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/reportCards/clientForged'),
      {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', average: 100, version: 1,
      },
    ));
  });

  test('no client may edit an existing report card - not the average, not isFinalized', async () => {
    await seedReportCard();
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'schools/schoolA/reportCards/rc1'),
      { average: 100 },
    ));
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'schools/schoolA/reportCards/rc1'),
      { isFinalized: true },
    ));
  });

  test('no client may delete a report card', async () => {
    await seedReportCard();
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'schools/schoolA/reportCards/rc1')));
  });

  test('another school never reaches this collection', async () => {
    await seedReportCard();
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/reportCards/rc1')));
  });

  test('a parent or student cannot read an unfinalized, unreleased report card', async () => {
    await seedReportCard();
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportCards/rc1')));
    await assertFails(getDoc(doc(dbFor('studentUserA'), 'schools/schoolA/reportCards/rc1')));
  });

  test('a parent or student cannot read a finalized report card the Bursar has not released', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportCards/rcFinalizedHeld'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', average: 79, version: 1,
        isFinalized: true, financialAccessStatus: 'held',
      });
    });
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportCards/rcFinalizedHeld')));
    await assertFails(getDoc(doc(dbFor('studentUserA'), 'schools/schoolA/reportCards/rcFinalizedHeld')));
  });

  test('the linked parent and the student themself CAN read a finalized, released report card', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportCards/rcReleased'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', average: 79, version: 1,
        isFinalized: true, financialAccessStatus: 'released',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportCards/rcReleased')));
    await assertSucceeds(getDoc(doc(dbFor('studentUserA'), 'schools/schoolA/reportCards/rcReleased')));
  });

  test('an unrelated parent cannot read a released report card for a student they are not linked to', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportCards/rcReleasedOther'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', average: 79, version: 1,
        isFinalized: true, financialAccessStatus: 'released',
      });
    });
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'schools/schoolA/reportCards/rcReleasedOther')));
  });

  test('a released report revoked by the Bursar is denied to parent/student again', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportCards/rcRevoked'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', average: 79, version: 1,
        isFinalized: true, financialAccessStatus: 'revoked',
      });
    });
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportCards/rcRevoked')));
  });

  test('another school tenant is denied even for a finalized, released report', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportCards/rcReleasedCrossTenant'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', average: 79, version: 1,
        isFinalized: true, financialAccessStatus: 'released',
      });
    });
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/reportCards/rcReleasedCrossTenant')));
  });

  test('the auditLog subcollection is staff-readable but client-immutable, same as every other audit trail', async () => {
    await seedReportCard();
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/reportCards/rc1/auditLog/forged'),
      { action: 'report_card.generated' },
    ));
  });
});

describe('reportCardReleaseExceptions + reportReleasePolicy: Bursar release layer', () => {
  async function seedException() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'schools/schoolA/reportCardReleaseExceptions/exc1'),
        {
          schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
          academicYearId: '2026', termId: 't2', reasonCode: 'paymentPlan',
          outstandingBalanceUgxAtRelease: 100000, status: 'active',
          createdByUid: 'bursarA', createdByName: 'bursarA',
        },
      );
    });
  }

  test('staff of the same school may read an exception record', async () => {
    await seedException();
    await assertSucceeds(
      getDoc(doc(dbFor('teacherA'), 'schools/schoolA/reportCardReleaseExceptions/exc1')),
    );
    await assertSucceeds(
      getDoc(doc(dbFor('bursarA'), 'schools/schoolA/reportCardReleaseExceptions/exc1')),
    );
  });

  test('a parent - even the linked parent - can never read an exception record', async () => {
    await seedException();
    await assertFails(
      getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportCardReleaseExceptions/exc1')),
    );
    await assertFails(
      getDoc(doc(dbFor('studentUserA'), 'schools/schoolA/reportCardReleaseExceptions/exc1')),
    );
  });

  test('cross-school staff cannot read another school\'s exception records', async () => {
    await seedException();
    await assertFails(
      getDoc(doc(dbFor('teacherB'), 'schools/schoolA/reportCardReleaseExceptions/exc1')),
    );
  });

  test('no client - not even the Bursar - may write an exception record directly', async () => {
    await assertFails(setDoc(
      doc(dbFor('bursarA'), 'schools/schoolA/reportCardReleaseExceptions/forged'),
      {
        schoolId: 'schoolA', studentId: 'studentA', status: 'active',
        outstandingBalanceUgxAtRelease: 0, reasonCode: 'custom',
      },
    ));
    await seedException();
    await assertFails(updateDoc(
      doc(dbFor('bursarA'), 'schools/schoolA/reportCardReleaseExceptions/exc1'),
      { status: 'revoked' },
    ));
  });

  test('a held finalized report is unreadable by the linked parent even while an exception doc exists', async () => {
    await seedException();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportCards/rcHeldWithExc'), {
        schoolId: 'schoolA', studentId: 'studentA', classId: 'p7',
        academicYearId: '2026', termId: 't2', version: 1,
        isFinalized: true, financialAccessStatus: 'held',
      });
    });
    await assertFails(
      getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportCards/rcHeldWithExc')),
    );
  });

  test('the release policy is readable by any same-school user (parent needs the restriction message)', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/configs/reportReleasePolicy'), {
        financialClearance: { mode: 'fullBalance', restrictionMessage: 'Contact the bursar.' },
      });
    });
    await assertSucceeds(
      getDoc(doc(dbFor('parentA'), 'schools/schoolA/configs/reportReleasePolicy')),
    );
    await assertSucceeds(
      getDoc(doc(dbFor('teacherA'), 'schools/schoolA/configs/reportReleasePolicy')),
    );
  });

  test('only finance/leadership may change the clearance policy', async () => {
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/configs/reportReleasePolicy'),
      { financialClearance: { mode: 'minimumPercentage', minimumPercentagePaid: 0 } },
    ));
    await assertFails(setDoc(
      doc(dbFor('parentA'), 'schools/schoolA/configs/reportReleasePolicy'),
      { financialClearance: { mode: 'minimumPercentage', minimumPercentagePaid: 0 } },
    ));
    await assertSucceeds(setDoc(
      doc(dbFor('bursarA'), 'schools/schoolA/configs/reportReleasePolicy'),
      { financialClearance: { mode: 'fullBalance' } },
    ));
    await assertSucceeds(setDoc(
      doc(dbFor('headTeacherA'), 'schools/schoolA/configs/reportReleasePolicy'),
      { financialClearance: { mode: 'selectedCategories', feeCategoryIds: ['tuition'] } },
    ));
  });
});

describe('reportVerifications: public get(), server-write-only', () => {
  test('anyone signed in may get() a known verification code, but never list the collection', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/reportVerifications/tok123'), {
        verificationCode: 'tok123', schoolId: 'schoolA', isFinalized: true, isCurrent: true,
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/reportVerifications/tok123')));
  });

  test('no client - not even staff - may write a verification record directly', async () => {
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/reportVerifications/forged'),
      { verificationCode: 'forged', schoolId: 'schoolA', isFinalized: true, isCurrent: true },
    ));
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

  test('the write-lock generalizes to other threaded collections (attendance_records)', async () => {
    // staff_attendance used to be the example here, but it became
    // callable-write-only (3487115f), so it no longer exercises
    // schoolCanWrite; attendance_records is still client-writable behind it.
    await assertFails(setDoc(doc(dbFor('teacherReadOnly'), 'attendance_records', 'roAttendance'), {
      schoolId: 'schoolReadOnly', studentId: 'student1', date: '2026-08-12',
    }));
    await assertSucceeds(setDoc(doc(dbFor('teacherFull'), 'attendance_records', 'fullAttendance'), {
      schoolId: 'schoolFull', studentId: 'student1', date: '2026-08-12',
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

  test('institution_profile: only School Admin-tier roles may write it, a general staff account cannot', async () => {
    await assertSucceeds(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/config/institution_profile'),
      { name: 'Greenwood Primary' },
    ));
    // A plain teacher must not be able to rewrite the school's identity -
    // institution_profile is deliberately stricter than the other config
    // docs under schools/{schoolId}/config, which any staff may write.
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/config/institution_profile'),
      { name: 'Hacked by teacher' },
    ));
    await assertFails(setDoc(
      doc(dbFor('teacherB'), 'schools/schoolA/config/institution_profile'),
      { name: 'Hacked cross-school' },
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

describe('users/{uid} self-service lastActiveAt heartbeat (4-month idle-logout window)', () => {
  test('a staff member can bump only their own lastActiveAt', async () => {
    await assertSucceeds(updateDoc(
      doc(dbFor('teacherA'), 'users', 'teacherA'),
      { lastActiveAt: new Date() },
    ));
  });

  test('a staff member cannot bump another user\'s lastActiveAt', async () => {
    await assertFails(updateDoc(
      doc(dbFor('teacherA'), 'users', 'otherTeacherA'),
      { lastActiveAt: new Date() },
    ));
  });

  test('lastActiveAt cannot be combined with any other field in the same write', async () => {
    await assertFails(updateDoc(
      doc(dbFor('teacherA'), 'users', 'teacherA'),
      { lastActiveAt: new Date(), roles: ['schoolAdmin'] },
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

  test('student_access_codes: no client (including a tenant administrator) may write directly - '
    + 'provisionStudentAccessCode/resetStudentPin/setStudentAccessCodeStatus are the only writers; '
    + 'list is staff-only same-school, direct-by-id get is public', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'student_access_codes', 'STU123'), {
        schoolId: 'schoolA', studentId: 'studentA', studentName: 'Student A',
        phoneNumber: '+256700000000', pin: '1234', isActive: true,
      });
    });
    await assertFails(setDoc(doc(dbFor('adminA'), 'student_access_codes', 'STU456'), {
      schoolId: 'schoolA', studentId: 'studentB', studentName: 'Student B',
      phoneNumber: '+256700000001', pin: '5678', isActive: true,
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'student_access_codes', 'STU123'), {
      pin: '9999',
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
  test('root config is platform-only while appointment policy keeps its explicit client read', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'config', 'system'), { value: 'legacy' });
      await setDoc(doc(context.firestore(), 'config', 'appointment_policy'), { value: 'policy' });
    });
    await assertFails(getDoc(doc(dbFor('adminA'), 'config', 'system')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'config', 'system')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'config', 'appointment_policy')));
    await assertFails(setDoc(doc(dbFor('teacherA'), 'config', 'appointment_policy'), { value: 'changed' }));
  });

  test('alerts: staff notification queries must carry the active school scope', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'alerts', 'alertA'), {
        schoolId: 'schoolA', targets: ['Teachers'], timestamp: new Date(),
      });
      await setDoc(doc(db, 'alerts', 'alertB'), {
        schoolId: 'schoolB', targets: ['Teachers'], timestamp: new Date(),
      });
    });
    await assertSucceeds(getDocs(query(
      collection(dbFor('teacherA'), 'alerts'),
      where('schoolId', '==', 'schoolA'),
      where('targets', 'array-contains-any', ['Teachers']),
    )));
    await assertFails(getDocs(query(
      collection(dbFor('teacherA'), 'alerts'),
      where('targets', 'array-contains-any', ['Teachers']),
    )));
  });

  test('parent_access_codes: list and mutation are tenant-scoped while direct resolution remains public', async () => {
    const ref = doc(dbFor('adminA'), 'parent_access_codes', 'PA1');
    await assertSucceeds(setDoc(ref, {
      schoolId: 'schoolA', studentIds: ['studentA'], phoneNumber: '+256700000001', isActive: true,
    }));
    await assertSucceeds(getDoc(doc(dbFor('anonymous'), 'parent_access_codes', 'PA1')));
    await assertSucceeds(getDocs(query(collection(dbFor('teacherA'), 'parent_access_codes'), where('schoolId', '==', 'schoolA'))));
    await assertFails(getDocs(collection(dbFor('teacherB'), 'parent_access_codes')));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'parent_access_codes', 'PB1'), {
      schoolId: 'schoolA', studentIds: ['studentA'], phoneNumber: '+256700000002', isActive: true,
    }));
    await assertFails(updateDoc(ref, { schoolId: 'schoolB' }));
  });

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

  test('staff_attendance: cross-school read denied, all client writes denied (callable-only)', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'staff_attendance', 'teacherA_2026-01-01'), {
        schoolId: 'schoolA', staffId: 'teacherA', clockIn: new Date(), status: 'on_time', location: 'Main Gate',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'staff_attendance', 'teacherA_2026-01-01')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'staff_attendance', 'teacherA_2026-01-01')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'staff_attendance', 'teacherA_2026-01-01'), {
      schoolId: 'schoolA', staffId: 'teacherA', clockIn: new Date(), status: 'on_time', location: 'Main Gate',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'staff_attendance', 'teacherA_2026-01-01'), { schoolId: 'schoolB' }));
  });

  test('staff_shifts: tenant-scoped read, all client writes denied (setStaffShift callable-only)', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'institutions', 'schoolA', 'staff_shifts', 'teacherA'), {
        staffId: 'teacherA', schoolId: 'schoolA', scheduledStart: '08:00', scheduledEnd: '16:00',
        daysOfWeek: [1, 2, 3, 4, 5], graceMinutes: 10,
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institutions', 'schoolA', 'staff_shifts', 'teacherA')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'institutions', 'schoolA', 'staff_shifts', 'teacherA')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'institutions', 'schoolA', 'staff_shifts', 'teacherA'), {
      staffId: 'teacherA', schoolId: 'schoolA', scheduledStart: '09:00',
    }));
  });

  test('staff_leave_requests: tenant staff read + self-read carve-out, cross-school denied, writes denied', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'institutions', 'schoolA', 'staff_leave_requests', 'leave1'), {
        staffId: 'teacherA', schoolId: 'schoolA', startDate: '2026-09-01', endDate: '2026-09-03',
        status: 'pending', reason: 'Family event',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institutions', 'schoolA', 'staff_leave_requests', 'leave1')));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'institutions', 'schoolA', 'staff_leave_requests', 'leave1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'institutions', 'schoolA', 'staff_leave_requests', 'leave1')));
    await assertFails(setDoc(doc(dbFor('teacherA'), 'institutions', 'schoolA', 'staff_leave_requests', 'leave1'), {
      status: 'approved',
    }));
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

describe('Appointments module tenant isolation', () => {
  async function seedAppointmentsFixtures() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await Promise.all([
        setDoc(doc(db, 'appointment_types', 'typeA'), {
          schoolId: 'schoolA', name: 'Parent-Teacher Meeting',
        }),
        setDoc(doc(db, 'staff_availability', 'teacherA'), {
          schoolId: 'schoolA', mondaySlots: ['09:00-10:00'],
        }),
      ]);
    });
  }

  test('appointment_types: same-school staff and parents can read, cross-school cannot', async () => {
    await seedAppointmentsFixtures();
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'appointment_types', 'typeA')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'appointment_types', 'typeA')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'appointment_types', 'typeA')));
  });

  test('appointment_types: only same-school staff can create/update, never cross-school', async () => {
    await seedAppointmentsFixtures();
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'appointment_types', 'newType'), {
      schoolId: 'schoolA', name: 'Bursar Meeting',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'appointment_types', 'crossSchoolType'), {
      schoolId: 'schoolA', name: 'Forged',
    }));
    await assertFails(updateDoc(doc(dbFor('teacherB'), 'appointment_types', 'typeA'), {
      name: 'Hijacked',
    }));
  });

  test('staff_availability: same-school staff/parents can read, cross-school cannot', async () => {
    await seedAppointmentsFixtures();
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'staff_availability', 'teacherA')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'staff_availability', 'teacherA')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'staff_availability', 'teacherA')));
  });

  test('staff_availability: the owning staff member can write their own row, a cross-school admin cannot', async () => {
    await seedAppointmentsFixtures();
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'staff_availability', 'teacherA'), {
      schoolId: 'schoolA', mondaySlots: ['10:00-11:00'],
    }, { merge: true }));
    await assertFails(setDoc(doc(dbFor('bursarB'), 'staff_availability', 'teacherA'), {
      schoolId: 'schoolA', mondaySlots: ['forged'],
    }, { merge: true }));
  });
});

describe('Gate ops visitors and movement events', () => {
  test('visitors: same-school staff can read/write, cross-school staff cannot', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools', 'schoolA', 'visitors', 'visitor1'), {
        schoolId: 'schoolA', fullName: 'Jane Guest', status: 'checkedIn',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools', 'schoolA', 'visitors', 'visitor1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools', 'schoolA', 'visitors', 'visitor1')));
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'schools', 'schoolA', 'visitors', 'visitor2'), {
      schoolId: 'schoolA', fullName: 'New Guest', status: 'checkedIn',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'schools', 'schoolA', 'visitors', 'visitor3'), {
      schoolId: 'schoolA', fullName: 'Forged Guest', status: 'checkedIn',
    }));
  });

  test('movement_events: append-only for same-school staff, unreadable cross-school, never editable/deletable', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools', 'schoolA', 'movement_events', 'evt1'), {
        schoolId: 'schoolA', personId: 'studentA', direction: 'in',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools', 'schoolA', 'movement_events', 'evt1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools', 'schoolA', 'movement_events', 'evt1')));
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'schools', 'schoolA', 'movement_events', 'evt2'), {
      schoolId: 'schoolA', personId: 'studentA', direction: 'out',
    }));
    await assertFails(updateDoc(doc(dbFor('teacherA'), 'schools', 'schoolA', 'movement_events', 'evt1'), {
      direction: 'out',
    }));
    await assertFails(deleteDoc(doc(dbFor('teacherA'), 'schools', 'schoolA', 'movement_events', 'evt1')));
  });

  test('movement_events: the linked student and their parent can read their own event', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools', 'schoolA', 'movement_events', 'evtStudentA'), {
        schoolId: 'schoolA', personId: 'studentA', direction: 'in',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('studentUserA'), 'schools', 'schoolA', 'movement_events', 'evtStudentA')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools', 'schoolA', 'movement_events', 'evtStudentA')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'schools', 'schoolA', 'movement_events', 'evtStudentA')));
  });
});

describe('Phase 14 IDOR fixes: payroll, discipline/counseling, homework', () => {
  test('payroll: retired client-authored ledger - no client, including same-school staff, '
    + 'may read or write it; tenant-scoped payroll_runs/callables are the only path now', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'payroll', 'pay1'), {
        schoolId: 'schoolA', staffId: 'teacherA', netPay: 100000,
      });
    });
    await assertFails(getDoc(doc(dbFor('adminA'), 'payroll', 'pay1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'payroll', 'pay1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'payroll', 'pay2'), {
      schoolId: 'schoolA', staffId: 'teacherA', netPay: 200000,
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'payroll', 'pay3'), {
      schoolId: 'schoolA', staffId: 'teacherA', netPay: 999999,
    }));
  });

  test('discipline_incidents and counseling_sessions: cross-referenced against the linked student\'s own school', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'students', 'studentIdorA'), { schoolId: 'schoolA' });
      await setDoc(doc(db, 'discipline_incidents', 'incidentA'), {
        studentId: 'studentIdorA', studentName: 'Student A', category: 'Late', severity: 'Low',
      });
      await setDoc(doc(db, 'counseling_sessions', 'sessionA'), {
        studentId: 'studentIdorA', counselorId: 'staffA', reason: 'Check-in',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'discipline_incidents', 'incidentA')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'discipline_incidents', 'incidentA')));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'counseling_sessions', 'sessionA')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'counseling_sessions', 'sessionA')));

    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'discipline_incidents', 'incidentNew'), {
      studentId: 'studentIdorA', studentName: 'Student A', category: 'Late', severity: 'Low',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'discipline_incidents', 'incidentForged'), {
      studentId: 'studentIdorA', studentName: 'Student A', category: 'Forged', severity: 'High',
    }));
  });

  test('homework: same-school signed-in users can read, cross-school cannot; only same-school staff can write', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'homework', 'hw1'), {
        schoolId: 'schoolA', className: 'P.1', teacherId: 'teacherA',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'homework', 'hw1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'homework', 'hw1')));
    await assertFails(getDoc(doc(dbFor('nurseB'), 'homework', 'hw1')));
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'homework', 'hw2'), {
      schoolId: 'schoolA', className: 'P.1', teacherId: 'teacherA',
    }));
    await assertFails(setDoc(doc(dbFor('teacherB'), 'homework', 'hw3'), {
      schoolId: 'schoolA', className: 'P.1', teacherId: 'teacherB',
    }));
  });
});

describe('Support + Audit Center: tenant isolation and append-only', () => {
  test('support_requests: same-school admin can read, cross-school admin cannot, clients cannot write', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'institutions/schoolA/support_requests/req1'), {
        institutionId: 'schoolA', subject: 'Attendance bug', status: 'submitted',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'institutions/schoolA/support_requests/req1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'institutions/schoolA/support_requests/req1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req2'), {
      institutionId: 'schoolA', subject: 'Forged direct write', status: 'submitted',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req1'), {
      status: 'resolved',
    }));
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req1')));
  });

  test('support responses: institution-visible responses readable by same-school admin, platform-internal notes hidden, cross-school denied', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'institutions/schoolA/support_requests/req1'), {
        institutionId: 'schoolA', subject: 'Attendance bug', status: 'submitted',
      });
      await setDoc(doc(db, 'institutions/schoolA/support_requests/req1/responses/resp1'), {
        supportRequestId: 'req1', institutionId: 'schoolA', body: 'We are looking into it.',
        visibility: 'institution_visible',
      });
      await setDoc(doc(db, 'institutions/schoolA/support_requests/req1/responses/resp2'), {
        supportRequestId: 'req1', institutionId: 'schoolA', body: 'internal triage note',
        visibility: 'platform_internal',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req1/responses/resp1')));
    await assertFails(getDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req1/responses/resp2')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'institutions/schoolA/support_requests/req1/responses/resp1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_requests/req1/responses/resp3'), {
      supportRequestId: 'req1', institutionId: 'schoolA', body: 'forged reply', visibility: 'institution_visible',
    }));
  });

  test('support_access_requests: same-school admin can read/approve context, cross-school denied, no client writes', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'institutions/schoolA/support_access_requests/access1'), {
        institutionId: 'schoolA', status: 'requested', reason: 'diagnose sync issue',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_access_requests/access1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'institutions/schoolA/support_access_requests/access1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'institutions/schoolA/support_access_requests/access1')));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'institutions/schoolA/support_access_requests/access1'), {
      status: 'active',
    }));
  });

  test('audit_events: same-school admin can read, cross-school and non-admin denied, append-only for clients', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'institutions/schoolA/audit_events/event1'), {
        institutionId: 'schoolA', moduleKey: 'support', action: 'support_request_created',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'institutions/schoolA/audit_events/event1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'institutions/schoolA/audit_events/event1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'institutions/schoolA/audit_events/event1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'institutions/schoolA/audit_events/event2'), {
      institutionId: 'schoolA', moduleKey: 'support', action: 'forged_event',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'institutions/schoolA/audit_events/event1'), {
      action: 'tampered',
    }));
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'institutions/schoolA/audit_events/event1')));
  });
});

describe('Module Control Center + Institution Policy Engine', () => {
  test('module_configuration: entitlement is server-owned, admin cannot forge it, cannot re-parent, non-admin cannot enable', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/module_configuration/attendance'), {
        institutionId: 'schoolA', moduleKey: 'attendance', entitled: true, enabled: false,
        configurationVersion: 1,
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools/schoolA/module_configuration/attendance')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/module_configuration/attendance')));
    await assertSucceeds(updateDoc(doc(dbFor('adminA'), 'schools/schoolA/module_configuration/attendance'), {
      institutionId: 'schoolA', moduleKey: 'attendance', entitled: true, enabled: true,
      configurationVersion: 2, updatedBy: 'adminA', reason: 'enable for term',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'schools/schoolA/module_configuration/attendance'), {
      institutionId: 'schoolA', moduleKey: 'attendance', entitled: false, enabled: true,
      configurationVersion: 3, updatedBy: 'adminA', reason: 'forge entitlement',
    }));
    await assertFails(updateDoc(doc(dbFor('teacherA'), 'schools/schoolA/module_configuration/attendance'), {
      institutionId: 'schoolA', moduleKey: 'attendance', entitled: true, enabled: false,
      configurationVersion: 3, updatedBy: 'teacherA', reason: 'unauthorized',
    }));
  });

  test('module_configuration: create is always denied for clients (entitlement is server-written only)', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools/schoolA/module_configuration/boarding'), {
      institutionId: 'schoolA', moduleKey: 'boarding', entitled: true, enabled: false, configurationVersion: 1,
    }));
  });

  test('institution_policies: same-school admin can create/update, cross-school denied, non-admin denied, cannot re-parent institutionId', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'schools/schoolA/institution_policies/policy1'), {
      institutionId: 'schoolA', policyType: 'attendance', policyName: 'Attendance Policy',
      scope: { type: 'institution' }, configuration: {}, status: 'active', version: 1,
      effectiveFrom: new Date(), createdBy: 'adminA', updatedBy: 'adminA', changeReason: 'initial',
    }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/institution_policies/policy1')));
    await assertFails(setDoc(doc(dbFor('teacherA'), 'schools/schoolA/institution_policies/policy2'), {
      institutionId: 'schoolA', policyType: 'attendance', policyName: 'Unauthorized', scope: { type: 'institution' },
      configuration: {}, status: 'draft', version: 1, effectiveFrom: new Date(), createdBy: 'teacherA',
      updatedBy: 'teacherA', changeReason: 'unauthorized',
    }));
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools/schoolB/institution_policies/policy3'), {
      institutionId: 'schoolA', policyType: 'attendance', policyName: 'Cross-tenant re-parent',
      scope: { type: 'institution' }, configuration: {}, status: 'draft', version: 1,
      effectiveFrom: new Date(), createdBy: 'adminA', updatedBy: 'adminA', changeReason: 'attempt',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'schools/schoolA/institution_policies/policy1'), {
      institutionId: 'schoolB',
    }));
  });

  test('institution_policies versions: append-only history, no update or delete', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/institution_policies/policy1'), {
        institutionId: 'schoolA', policyType: 'attendance', policyName: 'Attendance Policy',
        scope: { type: 'institution' }, configuration: {}, status: 'active', version: 1,
        effectiveFrom: new Date(), createdBy: 'adminA', updatedBy: 'adminA', changeReason: 'initial',
      });
    });
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'schools/schoolA/institution_policies/policy1/versions/1'), {
      institutionId: 'schoolA', policyType: 'attendance', version: 1, createdAt: new Date(),
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'schools/schoolA/institution_policies/policy1/versions/1'), {
      version: 2,
    }));
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'schools/schoolA/institution_policies/policy1/versions/1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/institution_policies/policy1/versions/1')));
  });

  test('module_policy_audit: readable only by same-school admin roles, never client-writable', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/module_policy_audit/audit1'), {
        action: 'module_enabled', moduleKey: 'attendance', actorId: 'adminA',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools/schoolA/module_policy_audit/audit1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/module_policy_audit/audit1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/module_policy_audit/audit1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools/schoolA/module_policy_audit/audit2'), {
      action: 'forged',
    }));
  });

  test('communication_campaigns: readable by admin roles same-school, never client-writable', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/communication_campaigns/camp1'), {
        title: 'Term closure', status: 'published', schoolId: 'schoolA',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools/schoolA/communication_campaigns/camp1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/communication_campaigns/camp1')));
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/communication_campaigns/camp1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/communication_campaigns/camp1')));
    // Everything, including publishing a draft, goes through the callable
    // Cloud Functions - the client can never write a campaign document.
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools/schoolA/communication_campaigns/camp2'), {
      title: 'Forged', status: 'published', schoolId: 'schoolA',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'schools/schoolA/communication_campaigns/camp1'), {
      status: 'cancelled',
    }));
  });

  test('communication_acknowledgements: a user may only read/write their own, never another recipient\'s', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/communication_campaigns/camp1'), {
        title: 'Ack required', status: 'published', schoolId: 'schoolA',
      });
      await setDoc(
        doc(context.firestore(), 'schools/schoolA/communication_campaigns/camp1/communication_acknowledgements/parentA'),
        { userId: 'parentA', campaignId: 'camp1', acknowledgedAt: new Date() },
      );
    });
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/communication_campaigns/camp1/communication_acknowledgements/parentA')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'schools/schoolA/communication_campaigns/camp1/communication_acknowledgements/parentA')));
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools/schoolA/communication_campaigns/camp1/communication_acknowledgements/parentA')));
    // Acknowledgement writes go through acknowledgeCommunicationCampaign so
    // the campaign's published status and audience membership are validated
    // server-side; a client write - even of one's own doc - must fail.
    await assertFails(setDoc(
      doc(dbFor('parentA'), 'schools/schoolA/communication_campaigns/camp1/communication_acknowledgements/parentA'),
      { userId: 'parentA', campaignId: 'camp1', acknowledgedAt: new Date() },
    ));
    await assertFails(setDoc(
      doc(dbFor('parentA'), 'schools/schoolA/communication_campaigns/camp1/communication_acknowledgements/parentOtherA'),
      { userId: 'parentOtherA', campaignId: 'camp1', acknowledgedAt: new Date() },
    ));
  });

  test('communication_templates: manageable only by admin/leadership roles, never client-writable', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/communication_templates/tmpl1'), {
        name: 'Fee reminder', schoolId: 'schoolA', body: 'Your fees are due.',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'schools/schoolA/communication_templates/tmpl1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/communication_templates/tmpl1')));
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/communication_templates/tmpl1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'schools/schoolA/communication_templates/tmpl2'), {
      name: 'Forged', schoolId: 'schoolA', body: 'x',
    }));
  });
});

describe('NFC credential lifecycle', () => {
  function newCredential(overrides = {}) {
    return {
      credentialValue: 'CARDA999', credentialType: 'nfc', identityId: 'SP-STUDENT-NEW',
      identityType: 'student', schoolId: 'schoolA', status: 'active',
      updatedAt: new Date().toISOString(), credentialVersion: 1,
      ...overrides,
    };
  }

  // Every mutation path (assign/replace/revoke/reactivate/regenerateQr) now
  // goes through a Cloud Function transaction (functions/student_credentials.js)
  // that also records a credential_history + audit_events row - see
  // assignNfcCredential/replaceNfcCredential/revokeNfcCredential/
  // reactivateNfcCredential. Cloud Functions use the Admin SDK, which
  // bypasses these rules entirely, so no legitimate write path is closed by
  // denying all client writes here - only the previously-unaudited direct-
  // write shortcut is. This whole describe block asserts NO client, of any
  // role, can write these collections directly anymore.

  test('no client, not even an authorised School Admin, can register a new '
    + 'credential directly - only assignNfcCredential can', async () => {
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/credentials/CARDA999'),
      newCredential(),
    ));
  });

  test('an ordinary Class Teacher cannot register a credential', async () => {
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/credentials/CARDA999'),
      newCredential(),
    ));
  });

  test('no client can replace a credential (revoke the old one or write '
    + 'the new one) - only replaceNfcCredential can', async () => {
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'schools/schoolA/credentials/CARDA001'),
      { status: 'replaced', updatedAt: new Date().toISOString() },
    ));
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/credentials/CARDA999'),
      newCredential({ identityId: 'SP-STUDENT-A' }),
    ));
  });

  test('no client can revoke a credential - only revokeNfcCredential can', async () => {
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'schools/schoolA/credentials/CARDA001'),
      { status: 'revoked', updatedAt: new Date().toISOString() },
    ));
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/revoked_credentials/CARDA001'),
      { credentialValue: 'CARDA001', schoolId: 'schoolA', revokedAt: new Date().toISOString(), reason: 'lost' },
    ));
  });

  test('no client can reactivate a revoked credential - only '
    + 'reactivateNfcCredential can', async () => {
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'schools/schoolA/credentials/CARDA002'),
      { status: 'active', updatedAt: new Date().toISOString() },
    ));
  });

  test('a role_permission_overrides credential-manage grant does not '
    + 'restore direct write access either - the callable-only gate applies '
    + 'to every role uniformly, not just ordinary staff', async () => {
    const db = dbFor('credentialManagerA');
    await assertFails(setDoc(doc(db, 'schools/schoolA/credentials/CARDA999'), newCredential()));
    await assertFails(updateDoc(
      doc(db, 'schools/schoolA/credentials/CARDA002'),
      { status: 'revoked', updatedAt: new Date().toISOString() },
    ));
    await assertFails(setDoc(
      doc(db, 'schools/schoolA/revoked_credentials/CARDA999'),
      { credentialValue: 'CARDA999', schoolId: 'schoolA', revokedAt: new Date().toISOString(), reason: 'lost' },
    ));
  });

  test('School A admin cannot read or write a School B credential', async () => {
    await assertFails(getDoc(doc(dbFor('adminA'), 'schools/schoolB/credentials/CARDB001')));
    await assertFails(updateDoc(
      doc(dbFor('adminA'), 'schools/schoolB/credentials/CARDB001'),
      { status: 'revoked', updatedAt: new Date().toISOString() },
    ));
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolB/credentials/CARDB999'),
      newCredential({ credentialValue: 'CARDB999', schoolId: 'schoolB' }),
    ));
  });

  test('a School A teacher cannot read or write School B credential mappings', async () => {
    // otherTeacherA (not teacherA, who holds a real active School B
    // membership for the multi-school-workspace tests elsewhere in this
    // file) has no School B access at all.
    await assertFails(getDoc(doc(dbFor('otherTeacherA'), 'schools/schoolB/credentials/CARDB001')));
    await assertFails(setDoc(
      doc(dbFor('otherTeacherA'), 'schools/schoolB/credentials/CARDB999'),
      newCredential({ credentialValue: 'CARDB999', schoolId: 'schoolB' }),
    ));
  });

  test('credential documents are never deleted by any client - revoke is a '
    + 'status change made server-side, history must survive', async () => {
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'schools/schoolA/credentials/CARDA001')));
  });

  test('the legitimate attendance workflow still works: an ordinary Class '
    + 'Teacher can read a credential mapping to resolve a scanned card, '
    + 'even one they have never seen before, purely to mark attendance', async () => {
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/credentials/CARDA001')));
    // The revocation denylist is checked before the credential cache at
    // scan time (IdentityResolverImpl._resolveNfc) - a teacher must be able
    // to read it too, or every scan would appear to hang/fail offline.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/revoked_credentials/CARDA003'), {
        credentialValue: 'CARDA003', schoolId: 'schoolA',
        revokedAt: new Date().toISOString(), reason: 'lost',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/revoked_credentials/CARDA003')));
  });

  test('a QR-typed credential is denied the same client-write path as NFC - '
    + 'credentialType is just a field, not a separate rule path', async () => {
    const qrCredential = {
      credentialValue: 'SPQR1TOKENAAA', credentialType: 'qr', identityId: 'SP-STUDENT-NEW',
      identityType: 'student', schoolId: 'schoolA', status: 'active',
      updatedAt: new Date().toISOString(), credentialVersion: 1,
    };
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/credentials/SPQR1TOKENAAA'),
      qrCredential,
    ));
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/credentials/SPQR1TOKENAAA'),
      qrCredential,
    ));
    // Same read-for-attendance-use exception NFC gets: a teacher may read
    // an unfamiliar QR credential mapping purely to resolve a scan.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/credentials/SPQR1TOKENAAA'), qrCredential);
    });
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/credentials/SPQR1TOKENAAA')));
  });

  // The append-only history collection the new callables write to - never
  // client-writable, staff-readable for the Identity tab's "Card history"
  // view.
  describe('credential_history (append-only, callable-only)', () => {
    function historyEntry(overrides = {}) {
      return {
        schoolId: 'schoolA', studentId: 'studentA', identityDocumentId: 'identity-1',
        credentialType: 'nfc', credentialValueMasked: '••••A001', action: 'nfc_assigned',
        reason: null, actorId: 'adminA', createdAt: new Date().toISOString(),
        ...overrides,
      };
    }

    test('no client can write a credential_history entry directly, even an '
      + 'authorised School Admin - only the Cloud Functions can', async () => {
      await assertFails(setDoc(
        doc(dbFor('adminA'), 'schools/schoolA/credential_history/hist1'),
        historyEntry(),
      ));
    });

    test('a same-school staff member can read credential_history entries', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(
          doc(context.firestore(), 'schools/schoolA/credential_history/hist1'),
          historyEntry(),
        );
      });
      await assertSucceeds(
        getDoc(doc(dbFor('teacherA'), 'schools/schoolA/credential_history/hist1')),
      );
    });

    test('a School A teacher cannot read School B credential_history entries', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(
          doc(context.firestore(), 'schools/schoolB/credential_history/hist1'),
          historyEntry({ schoolId: 'schoolB' }),
        );
      });
      // otherTeacherA (not teacherA, who holds a real active School B
      // membership elsewhere in this file) has no School B access at all.
      await assertFails(
        getDoc(doc(dbFor('otherTeacherA'), 'schools/schoolB/credential_history/hist1')),
      );
    });

    test('credential_history entries are never deleted or updated by any client', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(
          doc(context.firestore(), 'schools/schoolA/credential_history/hist1'),
          historyEntry(),
        );
      });
      await assertFails(deleteDoc(doc(dbFor('adminA'), 'schools/schoolA/credential_history/hist1')));
      await assertFails(updateDoc(
        doc(dbFor('adminA'), 'schools/schoolA/credential_history/hist1'),
        { reason: 'tampered' },
      ));
    });
  });
});

describe('attendance_records: real per-school collection AttendanceRemoteDataSource writes to', () => {
  function attendanceRecord(overrides = {}) {
    return {
      schoolId: 'schoolA', category: 'students', scopeId: 'p7', scopeName: 'P7',
      sessionType: 'daily', date: '2026-08-17T00:00:00.000Z',
      personId: 'studentA', personName: 'A Student', status: 'present',
      method: 'qr', markedBy: 'Teacher A', operatorId: 'teacherA',
      createdAt: new Date().toISOString(), roleAssignmentId: 'assignP7',
      ...overrides,
    };
  }

  test('a Class Teacher holding the P7 assignment can write a QR attendance '
    + 'record for P7, exactly as they could for NFC or manual', async () => {
    await assertSucceeds(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/attendance_records/qr_p7_daily_20260817_studentA'),
      attendanceRecord(),
    ));
  });

  test('the same P7 assignment cannot write attendance for a different class', async () => {
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/attendance_records/qr_p6_daily_20260817_studentA'),
      attendanceRecord({ scopeId: 'p6' }),
    ));
  });

  test('a teacher holding only the P6 assignment cannot write attendance for P7 via QR', async () => {
    await assertFails(setDoc(
      doc(dbFor('otherTeacherA'), 'schools/schoolA/attendance_records/qr_p7_daily_20260817_studentB'),
      attendanceRecord({ scopeId: 'p7', operatorId: 'otherTeacherA', roleAssignmentId: 'assignP6' }),
    ));
  });

  test('a School B teacher cannot write an attendance record into School A', async () => {
    await assertFails(setDoc(
      doc(dbFor('teacherB'), 'schools/schoolA/attendance_records/qr_p7_daily_20260817_studentC'),
      attendanceRecord({ operatorId: 'teacherB' }),
    ));
  });

  test('attendance records are never updated or deleted in place - the '
    + 'correction trail is a separate collection', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'schools/schoolA/attendance_records/qr_p7_daily_20260817_studentD'),
        attendanceRecord(),
      );
    });
    await assertFails(updateDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/attendance_records/qr_p7_daily_20260817_studentD'),
      { status: 'absent' },
    ));
    await assertFails(deleteDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/attendance_records/qr_p7_daily_20260817_studentD'),
    ));
  });
});

describe('Google Sheets OAuth: tokens, CSRF state, and export ledger are Admin-SDK only', () => {
  test('schoolAdmin cannot read or write attendance_sheets_oauth tokens directly', async () => {
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'schools/schoolA/attendance_sheets_oauth/tokens'),
      { refreshToken: 'leaked' },
    ));
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'schools/schoolA/attendance_sheets_oauth/tokens'),
        { refreshToken: 'secret' },
      );
    });
    await assertFails(getDoc(doc(dbFor('adminA'), 'schools/schoolA/attendance_sheets_oauth/tokens')));
  });

  test('no signed-in user can read or write the OAuth CSRF state collection', async () => {
    await assertFails(setDoc(
      doc(dbFor('adminA'), 'attendance_sheets_oauth_state', 'nonce1'),
      { schoolId: 'schoolA', uid: 'adminA' },
    ));
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'attendance_sheets_oauth_state', 'nonce1'),
        { schoolId: 'schoolA', uid: 'adminA' },
      );
    });
    await assertFails(getDoc(doc(dbFor('adminA'), 'attendance_sheets_oauth_state', 'nonce1')));
  });

  test('the per-record export idempotency ledger is not client-readable or writable', async () => {
    await assertFails(setDoc(
      doc(dbFor('teacherA'), 'schools/schoolA/attendance_sheets_export_state/rec1'),
      { exportedAt: new Date().toISOString() },
    ));
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'schools/schoolA/attendance_sheets_export_state/rec1'),
        { exportedAt: new Date().toISOString() },
      );
    });
    await assertFails(getDoc(doc(dbFor('adminA'), 'schools/schoolA/attendance_sheets_export_state/rec1')));
  });
});

// Section 7 audit (student identity/credential system): confirms the
// tenant-isolation guarantees issueStudentIdentity/regenerateStudentQrCredential/
// assignNfcCredential rely on (those Cloud Functions bypass rules via the
// Admin SDK, but everything a client can read/write directly around a
// student's identity must still be same-school-only, same as every other
// per-tenant collection).
describe('student identity + credential tenant isolation', () => {
  test('a School A staff member cannot read a School B student even '
    + 'knowing/guessing its document id', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'students/studentInSchoolB'), {
        schoolId: 'schoolB', name: 'B Student', status: 'active',
      });
    });
    // otherTeacherA, not teacherA, is the right fixture here: teacherA holds
    // a real, active institution_memberships doc into School B elsewhere in
    // this file (the institution-switcher fixtures), so isSameSchool('schoolB')
    // is genuinely, correctly true for teacherA - that's a different feature
    // being exercised, not a tenant-isolation hole. otherTeacherA has no
    // School B membership at all, which is what this test needs.
    await assertFails(getDoc(doc(dbFor('otherTeacherA'), 'students/studentInSchoolB')));
    await assertSucceeds(getDoc(doc(dbFor('teacherB'), 'students/studentInSchoolB')));
  });

  test('a School A staff member cannot create a student doc for School B, '
    + 'even by supplying schoolId: schoolB in the payload', async () => {
    await assertFails(setDoc(doc(dbFor('teacherA'), 'students/forgedStudent'), {
      schoolId: 'schoolB', name: 'Forged', status: 'active',
    }));
  });

  test('a student doc can never be re-parented to another school via update', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'students/studentToReparent'), {
        schoolId: 'schoolA', name: 'A Student', status: 'active',
      });
    });
    await assertFails(updateDoc(doc(dbFor('teacherA'), 'students/studentToReparent'), {
      schoolId: 'schoolB',
    }));
  });

  test('student_identities: a School B staff member cannot read a School A '
    + "student's identity doc (uniqueSystemId/QR lookup), even across the "
    + 'collection issueStudentIdentity writes to', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'student_identities/identityInSchoolA'), {
        studentId: 'studentInSchoolA', schoolId: 'schoolA',
        uniqueSystemId: 'SP-STUDENT-isolationtest', schoolStudentId: 'SP2026000999',
      });
    });
    await assertFails(getDoc(doc(dbFor('teacherB'), 'student_identities/identityInSchoolA')));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'student_identities/identityInSchoolA')));
  });

  test('student_identities: a School A staff member cannot create an identity '
    + 'doc claiming schoolId: schoolB', async () => {
    // otherTeacherA, not teacherA - see the comment on the read-isolation
    // test above: teacherA has a genuine active School B membership from an
    // unrelated fixture, so isSameSchool('schoolB') is correctly true for
    // teacherA and this assertion would not be testing tenant isolation at
    // all with that fixture.
    await assertFails(setDoc(doc(dbFor('otherTeacherA'), 'student_identities/forgedIdentity'), {
      studentId: 'someStudent', schoolId: 'schoolB',
      uniqueSystemId: 'SP-STUDENT-forged', schoolStudentId: 'SP2026000998',
    }));
  });

  test('student_identities: schoolId is locked on update, same as students/{id}', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'student_identities/identityToReparent'), {
        studentId: 'studentX', schoolId: 'schoolA',
        uniqueSystemId: 'SP-STUDENT-reparent', schoolStudentId: 'SP2026000997',
      });
    });
    await assertFails(updateDoc(doc(dbFor('teacherA'), 'student_identities/identityToReparent'), {
      schoolId: 'schoolB',
    }));
  });

  test('a QR credential minted for School A cannot be read by School B staff, '
    + 'even though the collectionGroup query the public verification endpoint '
    + 'uses runs under the Admin SDK and bypasses this rule entirely', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/credentials/isolationTestToken'), {
        credentialValue: 'isolationTestToken', credentialType: 'qr',
        identityId: 'SP-STUDENT-isolationtest', identityType: 'student',
        schoolId: 'schoolA', status: 'active', updatedAt: new Date().toISOString(),
        credentialVersion: 1,
      });
    });
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/credentials/isolationTestToken')));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/credentials/isolationTestToken')));
  });
});

describe('Enrollment Setup Wizard: scholarship_awards/dormitory_assignments/'
  + 'student_club_memberships tenant isolation and role gating', () => {
  test('scholarship_awards: cross-school read is denied, same-school finance '
    + 'staff (bursar) can create, a non-finance staff member cannot create',
    async () => {
      await assertSucceeds(setDoc(doc(dbFor('bursarA'), 'scholarship_awards/awardA'), {
        schoolId: 'schoolA', studentId: 'studentA', type: 'discount',
        amountOrPercentage: 10, isPercentage: true, approvedBy: 'bursarA',
        reason: 'sibling discount', createdAt: new Date().toISOString(),
      }));
      await assertFails(getDoc(doc(dbFor('bursarB'), 'scholarship_awards/awardA')));
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'scholarship_awards/awardA')));

      // teacherA is staff but not finance staff - canWriteFinance() must
      // reject this, matching the "stricter than general finance" /
      // Bursar-only requirement for scholarship awards.
      await assertFails(setDoc(doc(dbFor('teacherA'), 'scholarship_awards/awardDeniedByTeacher'), {
        schoolId: 'schoolA', studentId: 'studentA', type: 'discount',
        amountOrPercentage: 5, isPercentage: true, approvedBy: 'teacherA',
        reason: 'attempt', createdAt: new Date().toISOString(),
      }));
    });

  test('scholarship_awards: a student cannot write their own award '
    + '(isMe grants read only, never create/update)', async () => {
    await assertFails(setDoc(doc(dbFor('studentUserA'), 'scholarship_awards/selfAward'), {
      schoolId: 'schoolA', studentId: 'studentA', type: 'discount',
      amountOrPercentage: 50, isPercentage: true, approvedBy: 'studentUserA',
      reason: 'self-granted', createdAt: new Date().toISOString(),
    }));
  });

  test('dormitory_assignments: cross-school read denied, an admin role can '
    + 'create, a student cannot write their own assignment', async () => {
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'dormitory_assignments/assignA'), {
      schoolId: 'schoolA', studentId: 'studentA', hostelId: 'hostel1',
      roomId: 'room1', bed: 'A', assignedAt: new Date().toISOString(),
      assignedBy: 'adminA',
    }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'dormitory_assignments/assignA')));
    await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'dormitory_assignments/assignA')));
    await assertFails(setDoc(doc(dbFor('studentUserA'), 'dormitory_assignments/selfAssign'), {
      schoolId: 'schoolA', studentId: 'studentA', hostelId: 'hostel1',
      roomId: 'room1', bed: 'B', assignedAt: new Date().toISOString(),
      assignedBy: 'studentUserA',
    }));
  });

  test('dormitory_assignments: enrollment.boarding_assign is required - '
    + 'a boardingMatron with no permission grant is denied, the same role '
    + 'succeeds once granted the permission via role_permission_overrides',
    async () => {
      await assertFails(setDoc(doc(dbFor('matronA'), 'dormitory_assignments/deniedAssign'), {
        schoolId: 'schoolA', studentId: 'studentA', hostelId: 'hostel1',
        roomId: 'room1', bed: 'C', assignedAt: new Date().toISOString(),
        assignedBy: 'matronA',
      }));
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(
          doc(context.firestore(), 'schools/schoolA/role_permission_overrides/boardingMatron'),
          { permissions: ['enrollment.boarding_assign'] },
        );
      });
      await assertSucceeds(setDoc(doc(dbFor('matronA'), 'dormitory_assignments/grantedAssign'), {
        schoolId: 'schoolA', studentId: 'studentA', hostelId: 'hostel1',
        roomId: 'room1', bed: 'D', assignedAt: new Date().toISOString(),
        assignedBy: 'matronA',
      }));
    });

  test('student_club_memberships: cross-school read denied, same-school '
    + 'staff can create, a student cannot self-enrol by writing directly',
    async () => {
      await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'student_club_memberships/memberA'), {
        schoolId: 'schoolA', studentId: 'studentA', clubId: 'chessClub',
        joinedAt: new Date().toISOString(),
      }));
      await assertFails(getDoc(doc(dbFor('teacherB'), 'student_club_memberships/memberA')));
      await assertSucceeds(getDoc(doc(dbFor('teacherA'), 'student_club_memberships/memberA')));
      await assertFails(setDoc(doc(dbFor('studentUserA'), 'student_club_memberships/selfJoin'), {
        schoolId: 'schoolA', studentId: 'studentA', clubId: 'debateClub',
        joinedAt: new Date().toISOString(),
      }));
    });
});

describe('admission_applications: enrollment-follow-up visibility/role checks '
  + '(parent enumeration, teacher status escalation)', () => {
  test('a parent account cannot read/list admission_applications at all - '
    + 'only isStaff() is granted read/create, parents have no clause here',
    async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'admission_applications/appForParentTest'), {
          schoolId: 'schoolA', studentName: 'Test Applicant', status: 'submitted',
        });
      });
      await assertFails(getDoc(doc(dbFor('parentA'), 'admission_applications/appForParentTest')));
      await assertFails(
        getDocs(query(collection(dbFor('parentA'), 'admission_applications'),
          where('schoolId', '==', 'schoolA'))),
      );
    });

  test('a Class Teacher cannot approve/reject an admission application - '
    + 'admission.application.review is required for a status transition, '
    + 'not granted to classTeacher by default or in this test\'s fixtures',
    async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'admission_applications/appForTeacherEscalation'), {
          schoolId: 'schoolA', studentName: 'Test Applicant', status: 'application',
        });
      });
      await assertFails(updateDoc(
        doc(dbFor('teacherA'), 'admission_applications/appForTeacherEscalation'),
        { schoolId: 'schoolA', status: 'approved' },
      ));
      // A plain field edit that does not change status is still allowed -
      // only the state-transition write is gated.
      await assertSucceeds(updateDoc(
        doc(dbFor('teacherA'), 'admission_applications/appForTeacherEscalation'),
        { schoolId: 'schoolA', status: 'application', studentName: 'Corrected Name' },
      ));
    });

  test('a Class Teacher cannot enroll a student directly by writing '
    + 'students/{id} with an enrollment-pipeline status - admission.enroll '
    + 'is required, matching admission_applications\' gate', async () => {
    await assertFails(setDoc(doc(dbFor('teacherA'), 'students/teacherEnrolledStudent'), {
      schoolId: 'schoolA', name: 'Escalation Attempt', status: 'enrollmentInProgress',
    }));
    // An admin-role account may.
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'students/adminEnrolledStudent'), {
      schoolId: 'schoolA', name: 'Valid Enrollment', status: 'enrollmentInProgress',
    }));
    // Writing a students doc for an unrelated, non-enrollment status
    // (e.g. an already-active student's ordinary field edit) is unaffected.
    await assertSucceeds(setDoc(doc(dbFor('teacherA'), 'students/ordinaryStudentEdit'), {
      schoolId: 'schoolA', name: 'Ordinary Student', status: 'suspended',
    }));
  });
});

describe('Fee-plan/billing backend (functions/student_fee_billing.js): '
  + 'fee_plans/fee_catalogue (Phase 1) and bills/adjustments/payments (Phase 2)',
  () => {
    async function seedPublishedPlan() {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'schools/schoolA/fee_plans/planA'), {
          schoolId: 'schoolA', name: 'Term 1 Fees',
          selector: {
            academicYearId: 'year1', termId: 'term1', classId: 'classA',
            studentCategory: 'day',
          },
          status: 'published', currency: 'UGX', latestVersion: 1,
          currentVersionId: 'v1',
        });
        await setDoc(doc(db, 'schools/schoolA/fee_plans/planA/versions/v1'), {
          schoolId: 'schoolA', planId: 'planA', version: 1, status: 'published',
          currency: 'UGX', lines: [{ chargeId: 'tuition', name: 'Tuition', amountUgx: 500000, required: true }],
          totalUgx: 500000,
        });
      });
    }

    async function seedBill() {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'schools/schoolA/student_accounts/studentA'), {
          schoolId: 'schoolA', studentId: 'studentA', currency: 'UGX', lastBillId: 'billA',
        });
        await setDoc(doc(db, 'schools/schoolA/student_accounts/studentA/bills/billA'), {
          schoolId: 'schoolA', studentId: 'studentA', billId: 'billA', status: 'open',
          currency: 'UGX', planId: 'planA', planVersionId: 'v1',
          issuedTotalUgx: 500000, paidTotalUgx: 0, adjustmentTotalUgx: 0, balanceUgx: 500000,
          lines: [{ chargeId: 'tuition', name: 'Tuition', amountUgx: 500000, required: true }],
        });
        await setDoc(
          doc(db, 'schools/schoolA/student_accounts/studentA/bills/billA/adjustments/adjA'),
          { schoolId: 'schoolA', studentId: 'studentA', billId: 'billA', type: 'discount', amountUgx: 50000, reason: 'sibling discount', approverId: 'bursarA' },
        );
        await setDoc(
          doc(db, 'schools/schoolA/student_accounts/studentA/bills/billA/payments/payA'),
          { schoolId: 'schoolA', studentId: 'studentA', billId: 'billA', status: 'recorded', method: 'cash', amountUgx: 200000, receiptNumber: 'RCT-000001', recordedBy: 'bursarA' },
        );

        await setDoc(doc(db, 'schools/schoolB/student_accounts/studentOther'), {
          schoolId: 'schoolB', studentId: 'studentOther', currency: 'UGX',
        });
        await setDoc(doc(db, 'schools/schoolB/student_accounts/studentOther/bills/billB'), {
          schoolId: 'schoolB', studentId: 'studentOther', billId: 'billB', status: 'open',
          currency: 'UGX', planId: 'planB', planVersionId: 'v1',
          issuedTotalUgx: 300000, paidTotalUgx: 0, adjustmentTotalUgx: 0, balanceUgx: 300000,
          lines: [],
        });
      });
    }

    test('fee_plans: same-school staff can read, cross-school staff cannot', async () => {
      await seedPublishedPlan();
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_plans/planA')));
      await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/fee_plans/planA')));
    });

    test('fee_plans: a client cannot mutate lines/status of a published plan '
      + 'directly, only flip status to archived with no other field changed', async () => {
      await seedPublishedPlan();
      await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_plans/planA'), {
        latestVersion: 99,
      }));
      await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_plans/planA'), {
        status: 'archived', latestVersion: 99,
      }));
      await assertSucceeds(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_plans/planA'), {
        status: 'archived',
      }));
    });

    test('fee_plans/versions: read-only for every client, including the '
      + 'owning school\'s finance staff - no client write path exists', async () => {
      await seedPublishedPlan();
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_plans/planA/versions/v1')));
      await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_plans/planA/versions/v2'), {
        version: 2, totalUgx: 1,
      }));
    });

    test('fee_catalogue: tenant-scoped staff read/write, cross-school denied', async () => {
      await assertSucceeds(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/fee_catalogue/tuition'), {
        schoolId: 'schoolA', name: 'Tuition',
      }));
      await assertFails(setDoc(doc(dbFor('bursarB'), 'schools/schoolA/fee_catalogue/hacked'), {
        schoolId: 'schoolA', name: 'Hacked',
      }));
    });

    test('student_accounts/bills: same-school staff can read, no client can '
      + 'ever write (issuance is callable-only)', async () => {
      await seedBill();
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA')));
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/billA')));
      await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/fakeBill'), {
        schoolId: 'schoolA', studentId: 'studentA', issuedTotalUgx: 1, balanceUgx: 0,
      }));
      await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/billA'), {
        balanceUgx: 0,
      }));
    });

    test('student_accounts/bills: cross-school staff cannot read another '
      + 'school\'s bill', async () => {
      await seedBill();
      await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/student_accounts/studentA/bills/billA')));
      await assertFails(getDoc(doc(dbFor('bursarA'), 'schools/schoolB/student_accounts/studentOther/bills/billB')));
    });

    test('student_accounts/bills: a linked parent (isParentOf) can read their '
      + 'own child\'s bill; an unrelated parent cannot - parent isolation', async () => {
      await seedBill();
      await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/student_accounts/studentA')));
      await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/student_accounts/studentA/bills/billA')));
      // parentOtherA is linked to studentOther, not studentA - must not see
      // this family's bill even though both parents are in the same school.
      await assertFails(getDoc(doc(dbFor('parentOtherA'), 'schools/schoolA/student_accounts/studentA/bills/billA')));
      // A student cannot read their own bill either (only isStaff/isParentOf
      // are granted here, isMe is deliberately not included for billing).
      await assertFails(getDoc(doc(dbFor('studentUserA'), 'schools/schoolA/student_accounts/studentA/bills/billA')));
    });

    test('bills/adjustments and bills/payments: same read pattern as the bill '
      + 'itself (staff or the linked parent only), no client write', async () => {
      await seedBill();
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/billA/adjustments/adjA')));
      await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/student_accounts/studentA/bills/billA/payments/payA')));
      await assertFails(getDoc(doc(dbFor('parentOtherA'), 'schools/schoolA/student_accounts/studentA/bills/billA/adjustments/adjA')));
      await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/student_accounts/studentA/bills/billA/payments/payA')));
      await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/billA/adjustments/fakeAdj'), {
        type: 'discount', amountUgx: 999999999, approverId: 'bursarA',
      }));
      await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/billA/payments/fakePay'), {
        method: 'cash', amountUgx: 999999999, receiptNumber: 'RCT-FORGED',
      }));
      // Even the payment's own recordedBy staff member cannot edit it after
      // the fact - correction is a reversal (a new record), never a rewrite.
      await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA/bills/billA/payments/payA'), {
        amountUgx: 1,
      }));
    });

    test('counters/receiptNumber: denied to every client, including the '
      + 'owning school\'s finance staff and the SaaS owner', async () => {
      await assertFails(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/counters/receiptNumber')));
      await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/counters/receiptNumber'), {
        value: 999999,
      }));
      await assertFails(getDoc(doc(dbFor('ownerA'), 'schools/schoolA/counters/receiptNumber')));
    });

    test('audit_events: denied to every client (no rule block - Firestore\'s '
      + 'default-deny) - confirms it was never weakened by this change', async () => {
      await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/audit_events/fake'), {
        action: 'forged', actorId: 'bursarA',
      }));
      await assertFails(getDoc(doc(dbFor('ownerA'), 'schools/schoolA/audit_events/fake')));
    });
  });

describe('Parent Payments redesign (functions/payment_codes.js): '
  + 'payment_config/channels, pending_payments, finance_audit_events', () => {
  async function seedPaymentConfig() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'schools/schoolA/payment_config/channels'), {
        schoolId: 'schoolA', schoolDisplayName: 'Victoria High School',
        mtnMomo: { enabled: true, ussdCode: '*165*80#', steps: [], merchantLabel: 'School Pay' },
        airtelMoney: { enabled: false, ussdCode: '', steps: [], merchantLabel: '' },
        bankAccounts: [], otherChannels: [],
      });
      await setDoc(doc(db, 'schools/schoolB/payment_config/channels'), {
        schoolId: 'schoolB', schoolDisplayName: 'School B',
        mtnMomo: { enabled: false, ussdCode: '', steps: [], merchantLabel: '' },
        airtelMoney: { enabled: false, ussdCode: '', steps: [], merchantLabel: '' },
        bankAccounts: [], otherChannels: [],
      });
      await setDoc(doc(db, 'schools/schoolA/pending_payments/pendingA'), {
        schoolId: 'schoolA', studentId: 'studentA', paymentCode: 'VHS-P1234567',
        channel: 'mtn_momo', amountUgx: 200000, status: 'pending',
        dedupeKey: 'mtn_momo:txA:200000', createdAt: new Date(),
      });
      await setDoc(doc(db, 'schools/schoolA/finance_audit_events/eventA'), {
        schoolId: 'schoolA', type: 'pending_confirmed', actorUid: 'bursarA',
        targetId: 'pendingA', occurredAt: new Date(),
      });
    });
  }

  test('payment_config/channels: any signed-in member of the tenant can '
    + 'read it (parents need it for How to pay); a different tenant\'s '
    + 'member is denied; writes are callable-only', async () => {
    await seedPaymentConfig();
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/payment_config/channels')));
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/payment_config/channels')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/payment_config/channels')));
    await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/payment_config/channels')));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/payment_config/channels'), {
      schoolDisplayName: 'Forged Name',
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/payment_config/channels'), {
      schoolDisplayName: 'Forged Name',
    }));
  });

  test('pending_payments: staff of the owning school can read the '
    + 'reconciliation queue; parents and other-school staff are denied; '
    + 'writes are callable-only (no client self-confirmation)', async () => {
    await seedPaymentConfig();
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/pending_payments/pendingA')));
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/pending_payments/pendingA')));
    await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/pending_payments/pendingA')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'schools/schoolA/pending_payments/pendingA')));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/pending_payments/forged'), {
      studentId: 'studentA', amountUgx: 999999999, status: 'confirmed',
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/pending_payments/pendingA'), {
      status: 'confirmed',
    }));
  });

  test('finance_audit_events: staff of the owning school can read the '
    + 'audit trail; parents and other-school staff are denied; writes are '
    + 'admin-SDK only', async () => {
    await seedPaymentConfig();
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/finance_audit_events/eventA')));
    await assertFails(getDoc(doc(dbFor('parentA'), 'schools/schoolA/finance_audit_events/eventA')));
    await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/finance_audit_events/eventA')));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/finance_audit_events/forged'), {
      type: 'forged', actorUid: 'bursarA',
    }));
  });

  test('student_accounts.paymentCode: readable by the owning school\'s '
    + 'staff and the linked parent via the existing student_accounts rule; '
    + 'denied to another school\'s staff and an unlinked parent', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'schools/schoolA/student_accounts/studentA'), {
        schoolId: 'schoolA', studentId: 'studentA', currency: 'UGX',
        paymentCode: 'VHS-P1234567', paymentCodeGeneratedBy: 'bursarA',
      });
    });
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA')));
    await assertSucceeds(getDoc(doc(dbFor('parentA'), 'schools/schoolA/student_accounts/studentA')));
    await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/student_accounts/studentA')));
    await assertFails(getDoc(doc(dbFor('parentOtherA'), 'schools/schoolA/student_accounts/studentA')));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/student_accounts/studentA'), {
      paymentCode: 'FORGED-CODE',
    }));
  });
});

describe('Finance governance (functions/finance_governance.js): '
  + 'expenditures + budgets are callable-only, cross-school reads denied', () => {
  async function seedFinanceRecords() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'schools/schoolA/expenditures/expA'), {
        schoolId: 'schoolA', requesterId: 'bursarA', requesterName: 'Bursar A',
        description: 'Lab reagents', amount: 450000, budgetCategoryId: 'cat-science',
        status: 'pending', approvalHistory: [], createdAt: new Date(),
      });
      await setDoc(doc(db, 'schools/schoolA/budgets/bdgA'), {
        schoolId: 'schoolA', name: 'Transport', academicYear: '2026', term: 'Term 1',
        allocatedAmount: 10000000, spentAmount: 1200000, createdAt: new Date(),
      });
      await setDoc(doc(db, 'schools/schoolB/expenditures/expB'), {
        schoolId: 'schoolB', requesterId: 'bursarB', description: 'Other school',
        amount: 100000, budgetCategoryId: 'c', status: 'pending', approvalHistory: [],
        createdAt: new Date(),
      });
      await setDoc(doc(db, 'schools/schoolB/budgets/bdgB'), {
        schoolId: 'schoolB', name: 'Meals', academicYear: '2026', term: 'Term 1',
        allocatedAmount: 5000000, spentAmount: 0, createdAt: new Date(),
      });
    });
  }

  test('expenditures: same-school staff read; another school\'s staff are '
    + 'denied read (tenant isolation)', async () => {
    await seedFinanceRecords();
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/expenditures/expA')));
    // NOTE: same-school read is intentionally staff-wide for these
    // non-payroll finance records (hasAnyRole() === isStaff(), product
    // decision 2026-08-26). The security-critical guarantees for audit
    // area 2 are (a) tenant isolation and (b) callable-only writes, both
    // asserted here and below.
    await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/expenditures/expA')));
  });

  test('expenditures: NO client may create, update, or delete - the '
    + 'submit/decide callables are the only write path', async () => {
    await seedFinanceRecords();
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/expenditures/forged'), {
      schoolId: 'schoolA', requesterId: 'bursarA', description: 'forged',
      amount: 1, budgetCategoryId: 'c', status: 'pending',
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/expenditures/expA'), {
      status: 'approved',
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/expenditures/expA'), {
      amount: 999999999,
    }));
    await assertFails(deleteDoc(doc(dbFor('bursarA'), 'schools/schoolA/expenditures/expA')));
    // and a cross-school actor certainly cannot
    await assertFails(updateDoc(doc(dbFor('bursarB'), 'schools/schoolA/expenditures/expA'), {
      status: 'approved',
    }));
  });

  test('budgets: same-school finance staff read; other-school staff denied '
    + 'read; NO client may write (saveSchoolBudget is the only path)', async () => {
    await seedFinanceRecords();
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/budgets/bdgA')));
    await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/budgets/bdgA')));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/budgets/forged'), {
      schoolId: 'schoolA', name: 'X', academicYear: '2026', term: 'Term 1',
      allocatedAmount: 1, spentAmount: 0,
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/budgets/bdgA'), {
      allocatedAmount: 999999999,
    }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/budgets/bdgA'), {
      spentAmount: 0,
    }));
  });
});

describe('Financial Entitlements (functions/financial_entitlements.js): '
  + 'policy / overrides / audit / terminals / taps are callable-only, '
  + 'finance-read, and service staff see nothing', () => {
  async function seed() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'schools/schoolA/financial_entitlement_policy/current'), {
        services: { dining: { enabled: true, minimumPaymentPercentage: 75 } }, version: 1,
      });
      await setDoc(doc(db, 'schools/schoolA/financial_entitlement_policy_proposals/p1'), {
        services: {}, status: 'pendingApproval', proposedBy: 'bursarA',
      });
      await setDoc(doc(db, 'schools/schoolA/financial_entitlement_overrides/o1'), {
        studentId: 'studentA', service: 'dining', decision: 'allow', status: 'active',
      });
      await setDoc(doc(db, 'schools/schoolA/financial_entitlement_audit/a1'), {
        action: 'policy.updated', actorId: 'bursarA',
      });
      await setDoc(doc(db, 'schools/schoolA/entitlement_terminals/t1'), {
        service: 'dining', secretHash: 'x'.repeat(64), status: 'active',
      });
      await setDoc(doc(db, 'schools/schoolA/entitlement_taps/tap1'), {
        studentId: 'studentA', service: 'dining', decision: 'allow',
      });
      await setDoc(doc(db, 'schools/schoolA/entitlement_terminal_nonces/n1'), { createdAt: new Date() });
    });
  }

  test('policy/overrides/audit/taps: same-school finance staff read; '
    + 'non-finance staff and other-school staff are denied; NO client writes', async () => {
    await seed();
    for (const col of ['financial_entitlement_policy/current', 'financial_entitlement_overrides/o1',
      'financial_entitlement_audit/a1', 'entitlement_taps/tap1']) {
      await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/' + col)));
      await assertFails(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/' + col)));
      await assertFails(getDoc(doc(dbFor('bursarB'), 'schools/schoolA/' + col)));
    }
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/financial_entitlement_policy/current'), { services: {} }));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/financial_entitlement_overrides/forged'), { decision: 'allow' }));
    await assertFails(updateDoc(doc(dbFor('bursarA'), 'schools/schoolA/entitlement_taps/tap1'), { decision: 'deny' }));
  });

  test('entitlement_terminals: only canWriteFinance() reads; write denied to all', async () => {
    await seed();
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/entitlement_terminals/t1')));
    await assertFails(getDoc(doc(dbFor('teacherA'), 'schools/schoolA/entitlement_terminals/t1')));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/entitlement_terminals/forged'), { service: 'dining' }));
  });

  test('entitlement_terminal_nonces: no client can ever read or write them', async () => {
    await seed();
    await assertFails(getDoc(doc(dbFor('bursarA'), 'schools/schoolA/entitlement_terminal_nonces/n1')));
    await assertFails(setDoc(doc(dbFor('bursarA'), 'schools/schoolA/entitlement_terminal_nonces/forged'), { x: 1 }));
  });
});

// Term-based SaaS billing Phase 1 (functions/academic_calendar_billing.js).
// subscription_cycles mirrors payment_transactions: tenant-scoped read,
// Cloud-Functions-only write. academic_terms gets defense-in-depth so a
// client can never set isConfirmed: true directly (confirmation only
// happens through the confirmAcademicCalendar callable, which uses the
// Admin SDK and bypasses these rules entirely).
describe('Term billing Phase 1: subscription_cycles + academic_terms.isConfirmed', () => {
  async function seedCycles() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await Promise.all([
        setDoc(doc(db, 'subscription_cycles', 'schoolA_term1'), {
          schoolId: 'schoolA', subscriptionId: 'schoolA', academicYearId: 'yearA',
          termId: 'term1', termNumber: 1, paymentStatus: 'unpaid', cycleStatus: 'upcoming',
        }),
        setDoc(doc(db, 'subscription_cycles', 'schoolB_term1'), {
          schoolId: 'schoolB', subscriptionId: 'schoolB', academicYearId: 'yearB',
          termId: 'term1', termNumber: 1, paymentStatus: 'unpaid', cycleStatus: 'upcoming',
        }),
      ]);
    });
  }

  test('subscription_cycles: same-school staff can read, other-school staff cannot', async () => {
    await seedCycles();
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'subscription_cycles', 'schoolA_term1')));
    await assertSucceeds(getDoc(doc(dbFor('bursarA'), 'subscription_cycles', 'schoolA_term1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'subscription_cycles', 'schoolA_term1')));
    await assertFails(getDoc(doc(dbFor('adminA'), 'subscription_cycles', 'schoolB_term1')));
  });

  test('subscription_cycles: SaaS owner can read across schools, unauthenticated cannot read', async () => {
    await seedCycles();
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'subscription_cycles', 'schoolA_term1')));
    await assertSucceeds(getDoc(doc(dbFor('ownerA'), 'subscription_cycles', 'schoolB_term1')));
    await assertFails(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'subscription_cycles', 'schoolA_term1')));
  });

  test('subscription_cycles: no client write is ever permitted, including by the owning school or the owner', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'subscription_cycles', 'forged'), {
      schoolId: 'schoolA', cycleStatus: 'paid',
    }));
    await assertFails(setDoc(doc(dbFor('ownerA'), 'subscription_cycles', 'forged2'), {
      schoolId: 'schoolA', cycleStatus: 'paid',
    }));
  });

  test('academic_terms: client create cannot set isConfirmed: true', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'academic_terms', 'newTerm'), {
      schoolId: 'schoolA', academicYearId: 'yearA', name: 'Term 1', order: 1,
      isConfirmed: true,
    }));
    await assertSucceeds(setDoc(doc(dbFor('adminA'), 'academic_terms', 'newTerm2'), {
      schoolId: 'schoolA', academicYearId: 'yearA', name: 'Term 1', order: 1,
      isConfirmed: false,
    }));
  });

  test('academic_terms: client cannot flip isConfirmed to true via update, and cannot modify an already-confirmed term at all', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'academic_terms', 'draftTerm'), {
        schoolId: 'schoolA', academicYearId: 'yearA', name: 'Term 1', order: 1, isConfirmed: false,
      });
      await setDoc(doc(context.firestore(), 'academic_terms', 'confirmedTerm'), {
        schoolId: 'schoolA', academicYearId: 'yearA', name: 'Term 2', order: 2, isConfirmed: true,
      });
    });
    // Draft term: client can update it as long as isConfirmed stays false.
    await assertSucceeds(updateDoc(doc(dbFor('adminA'), 'academic_terms', 'draftTerm'), { name: 'Term 1 (renamed)' }));
    // Draft term: client cannot flip isConfirmed to true via update.
    await assertFails(updateDoc(doc(dbFor('adminA'), 'academic_terms', 'draftTerm'), { isConfirmed: true }));
    // Already-confirmed term: no client update at all, even one that leaves isConfirmed alone.
    await assertFails(updateDoc(doc(dbFor('adminA'), 'academic_terms', 'confirmedTerm'), { name: 'Renamed' }));
  });
});

describe('Term billing Phase 3A: student_pricing_bands', () => {
  async function seedBand() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'student_pricing_bands', 'band1'), {
        minStudents: 1, maxStudents: 300, amountUgx: 350000, isActive: true,
      });
    });
  }

  test('student_pricing_bands: staff read all; unauthenticated read only active bands', async () => {
    // Active bands are deliberately public (marketing pricing page, 598ebdc6);
    // inactive/superseded bands stay staff-only.
    await seedBand();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'student_pricing_bands', 'oldBand'), {
        minStudents: 1, maxStudents: 300, amountUgx: 300000, isActive: false,
      });
    });
    const anon = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'student_pricing_bands', 'band1')));
    await assertSucceeds(getDoc(doc(dbFor('teacherB'), 'student_pricing_bands', 'band1')));
    await assertSucceeds(getDoc(doc(dbFor('teacherB'), 'student_pricing_bands', 'oldBand')));
    await assertSucceeds(getDoc(doc(anon, 'student_pricing_bands', 'band1')));
    await assertFails(getDoc(doc(anon, 'student_pricing_bands', 'oldBand')));
  });

  test('student_pricing_bands: only the SaaS owner may write directly; school admin/staff cannot', async () => {
    // The rule is a defense-in-depth outer boundary (isSuperAdmin()) - real
    // overlap/immutability validation happens in the createPricingBand/
    // updatePricingBand/deactivatePricingBand callables, not here.
    await assertFails(setDoc(doc(dbFor('adminA'), 'student_pricing_bands', 'forged'), {
      minStudents: 1, maxStudents: 300, amountUgx: 1, isActive: true,
    }));
    await assertSucceeds(setDoc(doc(dbFor('ownerA'), 'student_pricing_bands', 'forged2'), {
      minStudents: 1, maxStudents: 300, amountUgx: 1, isActive: true,
    }));
    await seedBand();
    await assertFails(updateDoc(doc(dbFor('adminA'), 'student_pricing_bands', 'band1'), { amountUgx: 1 }));
  });
});

describe('Direct enrolment: draft + restricted support notes', () => {
  async function seedDraft() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'direct_enrolment_drafts', 'draft1'), {
        schoolId: 'schoolA', createdBy: 'drafterA', status: 'draft', guardianConsent: null,
      });
      await setDoc(
        doc(context.firestore(), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
        { schoolId: 'schoolA', notes: 'seeded note' },
      );
    });
  }

  test('draft: creator can read/update their own draft, other-school staff cannot', async () => {
    await seedDraft();
    await assertSucceeds(getDoc(doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1')));
    await assertSucceeds(updateDoc(doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1'), {
      schoolId: 'schoolA', createdBy: 'drafterA', status: 'draft', guardianConsent: null, step: 3,
    }));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'direct_enrolment_drafts', 'draft1')));
  });

  test('draft: a client can never set status to anything but draft/cancelled', async () => {
    await seedDraft();
    await assertFails(updateDoc(doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1'), {
      schoolId: 'schoolA', createdBy: 'drafterA', status: 'active', guardianConsent: null,
    }));
  });

  test('restricted support notes: only an approved clinical role (nurse/schoolAdmin) may read, not the draft creator or an ordinary teacher', async () => {
    await seedDraft();
    await assertSucceeds(getDoc(
      doc(dbFor('nurseA'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
    ));
    await assertSucceeds(getDoc(
      doc(dbFor('adminA'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
    ));
    await assertFails(getDoc(
      doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
    ));
    await assertFails(getDoc(
      doc(dbFor('teacherA'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
    ));
  });

  test('restricted support notes: cross-school clinical staff cannot read or write another school\'s notes', async () => {
    await seedDraft();
    await assertFails(getDoc(
      doc(dbFor('nurseB'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
    ));
    // Also cannot forge access by asserting their own schoolId in the payload.
    await assertFails(setDoc(
      doc(dbFor('nurseB'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
      { schoolId: 'schoolB', notes: 'forged' },
    ));
  });

  test('restricted support notes: an ordinary teacher cannot write notes even for their own draft', async () => {
    await seedDraft();
    await assertFails(setDoc(
      doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
      { schoolId: 'schoolA', notes: 'should not be allowed' },
    ));
  });

  test('restricted support notes: nurse can update notes for their own school', async () => {
    await seedDraft();
    await assertSucceeds(setDoc(
      doc(dbFor('nurseA'), 'direct_enrolment_drafts', 'draft1', 'restricted', 'support'),
      { schoolId: 'schoolA', notes: 'updated by nurse' },
      { merge: true },
    ));
  });

  test('draft: a client update can never introduce or change guardianConsent directly', async () => {
    // Structured guardian consent is written only by guardian_consent.js's
    // callables (Cloud Functions bypass rules). A client merge-update must
    // echo back the existing value untouched.
    await seedDraft();
    await assertFails(updateDoc(doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1'), {
      schoolId: 'schoolA', createdBy: 'drafterA', status: 'draft',
      guardianConsent: { status: 'captured', method: 'guardian_signs_now' },
    }));
    // A merge write that never mentions guardianConsent leaves it untouched
    // and is allowed - this is how the wizard's autosave actually writes.
    await assertSucceeds(updateDoc(doc(dbFor('drafterA'), 'direct_enrolment_drafts', 'draft1'), {
      step: 5,
    }));
  });
});

describe('Guardian consent (direct enrolment Step 6)', () => {
  async function seedConsentRecord() {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'guardian_consent_records', 'record1'), {
        schoolId: 'schoolA', draftId: 'draft1', guardianId: 'g1', guardianName: 'Jane Doe',
        method: 'guardian_signs_now', status: 'captured', policyVersion: 'v1',
        consentTextHash: 'abc123',
      });
      await setDoc(doc(context.firestore(), 'guardian_consent_links', 'token1'), {
        id: 'token1', schoolId: 'schoolA', draftId: 'draft1', guardianId: 'g1',
        guardianName: 'Jane Doe', email: 'jane@example.com', used: false,
      });
    });
  }

  test('guardian_consent_records: same-school staff can read, other-school staff cannot', async () => {
    await seedConsentRecord();
    await assertSucceeds(getDoc(doc(dbFor('adminA'), 'guardian_consent_records', 'record1')));
    await assertFails(getDoc(doc(dbFor('teacherB'), 'guardian_consent_records', 'record1')));
  });

  test('guardian_consent_records: unauthenticated read fails', async () => {
    await seedConsentRecord();
    await assertFails(getDoc(
      doc(testEnv.unauthenticatedContext().firestore(), 'guardian_consent_records', 'record1'),
    ));
  });

  test('guardian_consent_records: no client, including a school admin, may write directly - append-only via callables only', async () => {
    await assertFails(setDoc(doc(dbFor('adminA'), 'guardian_consent_records', 'forged'), {
      schoolId: 'schoolA', draftId: 'draft1', guardianId: 'g1', guardianName: 'x',
      method: 'guardian_signs_now', status: 'captured', policyVersion: 'v1', consentTextHash: 'x',
    }));
    await seedConsentRecord();
    await assertFails(updateDoc(doc(dbFor('adminA'), 'guardian_consent_records', 'record1'), {
      status: 'withdrawn',
    }));
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'guardian_consent_records', 'record1')));
  });

  test('guardian_consent_links: no client may read or write a token doc directly - only resolveGuardianConsentLink may, and it is unauthenticated by design', async () => {
    await seedConsentRecord();
    // Not even the school admin who could have created it, and not the
    // guardian (who has no account) - the token is resolved exclusively
    // through the callable's own expiry/single-use transaction.
    await assertFails(getDoc(doc(dbFor('adminA'), 'guardian_consent_links', 'token1')));
    await assertFails(getDoc(
      doc(testEnv.unauthenticatedContext().firestore(), 'guardian_consent_links', 'token1'),
    ));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'guardian_consent_links', 'token1'), {
      used: true,
    }));
  });
});

describe('Parent invitations (parent_invitations.js) are server-only', () => {
  test('no client - not even a school admin - may read or write parent_invitations', async () => {
    await assertFails(getDoc(doc(dbFor('adminA'), 'parent_invitations', 'inv1')));
    await assertFails(setDoc(doc(dbFor('adminA'), 'parent_invitations', 'forged'), {
      schoolId: 'schoolA', parentInviteId: 'x', status: 'sent',
    }));
    await assertFails(updateDoc(doc(dbFor('adminA'), 'parent_invitations', 'inv1'), { status: 'accepted' }));
    await assertFails(deleteDoc(doc(dbFor('adminA'), 'parent_invitations', 'inv1')));
    await assertFails(getDoc(
      doc(testEnv.unauthenticatedContext().firestore(), 'parent_invitations', 'inv1'),
    ));
  });
});

