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
});
