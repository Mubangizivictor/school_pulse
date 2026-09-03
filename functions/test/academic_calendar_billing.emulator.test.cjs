// Firebase Emulator integration test for
// functions/academic_calendar_billing.js's confirmAcademicCalendar callable
// (term-based SaaS billing Phase 1).
//
// Run: `npm run test:academic-calendar-billing:emulator`
// (firebase emulators:exec --only firestore, requires JDK 21+). NOT run as
// part of this change's automated verification here - the sandbox only has
// JDK 17 available, which firebase-tools' emulator now refuses to start
// under. Confirmed to fail at the "firebase emulators:exec" step with
// "firebase-tools no longer supports Java version before 21." The pure
// server-side validation logic (overlap/range/duplicate-order checks) is
// covered without the emulator in ../academic_calendar_billing.test.js.
//
// academic_calendar_billing.js requires firebase-functions/firebase-admin
// directly (mirrors subscription_management.js's style) rather than the
// factory-injection pattern financial_entitlements.js uses, so it is
// exercised here via the real onCall wrapper against the emulator, the same
// way subscription_management.js would be if it had emulator coverage.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-academic-calendar-billing-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// Pull the raw handler out of the onCall wrapper so it can be invoked
// directly with a fabricated `request` (auth + data), same pattern other
// emulator tests in this repo use for onCall-wrapped functions.
const billing = require("../academic_calendar_billing");

const SCHOOL_A = "schoolA";
const SCHOOL_B = "schoolB";

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
    })
  );
}

async function seedSchool(schoolId, { planId = "growth" } = {}) {
  await db.collection("schools").doc(schoolId).set({ subscriptionPlanId: planId });
  await db.collection("subscription_plans").doc(planId).set({
    name: "Growth",
    price: 550000,
    currency: "UGX",
    includedFeatures: ["reportCards", "attendance"],
  });
}

async function seedAdmin(uid, schoolId, role = "schoolAdmin") {
  await db.collection("users").doc(uid).set({
    schoolId,
    role,
    roles: [role],
    isActive: true,
    name: "Test Admin",
  });
}

async function seedYearAndTerms(schoolId, yearId, terms) {
  await db.collection("academic_years").doc(yearId).set({
    schoolId,
    name: "2026",
    startDate: admin.firestore.Timestamp.fromDate(new Date("2026-01-01")),
    endDate: admin.firestore.Timestamp.fromDate(new Date("2026-12-15")),
    isCurrent: true,
    isArchived: false,
  });
  for (const t of terms) {
    await db.collection("academic_terms").doc(t.id).set({
      schoolId,
      academicYearId: yearId,
      name: t.name,
      order: t.order,
      startDate: admin.firestore.Timestamp.fromDate(t.start),
      endDate: admin.firestore.Timestamp.fromDate(t.end),
      isCurrent: false,
      isArchived: false,
      isConfirmed: false,
    });
  }
}

const req = (uid, data) => ({ auth: uid ? { uid } : null, data });

// v2 onCall exports are a CloudFunction object, not a plain async function
// - it exposes a `.run(request)` method for direct invocation in tests
// (see create_staff_account.emulator.test.cjs for the same pattern).
function handlerOf(exported) {
  return (request) => exported.run(request);
}

