// Firebase Emulator integration test for
// functions/student_pricing_bands.js's owner-only CRUD callables
// (createPricingBand, updatePricingBand, deactivatePricingBand,
// getPricingBands) - Phase 3A of the pricing-model replacement.
//
// Run: `npm run test:student-pricing-bands:emulator` (if added to
// package.json) or directly:
//   PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH" /opt/homebrew/bin/firebase \
//     emulators:exec --only firestore,auth \
//     --project demo-student-pricing-bands-test \
//     "node --test test/student_pricing_bands.emulator.test.cjs"
// (requires JDK 21+, run from functions/).
//
// Authorization is via vendor/owner-auth's requirePlatformOwner: the
// authenticated uid must equal platform_config/owner_seed.ownerUid AND
// users/{uid} must carry an active owner/superAdmin role. Both conditions
// are seeded per-test below via seedOwner/seedNonOwner.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-student-pricing-bands-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

const bands = require("../student_pricing_bands");

const OWNER_UID = "ownerUser1";

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

async function seedOwner(uid = OWNER_UID) {
  await db.collection("platform_config").doc("owner_seed").set({
    seeded: true,
    ownerUid: uid,
  });
  await db.collection("users").doc(uid).set({
    isActive: true,
    role: "superAdmin",
    roles: ["superAdmin"],
    isSuperAdmin: true,
    name: "Platform Owner",
  });
}

async function seedSchoolAdmin(uid, schoolId = "schoolA") {
  await db.collection("users").doc(uid).set({
    schoolId,
    role: "schoolAdmin",
    roles: ["schoolAdmin"],
    isActive: true,
    name: "Test School Admin",
  });
}

async function seedStaff(uid, schoolId = "schoolA") {
  await db.collection("users").doc(uid).set({
    schoolId,
    role: "classTeacher",
    roles: ["classTeacher"],
    isActive: true,
    name: "Test Staff",
  });
}

const req = (uid, data) => ({ auth: uid ? { uid } : null, data });

// v2 onCall exports are a CloudFunction object with a `.run(request)` method
// for direct invocation - same pattern used by academic_calendar_billing and
// create_staff_account emulator tests in this repo.
function handlerOf(exported) {
  return (request) => exported.run(request);
}

