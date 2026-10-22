// Firebase Emulator integration test for the verified parent-invitation
// callables in functions/parent_invitations.js:
//   createParentInvitation / cancelParentInvitation /
//   updateParentInvitationDetails / linkLearnersToExistingParent /
//   listParentLinkAudit / getParentAccessRecord
//
// Mirrors create_parent_access_code.emulator.test.cjs's fixtures and harness
// (firestore + auth emulators). Run via
// `npm run test:parent-invitations:emulator`.
const { after, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-parent-invitations-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });
process.env.PARENT_ACCESS_CODE_PEPPER =
  process.env.PARENT_ACCESS_CODE_PEPPER || "test-pepper-not-for-production";

const {
  createParentAccessCode,
  createParentInvitation,
  cancelParentInvitation,
  updateParentInvitationDetails,
  linkLearnersToExistingParent,
  listParentLinkAudit,
  getParentAccessRecord,
} = require("../index");

const admin = require("firebase-admin");
const db = admin.firestore();

const SCHOOL = "schoolA";
const SCHOOL_B = "schoolB";
const ADMIN_UID = "schoolAdminUid";
const REGISTRAR_UID = "registrarUid";
const NON_ADMIN_UID = "classTeacherUid";
const ADMIN_B_UID = "schoolAdminBUid";
const STUDENT_ID = "studentA";
const STUDENT_ID_2 = "studentB";

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => deleteCollectionRecursive(c)));
}
async function deleteCollectionRecursive(ref) {
  const docRefs = await ref.listDocuments();
  await Promise.all(docRefs.map(async (docRef) => {
    const subs = await docRef.listCollections();
    await Promise.all(subs.map((c) => deleteCollectionRecursive(c)));
    await docRef.delete();
  }));
}

async function seed() {
  await db.doc(`users/${ADMIN_UID}`).set({ roles: ["schoolAdmin"], schoolId: SCHOOL, schoolName: "School A" });
  await db.doc(`users/${REGISTRAR_UID}`).set({ roles: ["registrar"], schoolId: SCHOOL, schoolName: "School A" });
  await db.doc(`users/${NON_ADMIN_UID}`).set({ roles: ["classTeacher"], schoolId: SCHOOL });
  await db.doc(`users/${ADMIN_B_UID}`).set({ roles: ["schoolAdmin"], schoolId: SCHOOL_B, schoolName: "School B" });
  await db.doc(`students/${STUDENT_ID}`).set({ schoolId: SCHOOL, name: "Student A", className: "S1" });
  await db.doc(`students/${STUDENT_ID_2}`).set({ schoolId: SCHOOL, name: "Student B", className: "S2" });
  await db.doc(`schools/${SCHOOL}`).set({ name: "School A" });
  await db.doc(`schools/${SCHOOL_B}`).set({ name: "School B" });
}

// Creates a real parent record via the production path so downstream
// callables operate on realistic data.
async function makeRecord(overrides = {}) {
  const res = await createParentAccessCode.run(request(ADMIN_UID, {
    parentName: "Jane Parent",
    phoneNumber: `+2567012${String((makeRecord._n = (makeRecord._n || 0) + 1)).padStart(5, "0")}`,
    learners: [{ studentId: STUDENT_ID, relationship: "Mother" }],
    ...overrides,
  }));
  return res;
}

