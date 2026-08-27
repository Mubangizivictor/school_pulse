// Firebase Emulator integration test for the fee-plan/billing backend
// (functions/student_fee_billing.js). Run via
// `npm run test:student-fee-billing:emulator` (firebase emulators:exec
// --only firestore, same convention as test:rules/
// test:report-card-engine:emulator). Points FIRESTORE_EMULATOR_HOST at the
// emulator so the real Admin SDK's Firestore (transactions included) binds
// to it, then requires student_fee_billing.js DIRECTLY with a passthrough
// `onCall: (handler) => handler` - the same fixture enrollment_audit.test.cjs
// uses - rather than index.js's real onCall from firebase-functions/v2/https,
// whose wrapped CloudFunction object cannot be invoked directly as a plain
// function outside an actual HTTPS request. This exercises the real
// transaction logic (idempotency, balance-never-negative, compensating
// reversal) using the Admin SDK's own bypass of Firestore rules, exactly as
// the real Cloud Function does when deployed.
//
// This test is also what caught a real, previously undetected bug: the
// factory used to assign onto the bare `exports` identifier (which resolves
// to this file's own module-level exports, not something returned to the
// caller) and had no explicit `return`, so `require("./student_fee_billing")
// ({...})` always evaluated to undefined and index.js's
// `Object.assign(exports, ...)` silently no-op'd. None of these six
// functions were ever actually callable, despite compiling and passing
// static review - fixed in the same change as this test (see the comment at
// the top of student_fee_billing.js's factory).
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-student-fee-billing-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const admin = require("firebase-admin");
admin.initializeApp();
class HttpsError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}
const functions = require("../student_fee_billing")({
  admin,
  onCall: (handler) => handler,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const BURSAR_UID = "bursarUid";
const REGISTRAR_UID = "registrarUid";
const OTHER_STAFF_UID = "randomStaffUid";
const STUDENT_ID = "studentA";

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

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function seedBaseFixtures() {
  await db.doc(`users/${BURSAR_UID}`).set({ roles: ["bursar"], schoolId: SCHOOL });
  await db.doc(`users/${REGISTRAR_UID}`).set({ roles: ["registrar"], schoolId: SCHOOL });
  await db.doc(`users/${OTHER_STAFF_UID}`).set({ roles: ["classTeacher"], schoolId: SCHOOL });
  await db.doc(`students/${STUDENT_ID}`).set({ schoolId: SCHOOL, classId: "classA" });
}

async function publishAndIssueBill() {
  const publish = await functions.publishFeePlan(
    request(BURSAR_UID, {
      schoolId: SCHOOL, academicYearId: "year1", termId: "term1", classId: "classA",
      studentCategory: "day", name: "Term 1 Fees",
      lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 500000 }],
    })
  );
  const bill = await functions.issueStudentBill(
    request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, planId: publish.planId })
  );
  return { planId: publish.planId, billId: bill.billId };
}

