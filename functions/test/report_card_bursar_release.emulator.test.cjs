// Firebase Emulator integration test for Bursar-controlled financial access
// on canonical report cards. Run with:
// npm run test:report-card-bursar:emulator
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-report-card-bursar-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const functions = require("../index.js");
const admin = require("firebase-admin");

const db = admin.firestore();
const SCHOOL_A = "schoolA";
const SCHOOL_B = "schoolB";

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

async function seedUser(uid, { schoolId, roles }) {
  await db.collection("users").doc(uid).set({ schoolId, roles, name: uid });
}

async function seedReportCard(id, { schoolId = SCHOOL_A, isFinalized = true, financialAccessStatus = "held", version = 1 } = {}) {
  await db.collection("schools").doc(schoolId).collection("reportCards").doc(id).set({
    schoolId, studentId: "studentA", studentName: "Student A", academicYearId: "2026",
    termId: "t2", classId: "p7", version, sourceHash: "hash1", isFinalized, financialAccessStatus,
  });
}

function authFor(uid) {
  return { uid, token: {} };
}

async function getCard(schoolId, id) {
  const snap = await db.collection("schools").doc(schoolId).collection("reportCards").doc(id).get();
  return snap.data();
}

before(async () => {
  await clearFirestore();
});

beforeEach(async () => {
  await clearFirestore();
  await Promise.all([
    seedUser("bursarA", { schoolId: SCHOOL_A, roles: ["bursar"] }),
    seedUser("deanA", { schoolId: SCHOOL_A, roles: ["deanOfStudies"] }),
    seedUser("bursarB", { schoolId: SCHOOL_B, roles: ["bursar"] }),
  ]);
});

after(async () => {
  await clearFirestore();
});

describe("Bursar-controlled financial access - emulator scenario", { concurrency: 1 }, () => {
  test("the Bursar can release a finalized report, with a reason, producing an audit record", async () => {
    await seedReportCard("rc1");
    const result = await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1"], action: "release", reason: "Fees cleared" },
      auth: authFor("bursarA"),
    });
    assert.deepEqual(result.succeeded, ["rc1"]);
    const card = await getCard(SCHOOL_A, "rc1");
    assert.equal(card.financialAccessStatus, "released");
    assert.equal(card.financialAccessReason, "Fees cleared");

    const auditSnap = await db
      .collection("schools").doc(SCHOOL_A).collection("reportCards").doc("rc1")
      .collection("auditLog").get();
    assert.equal(auditSnap.size, 1);
    assert.equal(auditSnap.docs[0].data().action, "financial_access.release");
  });

  test("a reason is required for every release action", async () => {
    await seedReportCard("rc1");
    await assert.rejects(
      functions.setReportCardFinancialAccess.run({
        data: { reportCardIds: ["rc1"], action: "release", reason: "  " },
        auth: authFor("bursarA"),
      })
    );
  });

  test("only an academically finalized report may have its financial access changed", async () => {
    await seedReportCard("rc1", { isFinalized: false });
    const result = await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1"], action: "release", reason: "Fees cleared" },
      auth: authFor("bursarA"),
    });
    assert.deepEqual(result.succeeded, []);
    assert.equal(result.failed.length, 1);
    const card = await getCard(SCHOOL_A, "rc1");
    assert.equal(card.financialAccessStatus, "held", "must remain unchanged");
  });

  test("the Dean cannot control financial access - only the Bursar/admin roles may", async () => {
    await seedReportCard("rc1");
    await assert.rejects(
      functions.setReportCardFinancialAccess.run({
        data: { reportCardIds: ["rc1"], action: "release", reason: "Fees cleared" },
        auth: authFor("deanA"),
      })
    );
  });

  test("another school's Bursar cannot act on this school's report - tenant isolation", async () => {
    await seedReportCard("rc1");
    // setReportCardFinancialAccess is a bulk operation: bursarB's own
    // schoolId scopes the ref they can even construct, so this surfaces as
    // a per-report "not found" failure, not a thrown error - the same
    // partial-failure contract every bulk report-card function uses.
    const result = await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1"], action: "release", reason: "Fees cleared" },
      auth: authFor("bursarB"),
    });
    assert.deepEqual(result.succeeded, []);
    assert.equal(result.failed.length, 1);
    const card = await getCard(SCHOOL_A, "rc1");
    assert.equal(card.financialAccessStatus, "held", "schoolA's report must be untouched");
  });

  test("revoking a released report blocks future access again", async () => {
    await seedReportCard("rc1", { financialAccessStatus: "released" });
    const result = await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1"], action: "revoke", reason: "Fee balance re-opened" },
      auth: authFor("bursarA"),
    });
    assert.deepEqual(result.succeeded, ["rc1"]);
    const card = await getCard(SCHOOL_A, "rc1");
    assert.equal(card.financialAccessStatus, "revoked");
  });

  test("bulk release reports per-report failures without blocking the rest of the batch", async () => {
    await seedReportCard("rc1");
    await seedReportCard("rc2", { isFinalized: false });
    const result = await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1", "rc2"], action: "release", reason: "Term-end release" },
      auth: authFor("bursarA"),
    });
    assert.deepEqual(result.succeeded, ["rc1"]);
    assert.equal(result.failed.length, 1);
    assert.equal(result.failed[0].reportCardId, "rc2");
  });

  test("academicStatus/isFinalized are never touched by a financial-access action", async () => {
    await seedReportCard("rc1");
    const before1 = await getCard(SCHOOL_A, "rc1");
    await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1"], action: "release", reason: "Fees cleared" },
      auth: authFor("bursarA"),
    });
    const after1 = await getCard(SCHOOL_A, "rc1");
    assert.equal(after1.isFinalized, before1.isFinalized);
    assert.equal(after1.version, before1.version);
    assert.equal(after1.sourceHash, before1.sourceHash);
  });
});