describe("createParentInvitation / cancelParentInvitation", () => {
  beforeEach(async () => { await clearFirestore(); await seed(); });
  after(async () => { await clearFirestore(); });

  test("a non-admin caller is rejected", async () => {
    const rec = await makeRecord();
    await assert.rejects(
      () => createParentInvitation.run(request(NON_ADMIN_UID, { inviteId: rec.inviteId })),
      (err) => { assert.equal(err.code, "permission-denied"); return true; },
    );
  });

  test("a cross-tenant inviteId is rejected with a generic not-found", async () => {
    const rec = await makeRecord();
    await assert.rejects(
      () => createParentInvitation.run(request(ADMIN_B_UID, { inviteId: rec.inviteId })),
      (err) => { assert.equal(err.code, "not-found"); return true; },
    );
  });

  test("sends a verified invitation for a record with an email and mirrors status", async () => {
    const rec = await makeRecord({ email: "a@example.com" });
    // makeRecord already sent one; wait past cooldown by forcing the mirror.
    await db.collection("parent_access_code_invites").doc(rec.inviteId)
      .set({ invitationCanResendAt: admin.firestore.Timestamp.fromMillis(Date.now() - 1000) }, { merge: true });
    // Also age the parent_invitations record so the cooldown check passes.
    const existing = await db.collection("parent_invitations").where("parentInviteId", "==", rec.inviteId).get();
    await Promise.all(existing.docs.map((d) => d.ref.set({
      createdAt: admin.firestore.Timestamp.fromMillis(Date.now() - 120000),
    }, { merge: true })));

    const res = await createParentInvitation.run(request(REGISTRAR_UID, { inviteId: rec.inviteId }));
    assert.equal(res.delivered, true);
    assert.equal(res.status, "sent");

    const invite = await db.collection("parent_access_code_invites").doc(rec.inviteId).get();
    assert.equal(invite.data().invitationStatus, "sent");

    const audit = await db.collection("audit_logs")
      .where("module", "==", "parent_access").where("action", "==", "invitation_sent").get();
    assert.ok(audit.size >= 1);
  });

  test("resending within the cooldown window is rejected with resource-exhausted", async () => {
    const rec = await makeRecord({ email: "b@example.com" });
    await assert.rejects(
      () => createParentInvitation.run(request(ADMIN_UID, { inviteId: rec.inviteId })),
      (err) => { assert.equal(err.code, "resource-exhausted"); return true; },
    );
  });

  test("a record without an email prepares a manual invitation (delivered:false)", async () => {
    const rec = await makeRecord();
    const res = await createParentInvitation.run(request(ADMIN_UID, { inviteId: rec.inviteId }));
    assert.equal(res.delivered, false);
    assert.equal(res.status, "pending_manual");
  });

  test("cancel sets the invitation status to cancelled without revoking the record", async () => {
    const rec = await makeRecord({ email: "c@example.com" });
    const res = await cancelParentInvitation.run(request(ADMIN_UID, { inviteId: rec.inviteId }));
    assert.equal(res.status, "cancelled");
    const invite = await db.collection("parent_access_code_invites").doc(rec.inviteId).get();
    assert.equal(invite.data().invitationStatus, "cancelled");
    assert.equal(invite.data().status, "active", "the code itself stays active");
  });
});

describe("updateParentInvitationDetails", () => {
  beforeEach(async () => { await clearFirestore(); await seed(); });
  after(async () => { await clearFirestore(); });

  test("registrar (not schoolAdmin) is denied", async () => {
    const rec = await makeRecord();
    await assert.rejects(
      () => updateParentInvitationDetails.run(request(REGISTRAR_UID, { inviteId: rec.inviteId, parentName: "X" })),
      (err) => { assert.equal(err.code, "permission-denied"); return true; },
    );
  });

  test("schoolAdmin updates name/phone and syncs links", async () => {
    const rec = await makeRecord();
    await updateParentInvitationDetails.run(request(ADMIN_UID, {
      inviteId: rec.inviteId, parentName: "Jane Updated", phoneNumber: "+256700111222",
    }));
    const invite = await db.collection("parent_access_code_invites").doc(rec.inviteId).get();
    assert.equal(invite.data().parentName, "Jane Updated");
    assert.equal(invite.data().phoneNumber, "+256700111222");
    const links = await db.collection("parent_learner_links").where("parentInviteId", "==", rec.inviteId).get();
    assert.ok(links.docs.every((d) => d.data().phoneNumber === "+256700111222"));
  });

  test("an invalid phone is rejected", async () => {
    const rec = await makeRecord();
    await assert.rejects(
      () => updateParentInvitationDetails.run(request(ADMIN_UID, { inviteId: rec.inviteId, phoneNumber: "12345" })),
      (err) => { assert.equal(err.code, "invalid-argument"); return true; },
    );
  });
});

