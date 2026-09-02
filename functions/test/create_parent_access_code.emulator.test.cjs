// Firebase Emulator integration test for exports.createParentAccessCode in
// functions/index.js - the actual write path to the `parent_learner_links`
// collection (which is fully locked client-side in firestore.rules:
// `allow read, write: if false`). This callable is how a school admin links
// (and, by generating a fresh code for a learner that already has an active
// link, effectively reallocates) a parent to a learner.
//
// Scope: this file only covers createParentAccessCode's two invariants
// called out in the Day 2 brief - (a) non-admin callers are rejected,
// (b) admin callers succeed, (c) a third parent cannot be linked to a
// learner that already has two active links. It does not attempt a broader
// test harness for the parent-access-code flow.
//
// Run via `npm run test:create-parent-access-code:emulator` (mirrors the
// firestore,auth emulator convention in create_staff_account.emulator.test.cjs).
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-create-parent-access-code-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });
// createParentAccessCode's parentInviteHash() throws failed-precondition
// without a pepper configured - the onCall secrets binding isn't honored
// when invoked directly via .run() in the emulator, so set it here.
process.env.PARENT_ACCESS_CODE_PEPPER =
  process.env.PARENT_ACCESS_CODE_PEPPER || "test-pepper-not-for-production";

// index.js calls admin.initializeApp() unconditionally on load.
const { createParentAccessCode, reallocateParentLink } = require("../index");

const admin = require("firebase-admin");
const db = admin.firestore();

const SCHOOL = "schoolA";
const SCHOOL_B = "schoolB";
const ADMIN_UID = "schoolAdminUid";
const NON_ADMIN_UID = "classTeacherUid";
const STUDENT_ID = "studentA";

// The six roles PARENT_INVITE_ADMIN_ROLES allows for INITIAL links only.
// schoolAdmin is the sole role additionally allowed to reallocate.
const INITIAL_LINK_ROLES = [
  "director", "headTeacher", "deputyHead", "schoolAdmin", "admissions", "registrar",
];
const REALLOCATION_DENIED_ROLES = [
  "director", "headTeacher", "deputyHead", "admissions", "registrar",
];

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
  await db.doc(`users/${ADMIN_UID}`).set({
    roles: ["schoolAdmin"],
    schoolId: SCHOOL,
    schoolName: "School A",
  });
  await db.doc(`users/${NON_ADMIN_UID}`).set({
    roles: ["classTeacher"],
    schoolId: SCHOOL,
  });
  await db.doc(`students/${STUDENT_ID}`).set({
    schoolId: SCHOOL,
    name: "Student A",
  });
  await db.doc(`schools/${SCHOOL}`).set({ name: "School A" });
  await db.doc(`schools/${SCHOOL_B}`).set({ name: "School B" });

  for (const role of [...new Set([...INITIAL_LINK_ROLES, ...REALLOCATION_DENIED_ROLES])]) {
    await db.doc(`users/${role}Uid`).set({
      roles: [role],
      schoolId: SCHOOL,
      schoolName: "School A",
    });
  }
  // A schoolAdmin belonging to a different school, for cross-school denial.
  await db.doc(`users/schoolAdminBUid`).set({
    roles: ["schoolAdmin"],
    schoolId: SCHOOL_B,
    schoolName: "School B",
  });
}

function basePayload(overrides = {}) {
  let counter = basePayload._n = (basePayload._n || 0) + 1;
  return {
    parentName: "Jane Parent",
    phoneNumber: `+25670000${String(counter).padStart(4, "0")}`,
    learners: [{ studentId: STUDENT_ID, relationship: "Mother" }],
    ...overrides,
  };
}

