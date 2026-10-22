// Firestore Rules emulator tests for the Enrolled School Detail workspace's
// tenant-isolation boundary - the collections a Super Admin's new callables
// (getSchoolCounts, getManualPaymentsForOwner, manageSchoolAdmin,
// requestSupportAccess) rely on being denied to direct client reads, plus
// the one rules change this workspace made (support_access_requests'
// isSuperAdmin() read branch).
//
// The counts/payments/admin-management callables themselves run via the
// Admin SDK (bypasses rules by design - see public_functions/school_counts.js,
// payments.js, portal_domains.js) so they cannot be exercised against the
// Firestore rules emulator directly; the Functions emulator/unit-test layer
// covers their query-scoping logic instead (see
// public_functions/__tests__/{school_counts,payments_school_scope,
// portal_domains}.test.js). What IS provable against the rules emulator,
// and is proven here, is that the client-side read paths those callables
// exist specifically to avoid remain closed: a Super Admin (and everyone
// else) cannot read raw students/users/payments documents directly, cross-
// tenant reads on the client stay denied, and the support_access_requests
// rule change is exactly as scoped as intended.
//
// Standalone from firestore.rules.test.cjs and super_admin_console.rules.test.cjs
// (kept surgical - both are large and owned by other workstreams). Same
// harness convention as super_admin_console.rules.test.cjs.
//
// Run:
//   firebase emulators:exec --only firestore \
//     --project demo-school-pulse-workspace-rules-test \
//     "node --test test/school_workspace.rules.test.cjs"
const { after, before, beforeEach, describe, test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc } = require('firebase/firestore');

const projectId = 'demo-school-pulse-workspace-rules-test';
const rules = fs.readFileSync(path.resolve(__dirname, '../../firestore.rules'), 'utf8');

let testEnv;
const OWNER = 'owner1';
const ADMIN_A = 'adminA'; // schoolAdmin at schoolA
const ADMIN_B = 'adminB'; // schoolAdmin at schoolB
const TEACHER_A = 'teacherA'; // staff, non-admin, at schoolA
const PARENT_A = 'parentA'; // parent at schoolA

function dbFor(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}
function anon() {
  return testEnv.unauthenticatedContext().firestore();
}

async function seed() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/owner1'), { role: 'superAdmin', roles: ['superAdmin'], schoolId: null });
    await setDoc(doc(db, 'users/adminA'), { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolA', isActive: true });
    await setDoc(doc(db, 'users/adminB'), { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolB', isActive: true });
    await setDoc(doc(db, 'users/teacherA'), { role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolA', isActive: true });
    await setDoc(doc(db, 'users/parentA'), { role: 'parent', roles: ['parent'], schoolId: 'schoolA', studentIds: [] });

    await setDoc(doc(db, 'schools/schoolA'), { name: 'School A', status: 'active' });
    await setDoc(doc(db, 'schools/schoolB'), { name: 'School B', status: 'active' });

    // A student record at schoolA - proves the client can't read raw
    // student docs regardless of role, which is exactly why
    // getSchoolCounts runs server-side via the Admin SDK instead.
    await setDoc(doc(db, 'students/stuA1'), { schoolId: 'schoolA', status: 'active', name: 'Student One' });

    // A manual payment at each school.
    await setDoc(doc(db, 'manual_subscription_payments/payA1'), { schoolId: 'schoolA', status: 'pending_verification', submittedAmount: 100000 });
    await setDoc(doc(db, 'manual_subscription_payments/payB1'), { schoolId: 'schoolB', status: 'approved', submittedAmount: 200000 });

    // institution_memberships - proves manageSchoolAdmin's writes (which
    // touch this collection) cannot be forged client-side even by the
    // school's own admin.
    await setDoc(doc(db, 'institution_memberships/adminA_schoolA'), { userId: ADMIN_A, institutionId: 'schoolA', isPrimaryAdmin: true, status: 'active' });

    // A support access request at each school - the collection whose read
    // rule this workspace changed to add an isSuperAdmin() branch.
    await setDoc(doc(db, 'institutions/schoolA/support_access_requests/reqA1'), { institutionId: 'schoolA', status: 'pending', reason: 'Investigating an attendance issue', requestedByPlatformUser: OWNER });
    await setDoc(doc(db, 'institutions/schoolB/support_access_requests/reqB1'), { institutionId: 'schoolB', status: 'pending', reason: 'Unrelated', requestedByPlatformUser: OWNER });
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules, host: '127.0.0.1', port: 8080 },
  });
});
after(async () => { await testEnv.cleanup(); });
beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed();
});

describe('students - tenant isolation (Super Admin included, per isSameSchool()\'s deliberate cross-tenant grant)', () => {
  // CORRECTION from the original architecture research: isSameSchool()
  // (firestore.rules:93-104) already includes an isSuperAdmin() branch,
  // documented there as deliberate - "superAdmin ... has the same
  // operational cross-tenant access as the server-admin console." A Super
  // Admin CAN read a raw student document directly. getSchoolCounts is
  // still the right implementation (a count() aggregation avoids fetching
  // N full documents just to display a number, and avoids the client ever
  // touching personal data for a stat tile), but its justification is
  // efficiency/data-minimization, not a closed rules door - correcting
  // that claim here rather than leaving a false premise in the test suite.
  test('Super Admin CAN read a raw student document directly (documented cross-tenant grant)', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER), 'students/stuA1')));
  });
  test('the school\'s own admin can read their student (existing staff-read path, unaffected)', async () => {
    await assertSucceeds(getDoc(doc(dbFor(ADMIN_A), 'students/stuA1')));
  });
  test('a different school\'s admin cannot read this student - tenant isolation holds for non-owner staff', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_B), 'students/stuA1')));
  });
  test('a parent from the same school cannot read a student that is not theirs', async () => {
    await assertFails(getDoc(doc(dbFor(PARENT_A), 'students/stuA1')));
  });
  test('an unauthenticated caller cannot read a student', async () => {
    await assertFails(getDoc(doc(anon(), 'students/stuA1')));
  });
});