describe("confirmAcademicCalendar", () => {
  beforeEach(clearFirestore);

  test("generates one subscription_cycles doc per confirmed term", async () => {
    await seedSchool(SCHOOL_A);
    await seedAdmin("adminA", SCHOOL_A);
    await seedYearAndTerms(SCHOOL_A, "yearA", [
      { id: "termA1", name: "Term 1", order: 1, start: new Date("2026-01-10"), end: new Date("2026-04-10") },
      { id: "termA2", name: "Term 2", order: 2, start: new Date("2026-05-01"), end: new Date("2026-08-10") },
      { id: "termA3", name: "Term 3", order: 3, start: new Date("2026-09-01"), end: new Date("2026-12-10") },
    ]);

    const handler = handlerOf(billing.confirmAcademicCalendar);
    const result = await handler(req("adminA", { schoolId: SCHOOL_A }));
    assert.equal(result.ok, true);
    assert.equal(result.confirmedTermIds.length, 3);
    assert.equal(result.cycleIds.length, 3);

    for (const termId of ["termA1", "termA2", "termA3"]) {
      const cycleSnap = await db.collection("subscription_cycles").doc(`${SCHOOL_A}_${termId}`).get();
      assert.equal(cycleSnap.exists, true);
      assert.equal(cycleSnap.data().cycleStatus, "upcoming");
      assert.equal(cycleSnap.data().paymentStatus, "unpaid");
      assert.equal(cycleSnap.data().invoiceIssuedAt, null);
      const termSnap = await db.collection("academic_terms").doc(termId).get();
      assert.equal(termSnap.data().isConfirmed, true);
    }
  });

  test("re-confirm is idempotent - no duplicate cycle docs, createdAt is preserved", async () => {
    await seedSchool(SCHOOL_A);
    await seedAdmin("adminA", SCHOOL_A);
    await seedYearAndTerms(SCHOOL_A, "yearA", [
      { id: "termA1", name: "Term 1", order: 1, start: new Date("2026-01-10"), end: new Date("2026-04-10") },
    ]);

    const handler = handlerOf(billing.confirmAcademicCalendar);
    await handler(req("adminA", { schoolId: SCHOOL_A }));
    const firstSnap = await db.collection("subscription_cycles").doc(`${SCHOOL_A}_termA1`).get();
    const firstCreatedAt = firstSnap.data().createdAt;

    await handler(req("adminA", { schoolId: SCHOOL_A }));
    const allCycles = await db.collection("subscription_cycles").where("schoolId", "==", SCHOOL_A).get();
    assert.equal(allCycles.size, 1);
    const secondSnap = await db.collection("subscription_cycles").doc(`${SCHOOL_A}_termA1`).get();
    assert.deepEqual(secondSnap.data().createdAt, firstCreatedAt);
  });

  test("different schools get different paymentDueAt/graceEndsAt derived from their own term dates", async () => {
    await seedSchool(SCHOOL_A);
    await seedSchool(SCHOOL_B);
    await seedAdmin("adminA", SCHOOL_A);
    await seedAdmin("adminB", SCHOOL_B);
    await seedYearAndTerms(SCHOOL_A, "yearA", [
      { id: "termA1", name: "Term 1", order: 1, start: new Date("2026-01-10"), end: new Date("2026-04-10") },
    ]);
    await seedYearAndTerms(SCHOOL_B, "yearB", [
      { id: "termB1", name: "Term 1", order: 1, start: new Date("2026-02-15"), end: new Date("2026-05-15") },
    ]);

    const handler = handlerOf(billing.confirmAcademicCalendar);
    await handler(req("adminA", { schoolId: SCHOOL_A }));
    await handler(req("adminB", { schoolId: SCHOOL_B }));

    const cycleA = (await db.collection("subscription_cycles").doc(`${SCHOOL_A}_termA1`).get()).data();
    const cycleB = (await db.collection("subscription_cycles").doc(`${SCHOOL_B}_termB1`).get()).data();

    assert.notDeepEqual(cycleA.paymentDueAt, cycleB.paymentDueAt);
    assert.notDeepEqual(cycleA.graceEndsAt, cycleB.graceEndsAt);
    // paymentDueAt == termStart; graceEndsAt == termStart + default 7 days.
    assert.deepEqual(cycleA.paymentDueAt.toDate(), new Date("2026-01-10"));
    const expectedGraceA = new Date("2026-01-10");
    expectedGraceA.setDate(expectedGraceA.getDate() + 7);
    assert.deepEqual(cycleA.graceEndsAt.toDate(), expectedGraceA);
  });

  test("cross-tenant denial: School A admin cannot confirm School B's calendar", async () => {
    await seedSchool(SCHOOL_A);
    await seedSchool(SCHOOL_B);
    await seedAdmin("adminA", SCHOOL_A);
    await seedYearAndTerms(SCHOOL_B, "yearB", [
      { id: "termB1", name: "Term 1", order: 1, start: new Date("2026-01-10"), end: new Date("2026-04-10") },
    ]);

    const handler = handlerOf(billing.confirmAcademicCalendar);
    await assert.rejects(
      () => handler(req("adminA", { schoolId: SCHOOL_B })),
      /permission-denied|own school/i
    );
  });

  test("non-admin role is denied", async () => {
    await seedSchool(SCHOOL_A);
    await db.collection("users").doc("teacherA").set({
      schoolId: SCHOOL_A,
      role: "classTeacher",
      roles: ["classTeacher"],
      isActive: true,
    });
    await seedYearAndTerms(SCHOOL_A, "yearA", [
      { id: "termA1", name: "Term 1", order: 1, start: new Date("2026-01-10"), end: new Date("2026-04-10") },
    ]);

    const handler = handlerOf(billing.confirmAcademicCalendar);
    await assert.rejects(
      () => handler(req("teacherA", { schoolId: SCHOOL_A })),
      /permission-denied|school admin|head teacher|director/i
    );
  });

  test("unauthenticated caller is denied", async () => {
    const handler = handlerOf(billing.confirmAcademicCalendar);
    await assert.rejects(
      () => handler(req(null, { schoolId: SCHOOL_A })),
      /unauthenticated|must be signed in/i
    );
  });
});
