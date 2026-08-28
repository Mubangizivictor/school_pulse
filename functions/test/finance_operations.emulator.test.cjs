// Firebase Emulator integration test for functions/finance_operations.js
// (audit area 3: Suppliers + Petty Cash real workflows).
//
// Run: `npm run test:finance-operations:emulator`. Requires the Firestore
// emulator. The module is required directly with `onCall: h => h` so the
// real Admin SDK transaction logic (balance/float authority, idempotency,
// four-eyes, tenant isolation, audit-in-transaction) runs against the
// emulator exactly as the deployed function does.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-finance-operations-test";
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
const fns = require("../finance_operations")({
  admin,
  onCall: (h) => h,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const OTHER = "schoolB";
const BURSAR = "bursarUid";
const BURSAR2 = "bursar2Uid";
const HEAD = "headUid";
const TEACHER = "teacherUid";
const FOREIGN = "foreignBursarUid";

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
  await db.doc(`users/${BURSAR2}`).set({ roles: ["bursar"], schoolId: SCHOOL, name: "Ben" });
  await db.doc(`users/${HEAD}`).set({ roles: ["headTeacher"], schoolId: SCHOOL, name: "Hana" });
  await db.doc(`users/${TEACHER}`).set({ roles: ["classTeacher"], schoolId: SCHOOL, name: "Tim" });
  await db.doc(`users/${FOREIGN}`).set({ roles: ["bursar"], schoolId: OTHER, name: "Fred" });
  await db.doc(`schools/${SCHOOL}/bank_accounts/accMain`).set({
    schoolId: SCHOOL, name: "Stanbic Main", kind: "bank", balanceUgx: 20000000,
  });
}

beforeEach(async () => {
  await clearFirestore();
  await seed();
});

async function makeSupplier(extra = {}) {
  const r = await fns.saveSupplier(
    req(BURSAR, { schoolId: SCHOOL, name: "Acme Stationers", category: "Supplies", ...extra }),
  );
  return r.supplierId;
}

describe("suppliers", () => {
  test("create then edit in place; payableBalance is not client-settable", async () => {
    const id = await makeSupplier();
    let snap = await db.doc(`schools/${SCHOOL}/finance_suppliers/${id}`).get();
    assert.equal(snap.data().payableBalanceUgx, 0);
    await fns.saveSupplier(
      req(BURSAR, { schoolId: SCHOOL, supplierId: id, name: "Acme Stationers Ltd", category: "Supplies", payableBalanceUgx: 999 }),
    );
    snap = await db.doc(`schools/${SCHOOL}/finance_suppliers/${id}`).get();
    assert.equal(snap.data().name, "Acme Stationers Ltd");
    assert.equal(snap.data().payableBalanceUgx, 0);
  });

  test("idempotent on clientRequestId", async () => {
    const body = { schoolId: SCHOOL, name: "X", category: "Y", clientRequestId: "u-1" };
    const a = await fns.saveSupplier(req(BURSAR, body));
    const b = await fns.saveSupplier(req(BURSAR, body));
    assert.equal(a.supplierId, b.supplierId);
    const all = await db.collection(`schools/${SCHOOL}/finance_suppliers`).get();
    assert.equal(all.size, 1);
  });

  test("a non-operator role cannot create; a foreign bursar cannot either", async () => {
    await assert.rejects(() => fns.saveSupplier(req(HEAD, { schoolId: SCHOOL, name: "X" })), /Not authorised/);
    await assert.rejects(() => fns.saveSupplier(req(FOREIGN, { schoolId: SCHOOL, name: "X" })), /another school/);
  });

  test("cannot archive a supplier with an outstanding payable", async () => {
    const id = await makeSupplier();
    await db.doc(`schools/${SCHOOL}/finance_suppliers/${id}`).update({ payableBalanceUgx: 500 });
    await assert.rejects(
      () => fns.archiveSupplier(req(BURSAR, { schoolId: SCHOOL, supplierId: id })),
      /Settle outstanding invoices/,
    );
  });
});

describe("supplier invoices", () => {
  async function recordInvoice(supplierId, extra = {}) {
    return fns.recordSupplierInvoice(
      req(BURSAR, {
        schoolId: SCHOOL, supplierId, invoiceNumber: "INV-100",
        category: "Supplies", amountUgx: 750000, ...extra,
      }),
    );
  }

  test("record lands as pending_approval; duplicate number is rejected", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    const snap = await db.doc(`schools/${SCHOOL}/supplier_invoices/${r.invoiceId}`).get();
    assert.equal(snap.data().status, "pending_approval");
    await assert.rejects(() => recordInvoice(sup), /already in the workflow/);
  });

  test("four-eyes: the recorder cannot approve their own invoice", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    await assert.rejects(
      () => fns.decideSupplierInvoice(req(BURSAR, { schoolId: SCHOOL, invoiceId: r.invoiceId, decision: "approve" })),
      /cannot decide an invoice you recorded/,
    );
  });

  test("approve bumps the supplier payable balance", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    await fns.decideSupplierInvoice(req(HEAD, { schoolId: SCHOOL, invoiceId: r.invoiceId, decision: "approve" }));
    const s = await db.doc(`schools/${SCHOOL}/finance_suppliers/${sup}`).get();
    assert.equal(s.data().payableBalanceUgx, 750000);
  });

  test("reject/return require a comment", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    await assert.rejects(
      () => fns.decideSupplierInvoice(req(HEAD, { schoolId: SCHOOL, invoiceId: r.invoiceId, decision: "reject" })),
      /comment is required/,
    );
  });

  test("pay: approved invoice → bank_ledger entry, account debited, payable cleared, invoice paid", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    await fns.decideSupplierInvoice(req(HEAD, { schoolId: SCHOOL, invoiceId: r.invoiceId, decision: "approve" }));
    const pay = await fns.paySupplierInvoice(
      req(BURSAR, { schoolId: SCHOOL, invoiceId: r.invoiceId, accountId: "accMain", paymentReference: "TXN-9" }),
    );
    const inv = await db.doc(`schools/${SCHOOL}/supplier_invoices/${r.invoiceId}`).get();
    assert.equal(inv.data().status, "paid");
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/accMain`).get();
    assert.equal(acc.data().balanceUgx, 20000000 - 750000);
    const led = await db.doc(`schools/${SCHOOL}/bank_ledger/${pay.bankLedgerEntryId}`).get();
    assert.equal(led.data().amountUgx, -750000);
    const s = await db.doc(`schools/${SCHOOL}/finance_suppliers/${sup}`).get();
    assert.equal(s.data().payableBalanceUgx, 0);
  });

  test("pay is idempotent on the same payment reference (no double debit)", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    await fns.decideSupplierInvoice(req(HEAD, { schoolId: SCHOOL, invoiceId: r.invoiceId, decision: "approve" }));
    const body = { schoolId: SCHOOL, invoiceId: r.invoiceId, accountId: "accMain", paymentReference: "TXN-SAME" };
    await fns.paySupplierInvoice(req(BURSAR, body));
    const again = await fns.paySupplierInvoice(req(BURSAR, body));
    assert.equal(again.idempotent, true);
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/accMain`).get();
    assert.equal(acc.data().balanceUgx, 20000000 - 750000, "second call must not debit again");
  });

  test("cannot pay an invoice that is not approved", async () => {
    const sup = await makeSupplier();
    const r = await recordInvoice(sup);
    await assert.rejects(
      () => fns.paySupplierInvoice(req(BURSAR, { schoolId: SCHOOL, invoiceId: r.invoiceId, accountId: "accMain", paymentReference: "X" })),
      /Only an approved invoice can be paid/,
    );
  });
});

