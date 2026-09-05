// Firebase Emulator integration test for exports.createStaffAccount in
// functions/index.js. Run via `npm run test:create-staff-account:emulator`
// (firebase emulators:exec --only firestore,auth, extending the
// test:student-fee-billing:emulator/test:rules convention in this directory).
//
// Unlike student_fee_billing.js/support_audit.js/enrollment_audit.js, index.js
// is not a factory - its exports are built directly from the real `onCall`
// from firebase-functions/v2/https, so the exported symbol is a CloudFunction
// object, not a plain async function. It exposes a `.run(request)` method
// that invokes the wrapped handler directly against a plain
// {auth, data} request, without needing an actual HTTPS trigger - that's
// what's used below (see staff_roles.test.cjs for the sibling pattern of
// requiring ../index directly for its `exports.__test__`).
//
// createStaffAccount calls admin.auth().createUser(...) and
// admin.auth().generatePasswordResetLink(...), so the Auth emulator must also
// be running - FIREBASE_AUTH_EMULATOR_HOST is set before requiring index.js
// (via firebase-admin) below, same as FIRESTORE_EMULATOR_HOST.
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-create-staff-account-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

// index.js calls admin.initializeApp() unconditionally on load - don't
// pre-initialize here (mirrors staff_roles.test.cjs).
const { createStaffAccount } = require("../index");

const admin = require("firebase-admin");
const db = admin.firestore();
const auth = admin.auth();

const SCHOOL = "schoolA";
const OTHER_SCHOOL = "schoolB";
const ADMIN_UID = "adminUid";

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => deleteCollectionRecursive(c)));
}

async function deleteCollectionRecursive(collectionRef) {
  const docRefs = await collectionRef.listDocuments();
  await Promise.all(
    docRefs.map(async (docRef) => {
      const subcollections = await docRef.listCollections();
      await Promise.all(subcollections.map((c) => deleteCollectionRecursive(c)));
      await docRef.delete();
    })
  );
}

async function clearAuthUsers() {
  const list = await auth.listUsers(1000);
  await Promise.all(list.users.map((u) => auth.deleteUser(u.uid).catch(() => {})));
}

async function seedBaseFixtures() {
  await db.doc(`users/${ADMIN_UID}`).set({ roles: ["schoolAdmin"], schoolId: SCHOOL });
  await db.doc("staff_designations/desigA").set({ schoolId: SCHOOL, name: "Teacher", isArchived: false });
  await db.doc("staff_designations/desigB").set({ schoolId: OTHER_SCHOOL, name: "Other-School Teacher", isArchived: false });
  await db.doc("campuses/campusOther").set({ schoolId: OTHER_SCHOOL, name: "Other Campus", isActive: true });
}

function baseStaffPayload(overrides = {}) {
  let counter = baseStaffPayload._n = (baseStaffPayload._n || 0) + 1;
  return {
    name: "Jane Doe",
    email: `jane.doe.${counter}@example.com`,
    roles: ["bursar"],
    schoolId: SCHOOL,
    designationId: "desigA",
    idempotencyKey: `idem-key-${counter}-000000000000`,
    signInMethod: "invite",
    sendLoginDetailsViaEmail: false,
    ...overrides,
  };
}

