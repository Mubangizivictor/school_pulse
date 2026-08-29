// Firebase Emulator integration test for functions/health_clinic.js — the
// server-authoritative clinic mutations (createClinicVisit, dispenseMedicalItem).
//
// Run: `npm run test:health-clinic:emulator`. Requires the Firestore
// emulator (JDK 21). The module is required with `onCall: h => h` so the
// real Admin SDK transaction logic runs against the emulator exactly as the
// deployed function does — idempotency, stock-decrement atomicity,
// zero/negative-stock prevention, cross-school isolation, visit-status
// precondition, and audit-in-transaction.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-health-clinic-test";
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
const fns = require("../health_clinic")({ admin, onCall: (h) => h, HttpsError });

const db = admin.firestore();
const SCHOOL = "schoolA";
const OTHER = "schoolB";
const NURSE = "nurseUid";
const NURSE2 = "nurse2Uid";
const ADMIN = "adminUid";
const TEACHER = "teacherUid";
const DISABLED_NURSE = "disabledNurseUid";
const FOREIGN_NURSE = "foreignNurseUid";

const req = (uid, data) => ({ auth: uid ? { uid } : null, data });

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
  await db.doc(`users/${NURSE}`).set({ roles: ["nurse"], schoolId: SCHOOL, name: "Nia", isActive: true });
  await db.doc(`users/${NURSE2}`).set({ roles: ["nurse"], schoolId: SCHOOL, name: "Noa", isActive: true });
  await db.doc(`users/${ADMIN}`).set({ role: "schoolAdmin", roles: ["schoolAdmin"], schoolId: SCHOOL, name: "Ada" });
  await db.doc(`users/${TEACHER}`).set({ roles: ["classTeacher"], schoolId: SCHOOL, name: "Tom", isActive: true });
  await db.doc(`users/${DISABLED_NURSE}`).set({ roles: ["nurse"], schoolId: SCHOOL, name: "Dan", isActive: false });
  await db.doc(`users/${FOREIGN_NURSE}`).set({ roles: ["nurse"], schoolId: OTHER, name: "Fay", isActive: true });
}

beforeEach(async () => {
  await clearFirestore();
  await seed();
});

const validVisit = (extra = {}) => ({
  schoolId: SCHOOL,
  studentId: "studentA",
  reason: "Headache",
  ...extra,
});

async function auditRows(action) {
  const snap = await db.collection("health_audit").where("action", "==", action).get();
  return snap.docs.map((d) => d.data());
}

// ---------------------------------------------------------------------------
describe("createClinicVisit", () => {
  test("a nurse records a visit; server stamps recordedBy/status and writes an audit row", async () => {
    const { id, status } = await fns.createClinicVisit(req(NURSE, { visit: validVisit() }));
    assert.equal(status, "completed");
    const doc = (await db.collection("clinic_visits").doc(id).get()).data();
    assert.equal(doc.recordedBy, NURSE);
    assert.equal(doc.schoolId, SCHOOL);
    assert.equal(doc.status, "completed");
    assert.ok(doc.completedAt);
    const audit = await auditRows("clinic_visit.created");
    assert.equal(audit.length, 1);
    assert.equal(audit[0].recordId, id);
    assert.equal(audit[0].actorId, NURSE);
  });

  test("recordedBy is server-derived — a spoofed recordedBy in the payload is overwritten", async () => {
    const { id } = await fns.createClinicVisit(
      req(NURSE, { visit: validVisit({ recordedBy: NURSE2, status: "draft" }) }),
    );
    const doc = (await db.collection("clinic_visits").doc(id).get()).data();
    assert.equal(doc.recordedBy, NURSE);
    assert.equal(doc.status, "completed");
  });

  test("idempotent on a client-supplied visit id — a retry does not double-write or double-audit", async () => {
    const body = { visit: validVisit({ id: "visit-fixed-1" }) };
    const a = await fns.createClinicVisit(req(NURSE, body));
    const b = await fns.createClinicVisit(req(NURSE, body));
    assert.equal(a.id, b.id);
    const all = await db.collection("clinic_visits").get();
    assert.equal(all.size, 1);
    assert.equal((await auditRows("clinic_visit.created")).length, 1);
  });

  test("rejects an incomplete visit (missing studentId or reason)", async () => {
    await assert.rejects(
      () => fns.createClinicVisit(req(NURSE, { visit: validVisit({ studentId: "  " }) })),
      /incomplete/,
    );
    await assert.rejects(
      () => fns.createClinicVisit(req(NURSE, { visit: validVisit({ reason: "" }) })),
      /incomplete/,
    );
  });

  test("rejects a visit whose schoolId does not match the caller's school", async () => {
    await assert.rejects(
      () => fns.createClinicVisit(req(NURSE, { visit: validVisit({ schoolId: OTHER }) })),
      /incomplete/,
    );
  });

  test("permission boundary — unauthenticated, class teacher, and a disabled nurse are all denied", async () => {
    await assert.rejects(() => fns.createClinicVisit(req(null, { visit: validVisit() })), /Sign in/);
    await assert.rejects(() => fns.createClinicVisit(req(TEACHER, { visit: validVisit() })), /not authorised/i);
    await assert.rejects(
      () => fns.createClinicVisit(req(DISABLED_NURSE, { visit: validVisit() })),
      /not authorised/i,
    );
    assert.equal((await db.collection("clinic_visits").get()).size, 0);
  });

  test("a nurse cannot record a visit into a school that is not their own", async () => {
    // FOREIGN_NURSE is a valid nurse in OTHER; recording against SCHOOL is refused
    // because visit.schoolId must equal the caller's own schoolId.
    await assert.rejects(
      () => fns.createClinicVisit(req(FOREIGN_NURSE, { visit: validVisit({ schoolId: SCHOOL }) })),
      /incomplete/,
    );
    assert.equal((await db.collection("clinic_visits").get()).size, 0);
  });

  test("a schoolAdmin may also record a clinic visit", async () => {
    const { status } = await fns.createClinicVisit(req(ADMIN, { visit: validVisit() }));
    assert.equal(status, "completed");
  });
});

