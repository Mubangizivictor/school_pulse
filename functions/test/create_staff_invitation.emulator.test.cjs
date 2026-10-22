// Firebase Emulator integration test for exports.createStaffInvitation and
// exports.cancelStaffInvitation in functions/index.js. Run via
// `npm run test:create-staff-invitation:emulator` (see
// create_staff_account.emulator.test.cjs for the shared pattern this
// mirrors: index.js is not a factory, so each export is a CloudFunction
// object exposing `.run(request)`).
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-create-staff-invitation-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const { createStaffAccount, createStaffInvitation, cancelStaffInvitation } = require("../index");

const admin = require("firebase-admin");
const db = admin.firestore();
const auth = admin.auth();

const SCHOOL = "schoolA";
const OTHER_SCHOOL = "schoolB";
const ADMIN_UID = "adminUid";
const OTHER_SCHOOL_ADMIN_UID = "otherAdminUid";
const NON_ADMIN_UID = "teacherUid";

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
  await db.doc(`users/${OTHER_SCHOOL_ADMIN_UID}`).set({ roles: ["schoolAdmin"], schoolId: OTHER_SCHOOL });
  await db.doc(`users/${NON_ADMIN_UID}`).set({ roles: ["subjectTeacher"], schoolId: SCHOOL });
}

let counter = 0;
async function createStaffFixture(overrides = {}) {
  counter += 1;
  const result = await createStaffAccount.run(
    request(ADMIN_UID, {
      name: "Jane Doe",
      email: `jane.doe.${counter}@example.com`,
      roles: ["bursar"],
      schoolId: SCHOOL,
      idempotencyKey: `idem-key-${counter}-000000000000`,
      signInMethod: "noLogin",
      ...overrides,
    })
  );
  return result.uid;
}

describe("createStaffInvitation / cancelStaffInvitation", () => {
  beforeEach(async () => {
    await clearFirestore();
    await clearAuthUsers();
    await seedBaseFixtures();
  });

  after(async () => {
    await clearFirestore();
    await clearAuthUsers();
  });

  test("issues an invitation, writes status metadata, and never returns a password", async () => {
    const uid = await createStaffFixture();

    const result = await createStaffInvitation.run(request(ADMIN_UID, { uid }));
    assert.ok(result.inviteId);
    assert.equal(result.status, "sent");
    assert.equal(result.password, undefined);

    const userDoc = await db.doc(`users/${uid}`).get();
    assert.equal(userDoc.data().invitationStatus, "sent");
    assert.equal(userDoc.data().invitationId, result.inviteId);

    const inviteDoc = await db.collection("staff_invitations").doc(result.inviteId).get();
    assert.equal(inviteDoc.data().status, "sent");
    assert.equal(inviteDoc.data().schoolId, SCHOOL);
    assert.equal(inviteDoc.data().password, undefined);
    assert.ok(inviteDoc.data().expiresAt);

    const queueSnap = await db.collection("transactional_email_queue")
      .where("to", "==", userDoc.data().email)
      .get();
    assert.equal(queueSnap.empty, false);
  });

  test("rejects a resend within the cooldown window", async () => {
    const uid = await createStaffFixture();
    await createStaffInvitation.run(request(ADMIN_UID, { uid }));

    await assert.rejects(
      () => createStaffInvitation.run(request(ADMIN_UID, { uid })),
      (err) => {
        assert.equal(err.code, "resource-exhausted");
        return true;
      }
    );
  });

  test("rejects a non-admin caller", async () => {
    const uid = await createStaffFixture();
    await assert.rejects(
      () => createStaffInvitation.run(request(NON_ADMIN_UID, { uid })),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
  });

  test("rejects a cross-tenant invitation attempt", async () => {
    const uid = await createStaffFixture();
    await assert.rejects(
      () => createStaffInvitation.run(request(OTHER_SCHOOL_ADMIN_UID, { uid })),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
  });

  test("cancelStaffInvitation marks the invitation and user cancelled", async () => {
    const uid = await createStaffFixture();
    const { inviteId } = await createStaffInvitation.run(request(ADMIN_UID, { uid }));

    const result = await cancelStaffInvitation.run(request(ADMIN_UID, { uid }));
    assert.equal(result.status, "cancelled");

    const inviteDoc = await db.collection("staff_invitations").doc(inviteId).get();
    assert.equal(inviteDoc.data().status, "cancelled");

    const userDoc = await db.doc(`users/${uid}`).get();
    assert.equal(userDoc.data().invitationStatus, "cancelled");
  });

  test("cancelling then reinviting is allowed immediately (cooldown does not apply to a cancelled invite)", async () => {
    const uid = await createStaffFixture();
    await createStaffInvitation.run(request(ADMIN_UID, { uid }));
    await cancelStaffInvitation.run(request(ADMIN_UID, { uid }));

    const result = await createStaffInvitation.run(request(ADMIN_UID, { uid }));
    assert.ok(result.inviteId);
    assert.equal(result.status, "sent");
  });

  test("rejects an unknown uid with the same generic error as a cross-tenant one", async () => {
    await assert.rejects(
      () => createStaffInvitation.run(request(ADMIN_UID, { uid: "does-not-exist" })),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
  });
});