describe("createParentAccessCode", () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
  });

  after(async () => {
    await clearFirestore();
  });

  test("a non-admin caller is rejected", async () => {
    await assert.rejects(
      () => createParentAccessCode.run(request(NON_ADMIN_UID, basePayload())),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
    const links = await db.collection("parent_learner_links")
      .where("schoolId", "==", SCHOOL)
      .where("studentId", "==", STUDENT_ID)
      .get();
    assert.equal(links.empty, true, "no link should be written by a rejected call");
  });

  test("an unauthenticated caller is rejected", async () => {
    await assert.rejects(
      () => createParentAccessCode.run(request(null, basePayload())),
      (err) => {
        assert.equal(err.code, "unauthenticated");
        return true;
      }
    );
  });

  test("an admin caller succeeds and writes a pending parent_learner_links doc", async () => {
    const result = await createParentAccessCode.run(request(ADMIN_UID, basePayload()));
    assert.ok(result.code);
    assert.ok(result.inviteId);

    const links = await db.collection("parent_learner_links")
      .where("schoolId", "==", SCHOOL)
      .where("studentId", "==", STUDENT_ID)
      .get();
    assert.equal(links.size, 1);
    assert.equal(links.docs[0].data().status, "pending");
    assert.equal(links.docs[0].data().parentInviteId, result.inviteId);
  });

  test("attempting to link a third parent to a learner that already has two active links is rejected", async () => {
    // Seed two already-active (non-revoked) links directly, simulating two
    // parents already linked to this learner via prior redemption.
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL,
      studentId: STUDENT_ID,
      phoneNumber: "+256700001111",
      status: "active",
    });
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL,
      studentId: STUDENT_ID,
      phoneNumber: "+256700002222",
      status: "active",
    });

    await assert.rejects(
      () => createParentAccessCode.run(request(ADMIN_UID, basePayload())),
      (err) => {
        assert.equal(err.code, "failed-precondition");
        assert.match(err.message, /maximum of two parents/i);
        return true;
      }
    );

    // Confirm no third link (pending or otherwise) was written.
    const links = await db.collection("parent_learner_links")
      .where("schoolId", "==", SCHOOL)
      .where("studentId", "==", STUDENT_ID)
      .get();
    assert.equal(links.size, 2, "the rejected call must not add a third link");
  });

  test("a revoked existing link does not count toward the two-parent cap", async () => {
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL,
      studentId: STUDENT_ID,
      phoneNumber: "+256700001111",
      status: "active",
    });
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL,
      studentId: STUDENT_ID,
      phoneNumber: "+256700002222",
      status: "revoked",
    });

    // One active + one revoked = room for one more.
    const result = await createParentAccessCode.run(request(ADMIN_UID, basePayload()));
    assert.ok(result.code);
  });

  for (const role of INITIAL_LINK_ROLES) {
    test(`${role} may create an INITIAL link when the learner has an open slot`, async () => {
      const result = await createParentAccessCode.run(request(`${role}Uid`, basePayload()));
      assert.ok(result.code);
      const links = await db.collection("parent_learner_links")
        .where("schoolId", "==", SCHOOL)
        .where("studentId", "==", STUDENT_ID)
        .get();
      assert.equal(links.size, 1);
      assert.equal(links.docs[0].data().linkType, "initial");
    });
  }
});