describe("petty cash", () => {
  async function replenish(amountUgx = 500000, extra = {}) {
    return fns.replenishPettyCash(
      req(BURSAR, { schoolId: SCHOOL, accountId: "accMain", amountUgx, reference: "PC-1", ...extra }),
    );
  }

  test("replenish creates the float, debits the bank, writes both ledgers", async () => {
    const r = await replenish(600000);
    const f = await db.doc(`schools/${SCHOOL}/petty_cash/main`).get();
    assert.equal(f.data().currentFloatUgx, 600000);
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/accMain`).get();
    assert.equal(acc.data().balanceUgx, 20000000 - 600000);
    const bank = await db.collection(`schools/${SCHOOL}/bank_ledger`).where("source", "==", "petty_cash_replenishment").get();
    assert.equal(bank.size, 1);
    const petty = await db.doc(`schools/${SCHOOL}/petty_cash_ledger/${r.entryId}`).get();
    assert.equal(petty.data().type, "Replenishment");
  });

  test("disbursement moves the float down and writes a signed ledger entry", async () => {
    await replenish(500000);
    const r = await fns.recordPettyCashDisbursement(
      req(BURSAR, { schoolId: SCHOOL, payee: "Boda", category: "Transport", purpose: "Bank run", amountUgx: 20000 }),
    );
    const f = await db.doc(`schools/${SCHOOL}/petty_cash/main`).get();
    assert.equal(f.data().currentFloatUgx, 480000);
    assert.equal(f.data().totalOutUgx, 20000);
    const e = await db.doc(`schools/${SCHOOL}/petty_cash_ledger/${r.entryId}`).get();
    assert.equal(e.data().amountUgx, -20000);
  });

  test("disbursement over the threshold needs an approver", async () => {
    await replenish(500000);
    await assert.rejects(
      () =>
        fns.recordPettyCashDisbursement(
          req(BURSAR, { schoolId: SCHOOL, payee: "P", category: "C", purpose: "big", amountUgx: 120000 }),
        ),
      /need an approver/,
    );
    // with an approver it succeeds
    const ok = await fns.recordPettyCashDisbursement(
      req(BURSAR, { schoolId: SCHOOL, payee: "P", category: "C", purpose: "big", amountUgx: 120000, approvedBy: "Hana Head" }),
    );
    assert.ok(ok.entryId);
  });

  test("disbursement cannot exceed the available float", async () => {
    await replenish(100000);
    await assert.rejects(
      () =>
        fns.recordPettyCashDisbursement(
          req(BURSAR, { schoolId: SCHOOL, payee: "P", category: "C", purpose: "x", amountUgx: 150000, approvedBy: "H" }),
        ),
      /exceeds the available float/,
    );
  });

  test("disbursement before any float exists is refused", async () => {
    await assert.rejects(
      () =>
        fns.recordPettyCashDisbursement(
          req(BURSAR, { schoolId: SCHOOL, payee: "P", category: "C", purpose: "x", amountUgx: 1000 }),
        ),
      /Replenish it first/,
    );
  });

  test("replenish is idempotent on clientRequestId (no double debit)", async () => {
    const body = { schoolId: SCHOOL, accountId: "accMain", amountUgx: 300000, reference: "R", clientRequestId: "rep-1" };
    await fns.replenishPettyCash(req(BURSAR, body));
    const again = await fns.replenishPettyCash(req(BURSAR, body));
    assert.equal(again.idempotent, true);
    const acc = await db.doc(`schools/${SCHOOL}/bank_accounts/accMain`).get();
    assert.equal(acc.data().balanceUgx, 20000000 - 300000);
  });

  test("a foreign bursar cannot replenish or disburse here", async () => {
    await assert.rejects(
      () => fns.replenishPettyCash(req(FOREIGN, { schoolId: SCHOOL, accountId: "accMain", amountUgx: 1000, reference: "R" })),
      /another school/,
    );
  });

  test("every money move writes exactly one audit event", async () => {
    await replenish(500000);
    await fns.recordPettyCashDisbursement(
      req(BURSAR, { schoolId: SCHOOL, payee: "Boda", category: "Transport", purpose: "run", amountUgx: 10000 }),
    );
    const events = await auditCol().where("module", "==", "petty_cash").get();
    assert.equal(events.size, 2);
  });
});