describe("createStaffAccount", () => {
  beforeEach(async () => {
    await clearFirestore();
    await clearAuthUsers();
    await seedBaseFixtures();
  });

  after(async () => {
    await clearFirestore();
    await clearAuthUsers();
  });

  // --- (a) signInMethod invite vs noLogin: an Auth invitation is only
  // issued (and only ever emailed) for "invite"; "noLogin" creates just the
  // profile with no email and no invitation record. mustChangePassword and
  // setupRequired are always true - the staff member always sets their own
  // password, never the admin. ---
  const signInMethodCases = ["invite", "noLogin"];
  for (const signInMethod of signInMethodCases) {
    test(`signInMethod=${signInMethod} never persists a password and controls invitation issuance`, async () => {
      const result = await createStaffAccount.run(
        request(ADMIN_UID, baseStaffPayload({ signInMethod }))
      );
      assert.ok(result.uid);

      const userDoc = await db.doc(`users/${result.uid}`).get();
      assert.equal(userDoc.data().mustChangePassword, true);
      assert.equal(userDoc.data().setupRequired, true);
      assert.equal(userDoc.data().signInMethod, signInMethod);
      assert.equal(userDoc.data().password, undefined);

      const shouldInvite = signInMethod === "invite";
      assert.equal(result.setupEmailQueued, shouldInvite);
      assert.equal(userDoc.data().invitationStatus, shouldInvite ? "sent" : undefined);

      const queueSnap = await db.collection("transactional_email_queue")
        .where("to", "==", userDoc.data().email)
        .get();
      assert.equal(queueSnap.empty, !shouldInvite);

      const invitesSnap = await db.collection("staff_invitations")
        .where("uid", "==", result.uid)
        .get();
      assert.equal(invitesSnap.empty, !shouldInvite);
    });
  }

  // --- (b) Field persistence ---
  test("persists gender/phone/alternatePhone/address/nationality/emergencyContact", async () => {
    const payload = baseStaffPayload({
      gender: "Female",
      phoneNumber: "+256700000001",
      alternatePhone: "+256700000002",
      address: "123 Main Street, Kampala",
      nationality: "Ugandan",
      emergencyContact: {
        name: "John Doe",
        relationship: "Spouse",
        phone: "+256700000003",
        alternatePhone: "+256700000004",
      },
    });
    const result = await createStaffAccount.run(request(ADMIN_UID, payload));
    const userDoc = await db.doc(`users/${result.uid}`).get();
    const data = userDoc.data();

    assert.equal(data.gender, "Female");
    assert.equal(data.phoneNumber, "+256700000001");
    assert.equal(data.alternatePhone, "+256700000002");
    assert.equal(data.address, "123 Main Street, Kampala");
    assert.equal(data.nationality, "Ugandan");
    assert.deepEqual(data.emergencyContact, {
      name: "John Doe",
      relationship: "Spouse",
      phone: "+256700000003",
      alternatePhone: "+256700000004",
    });
  });

  test("creates staff without a legacy designation", async () => {
    const payload = baseStaffPayload({ designationId: null });

    const result = await createStaffAccount.run(request(ADMIN_UID, payload));
    const userDoc = await db.doc(`users/${result.uid}`).get();

    assert.equal(userDoc.exists, true);
    assert.equal(userDoc.data().designationId, undefined);
  });

  // --- (c) Idempotency retry ---
  test("retrying with the same idempotencyKey does not create duplicate Auth users or user docs", async () => {
    const payload = baseStaffPayload({ idempotencyKey: "fixed-retry-key-0000000000" });

    const first = await createStaffAccount.run(request(ADMIN_UID, payload));
    const second = await createStaffAccount.run(request(ADMIN_UID, payload));

    assert.equal(first.uid, second.uid);
    assert.equal(first.staffCode, second.staffCode);
    assert.equal(second.replayed, true);

    const usersSnap = await db.collection("users")
      .where("schoolId", "==", SCHOOL)
      .where("email", "==", payload.email)
      .get();
    assert.equal(usersSnap.size, 1);

    const authList = await auth.listUsers(1000);
    const matches = authList.users.filter((u) => u.email === payload.email);
    assert.equal(matches.length, 1);
  });

  // --- (d) Cross-tenant rejection ---
  test("rejects a designationId belonging to a different school", async () => {
    const payload = baseStaffPayload({ designationId: "desigB" });
    await assert.rejects(
      () => createStaffAccount.run(request(ADMIN_UID, payload)),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      }
    );
  });

  test("rejects a campusId belonging to a different school", async () => {
    const payload = baseStaffPayload({ campusId: "campusOther" });
    await assert.rejects(
      () => createStaffAccount.run(request(ADMIN_UID, payload)),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      }
    );
  });
});
