// Firebase Emulator integration test for functions/finance_reconciliation.js
// (audit area 4: Cash & Bank reconciliation).
//
// Run: `npm run test:finance-reconciliation:emulator`. Requires the
// Firestore emulator. Exercises the real Admin SDK transactions
// (match/unmatch metadata, duplicate guards, opposite-sign/equal-amount
// pairing, balance-preserving adjustments, audit-in-transaction).
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-finance-reconciliation-test";
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
const fns = require("../finance_reconciliation")({
  admin,
  onCall: (h) => h,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const BURSAR = "bursarUid";
const HEAD = "headUid";
const FOREIGN = "foreignUid";
const req = (uid, data) => ({ auth: uid ? { uid } : null, data });
const auditCol = () => db.collection(`schools/${SCHOOL}/finance_audit_events`);

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

async function seed() {
  await db.doc(`users/${BURSAR}`).set({ roles: ["bursar"], schoolId: SCHOOL, name: "Bea" });
  await db.doc(`users/${HEAD}`).set({ roles: ["headTeacher"], schoolId: SCHOOL, name: "Hana" });
  await db.doc(`users/${FOREIGN}`).set({ roles: ["bursar"], schoolId: "schoolB", name: "Fred" });
  await db.doc(`schools/${SCHOOL}/bank_accounts/acc1`).set({
    schoolId: SCHOOL, name: "Main", kind: "bank", balanceUgx: 10000000, unmatchedCount: 3,
  });
  await db.doc(`schools/${SCHOOL}/bank_ledger/e1`).set({
    schoolId: SCHOOL, accountId: "acc1", type: "Receipt", amountUgx: 500000,
    balanceUgx: 10000000, reconciled: false,
  });
  await db.doc(`schools/${SCHOOL}/bank_ledger/e2`).set({
    schoolId: SCHOOL, accountId: "acc1", type: "Payment", amountUgx: -500000,
    balanceUgx: 9500000, reconciled: false,
  });
  await db.doc(`schools/${SCHOOL}/bank_ledger/e3`).set({
    schoolId: SCHOOL, accountId: "acc1", type: "Payment", amountUgx: -250000,
    balanceUgx: 9250000, reconciled: false,
  });
}

beforeEach(async () => {
  await clearFirestore();
  await seed();
});

describe("matchBankLedgerEntry", () => {
  test("statement-reference match sets reconciliation metadata + audit", async () => {
    const r = await fns.matchBankLedgerEntry(
      req(BURSAR, { schoolId: SCHOOL, entryId: "e1", statementReference: "STMT-001" }),
    );
    assert.equal(r.idempotent, false);
    const e = await db.doc(`schools/${SCHOOL}/bank_ledger/e1`).get();
    assert.equal(e.data().reconciled, true);
    assert.equal(e.data().statementReference, "STMT-001");
    const audit = await auditCol().where("action", "==", "bank_entry_matched").get();
    assert.equal(audit.size, 1);
  });

  test("re-using a statement reference on the same account is rejected", async () => {
    await fns.matchBankLedgerEntry(
      req(BURSAR, { schoolId: SCHOOL, entryId: "e1", statementReference: "DUP" }),
    );
    await assert.rejects(
      () =>
        fns.matchBankLedgerEntry(
          req(BURSAR, { schoolId: SCHOOL, entryId: "e3", statementReference: "DUP" }),
        ),
      /already reconciled against another entry/,
    );
  });

  test("pair match requires opposite sign + equal magnitude, marks both", async () => {
    const r = await fns.matchBankLedgerEntry(
      req(BURSAR, { schoolId: SCHOOL, entryId: "e1", counterEntryId: "e2" }),
    );
    assert.equal(r.idempotent, false);
    const [a, b] = await Promise.all([
      db.doc(`schools/${SCHOOL}/bank_ledger/e1`).get(),
      db.doc(`schools/${SCHOOL}/bank_ledger/e2`).get(),
    ]);
    assert.equal(a.data().matchedEntryId, "e2");
    assert.equal(b.data().matchedEntryId, "e1");
    assert.equal(a.data().reconciled, true);
    assert.equal(b.data().reconciled, true);
  });

  test("pair match rejects unequal amounts", async () => {
    await assert.rejects(
      () => fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", counterEntryId: "e3" })),
      /equal in amount/,
    );
  });

  test("matching an already-reconciled entry to a new target fails", async () => {
    await fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", statementReference: "S1" }));
    await assert.rejects(
      () => fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", statementReference: "S2" })),
      /already reconciled\. Unmatch it first/,
    );
  });

  test("same match again is idempotent", async () => {
    await fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", statementReference: "S1" }));
    const again = await fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", statementReference: "S1" }));
    assert.equal(again.idempotent, true);
  });

  test("account unmatchedCount is refreshed from the ledger", async () => {
    await fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", counterEntryId: "e2" }));
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/acc1`).get();
    assert.equal(acc.data().unmatchedCount, 1); // e3 still unmatched
  });

  test("a non-recon role and a foreign user are rejected", async () => {
    await assert.rejects(
      () => fns.matchBankLedgerEntry(req(HEAD, { schoolId: SCHOOL, entryId: "e1", statementReference: "X" })),
      /Only a bursar or school admin/,
    );
    await assert.rejects(
      () => fns.matchBankLedgerEntry(req(FOREIGN, { schoolId: SCHOOL, entryId: "e1", statementReference: "X" })),
      /another school/,
    );
  });
});

describe("unmatchBankLedgerEntry", () => {
  test("clears metadata on the entry and its pair; requires a reason", async () => {
    await fns.matchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1", counterEntryId: "e2" }));
    await assert.rejects(
      () => fns.unmatchBankLedgerEntry(req(BURSAR, { schoolId: SCHOOL, entryId: "e1" })),
      /reason is required/,
    );
    await fns.unmatchBankLedgerEntry(
      req(BURSAR, { schoolId: SCHOOL, entryId: "e1", reason: "wrong pair" }),
    );
    const [a, b] = await Promise.all([
      db.doc(`schools/${SCHOOL}/bank_ledger/e1`).get(),
      db.doc(`schools/${SCHOOL}/bank_ledger/e2`).get(),
    ]);
    assert.equal(a.data().reconciled, false);
    assert.equal(b.data().reconciled, false);
    assert.equal(a.data().matchedEntryId, null);
    const audit = await auditCol().where("action", "==", "bank_entry_unmatched").get();
    assert.equal(audit.size, 1);
  });

  test("unmatching an already-unmatched entry is an idempotent no-op", async () => {
    const r = await fns.unmatchBankLedgerEntry(
      req(BURSAR, { schoolId: SCHOOL, entryId: "e3", reason: "n/a" }),
    );
    assert.equal(r.idempotent, true);
  });
});

describe("recordBankLedgerAdjustment", () => {
  test("posts a signed entry and moves the account balance; reference required", async () => {
    await assert.rejects(
      () => fns.recordBankLedgerAdjustment(req(BURSAR, { schoolId: SCHOOL, accountId: "acc1", amountUgx: -15000, description: "Bank charge" })),
      /reference are required/,
    );
    const r = await fns.recordBankLedgerAdjustment(
      req(BURSAR, {
        schoolId: SCHOOL, accountId: "acc1", amountUgx: -15000,
        description: "Monthly bank charge", reference: "CHG-05",
      }),
    );
    assert.equal(r.balanceUgx, 10000000 - 15000);
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/acc1`).get();
    assert.equal(acc.data().balanceUgx, 10000000 - 15000);
    const e = await db.doc(`schools/${SCHOOL}/bank_ledger/${r.entryId}`).get();
    assert.equal(e.data().amountUgx, -15000);
    assert.equal(e.data().source, "manual_adjustment");
    assert.equal(e.data().reconciled, true);
  });

  test("zero amount is rejected", async () => {
    await assert.rejects(
      () => fns.recordBankLedgerAdjustment(req(BURSAR, { schoolId: SCHOOL, accountId: "acc1", amountUgx: 0, description: "x", reference: "y" })),
      /non-zero whole number/,
    );
  });

  test("idempotent on clientRequestId (no double balance move)", async () => {
    const body = {
      schoolId: SCHOOL, accountId: "acc1", amountUgx: 40000,
      description: "Interest", reference: "INT-1", clientRequestId: "adj-1",
    };
    await fns.recordBankLedgerAdjustment(req(BURSAR, body));
    const again = await fns.recordBankLedgerAdjustment(req(BURSAR, body));
    assert.equal(again.idempotent, true);
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/acc1`).get();
    assert.equal(acc.data().balanceUgx, 10000000 + 40000);
  });
});