describe("student_fee_billing: publish/match/issue (Phase 1 regression)", () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
  });

  test("issueStudentBill is idempotent: a second call with the same idempotencyKey is a no-op, never a duplicate bill", async () => {
    const { planId } = await (async () => {
      const publish = await functions.publishFeePlan(
        request(BURSAR_UID, {
          schoolId: SCHOOL, academicYearId: "year1", termId: "term1", classId: "classA",
          studentCategory: "day", name: "Term 1 Fees",
          lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 500000 }],
        })
      );
      return publish;
    })();

    const first = await functions.issueStudentBill(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, planId, idempotencyKey: "fixed-key" })
    );
    const second = await functions.issueStudentBill(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, planId, idempotencyKey: "fixed-key" })
    );
    assert.equal(first.billId, second.billId);

    const billsSnap = await db.collection(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills`).get();
    assert.equal(billsSnap.size, 1, "a retried issueStudentBill call must never create a second bill doc");
  });

  test("publishFeePlan refuses to edit a published plan without createNewVersion, and bumps the version when it is set", async () => {
    const publish = await functions.publishFeePlan(
      request(BURSAR_UID, {
        schoolId: SCHOOL, academicYearId: "year1", termId: "term1", classId: "classA",
        studentCategory: "day", name: "Term 1 Fees",
        lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 500000 }],
      })
    );

    await assert.rejects(
      functions.publishFeePlan(
        request(BURSAR_UID, {
          schoolId: SCHOOL, planId: publish.planId, academicYearId: "year1", termId: "term1",
          classId: "classA", studentCategory: "day", name: "Term 1 Fees (edited)",
          lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 999999 }],
        })
      ),
      /immutable/i
    );

    const versioned = await functions.publishFeePlan(
      request(BURSAR_UID, {
        schoolId: SCHOOL, planId: publish.planId, academicYearId: "year1", termId: "term1",
        classId: "classA", studentCategory: "day", name: "Term 1 Fees v2",
        lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 600000 }],
        createNewVersion: true,
      })
    );
    assert.notEqual(versioned.versionId, publish.versionId);

    // The original version's snapshot must never change.
    const originalVersion = await db.doc(`schools/${SCHOOL}/fee_plans/${publish.planId}/versions/${publish.versionId}`).get();
    assert.equal(originalVersion.data().lines[0].amountUgx, 500000);
  });

  test("registrar/admissions may issue a bill but may not apply an adjustment or record a payment (callerForFinance is narrower than callerForSchool)", async () => {
    const { planId } = await publishAndIssueBillAsRegistrar();

    async function publishAndIssueBillAsRegistrar() {
      const publish = await functions.publishFeePlan(
        request(REGISTRAR_UID, {
          schoolId: SCHOOL, academicYearId: "year1", termId: "term1", classId: "classA",
          studentCategory: "day", name: "Term 1 Fees",
          lines: [{ chargeId: "tuition", name: "Tuition", amountUgx: 500000 }],
        })
      );
      return publish;
    }
    assert.ok(planId);

    const bill = await functions.issueStudentBill(
      request(REGISTRAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, planId })
    );

    await assert.rejects(
      functions.applyBillAdjustment(
        request(REGISTRAR_UID, {
          schoolId: SCHOOL, studentId: STUDENT_ID, billId: bill.billId,
          type: "discount", amountUgx: 10000, reason: "attempt",
        })
      ),
      /finance leadership/i
    );
    await assert.rejects(
      functions.recordStudentPayment(
        request(REGISTRAR_UID, {
          schoolId: SCHOOL, studentId: STUDENT_ID, billId: bill.billId,
          method: "cash", amountUgx: 10000,
        })
      ),
      /finance leadership/i
    );
  });
});

describe("student_fee_billing: adjustments, payments, reversals (Phase 2)", () => {
  let billId;

  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
    const result = await publishAndIssueBill();
    billId = result.billId;
  });

  test("a non-finance staff member cannot apply an adjustment or record a payment", async () => {
    await assert.rejects(
      functions.applyBillAdjustment(
        request(OTHER_STAFF_UID, {
          schoolId: SCHOOL, studentId: STUDENT_ID, billId, type: "discount",
          amountUgx: 10000, reason: "attempt",
        })
      ),
      /finance leadership/i
    );
    await assert.rejects(
      functions.recordStudentPayment(
        request(OTHER_STAFF_UID, {
          schoolId: SCHOOL, studentId: STUDENT_ID, billId, method: "cash", amountUgx: 10000,
        })
      ),
      /finance leadership/i
    );
  });

  test("applyBillAdjustment captures approverId from the caller's auth uid, never from the client payload", async () => {
    const result = await functions.applyBillAdjustment(
      request(BURSAR_UID, {
        schoolId: SCHOOL, studentId: STUDENT_ID, billId, type: "discount",
        amountUgx: 50000, reason: "sibling discount", approverId: "someone-else-entirely",
      })
    );
    const adjustment = await db
      .doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}/adjustments/${result.adjustmentId}`)
      .get();
    assert.equal(adjustment.data().approverId, BURSAR_UID);

    const bill = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}`).get();
    assert.equal(bill.data().adjustmentTotalUgx, 50000);
    assert.equal(bill.data().balanceUgx, 450000);
  });

  test("an adjustment that would drive the balance below zero is rejected, not silently clamped", async () => {
    await assert.rejects(
      functions.applyBillAdjustment(
        request(BURSAR_UID, {
          schoolId: SCHOOL, studentId: STUDENT_ID, billId, type: "waiver",
          amountUgx: 600000, reason: "too much",
        })
      ),
      /below zero/i
    );
    const bill = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}`).get();
    assert.equal(bill.data().adjustmentTotalUgx, 0, "a rejected adjustment must not partially apply");
  });

  test("recordStudentPayment generates a server-side receiptNumber and updates paidTotalUgx/balanceUgx atomically", async () => {
    const payment = await functions.recordStudentPayment(
      request(BURSAR_UID, {
        schoolId: SCHOOL, studentId: STUDENT_ID, billId, method: "cash", amountUgx: 200000,
        receiptNumber: "CLIENT-FORGED-0001",
      })
    );
    assert.notEqual(payment.receiptNumber, "CLIENT-FORGED-0001", "receiptNumber must never come from the client");
    assert.match(payment.receiptNumber, /^RCT-\d{6}$/);

    const bill = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}`).get();
    assert.equal(bill.data().paidTotalUgx, 200000);
    assert.equal(bill.data().balanceUgx, 300000);
    assert.equal(bill.data().status, "open");
  });

  test("a payment that exceeds the remaining balance is rejected", async () => {
    await assert.rejects(
      functions.recordStudentPayment(
        request(BURSAR_UID, {
          schoolId: SCHOOL, studentId: STUDENT_ID, billId, method: "cash", amountUgx: 999999,
        })
      ),
      /exceeds/i
    );
  });

  test("a fully-paid bill flips status to 'paid'", async () => {
    await functions.recordStudentPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, billId, method: "cash", amountUgx: 500000 })
    );
    const bill = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}`).get();
    assert.equal(bill.data().status, "paid");
    assert.equal(bill.data().balanceUgx, 0);
  });

  test("reverseStudentPayment writes a compensating record and never mutates the original payment's money fields", async () => {
    const payment = await functions.recordStudentPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, billId, method: "cash", amountUgx: 200000 })
    );

    const reversal = await functions.reverseStudentPayment(
      request(BURSAR_UID, {
        schoolId: SCHOOL, studentId: STUDENT_ID, billId, paymentId: payment.paymentId,
        reason: "recorded in error",
      })
    );

    const originalDoc = await db
      .doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}/payments/${payment.paymentId}`)
      .get();
    assert.equal(originalDoc.data().amountUgx, 200000, "the original payment's amount must never change");
    assert.equal(originalDoc.data().reversalPaymentId, reversal.reversalPaymentId);

    const reversalDoc = await db
      .doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}/payments/${reversal.reversalPaymentId}`)
      .get();
    assert.equal(reversalDoc.data().amountUgx, -200000);
    assert.equal(reversalDoc.data().reversalOfPaymentId, payment.paymentId);

    const bill = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/${billId}`).get();
    assert.equal(bill.data().paidTotalUgx, 0);
    assert.equal(bill.data().balanceUgx, 500000);
  });

  test("a payment cannot be reversed twice", async () => {
    const payment = await functions.recordStudentPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, billId, method: "cash", amountUgx: 100000 })
    );
    await functions.reverseStudentPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, billId, paymentId: payment.paymentId, reason: "first reversal" })
    );
    await assert.rejects(
      functions.reverseStudentPayment(
        request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, billId, paymentId: payment.paymentId, reason: "second attempt" })
      ),
      /already been reversed/i
    );
  });
});

after(async () => {
  await clearFirestore();
});