describe("linkLearnersToExistingParent", () => {
  beforeEach(async () => { await clearFirestore(); await seed(); });
  after(async () => { await clearFirestore(); });

  test("adds a new learner link to an existing parent record", async () => {
    const rec = await makeRecord();
    const res = await linkLearnersToExistingParent.run(request(ADMIN_UID, {
      inviteId: rec.inviteId,
      learners: [{ studentId: STUDENT_ID_2, relationship: "Mother", isPrimaryContact: true }],
    }));
    assert.equal(res.success, true);
    assert.equal(res.links.length, 1);
    const invite = await db.collection("parent_access_code_invites").doc(rec.inviteId).get();
    assert.ok(invite.data().learnerIds.includes(STUDENT_ID_2));
  });

  test("rejects a learner already linked to this parent", async () => {
    const rec = await makeRecord();
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL, studentId: STUDENT_ID_2, parentInviteId: rec.inviteId,
      phoneNumber: (await db.collection("parent_access_code_invites").doc(rec.inviteId).get()).data().phoneNumber,
      status: "active",
    });
    await assert.rejects(
      () => linkLearnersToExistingParent.run(request(ADMIN_UID, {
        inviteId: rec.inviteId, learners: [{ studentId: STUDENT_ID_2 }],
      })),
      (err) => { assert.equal(err.code, "already-exists"); return true; },
    );
  });

  test("enforces the configurable guardian cap on the target learner", async () => {
    await db.doc(`people_policies/${SCHOOL}`).set({ maxStandardGuardians: 1 });
    const rec = await makeRecord();
    await db.collection("parent_learner_links").add({
      schoolId: SCHOOL, studentId: STUDENT_ID_2, phoneNumber: "+256700999888", status: "active",
    });
    await assert.rejects(
      () => linkLearnersToExistingParent.run(request(ADMIN_UID, {
        inviteId: rec.inviteId, learners: [{ studentId: STUDENT_ID_2 }],
      })),
      (err) => { assert.equal(err.code, "failed-precondition"); return true; },
    );
  });
});

describe("getParentAccessRecord / listParentLinkAudit", () => {
  beforeEach(async () => { await clearFirestore(); await seed(); });
  after(async () => { await clearFirestore(); });

  test("returns the record with resolved learner names", async () => {
    const rec = await makeRecord({ email: "d@example.com" });
    const out = await getParentAccessRecord.run(request(ADMIN_UID, { inviteId: rec.inviteId }));
    assert.equal(out.parentName, "Jane Parent");
    assert.equal(out.email, "d@example.com");
    assert.equal(out.learners.length, 1);
    assert.equal(out.learners[0].studentName, "Student A");
    assert.equal(out.learners[0].studentId, STUDENT_ID);
    assert.equal(typeof out.maxGuardians, "number");
  });

  test("a cross-tenant record read is denied", async () => {
    const rec = await makeRecord();
    await assert.rejects(
      () => getParentAccessRecord.run(request(ADMIN_B_UID, { inviteId: rec.inviteId })),
      (err) => { assert.equal(err.code, "not-found"); return true; },
    );
  });

  test("listParentLinkAudit returns reallocation entries for the record's learners", async () => {
    const rec = await makeRecord();
    await db.collection("parent_link_audit_log").add({
      schoolId: SCHOOL, studentId: STUDENT_ID, action: "reallocated", actorRole: "schoolAdmin",
      reason: "custody change", createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const out = await listParentLinkAudit.run(request(ADMIN_UID, { inviteId: rec.inviteId }));
    assert.equal(out.entries.length, 1);
    assert.equal(out.entries[0].action, "reallocated");
  });
});
