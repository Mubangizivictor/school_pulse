// Firebase Emulator integration test for the structured Report Card
// Financial Clearance & Bursar Release-exception layer
// (functions/report_card_release.js + report_card_financial_gate.js).
//
// Run with:  npm run test:report-card-release-exceptions:emulator
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-report-card-release-exceptions-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const functions = require("../index.js");
const admin = require("firebase-admin");

const db = admin.firestore();
const SCHOOL_A = "schoolA";
const SCHOOL_B = "schoolB";
const YEAR = "2026";
const TERM = "t2";

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
    }),
  );
}

const authFor = (uid) => ({ uid, token: {} });

async function seedUser(uid, { schoolId, roles }) {
  await db.collection("users").doc(uid).set({ schoolId, roles, name: uid });
}

async function seedStudent(
  studentId = "studentA",
  { schoolId = SCHOOL_A, name = "Student A" } = {},
) {
  await db
    .doc(`schools/${schoolId}/students/${studentId}`)
    .set({ schoolId, fullName: name });
}

async function seedParent(uid, studentId, { schoolId = SCHOOL_A } = {}) {
  await db
    .collection("users")
    .doc(uid)
    .set({ schoolId, roles: ["parent"], name: uid, studentIds: [studentId] });
}

async function seedReportCard(
  id,
  {
    schoolId = SCHOOL_A,
    studentId = "studentA",
    isFinalized = true,
    financialAccessStatus = "held",
    financialAccessSource = "auto",
    version = 1,
  } = {},
) {
  await db
    .doc(`schools/${schoolId}/reportCards/${id}`)
    .set({
      schoolId,
      studentId,
      studentName: "Student A",
      academicYearId: YEAR,
      termId: TERM,
      classId: "p7",
      version,
      isFinalized,
      financialAccessStatus,
      financialAccessSource,
    });
}

