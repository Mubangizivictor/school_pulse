// Firebase Emulator integration test for the Parent Payments backend
// (functions/payment_codes.js). Run via
// `npm run test:payment-codes:emulator` (firebase emulators:exec --only
// firestore, same convention as test:student-fee-billing:emulator). Requires
// payment_codes.js DIRECTLY with a passthrough `onCall: (handler) =>
// handler`, exercising the real transaction/read logic via the Admin SDK's
// own bypass of Firestore rules, exactly as the deployed Cloud Function does.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-payment-codes-test";
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
const functions = require("../payment_codes")({
  admin,
  onCall: (handler) => handler,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const SCHOOL_B = "schoolB";
const BURSAR_UID = "bursarUid";
const OTHER_STAFF_UID = "randomStaffUid";
const STUDENT_ID = "studentA";
const STUDENT_2_ID = "studentB";

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
  await db.doc(`users/${OTHER_STAFF_UID}`).set({ roles: ["classTeacher"], schoolId: SCHOOL });
  await db.doc(`schools/${SCHOOL}`).set({ name: "Victoria High School" });
  await db.doc(`schools/${SCHOOL_B}`).set({ name: "Beta School" });
}

describe("payment_codes: generateStudentPaymentCode / trigger core", () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
  });

  test("generates a unique {PREFIX}-P{7 chars} code and writes it onto student_accounts", async () => {
    const result = await functions.generateStudentPaymentCode(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID })
    );
    assert.match(result.paymentCode, /^VHS-P[23456789ABCDEFGHJKMNPQRSTUVWXYZ]{7}$/);

    const accountSnap = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}`).get();
    assert.equal(accountSnap.data().paymentCode, result.paymentCode);
    assert.ok(accountSnap.data().paymentCodeGeneratedAt);
    assert.equal(accountSnap.data().paymentCodeGeneratedBy, BURSAR_UID);
  });

  test("a second call for the same student is a no-op: the code never changes", async () => {
    const first = await functions.generateStudentPaymentCode(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID })
    );
    const second = await functions.generateStudentPaymentCode(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID })
    );
    assert.equal(first.paymentCode, second.paymentCode);
    assert.equal(second.alreadyExisted, true);
  });

  test("two different learners at the same school get two different codes", async () => {
    const a = await functions.generateStudentPaymentCode(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_ID })
    );
    const b = await functions.generateStudentPaymentCode(
      request(BURSAR_UID, { schoolId: SCHOOL, studentId: STUDENT_2_ID })
    );
    assert.notEqual(a.paymentCode, b.paymentCode);
  });

  test("a non-finance staff member (e.g. classTeacher) is denied", async () => {
    await assert.rejects(
      functions.generateStudentPaymentCode(
        request(OTHER_STAFF_UID, { schoolId: SCHOOL, studentId: STUDENT_ID })
      ),
      /finance leadership/i
    );
  });

  test("an unauthenticated caller is rejected", async () => {
    await assert.rejects(
      functions.generateStudentPaymentCode(
        request(null, { schoolId: SCHOOL, studentId: STUDENT_ID })
      ),
      /unauthenticated|sign-in/i
    );
  });

  test("generatePaymentCodeCore writes a finance_audit_events entry", async () => {
    const result = await functions.generatePaymentCodeCore({
      schoolId: SCHOOL, studentId: STUDENT_ID, actorUid: BURSAR_UID,
    });
    const eventsSnap = await db.collection(`schools/${SCHOOL}/finance_audit_events`)
      .where("type", "==", "payment_code_generated")
      .where("targetId", "==", STUDENT_ID)
      .get();
    assert.equal(eventsSnap.size, 1);
    assert.equal(eventsSnap.docs[0].data().detail.paymentCode, result.paymentCode);
  });
});

describe("payment_codes: updatePaymentChannelConfig", () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
  });

  test("bursar can set the channel config; it is scoped to that school only", async () => {
    await functions.updatePaymentChannelConfig(
      request(BURSAR_UID, {
        schoolId: SCHOOL,
        schoolDisplayName: "Victoria High School",
        mtnMomo: { enabled: true, ussdCode: "*165*80#", steps: ["Dial", "Choose School Pay"], merchantLabel: "School Pay" },
        airtelMoney: { enabled: false },
        bankAccounts: [{ bankName: "Stanbic", accountName: "VHS Collections", accountNumber: "0123456789", showAccountNumber: true, enabled: true }],
        otherChannels: [],
      })
    );

    const configSnap = await db.doc(`schools/${SCHOOL}/payment_config/channels`).get();
    const config = configSnap.data();
    assert.equal(config.schoolDisplayName, "Victoria High School");
    assert.equal(config.mtnMomo.enabled, true);
    assert.equal(config.mtnMomo.ussdCode, "*165*80#");
    assert.equal(config.bankAccounts[0].bankName, "Stanbic");
    assert.equal(config.updatedBy, BURSAR_UID);

    // schoolB's config document must not exist / must be untouched.
    const otherSchoolSnap = await db.doc(`schools/${SCHOOL_B}/payment_config/channels`).get();
    assert.equal(otherSchoolSnap.exists, false);
  });

  test("writes a channel_config_updated audit event", async () => {
    await functions.updatePaymentChannelConfig(
      request(BURSAR_UID, { schoolId: SCHOOL, schoolDisplayName: "VHS" })
    );
    const eventsSnap = await db.collection(`schools/${SCHOOL}/finance_audit_events`)
      .where("type", "==", "channel_config_updated")
      .get();
    assert.equal(eventsSnap.size, 1);
    assert.equal(eventsSnap.docs[0].data().actorUid, BURSAR_UID);
  });

  test("a non-finance staff member is denied", async () => {
    await assert.rejects(
      functions.updatePaymentChannelConfig(
        request(OTHER_STAFF_UID, { schoolId: SCHOOL, schoolDisplayName: "Forged" })
      ),
      /finance leadership/i
    );
  });
});

describe("payment_codes: claim/confirm/reject pending payments", () => {
  const PARENT_UID = "parentUid";
  const OTHER_PARENT_UID = "otherParentUid";

  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
    await db.doc(`users/${PARENT_UID}`).set({ role: "parent", roles: ["parent"], schoolId: SCHOOL, studentIds: [STUDENT_ID] });
    await db.doc(`users/${OTHER_PARENT_UID}`).set({ role: "parent", roles: ["parent"], schoolId: SCHOOL, studentIds: [STUDENT_2_ID] });
    await functions.generatePaymentCodeCore({ schoolId: SCHOOL, studentId: STUDENT_ID, actorUid: BURSAR_UID });
  });

  async function seedBill() {
    await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/billA`).set({
      schoolId: SCHOOL, studentId: STUDENT_ID, billId: "billA", status: "open", currency: "UGX",
      issuedTotalUgx: 500000, paidTotalUgx: 0, adjustmentTotalUgx: 0, balanceUgx: 500000, lines: [],
    });
  }

  test("a linked parent can claim a pending payment; an unlinked parent cannot", async () => {
    const claim = await functions.claimPendingPayment(
      request(PARENT_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, channel: "mtn_momo", amountUgx: 200000 })
    );
    assert.ok(claim.pendingPaymentId);
    const snap = await db.doc(`schools/${SCHOOL}/pending_payments/${claim.pendingPaymentId}`).get();
    assert.equal(snap.data().status, "pending");
    assert.equal(snap.data().claimedByParentUid, PARENT_UID);

    await assert.rejects(
      functions.claimPendingPayment(
        request(OTHER_PARENT_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, channel: "mtn_momo", amountUgx: 200000 })
      ),
      /not linked/i
    );
  });

  test("confirmPendingPayment records a real payment with receipt/amountInWords/qrVerificationUrl and marks the queue entry confirmed", async () => {
    await seedBill();
    const claim = await functions.claimPendingPayment(
      request(PARENT_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, channel: "mtn_momo", amountUgx: 200000 })
    );
    const result = await functions.confirmPendingPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, pendingPaymentId: claim.pendingPaymentId, billId: "billA" })
    );
    assert.ok(result.paymentId);
    assert.match(result.receiptNumber, /^RCT-\d{6}$/);
    assert.equal(result.balanceUgx, 300000);

    const paymentSnap = await db.doc(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/billA/payments/${result.paymentId}`).get();
    const payment = paymentSnap.data();
    assert.equal(payment.amountUgx, 200000);
    assert.match(payment.amountInWords, /Two Hundred Thousand Shillings/);
    assert.match(payment.qrVerificationUrl, /^https:\/\/.+verify-payment\?r=/);
    assert.equal(payment.sourcePendingPaymentId, claim.pendingPaymentId);

    const pendingSnap = await db.doc(`schools/${SCHOOL}/pending_payments/${claim.pendingPaymentId}`).get();
    assert.equal(pendingSnap.data().status, "confirmed");
    assert.equal(pendingSnap.data().resultingPaymentId, result.paymentId);
  });

  test("confirming the same pending payment twice fails the second time (idempotent against double-confirm)", async () => {
    await seedBill();
    const claim = await functions.claimPendingPayment(
      request(PARENT_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, channel: "mtn_momo", amountUgx: 200000 })
    );
    await functions.confirmPendingPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, pendingPaymentId: claim.pendingPaymentId, billId: "billA" })
    );
    await assert.rejects(
      functions.confirmPendingPayment(
        request(BURSAR_UID, { schoolId: SCHOOL, pendingPaymentId: claim.pendingPaymentId, billId: "billA" })
      ),
      /already been resolved/i
    );
    const paymentsSnap = await db.collection(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/billA/payments`).get();
    assert.equal(paymentsSnap.size, 1, "a duplicate confirm call must never create a second payment");
  });

  test("rejectPendingPayment marks the queue entry rejected and creates no payment", async () => {
    await seedBill();
    const claim = await functions.claimPendingPayment(
      request(PARENT_UID, { schoolId: SCHOOL, studentId: STUDENT_ID, channel: "mtn_momo", amountUgx: 200000 })
    );
    await functions.rejectPendingPayment(
      request(BURSAR_UID, { schoolId: SCHOOL, pendingPaymentId: claim.pendingPaymentId, reason: "No matching bank reference" })
    );
    const pendingSnap = await db.doc(`schools/${SCHOOL}/pending_payments/${claim.pendingPaymentId}`).get();
    assert.equal(pendingSnap.data().status, "rejected");
    assert.equal(pendingSnap.data().rejectionReason, "No matching bank reference");
    const paymentsSnap = await db.collection(`schools/${SCHOOL}/student_accounts/${STUDENT_ID}/bills/billA/payments`).get();
    assert.equal(paymentsSnap.size, 0);
  });
});