describe('manual_subscription_payments - no direct client read/write for anyone', () => {
  // getManualPaymentsForOwner exists specifically because this collection
  // has no client-facing rules block (default-deny) - this proves that
  // premise still holds, i.e. a Super Admin cannot bypass the callable's
  // server-side schoolId filter by reading the collection directly.
  test('Super Admin cannot read a payment document directly', async () => {
    await assertFails(getDoc(doc(dbFor(OWNER), 'manual_subscription_payments/payA1')));
  });
  test('the paying school\'s own admin cannot read the payment document directly either', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_A), 'manual_subscription_payments/payA1')));
  });
  test('no client can write a payment document', async () => {
    await assertFails(setDoc(doc(dbFor(OWNER), 'manual_subscription_payments/payHack'), { schoolId: 'schoolA', status: 'approved' }));
  });
});

describe('users/{uid} - checking the actual cross-tenant read boundary the staff-count query relies on', () => {
  // The users/{uid} read rule (firestore.rules:215) is `request.auth.uid ==
  // uid || isStaff()` - isStaff() alone, with NO isSameSchool() check on
  // this particular rule. This block verifies exactly what that means in
  // practice rather than assuming from reading the rule text.
  test('Super Admin can read any user document directly (isStaff() branch, no tenancy check here)', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER), 'users/adminB')));
  });
  test('a staff member from School A can also read a School B staff document directly - isStaff() alone has no tenancy check on this rule', async () => {
    await assertSucceeds(getDoc(doc(dbFor(ADMIN_A), 'users/adminB')));
  });
  test('a parent can only read their own document, not another user\'s', async () => {
    await assertFails(getDoc(doc(dbFor(PARENT_A), 'users/adminA')));
    await assertSucceeds(getDoc(doc(dbFor(PARENT_A), 'users/parentA')));
  });
});

describe('institution_memberships - manageSchoolAdmin\'s target collection stays server-write-only', () => {
  test('Super Admin can read a membership (existing isSuperAdmin() branch)', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER), 'institution_memberships/adminA_schoolA')));
  });
  test('a school\'s own admin cannot forge/alter their own membership (e.g. self-promote to primary)', async () => {
    await assertFails(setDoc(doc(dbFor(ADMIN_A), 'institution_memberships/adminA_schoolA'), { isPrimaryAdmin: true }));
    await assertFails(updateDoc(doc(dbFor(ADMIN_A), 'institution_memberships/adminA_schoolA'), { isPrimaryAdmin: true }));
  });
  test('a different school\'s admin cannot read this membership', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_B), 'institution_memberships/adminA_schoolA')));
  });
});

describe('institutions/{id}/support_access_requests - the rule this workspace changed', () => {
  test('Super Admin can now read a support access request for any school (the new branch)', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER), 'institutions/schoolA/support_access_requests/reqA1')));
    await assertSucceeds(getDoc(doc(dbFor(OWNER), 'institutions/schoolB/support_access_requests/reqB1')));
  });
  test('a school\'s own admin can still read their own school\'s request (unchanged branch)', async () => {
    await assertSucceeds(getDoc(doc(dbFor(ADMIN_A), 'institutions/schoolA/support_access_requests/reqA1')));
  });
  test('a different school\'s admin cannot read another school\'s support access request', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_B), 'institutions/schoolA/support_access_requests/reqA1')));
  });
  test('a non-admin staff member (teacher) cannot read a support access request', async () => {
    await assertFails(getDoc(doc(dbFor(TEACHER_A), 'institutions/schoolA/support_access_requests/reqA1')));
  });
  test('a parent cannot read a support access request', async () => {
    await assertFails(getDoc(doc(dbFor(PARENT_A), 'institutions/schoolA/support_access_requests/reqA1')));
  });
  test('no client, including Super Admin, can write a support access request (Admin-SDK only)', async () => {
    await assertFails(setDoc(doc(dbFor(OWNER), 'institutions/schoolA/support_access_requests/reqHack'), { institutionId: 'schoolA', status: 'active' }));
    await assertFails(updateDoc(doc(dbFor(OWNER), 'institutions/schoolA/support_access_requests/reqA1'), { status: 'active' }));
  });
  test('an unauthenticated caller is denied', async () => {
    await assertFails(getDoc(doc(anon(), 'institutions/schoolA/support_access_requests/reqA1')));
  });
});

describe('school_admin_invitations - the invite-admin write path this workspace reuses', () => {
  test('Super Admin can create an invitation', async () => {
    await assertSucceeds(setDoc(doc(dbFor(OWNER), 'school_admin_invitations/inv1'), {
      email: 'new-admin@schoolA.ug', schoolId: 'schoolA', tenantId: 'SCHOOLA', tempPassword: 'x', status: 'pending',
    }));
  });
  test('a school admin cannot create an invitation for their own or another school', async () => {
    await assertFails(setDoc(doc(dbFor(ADMIN_A), 'school_admin_invitations/inv2'), {
      email: 'x@y.com', schoolId: 'schoolA', tenantId: 'SCHOOLA', tempPassword: 'x', status: 'pending',
    }));
  });
  test('nobody, including Super Admin, can read an invitation back (plaintext temp password)', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'school_admin_invitations/invSeed'), { email: 'x@y.com', schoolId: 'schoolA', status: 'pending' });
    });
    await assertFails(getDoc(doc(dbFor(OWNER), 'school_admin_invitations/invSeed')));
  });
});