async function seedBill(
  billId,
  {
    schoolId = SCHOOL_A,
    studentId = "studentA",
    balanceUgx = 0,
    paidTotalUgx = 0,
    lines = [{ chargeId: "tuition", name: "Tuition", amountUgx: 100000, required: true }],
  } = {},
) {
  await db
    .doc(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}`)
    .set({
      schoolId,
      studentId,
      academicYearId: YEAR,
      termId: TERM,
      classId: "p7",
      balanceUgx,
      paidTotalUgx,
      adjustmentTotalUgx: 0,
      issuedTotalUgx: paidTotalUgx + Math.max(0, balanceUgx),
      lines,
      status: balanceUgx <= 0 ? "paid" : "open",
    });
}

async function setPolicy(financialClearance, { schoolId = SCHOOL_A } = {}) {
  await db
    .doc(`schools/${schoolId}/configs/reportReleasePolicy`)
    .set({ financialClearance }, { merge: true });
}

const getCard = async (id, schoolId = SCHOOL_A) =>
  (await db.doc(`schools/${schoolId}/reportCards/${id}`).get()).data();
const getException = async (id, schoolId = SCHOOL_A) =>
  (await db
    .doc(`schools/${schoolId}/reportCardReleaseExceptions/${id}`)
    .get()).data();

before(async () => {
  await clearFirestore();
});
beforeEach(async () => {
  await clearFirestore();
  await Promise.all([
    seedUser("bursarA", { schoolId: SCHOOL_A, roles: ["bursar"] }),
    seedUser("headA", { schoolId: SCHOOL_A, roles: ["headTeacher"] }),
    seedUser("directorA", { schoolId: SCHOOL_A, roles: ["director"] }),
    seedUser("teacherA", { schoolId: SCHOOL_A, roles: ["classTeacher"] }),
    seedUser("bursarB", { schoolId: SCHOOL_B, roles: ["bursar"] }),
  ]);
  await seedStudent();
});
after(async () => {
  await clearFirestore();
});

describe("Report card release exceptions - emulator", { concurrency: 1 }, () => {
  test("full payment: gate auto-releases finalized report", async () => {
    await seedBill("b1", { balanceUgx: 0, paidTotalUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    // simulate the finalization/payment hook
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");
  });

  test("partial payment: report stays held under default full-balance policy", async () => {
    await seedBill("b1", { balanceUgx: 40000, paidTotalUgx: 60000 });
    await seedReportCard("rc1");
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");
  });

  test("minimum-percentage policy: 60% paid clears at a 50% threshold", async () => {
    await setPolicy({ mode: "minimumPercentage", minimumPercentagePaid: 50 });
    await seedBill("b1", { balanceUgx: 40000, paidTotalUgx: 60000 });
    await seedReportCard("rc1");
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");
  });

  test("minimum-percentage policy: 40% paid stays held at a 50% threshold", async () => {
    await setPolicy({ mode: "minimumPercentage", minimumPercentagePaid: 50 });
    await seedBill("b1", { balanceUgx: 60000, paidTotalUgx: 40000 });
    await seedReportCard("rc1");
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");
  });

  test("selected-categories policy: unpaid non-selected category does not block", async () => {
    await setPolicy({ mode: "selectedCategories", feeCategoryIds: ["tuition"] });
    await seedBill("tuition-bill", {
      balanceUgx: 0,
      paidTotalUgx: 100000,
      lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 100000, required: true }],
    });
    await seedBill("bus-bill", {
      balanceUgx: 50000,
      paidTotalUgx: 0,
      lines: [{ chargeId: "transport", name: "Bus", amountUgx: 50000, required: false }],
    });
    await seedReportCard("rc1");
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");
  });

  test("no bill for the period is never treated as cleared", async () => {
    await seedReportCard("rc1");
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");
  });

  test("grant exception: withheld report flips to released via an exception", async () => {
    await seedBill("b1", { balanceUgx: 100000, paidTotalUgx: 0 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const res = await functions.grantReportCardReleaseException.run({
      data: {
        studentId: "studentA",
        academicYearId: YEAR,
        termId: TERM,
        reasonCode: "paymentPlan",
        clientRequestId: "req-1",
      },
      auth: authFor("bursarA"),
    });
    assert.equal(res.status, "active");
    assert.equal(res.outstandingBalanceUgxAtRelease, 100000);
    const card = await getCard("rc1");
    assert.equal(card.financialAccessStatus, "released");
    assert.equal(card.financialAccessSource, "exception");
    assert.equal(card.activeExceptionId, res.exceptionId);
    const exc = await getException(res.exceptionId);
    assert.equal(exc.outstandingBalanceUgxAtRelease, 100000);
    assert.equal(exc.auditTrail.length, 1);
    assert.equal(exc.auditTrail[0].action, "grant");
  });

  test("a report finalized AFTER an exception exists is materialised on the finalize hook", async () => {
    await seedBill("b1", { balanceUgx: 100000, paidTotalUgx: 0 });
    // No finalized report yet - grant covers the period ahead of time.
    await seedStudent(); // ensure student doc
    const grant = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "scholarship", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    assert.equal(grant.status, "active");

    // Now the report is finalized - simulate the finalize hook.
    await seedReportCard("rcLate", { financialAccessStatus: "held" });
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A, studentId: "studentA", academicYearId: YEAR, termId: TERM,
    });
    const card = await getCard("rcLate");
    assert.equal(card.financialAccessStatus, "released");
    assert.equal(card.financialAccessSource, "exception");
    assert.equal(card.activeExceptionId, grant.exceptionId);
  });

  test("grant exception is idempotent on clientRequestId", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1");
    const data = {
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
      reasonCode: "hardship",
      clientRequestId: "dup-req",
    };
    const a = await functions.grantReportCardReleaseException.run({ data, auth: authFor("bursarA") });
    const b = await functions.grantReportCardReleaseException.run({ data, auth: authFor("bursarA") });
    assert.equal(a.exceptionId, b.exceptionId);
    const snap = await db
      .collection(`schools/${SCHOOL_A}/reportCardReleaseExceptions`)
      .get();
    assert.equal(snap.size, 1);
  });

  test("duplicate active exception for the same period is rejected", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1");
    await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    await assert.rejects(
      functions.grantReportCardReleaseException.run({
        data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship", clientRequestId: "r2" },
        auth: authFor("bursarA"),
      }),
      /already exists/i,
    );
  });

  test("a class teacher may not grant an exception", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1");
    await assert.rejects(
      functions.grantReportCardReleaseException.run({
        data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship" },
        auth: authFor("teacherA"),
      }),
      /Only the Bursar/i,
    );
  });

  test("cross-school: bursar of school B cannot grant for a school A learner", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1");
    await assert.rejects(
      functions.grantReportCardReleaseException.run({
        data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship" },
        auth: authFor("bursarB"),
      }),
      /not found in your school/i,
    );
  });

  test("second-approver: above threshold ⇒ pendingApproval, no access; director approves ⇒ active + released", async () => {
    await setPolicy({
      secondApproverRequired: true,
      secondApproverArrearsThresholdUgx: 500000,
      secondApproverRoles: ["headTeacher", "director"],
    });
    await seedBill("b1", { balanceUgx: 1000000, paidTotalUgx: 0 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const res = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "managementInstruction", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    assert.equal(res.status, "pendingApproval");
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");

    // The creator cannot approve their own (bursar isn't an approver anyway).
    await assert.rejects(
      functions.approveReportCardReleaseException.run({
        data: { exceptionId: res.exceptionId },
        auth: authFor("bursarA"),
      }),
      /not authorised/i,
    );

    await functions.approveReportCardReleaseException.run({
      data: { exceptionId: res.exceptionId, note: "Approved by management" },
      auth: authFor("directorA"),
    });
    const exc = await getException(res.exceptionId);
    assert.equal(exc.status, "active");
    assert.equal(exc.authorisedByUid, "directorA");
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");
  });

  test("revoke after consumption still succeeds and re-gates the report", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const res = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");

    // parent consumes it
    await seedParent("parentA", "studentA");
    await functions.recordReportCardParentView.run({
      data: { reportCardId: "rc1" },
      auth: authFor("parentA"),
    });
    assert.ok((await getException(res.exceptionId)).consumedAt);

    await functions.revokeReportCardReleaseException.run({
      data: { exceptionId: res.exceptionId, reason: "Plan defaulted" },
      auth: authFor("bursarA"),
    });
    assert.equal((await getException(res.exceptionId)).status, "revoked");
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");
  });

  test("expiry sweep expires a lapsed exception and re-gates the report", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const res = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "paymentPlan", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    // force the expiry into the past
    await db
      .doc(`schools/${SCHOOL_A}/reportCardReleaseExceptions/${res.exceptionId}`)
      .update({ expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() - 1000) });

    await functions.expireLapsedReportCardExceptions.run({});
    assert.equal((await getException(res.exceptionId)).status, "expired");
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");
  });

  test("renew creates a new record and supersedes the old one", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const first = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "paymentPlan", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    await db
      .doc(`schools/${SCHOOL_A}/reportCardReleaseExceptions/${first.exceptionId}`)
      .update({ status: "expired" });

    const renewed = await functions.renewReportCardReleaseException.run({
      data: {
        exceptionId: first.exceptionId,
        newExpiresAt: Date.now() + 30 * 24 * 3600 * 1000,
        clientRequestId: "r2",
      },
      auth: authFor("bursarA"),
    });
    assert.notEqual(renewed.exceptionId, first.exceptionId);
    assert.equal(renewed.status, "active");
    const oldExc = await getException(first.exceptionId);
    assert.equal(oldExc.supersededByExceptionId, renewed.exceptionId);
    const newExc = await getException(renewed.exceptionId);
    assert.equal(newExc.renewedFromExceptionId, first.exceptionId);
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");
  });

  test("eligibility report classifies each report row", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const before = await functions.getReportCardReleaseEligibility.run({
      data: { academicYearId: YEAR, termId: TERM },
      auth: authFor("bursarA"),
    });
    assert.equal(before.rows.length, 1);
    assert.equal(before.rows[0].uiStatus, "withheldForFees");
    assert.equal(before.rows[0].balanceUgx, 100000);

    await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    const after = await functions.getReportCardReleaseEligibility.run({
      data: { academicYearId: YEAR, termId: TERM },
      auth: authFor("bursarA"),
    });
    assert.equal(after.rows[0].uiStatus, "exceptionActive");
    assert.equal(after.rows[0].exception.reasonCode, "hardship");
  });

  test("flat Bursar override is never overwritten by the auto gate", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    await functions.setReportCardFinancialAccess.run({
      data: { reportCardIds: ["rc1"], action: "release", reason: "Management instruction" },
      auth: authFor("bursarA"),
    });
    assert.equal((await getCard("rc1")).financialAccessSource, "bursar");
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A,
      studentId: "studentA",
      academicYearId: YEAR,
      termId: TERM,
    });
    const card = await getCard("rc1");
    assert.equal(card.financialAccessStatus, "released");
    assert.equal(card.financialAccessSource, "bursar");
  });

  test("recordReportCardParentView refuses to log access the rules would deny", async () => {
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    await seedParent("parentA", "studentA");
    const res = await functions.recordReportCardParentView.run({
      data: { reportCardId: "rc1" },
      auth: authFor("parentA"),
    });
    assert.equal(res.recorded, false);
  });

  test("saveReportCardClearancePolicy re-materialises finalized reports and audits with an effective timestamp", async () => {
    // 60% paid, released under a lenient 50% policy.
    await setPolicy({ mode: "minimumPercentage", minimumPercentagePaid: 50 });
    await seedBill("b1", { balanceUgx: 40000, paidTotalUgx: 60000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const gate = require("../report_card_financial_gate.js")({ admin });
    await gate.maybeAutoUpdateReportCardFinancialAccess({
      schoolId: SCHOOL_A, studentId: "studentA", academicYearId: YEAR, termId: TERM,
    });
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");

    // Tighten to 80% - the same report must drop back to held.
    const res = await functions.saveReportCardClearancePolicy.run({
      data: { financialClearance: { mode: "minimumPercentage", minimumPercentagePaid: 80 } },
      auth: authFor("bursarA"),
    });
    assert.ok(res.reMaterialisedPeriods >= 1);
    assert.equal((await getCard("rc1")).financialAccessStatus, "held");
    const cfg = (await db.doc(`schools/${SCHOOL_A}/configs/reportReleasePolicy`).get()).data();
    assert.ok(cfg.financialClearanceEffectiveFrom);
    assert.equal(cfg.financialClearanceUpdatedByName, "bursarA");
    assert.equal(cfg.financialClearance.minimumPercentagePaid, 80);
  });

  test("policy save never mutates a historical exception snapshot", async () => {
    await seedBill("b1", { balanceUgx: 100000, paidTotalUgx: 0 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const grant = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "hardship", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    const before = await getException(grant.exceptionId);
    await functions.saveReportCardClearancePolicy.run({
      data: { financialClearance: { mode: "fullBalance", compulsoryOnly: false } },
      auth: authFor("directorA"),
    });
    const after = await getException(grant.exceptionId);
    assert.equal(after.outstandingBalanceUgxAtRelease, before.outstandingBalanceUgxAtRelease);
    assert.equal(after.clearancePolicyModeAtRelease, before.clearancePolicyModeAtRelease);
    assert.equal(after.status, "active"); // still covers the report
    assert.equal((await getCard("rc1")).financialAccessStatus, "released");
  });

  test("saveReportCardClearancePolicy rejects an unauthorised role", async () => {
    await assert.rejects(
      functions.saveReportCardClearancePolicy.run({
        data: { financialClearance: { mode: "fullBalance" } },
        auth: authFor("teacherA"),
      }),
      /not authorised/i,
    );
  });

  test("saveReportCardClearancePolicy validates mode-specific fields", async () => {
    await assert.rejects(
      functions.saveReportCardClearancePolicy.run({
        data: { financialClearance: { mode: "minimumPercentage", minimumPercentagePaid: 0 } },
        auth: authFor("bursarA"),
      }),
      /greater than 0/i,
    );
    await assert.rejects(
      functions.saveReportCardClearancePolicy.run({
        data: { financialClearance: { mode: "selectedCategories", feeCategoryIds: [] } },
        auth: authFor("bursarA"),
      }),
      /at least one fee category/i,
    );
  });

  test("getReportCardClearancePolicy returns defaults + meta for the editor", async () => {
    const res = await functions.getReportCardClearancePolicy.run({
      data: {}, auth: authFor("bursarA"),
    });
    assert.equal(res.policy.mode, "fullBalance");
    assert.equal(res.meta.configured, false);
    await functions.saveReportCardClearancePolicy.run({
      data: { financialClearance: { mode: "fullBalance", restrictionMessage: "See bursar." } },
      auth: authFor("bursarA"),
    });
    const res2 = await functions.getReportCardClearancePolicy.run({
      data: {}, auth: authFor("bursarA"),
    });
    assert.equal(res2.meta.configured, true);
    assert.equal(res2.meta.updatedByName, "bursarA");
    assert.ok(res2.meta.effectiveFrom);
  });

  test("getReportCardExceptionHistory returns report audit + every covering exception", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    const g = await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "paymentPlan", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    await functions.revokeReportCardReleaseException.run({
      data: { exceptionId: g.exceptionId, reason: "Plan cancelled" },
      auth: authFor("bursarA"),
    });
    const hist = await functions.getReportCardExceptionHistory.run({
      data: { reportCardId: "rc1" }, auth: authFor("headA"),
    });
    assert.ok(hist.reportAudit.length >= 1);
    assert.equal(hist.exceptions.length, 1);
    assert.equal(hist.exceptions[0].status, "revoked");
    assert.ok(hist.exceptions[0].auditTrail.some((a) => a.action === "grant"));
    assert.ok(hist.exceptions[0].auditTrail.some((a) => a.action === "revoke"));
    // redaction: no raw uid fields
    assert.equal(hist.exceptions[0].createdByUid, undefined);
  });

  test("getReportCardReleaseEligibility rows carry period + redacted exception audit", async () => {
    await seedBill("b1", { balanceUgx: 100000 });
    await seedReportCard("rc1", { financialAccessStatus: "held" });
    await functions.grantReportCardReleaseException.run({
      data: { studentId: "studentA", academicYearId: YEAR, termId: TERM, reasonCode: "scholarship", clientRequestId: "r1" },
      auth: authFor("bursarA"),
    });
    const res = await functions.getReportCardReleaseEligibility.run({
      data: { academicYearId: YEAR, termId: TERM }, auth: authFor("bursarA"),
    });
    const row = res.rows[0];
    assert.equal(row.academicYearId, YEAR);
    assert.equal(row.termId, TERM);
    assert.equal(row.exception.reasonCode, "scholarship");
    assert.ok(Array.isArray(row.exception.auditTrail));
    assert.equal(row.exception.auditTrail[0].action, "grant");
  });
});
