// Firebase Emulator integration test for exports.setSchoolLifecycleStatus
// and exports.updateSchoolSubscriptionPlan in public_functions/portal_domains.js.
// Run via `npm run test:portal-domains-lifecycle:emulator` (extends the
// functions/test/create_staff_account.emulator.test.cjs convention: the
// exported symbols are real onCall CloudFunction objects, invoked directly
// via `.run(request)` against a plain {auth, data} request, no HTTPS
// trigger needed).
//
// portal_domains.js calls admin.auth().getUserByEmail/createUser during
// createSchoolPortal (not used by these two tests directly, but the module
// initializes admin unconditionally on load), so both the Firestore and
// Auth emulators must be running - env vars are set before requiring the
// module below, same as create_staff_account.emulator.test.cjs.
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-portal-domains-lifecycle-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const { setSchoolLifecycleStatus, updateSchoolSubscriptionPlan } = require("../portal_domains");

const admin = require("firebase-admin");
const db = admin.firestore();

const OWNER_UID = "ownerUid";
const SCHOOL_ADMIN_UID = "schoolAdminUid";
const STAFF_UID = "staffUid";
const SCHOOL_ID = "schoolA";
const OTHER_SCHOOL_ID = "schoolB";
const FORGED_SCHOOL_ID = "does-not-exist";

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

async function seedBaseFixtures() {
  await db.doc("platform_config/owner_seed").set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({
    role: "superAdmin",
    roles: ["superAdmin"],
    isActive: true,
  });
  await db.doc(`users/${SCHOOL_ADMIN_UID}`).set({
    role: "schoolAdmin",
    roles: ["schoolAdmin"],
    schoolId: SCHOOL_ID,
    isActive: true,
  });
  await db.doc(`users/${STAFF_UID}`).set({
    role: "classTeacher",
    roles: ["classTeacher"],
    schoolId: SCHOOL_ID,
    isActive: true,
  });
  await db.doc(`schools/${SCHOOL_ID}`).set({
    id: SCHOOL_ID,
    name: "School A",
    status: "trial",
    subscriptionPlanId: "starter",
    subscriptionExpiry: Date.now(),
    metadata: {},
  });
  await db.doc(`schools/${OTHER_SCHOOL_ID}`).set({
    id: OTHER_SCHOOL_ID,
    name: "School B",
    status: "trial",
    subscriptionPlanId: "starter",
    subscriptionExpiry: Date.now(),
    metadata: {},
  });
}

async function auditLogsFor(schoolId, action) {
  const snap = await db
    .collection("super_admin_audit_logs")
    .where("schoolId", "==", schoolId)
    .where("action", "==", action)
    .get();
  return snap.docs.map((d) => d.data());
}