// ---------------------------------------------------------------------------
describe("dispenseMedicalItem", () => {
  async function seedItemAndVisit({ qty = 10, visitStatus = "completed", itemSchool = SCHOOL, visitSchool = SCHOOL } = {}) {
    await db.collection("medical_inventory").doc("itemA").set({
      schoolId: itemSchool, name: "Paracetamol", quantity: qty, unit: "tablets",
    });
    await db.collection("clinic_visits").doc("visitA").set({
      schoolId: visitSchool, studentId: "studentA", recordedBy: NURSE, status: visitStatus,
    });
  }

  test("decrements stock atomically, writes a movement row and an audit row", async () => {
    await seedItemAndVisit({ qty: 10 });
    const r = await fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 3 }));
    assert.deepEqual(r, { ok: true });
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 7);
    const moves = await db.collection("medical_inventory_movements").get();
    assert.equal(moves.size, 1);
    const m = moves.docs[0].data();
    assert.equal(m.quantity, 3);
    assert.equal(m.type, "dispensed");
    assert.equal(m.itemId, "itemA");
    assert.equal(m.visitId, "visitA");
    assert.equal(m.studentId, "studentA");
    assert.equal(m.recordedBy, NURSE);
    assert.equal((await auditRows("medical_inventory.dispensed")).length, 1);
  });

  test("zero-stock / negative-stock prevention — a dispense larger than stock is rejected and nothing changes", async () => {
    await seedItemAndVisit({ qty: 2 });
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 5 })),
      /Insufficient stock/,
    );
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 2);
    assert.equal((await db.collection("medical_inventory_movements").get()).size, 0);
    assert.equal((await auditRows("medical_inventory.dispensed")).length, 0);
  });

  test("a dispense of exactly the remaining stock succeeds and lands the item at zero", async () => {
    await seedItemAndVisit({ qty: 4 });
    await fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 4 }));
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 0);
  });

  test("two sequential dispenses that together exceed stock — the second is rejected, stock never goes negative", async () => {
    await seedItemAndVisit({ qty: 5 });
    await fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 3 }));
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 3 })),
      /Insufficient stock/,
    );
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 2);
    assert.equal((await db.collection("medical_inventory_movements").get()).size, 1);
  });

  test("concurrent dispenses race safely — total dispensed never exceeds stock (transaction ret/contention)", async () => {
    await seedItemAndVisit({ qty: 10 });
    const results = await Promise.allSettled([
      fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 4 })),
      fns.dispenseMedicalItem(req(NURSE2, { itemId: "itemA", visitId: "visitA", quantity: 4 })),
      fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 4 })),
    ]);
    const ok = results.filter((r) => r.status === "fulfilled").length;
    const finalQty = (await db.collection("medical_inventory").doc("itemA").get()).data().quantity;
    const moves = (await db.collection("medical_inventory_movements").get()).size;
    // At most two of the three 4-unit dispenses can fit in 10 units.
    assert.ok(ok <= 2, `expected <=2 successes, got ${ok}`);
    assert.equal(finalQty, 10 - ok * 4);
    assert.equal(moves, ok);
    assert.ok(finalQty >= 0);
  });

  test("rejects a non-positive or non-integer quantity, and a missing visit/item", async () => {
    await seedItemAndVisit();
    // "3" is intentionally accepted (Number("3") === 3 is a positive integer);
    // the guard is against zero, negative, fractional, and absent values.
    for (const q of [0, -1, 1.5, null, undefined, NaN, "abc"]) {
      await assert.rejects(
        () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: q })),
        /positive quantity/,
      );
    }
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", quantity: 1 })),
      /positive quantity/,
    );
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { visitId: "visitA", quantity: 1 })),
      /positive quantity/,
    );
  });

  test("cross-school isolation — item or visit in another school is rejected", async () => {
    await seedItemAndVisit({ itemSchool: OTHER });
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 1 })),
      /outside your school/,
    );
    await clearFirestore();
    await seed();
    await seedItemAndVisit({ visitSchool: OTHER });
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 1 })),
      /outside your school/,
    );
  });

  test("a foreign nurse cannot dispense against this school's stock", async () => {
    await seedItemAndVisit();
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(FOREIGN_NURSE, { itemId: "itemA", visitId: "visitA", quantity: 1 })),
      /outside your school|not authorised/i,
    );
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 10);
  });

  test("visit-status precondition — dispensing is refused for a cancelled visit", async () => {
    await seedItemAndVisit({ visitStatus: "cancelled" });
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 1 })),
      /active or completed visit/,
    );
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 10);
  });

  test("dispensing is allowed for an in_progress visit", async () => {
    await seedItemAndVisit({ visitStatus: "in_progress" });
    await fns.dispenseMedicalItem(req(NURSE, { itemId: "itemA", visitId: "visitA", quantity: 1 }));
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 9);
  });

  test("unauthenticated and non-clinical roles are denied before any stock read", async () => {
    await seedItemAndVisit();
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(null, { itemId: "itemA", visitId: "visitA", quantity: 1 })),
      /Sign in/,
    );
    await assert.rejects(
      () => fns.dispenseMedicalItem(req(TEACHER, { itemId: "itemA", visitId: "visitA", quantity: 1 })),
      /not authorised/i,
    );
    assert.equal((await db.collection("medical_inventory").doc("itemA").get()).data().quantity, 10);
  });
});