describe("student_pricing_bands callables", () => {
  beforeEach(clearFirestore);

  describe("createPricingBand", () => {
    test("owner can create a valid non-overlapping band", async () => {
      await seedOwner();
      const handler = handlerOf(bands.createPricingBand);
      const result = await handler(
        req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })
      );
      assert.equal(result.ok, true);
      assert.ok(result.bandId);

      const snap = await db.collection("student_pricing_bands").doc(result.bandId).get();
      assert.equal(snap.exists, true);
      assert.equal(snap.data().minStudents, 0);
      assert.equal(snap.data().maxStudents, 50);
      assert.equal(snap.data().amountUgx, 200000);
      assert.equal(snap.data().isActive, true);
      assert.equal(snap.data().createdBy, OWNER_UID);
    });

    test("rejects an overlapping band against an existing active band", async () => {
      await seedOwner();
      const handler = handlerOf(bands.createPricingBand);
      await handler(req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 }));

      await assert.rejects(
        () => handler(req(OWNER_UID, { minStudents: 30, maxStudents: 80, amountUgx: 300000 })),
        /overlaps|already-exists|already exists/i
      );

      const allBands = await db.collection("student_pricing_bands").get();
      assert.equal(allBands.size, 1, "the rejected overlapping band must not have been persisted");
    });

    test("non-owner (school admin) is denied", async () => {
      await seedOwner();
      await seedSchoolAdmin("adminA");
      const handler = handlerOf(bands.createPricingBand);
      await assert.rejects(
        () => handler(req("adminA", { minStudents: 0, maxStudents: 50, amountUgx: 200000 })),
        /permission-denied|Access denied/i
      );
    });

    test("non-owner (staff) is denied", async () => {
      await seedOwner();
      await seedStaff("staffA");
      const handler = handlerOf(bands.createPricingBand);
      await assert.rejects(
        () => handler(req("staffA", { minStudents: 0, maxStudents: 50, amountUgx: 200000 })),
        /permission-denied|Access denied/i
      );
    });

    test("unauthenticated caller is denied", async () => {
      await seedOwner();
      const handler = handlerOf(bands.createPricingBand);
      await assert.rejects(
        () => handler(req(null, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })),
        /unauthenticated|Sign in/i
      );
    });
  });

  describe("updatePricingBand / immutability", () => {
    async function seedInvoicedBand() {
      const bandRef = db.collection("student_pricing_bands").doc("bandInvoiced");
      await bandRef.set({
        minStudents: 0,
        maxStudents: 50,
        amountUgx: 200000,
        isActive: true,
        effectiveFrom: admin.firestore.Timestamp.now(),
        effectiveTo: null,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        createdBy: OWNER_UID,
        updatedBy: OWNER_UID,
      });
      await db.collection("subscription_cycles").doc("cycle1").set({
        schoolId: "schoolA",
        cycleStatus: "upcoming",
        invoiceIssuedAt: admin.firestore.Timestamp.now(),
        pricingSnapshot: {
          bandId: "bandInvoiced",
          minStudents: 0,
          maxStudents: 50,
          amountUgx: 200000,
        },
      });
      return bandRef;
    }

    test("owner cannot change amount/range of a band already referenced by an invoiced cycle", async () => {
      await seedOwner();
      await seedInvoicedBand();
      const handler = handlerOf(bands.updatePricingBand);

      await assert.rejects(
        () => handler(req(OWNER_UID, { bandId: "bandInvoiced", amountUgx: 999999 })),
        /immutable|failed-precondition/i
      );

      const snap = await db.collection("student_pricing_bands").doc("bandInvoiced").get();
      assert.equal(snap.data().amountUgx, 200000, "amount must remain unchanged after the rejected update");
    });

    test("owner cannot change minStudents/maxStudents of an invoiced band", async () => {
      await seedOwner();
      await seedInvoicedBand();
      const handler = handlerOf(bands.updatePricingBand);

      await assert.rejects(
        () => handler(req(OWNER_UID, { bandId: "bandInvoiced", maxStudents: 60 })),
        /immutable|failed-precondition/i
      );
    });

    test("owner CAN change isActive on an invoiced band (does not touch priced range)", async () => {
      await seedOwner();
      await seedInvoicedBand();
      const handler = handlerOf(bands.updatePricingBand);

      const result = await handler(req(OWNER_UID, { bandId: "bandInvoiced", isActive: false }));
      assert.equal(result.ok, true);
      const snap = await db.collection("student_pricing_bands").doc("bandInvoiced").get();
      assert.equal(snap.data().isActive, false);
      assert.equal(snap.data().amountUgx, 200000);
    });

    test("owner can update a non-invoiced band's amount/range", async () => {
      await seedOwner();
      const createHandler = handlerOf(bands.createPricingBand);
      const created = await createHandler(
        req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })
      );

      const updateHandler = handlerOf(bands.updatePricingBand);
      const result = await updateHandler(
        req(OWNER_UID, { bandId: created.bandId, amountUgx: 250000 })
      );
      assert.equal(result.ok, true);
      const snap = await db.collection("student_pricing_bands").doc(created.bandId).get();
      assert.equal(snap.data().amountUgx, 250000);
    });

    test("non-owner (school admin) is denied on updatePricingBand", async () => {
      await seedOwner();
      await seedSchoolAdmin("adminA");
      const bandRef = await seedInvoicedBand();
      const handler = handlerOf(bands.updatePricingBand);
      await assert.rejects(
        () => handler(req("adminA", { bandId: bandRef.id, isActive: false })),
        /permission-denied|Access denied/i
      );
    });

    test("unauthenticated caller is denied on updatePricingBand", async () => {
      await seedOwner();
      const bandRef = await seedInvoicedBand();
      const handler = handlerOf(bands.updatePricingBand);
      await assert.rejects(
        () => handler(req(null, { bandId: bandRef.id, isActive: false })),
        /unauthenticated|Sign in/i
      );
    });
  });

  describe("deactivatePricingBand", () => {
    test("owner can deactivate a band", async () => {
      await seedOwner();
      const createHandler = handlerOf(bands.createPricingBand);
      const created = await createHandler(
        req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })
      );

      const handler = handlerOf(bands.deactivatePricingBand);
      const result = await handler(req(OWNER_UID, { bandId: created.bandId }));
      assert.equal(result.ok, true);
      assert.ok(Array.isArray(result.resultingGaps));

      const snap = await db.collection("student_pricing_bands").doc(created.bandId).get();
      assert.equal(snap.data().isActive, false);
    });

    test("non-owner (school admin) is denied", async () => {
      await seedOwner();
      await seedSchoolAdmin("adminA");
      const createHandler = handlerOf(bands.createPricingBand);
      const created = await createHandler(
        req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })
      );

      const handler = handlerOf(bands.deactivatePricingBand);
      await assert.rejects(
        () => handler(req("adminA", { bandId: created.bandId })),
        /permission-denied|Access denied/i
      );
    });

    test("non-owner (staff) is denied", async () => {
      await seedOwner();
      await seedStaff("staffA");
      const createHandler = handlerOf(bands.createPricingBand);
      const created = await createHandler(
        req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })
      );

      const handler = handlerOf(bands.deactivatePricingBand);
      await assert.rejects(
        () => handler(req("staffA", { bandId: created.bandId })),
        /permission-denied|Access denied/i
      );
    });

    test("unauthenticated caller is denied", async () => {
      await seedOwner();
      const createHandler = handlerOf(bands.createPricingBand);
      const created = await createHandler(
        req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 })
      );

      const handler = handlerOf(bands.deactivatePricingBand);
      await assert.rejects(
        () => handler(req(null, { bandId: created.bandId })),
        /unauthenticated|Sign in/i
      );
    });
  });

  describe("getPricingBands", () => {
    test("readable by any authenticated staff user (non-owner, non-admin)", async () => {
      await seedOwner();
      await seedStaff("staffA");
      const createHandler = handlerOf(bands.createPricingBand);
      await createHandler(req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 }));

      const handler = handlerOf(bands.getPricingBands);
      const result = await handler(req("staffA", {}));
      assert.equal(result.ok, true);
      assert.equal(result.bands.length, 1);
      assert.ok(Array.isArray(result.gaps));
    });

    test("readable by a school admin too", async () => {
      await seedOwner();
      await seedSchoolAdmin("adminA");
      const createHandler = handlerOf(bands.createPricingBand);
      await createHandler(req(OWNER_UID, { minStudents: 0, maxStudents: 50, amountUgx: 200000 }));

      const handler = handlerOf(bands.getPricingBands);
      const result = await handler(req("adminA", {}));
      assert.equal(result.ok, true);
      assert.equal(result.bands.length, 1);
    });

    test("unauthenticated caller is denied", async () => {
      const handler = handlerOf(bands.getPricingBands);
      await assert.rejects(
        () => handler(req(null, {})),
        /unauthenticated|must be signed in/i
      );
    });
  });
});