describe("setSchoolLifecycleStatus / updateSchoolSubscriptionPlan", () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
  });

  after(async () => {
    await clearFirestore();
  });

  // --- Authorization matrix ---

  test("Super Admin is allowed to suspend a school", async () => {
    const result = await setSchoolLifecycleStatus.run(
      request(OWNER_UID, { schoolId: SCHOOL_ID, status: "suspended", reason: "Non-payment" })
    );
    assert.equal(result.status, "suspended");
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.equal(school.data().status, "suspended");
  });

  test("School Admin is denied", async () => {
    await assert.rejects(
      () =>
        setSchoolLifecycleStatus.run(
          request(SCHOOL_ADMIN_UID, { schoolId: SCHOOL_ID, status: "suspended" })
        ),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.equal(school.data().status, "trial");
  });

  test("Normal staff is denied", async () => {
    await assert.rejects(
      () =>
        setSchoolLifecycleStatus.run(
          request(STAFF_UID, { schoolId: SCHOOL_ID, status: "suspended" })
        ),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.equal(school.data().status, "trial");
  });

  test("unauthenticated caller is denied", async () => {
    await assert.rejects(
      () => setSchoolLifecycleStatus.run(request(null, { schoolId: SCHOOL_ID, status: "suspended" })),
      (err) => {
        assert.equal(err.code, "unauthenticated");
        return true;
      }
    );
  });

  // --- Input validation ---

  test("invalid lifecycle status is denied and changes nothing", async () => {
    await assert.rejects(
      () =>
        setSchoolLifecycleStatus.run(
          request(OWNER_UID, { schoolId: SCHOOL_ID, status: "deleted" })
        ),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      }
    );
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.equal(school.data().status, "trial");
    assert.equal((await auditLogsFor(SCHOOL_ID, "UPDATE_SCHOOL_STATUS")).length, 0);
  });

  test("missing schoolId is denied", async () => {
    await assert.rejects(
      () => setSchoolLifecycleStatus.run(request(OWNER_UID, { status: "active" })),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      }
    );
  });

  test("cross-tenant/forged school target is denied", async () => {
    await assert.rejects(
      () =>
        setSchoolLifecycleStatus.run(
          request(OWNER_UID, { schoolId: FORGED_SCHOOL_ID, status: "active" })
        ),
      (err) => {
        assert.equal(err.code, "not-found");
        return true;
      }
    );
    assert.equal((await auditLogsFor(FORGED_SCHOOL_ID, "UPDATE_SCHOOL_STATUS")).length, 0);
  });

  test("an invalid subscription plan update is denied", async () => {
    await assert.rejects(
      () =>
        updateSchoolSubscriptionPlan.run(
          request(OWNER_UID, { schoolId: SCHOOL_ID, planId: "", expiry: Date.now() })
        ),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      }
    );
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.equal(school.data().subscriptionPlanId, "starter");
  });

  test("a non-numeric expiry is denied", async () => {
    await assert.rejects(
      () =>
        updateSchoolSubscriptionPlan.run(
          request(OWNER_UID, { schoolId: SCHOOL_ID, planId: "growth", expiry: "not-a-number" })
        ),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      }
    );
  });

  test("School Admin cannot change the subscription plan", async () => {
    await assert.rejects(
      () =>
        updateSchoolSubscriptionPlan.run(
          request(SCHOOL_ADMIN_UID, { schoolId: SCHOOL_ID, planId: "growth", expiry: Date.now() })
        ),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.equal(school.data().subscriptionPlanId, "starter");
  });

  // --- Audit trail integrity ---

  test("a successful status change writes exactly one immutable audit record", async () => {
    await setSchoolLifecycleStatus.run(
      request(OWNER_UID, { schoolId: SCHOOL_ID, status: "suspended", reason: "Fraud review" })
    );
    const logs = await auditLogsFor(SCHOOL_ID, "UPDATE_SCHOOL_STATUS");
    assert.equal(logs.length, 1);
    assert.equal(logs[0].ownerId, OWNER_UID);
    assert.equal(logs[0].metadata.previousStatus, "trial");
    assert.equal(logs[0].metadata.newStatus, "suspended");
  });

  test("a successful subscription change writes exactly one immutable audit record", async () => {
    const expiry = Date.now() + 30 * 24 * 60 * 60 * 1000;
    await updateSchoolSubscriptionPlan.run(
      request(OWNER_UID, { schoolId: SCHOOL_ID, planId: "growth", expiry })
    );
    const logs = await auditLogsFor(SCHOOL_ID, "UPDATE_SUBSCRIPTION");
    assert.equal(logs.length, 1);
    assert.equal(logs[0].ownerId, OWNER_UID);
    assert.equal(logs[0].metadata.previousPlanId, "starter");
    assert.equal(logs[0].metadata.planId, "growth");
    assert.equal(logs[0].metadata.expiry, expiry);
  });

  test("a denied request never writes an audit record", async () => {
    await assert.rejects(() =>
      setSchoolLifecycleStatus.run(
        request(STAFF_UID, { schoolId: SCHOOL_ID, status: "suspended" })
      )
    );
    assert.equal((await auditLogsFor(SCHOOL_ID, "UPDATE_SCHOOL_STATUS")).length, 0);
  });

  test("changing one school's status does not affect another school's document or audit trail", async () => {
    await setSchoolLifecycleStatus.run(
      request(OWNER_UID, { schoolId: SCHOOL_ID, status: "suspended" })
    );
    const other = await db.doc(`schools/${OTHER_SCHOOL_ID}`).get();
    assert.equal(other.data().status, "trial");
    assert.equal((await auditLogsFor(OTHER_SCHOOL_ID, "UPDATE_SCHOOL_STATUS")).length, 0);
  });
});