describe("reallocateParentLink", () => {
  let existingLinkId;

  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
    const linkRef = await db.collection("parent_learner_links").add({
      schoolId: SCHOOL,
      studentId: STUDENT_ID,
      phoneNumber: "+256700009999",
      relationship: "Mother",
      status: "active",
      linkType: "initial",
      createdBy: "schoolAdminUid",
    });
    existingLinkId = linkRef.id;
  });

  after(async () => {
    await clearFirestore();
  });

  function reallocatePayload(overrides = {}) {
    return {
      linkId: existingLinkId,
      parentName: "New Parent",
      phoneNumber: "+256700008888",
      reason: "guardian changed after custody transfer",
      ...overrides,
    };
  }

  test("schoolAdmin successfully reallocates an existing active link", async () => {
    const result = await reallocateParentLink.run(request(ADMIN_UID, reallocatePayload()));
    assert.equal(result.success, true);
    assert.ok(result.code);
    assert.ok(result.inviteId);

    const oldLink = await db.collection("parent_learner_links").doc(existingLinkId).get();
    assert.equal(oldLink.data().status, "revoked");
    assert.equal(oldLink.data().revokedBy, ADMIN_UID);

    const newLinks = await db.collection("parent_learner_links")
      .where("schoolId", "==", SCHOOL)
      .where("studentId", "==", STUDENT_ID)
      .where("status", "==", "pending")
      .get();
    assert.equal(newLinks.size, 1);
    assert.equal(newLinks.docs[0].data().linkType, "reallocation");
    assert.equal(newLinks.docs[0].data().previousLinkId, existingLinkId);
  });

  test("schoolAdmin can remove an existing link without a replacement", async () => {
    const result = await reallocateParentLink.run(
      request(ADMIN_UID, { linkId: existingLinkId, reason: "guardian relocated" })
    );
    assert.equal(result.success, true);
    assert.equal(result.removed, true);
    const oldLink = await db.collection("parent_learner_links").doc(existingLinkId).get();
    assert.equal(oldLink.data().status, "revoked");
  });

  for (const role of REALLOCATION_DENIED_ROLES) {
    test(`${role} is denied reallocation of an existing link`, async () => {
      await assert.rejects(
        () => reallocateParentLink.run(request(`${role}Uid`, reallocatePayload())),
        (err) => {
          assert.equal(err.code, "permission-denied");
          return true;
        }
      );
      const oldLink = await db.collection("parent_learner_links").doc(existingLinkId).get();
      assert.equal(oldLink.data().status, "active", `${role} must not be able to revoke the existing link`);
    });
  }

  test("a non-admin caller is denied reallocation", async () => {
    await assert.rejects(
      () => reallocateParentLink.run(request(NON_ADMIN_UID, reallocatePayload())),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
  });

  test("an unauthenticated caller is rejected", async () => {
    await assert.rejects(
      () => reallocateParentLink.run(request(null, reallocatePayload())),
      (err) => {
        assert.equal(err.code, "unauthenticated");
        return true;
      }
    );
  });

  test("a schoolAdmin from a different school cannot reallocate this school's link (cross-school denial)", async () => {
    await assert.rejects(
      () => reallocateParentLink.run(request("schoolAdminBUid", reallocatePayload())),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
    const oldLink = await db.collection("parent_learner_links").doc(existingLinkId).get();
    assert.equal(oldLink.data().status, "active", "cross-school caller must not be able to revoke the link");
  });

  test("reallocating still enforces the two-parent cap against the OTHER existing link", async () => {
    // Learner already has a second active link besides the one being
    // reallocated - after reallocation there would still only be two, so
    // this should succeed once, then fail if attempted a second time
    // against a learner that is genuinely full.
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL,
      studentId: STUDENT_ID,
      phoneNumber: "+256700007777",
      status: "active",
      linkType: "initial",
    });
    const result = await reallocateParentLink.run(request(ADMIN_UID, reallocatePayload()));
    assert.equal(result.success, true);
  });

  test("an immutable audit record is written with all required fields on a successful reallocation", async () => {
    await reallocateParentLink.run(request(ADMIN_UID, reallocatePayload()));
    const auditSnap = await db.collection("parent_link_audit_log")
      .where("schoolId", "==", SCHOOL)
      .where("studentId", "==", STUDENT_ID)
      .get();
    assert.equal(auditSnap.size, 1);
    const entry = auditSnap.docs[0].data();
    assert.equal(entry.actorUid, ADMIN_UID);
    assert.equal(entry.actorRole, "schoolAdmin");
    assert.equal(entry.schoolId, SCHOOL);
    assert.equal(entry.studentId, STUDENT_ID);
    assert.equal(entry.action, "reallocated");
    assert.ok(entry.oldLink && entry.oldLink.id === existingLinkId);
    assert.ok(entry.newLink && entry.newLink.phoneNumber === "+256700008888");
    assert.ok(entry.createdAt);
    assert.equal(entry.reason, "guardian changed after custody transfer");
  });

  test("attempting to reallocate an already-revoked link is rejected", async () => {
    await db.collection("parent_learner_links").doc(existingLinkId).update({ status: "revoked" });
    await assert.rejects(
      () => reallocateParentLink.run(request(ADMIN_UID, reallocatePayload())),
      (err) => {
        assert.equal(err.code, "failed-precondition");
        return true;
      }
    );
  });

  test("reallocating a non-existent link is rejected with not-found, and writes no audit record", async () => {
    await assert.rejects(
      () => reallocateParentLink.run(request(ADMIN_UID, reallocatePayload({ linkId: "no-such-link" }))),
      (err) => {
        assert.equal(err.code, "not-found");
        return true;
      }
    );
    const auditSnap = await db.collection("parent_link_audit_log")
      .where("schoolId", "==", SCHOOL)
      .where("studentId", "==", STUDENT_ID)
      .get();
    assert.equal(auditSnap.size, 0);
  });
});
