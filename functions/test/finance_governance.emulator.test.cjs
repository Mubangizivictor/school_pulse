// Firebase Emulator integration test for functions/finance_governance.js
// (submitExpenditure, decideExpenditure, saveSchoolBudget — audit area 2:
// callable-only financial writes).
//
// Run: `npm run test:finance-governance:emulator`
// (firebase emulators:exec --only firestore, same convention as
// test:student-fee-billing:emulator). Requires the local Firestore
// emulator; not run in the plain `node --test` unit lane.
//
// The module is required DIRECTLY with a passthrough `onCall: h => h` so
// the real Admin SDK transaction logic (idempotency, tenant isolation,
// self-approval block, audit-in-transaction) is exercised against the
// emulator, exactly as the deployed Cloud Function behaves.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-finance-governance-test";
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
const fns = require("../finance_governance")({
  admin,
  onCall: (handler) => handler,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const OTHER_SCHOOL = "schoolB";
const BURSAR = "bursarUid";
const HEAD = "headUid";
const OTHER_BURSAR = "otherBursarUid";
const TEACHER = "teacherUid";
const FOREIGN_BURSAR = "foreignBursarUid";

function req(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function clearFirestore() {
  const cols = await db.listCollections();
  await Promise.all(cols.map(del));
}
async function del(colRef) {
  const docs = await colRef.listDocuments();
  await Promise.all(
    docs.map(async (d) => {
      const subs = await d.listCollections();
      await Promise.all(subs.map(del));
      await d.delete();
    }),
  );
}

async function seedUsers() {
  await db.doc(`users/${BURSAR}`).set({ roles: ["bursar"], schoolId: SCHOOL, name: "Bea Bursar" });
  await db.doc(`users/${HEAD}`).set({ roles: ["headTeacher"], schoolId: SCHOOL, name: "Hana Head" });
  await db.doc(`users/${OTHER_BURSAR}`).set({ roles: ["bursar"], schoolId: SCHOOL, name: "Otto Bursar" });
  await db.doc(`users/${TEACHER}`).set({ roles: ["classTeacher"], schoolId: SCHOOL, name: "Tim Teacher" });
  await db.doc(`users/${FOREIGN_BURSAR}`).set({ roles: ["bursar"], schoolId: OTHER_SCHOOL, name: "Fred Foreign" });
}

const auditCol = () => db.collection(`schools/${SCHOOL}/finance_audit_events`);

beforeEach(async () => {
  await clearFirestore();
  await seedUsers();
});

describe("submitExpenditure", () => {
  test("creates a pending requisition and one audit event", async () => {
    const r = await fns.submitExpenditure(
      req(BURSAR, {
        schoolId: SCHOOL,
        description: "Science lab reagents",
        budgetCategoryId: "cat-science",
        amount: 450000,
      }),
    );
    const snap = await db.doc(`schools/${SCHOOL}/expenditures/${r.expenditureId}`).get();
    assert.equal(snap.data().status, "pending");
    assert.equal(snap.data().requesterId, BURSAR);
    assert.equal(snap.data().amount, 450000);
    const audit = await auditCol().where("expenditureId", "==", r.expenditureId).get();
    assert.equal(audit.size, 1);
    assert.equal(audit.docs[0].data().action, "expenditure_submitted");
  });

  test("is idempotent on clientRequestId — retry reuses the same doc", async () => {
    const body = {
      schoolId: SCHOOL,
      description: "Bus fuel",
      budgetCategoryId: "cat-transport",
      amount: 200000,
      clientRequestId: "uuid-fixed-1",
    };
    const a = await fns.submitExpenditure(req(BURSAR, body));
    const b = await fns.submitExpenditure(req(BURSAR, body));
    assert.equal(a.expenditureId, b.expenditureId);
    const all = await db.collection(`schools/${SCHOOL}/expenditures`).get();
    assert.equal(all.size, 1, "a retried submit must not create a second requisition");
  });

  test("rejects a non-positive or fractional amount", async () => {
    await assert.rejects(
      () => fns.submitExpenditure(req(BURSAR, { schoolId: SCHOOL, description: "x", budgetCategoryId: "c", amount: 0 })),
      /positive whole number/,
    );
    await assert.rejects(
      () => fns.submitExpenditure(req(BURSAR, { schoolId: SCHOOL, description: "x", budgetCategoryId: "c", amount: 12.5 })),
      /positive whole number/,
    );
  });

  test("a classTeacher (no finance role) cannot raise a requisition", async () => {
    await assert.rejects(
      () => fns.submitExpenditure(req(TEACHER, { schoolId: SCHOOL, description: "x", budgetCategoryId: "c", amount: 1000 })),
      /Not authorised/,
    );
  });

  test("a bursar of another school cannot write into this school", async () => {
    await assert.rejects(
      () => fns.submitExpenditure(req(FOREIGN_BURSAR, { schoolId: SCHOOL, description: "x", budgetCategoryId: "c", amount: 1000 })),
      /another school/,
    );
  });

  test("an unauthenticated call is rejected", async () => {
    await assert.rejects(
      () => fns.submitExpenditure(req(null, { schoolId: SCHOOL, description: "x", budgetCategoryId: "c", amount: 1000 })),
      /Sign-in required/,
    );
  });

  test("cannot amend a requisition once it has been decided", async () => {
    const r = await fns.submitExpenditure(
      req(BURSAR, { schoolId: SCHOOL, description: "Projector", budgetCategoryId: "cat-it", amount: 800000 }),
    );
    await fns.decideExpenditure(
      req(HEAD, { schoolId: SCHOOL, expenditureId: r.expenditureId, decision: "approve" }),
    );
    await assert.rejects(
      () =>
        fns.submitExpenditure(
          req(BURSAR, {
            schoolId: SCHOOL,
            expenditureId: r.expenditureId,
            description: "Projector (cheaper)",
            budgetCategoryId: "cat-it",
            amount: 500000,
          }),
        ),
      /no longer editable/,
    );
  });
});

describe("decideExpenditure", () => {
  async function pending() {
    const r = await fns.submitExpenditure(
      req(BURSAR, { schoolId: SCHOOL, description: "Staff room kettle", budgetCategoryId: "cat-admin", amount: 150000 }),
    );
    return r.expenditureId;
  }

  test("the requester cannot approve their own requisition", async () => {
    const id = await pending();
    await assert.rejects(
      () => fns.decideExpenditure(req(BURSAR, { schoolId: SCHOOL, expenditureId: id, decision: "approve" })),
      /cannot decide a requisition you raised/,
    );
  });

  test("approve moves it to approved, appends history, writes audit", async () => {
    const id = await pending();
    const res = await fns.decideExpenditure(
      req(HEAD, { schoolId: SCHOOL, expenditureId: id, decision: "approve", comment: "ok" }),
    );
    assert.equal(res.status, "approved");
    const snap = await db.doc(`schools/${SCHOOL}/expenditures/${id}`).get();
    assert.equal(snap.data().status, "approved");
    assert.equal(snap.data().approvalHistory.length, 1);
    assert.equal(snap.data().approvalHistory[0].approverId, HEAD);
    const audit = await auditCol().where("action", "==", "expenditure_approve").get();
    assert.equal(audit.size, 1);
  });

  test("reject and return require a comment", async () => {
    const id = await pending();
    await assert.rejects(
      () => fns.decideExpenditure(req(HEAD, { schoolId: SCHOOL, expenditureId: id, decision: "reject" })),
      /comment is required/,
    );
  });

  test("return sends it back to pending so the requester can amend", async () => {
    const id = await pending();
    await fns.decideExpenditure(
      req(HEAD, { schoolId: SCHOOL, expenditureId: id, decision: "return", comment: "need a quote" }),
    );
    const snap = await db.doc(`schools/${SCHOOL}/expenditures/${id}`).get();
    assert.equal(snap.data().status, "pending");
    // requester can now amend
    await fns.submitExpenditure(
      req(BURSAR, { schoolId: SCHOOL, expenditureId: id, description: "Staff room kettle + quote", budgetCategoryId: "cat-admin", amount: 150000 }),
    );
  });

  test("a second identical approve by the same actor is an idempotent no-op", async () => {
    const id = await pending();
    const a = await fns.decideExpenditure(req(HEAD, { schoolId: SCHOOL, expenditureId: id, decision: "approve" }));
    const b = await fns.decideExpenditure(req(HEAD, { schoolId: SCHOOL, expenditureId: id, decision: "approve" }));
    assert.equal(a.idempotent, false);
    assert.equal(b.idempotent, true);
    const audit = await auditCol().where("action", "==", "expenditure_approve").get();
    assert.equal(audit.size, 1, "the retry must not write a second audit event");
  });

  test("cannot reject a requisition that is already approved", async () => {
    const id = await pending();
    await fns.decideExpenditure(req(HEAD, { schoolId: SCHOOL, expenditureId: id, decision: "approve" }));
    await assert.rejects(
      () => fns.decideExpenditure(req(OTHER_BURSAR, { schoolId: SCHOOL, expenditureId: id, decision: "reject", comment: "no" })),
      /already approved/,
    );
  });

  test("a foreign-school user cannot decide", async () => {
    const id = await pending();
    await assert.rejects(
      () => fns.decideExpenditure(req(FOREIGN_BURSAR, { schoolId: SCHOOL, expenditureId: id, decision: "approve" })),
      /another school/,
    );
  });
});

describe("saveSchoolBudget", () => {
  test("creates a budget line; client-supplied spentAmount is ignored", async () => {
    const r = await fns.saveSchoolBudget(
      req(BURSAR, {
        schoolId: SCHOOL,
        name: "Transport",
        academicYear: "2026",
        term: "Term 1",
        allocatedAmount: 10000000,
        spentAmount: 9999999, // must be ignored
      }),
    );
    const snap = await db.doc(`schools/${SCHOOL}/budgets/${r.budgetId}`).get();
    assert.equal(snap.data().allocatedAmount, 10000000);
    assert.equal(snap.data().spentAmount, 0);
    const audit = await auditCol().where("action", "==", "budget_created").get();
    assert.equal(audit.size, 1);
  });

  test("re-saving the same year/term/name updates in place, preserving spentAmount", async () => {
    const first = await fns.saveSchoolBudget(
      req(BURSAR, { schoolId: SCHOOL, name: "Meals", academicYear: "2026", term: "Term 1", allocatedAmount: 5000000 }),
    );
    // simulate actuals accruing server-side
    await db.doc(`schools/${SCHOOL}/budgets/${first.budgetId}`).update({ spentAmount: 1200000 });
    const second = await fns.saveSchoolBudget(
      req(BURSAR, { schoolId: SCHOOL, name: "Meals", academicYear: "2026", term: "Term 1", allocatedAmount: 6000000 }),
    );
    assert.equal(first.budgetId, second.budgetId);
    const snap = await db.doc(`schools/${SCHOOL}/budgets/${second.budgetId}`).get();
    assert.equal(snap.data().allocatedAmount, 6000000);
    assert.equal(snap.data().spentAmount, 1200000, "actuals must survive a re-save");
    const all = await db.collection(`schools/${SCHOOL}/budgets`).get();
    assert.equal(all.size, 1);
  });

  test("rejects a negative allocation", async () => {
    await assert.rejects(
      () => fns.saveSchoolBudget(req(BURSAR, { schoolId: SCHOOL, name: "X", academicYear: "2026", term: "Term 1", allocatedAmount: -1 })),
      /0 or more/,
    );
  });

  test("a headTeacher cannot edit budget lines (author roles only)", async () => {
    await assert.rejects(
      () => fns.saveSchoolBudget(req(HEAD, { schoolId: SCHOOL, name: "X", academicYear: "2026", term: "Term 1", allocatedAmount: 1000 })),
      /Not authorised/,
    );
  });

  test("a foreign-school bursar cannot create a budget line here", async () => {
    await assert.rejects(
      () => fns.saveSchoolBudget(req(FOREIGN_BURSAR, { schoolId: SCHOOL, name: "X", academicYear: "2026", term: "Term 1", allocatedAmount: 1000 })),
      /another school/,
    );
  });
});
