// Firebase Emulator integration test for functions/staff_attendance_corrections.js.
//
// Run: `npm run test:staff-attendance-corrections:emulator`. Requires the
// Firestore emulator. The module is required directly with `onCall: h => h`
// so the real Admin SDK transaction logic (auth narrowing, tenant
// isolation, idempotency, trail + audit in one transaction) runs against
// the emulator exactly as the deployed function does.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-staff-attendance-corrections-test";
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
const fns = require("../staff_attendance_corrections")({
  admin,
  onCall: (optsOrHandler, maybeHandler) =>
    typeof optsOrHandler === "function" ? optsOrHandler : maybeHandler,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const OTHER = "schoolB";
const ADMIN = "adminUid";
const HR = "hrUid";
const DEPUTY = "deputyUid";
const TEACHER = "teacherUid";
const FOREIGN = "foreignAdminUid";
const STAFF = "staff1";
const DAY = "2026-09-01";

const req = (uid, data) => ({ auth: uid ? { uid } : null, data });
const recordRef = () => db.collection("staff_attendance").doc(`${STAFF}_${DAY}`);
const trailCol = () =>
  db.collection(`institutions/${SCHOOL}/staff_attendance_corrections`);
const auditCol = () => db.collection(`institutions/${SCHOOL}/audit_events`);

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

async function seed() {
  await db.doc(`users/${ADMIN}`).set({ roles: ["schoolAdmin"], schoolId: SCHOOL, name: "Ada", isActive: true });
  await db.doc(`users/${HR}`).set({ roles: ["hrOfficer"], schoolId: SCHOOL, name: "Hank", isActive: true });
  await db.doc(`users/${DEPUTY}`).set({ roles: ["deputyHead"], schoolId: SCHOOL, name: "Dee", isActive: true });
  await db.doc(`users/${TEACHER}`).set({ roles: ["classTeacher"], schoolId: SCHOOL, name: "Tom", isActive: true });
  await db.doc(`users/${FOREIGN}`).set({ roles: ["schoolAdmin"], schoolId: OTHER, name: "Fay", isActive: true });
  await db.doc(`users/${STAFF}`).set({ roles: ["classTeacher"], schoolId: SCHOOL, name: "Sam", campusId: "campusMain" });
}

beforeEach(async () => {
  await clearFirestore();
  await seed();
});

const validPatch = {
  schoolId: SCHOOL,
  staffId: STAFF,
  day: DAY,
  reason: "Forgot to clock in; verified with gate log.",
  patch: { status: "late", clockIn: "2026-09-01T08:45:00.000Z" },
};

describe("correctStaffAttendance — happy path", () => {
  test("creates the record, an immutable trail doc, and an audit event", async () => {
    const res = await fns.correctStaffAttendance(req(ADMIN, validPatch));
    assert.equal(res.ok, true);
    assert.equal(res.recordId, `${STAFF}_${DAY}`);

    const rec = (await recordRef().get()).data();
    assert.equal(rec.schoolId, SCHOOL);
    assert.equal(rec.staffId, STAFF);
    assert.equal(rec.campusId, "campusMain"); // resolved server-side
    assert.equal(rec.status, "late");
    assert.equal(rec.lastCorrectedBy, ADMIN);
    assert.ok(rec.lastCorrectionAt);

    const trail = await trailCol().get();
    assert.equal(trail.size, 1);
    const t = trail.docs[0].data();
    assert.equal(t.actorId, ADMIN);
    assert.equal(t.reason, validPatch.reason);
    // A new record also gets the default location written, and the trail
    // must list every field the write actually set.
    assert.equal(rec.location, "Main Gate");
    assert.deepEqual(t.changedFields.sort(), ["clockIn", "location", "status"].sort());
    assert.equal(t.before, null);

    const audit = await auditCol().where("action", "==", "staff_attendance.corrected").get();
    assert.equal(audit.size, 1);
    assert.equal(audit.docs[0].data().metadata.staffId, STAFF);
  });

  test("hrOfficer may also correct", async () => {
    const res = await fns.correctStaffAttendance(req(HR, validPatch));
    assert.equal(res.ok, true);
  });

  test("re-call updates in place (idempotent doc id) and appends a second trail row", async () => {
    await fns.correctStaffAttendance(req(ADMIN, validPatch));
    await fns.correctStaffAttendance(
      req(ADMIN, { ...validPatch, patch: { status: "absent" }, reason: "Confirmed absent." })
    );
    const all = await db.collection("staff_attendance").get();
    assert.equal(all.size, 1);
    assert.equal((await recordRef().get()).data().status, "absent");
    assert.equal((await trailCol().get()).size, 2);
  });
});

describe("correctStaffAttendance — authorisation", () => {
  test("unauthenticated is rejected", async () => {
    await assert.rejects(() => fns.correctStaffAttendance(req(null, validPatch)), /signed in/);
  });

  test("a deputy head (view-only) cannot correct", async () => {
    await assert.rejects(
      () => fns.correctStaffAttendance(req(DEPUTY, validPatch)),
      /may correct staff attendance/
    );
  });

  test("a class teacher cannot correct", async () => {
    await assert.rejects(() => fns.correctStaffAttendance(req(TEACHER, validPatch)), /may correct/);
  });

  test("a foreign-school admin cannot correct this school", async () => {
    await assert.rejects(
      () => fns.correctStaffAttendance(req(FOREIGN, validPatch)),
      /your own school/
    );
  });

  test("correcting a staff member from another school is rejected", async () => {
    await db.doc("users/otherStaff").set({ roles: ["classTeacher"], schoolId: OTHER, name: "Zoe" });
    await assert.rejects(
      () => fns.correctStaffAttendance(req(ADMIN, { ...validPatch, staffId: "otherStaff" })),
      /not part of this school/
    );
  });
});

describe("correctStaffAttendance — validation", () => {
  test("a reason is required", async () => {
    await assert.rejects(
      () => fns.correctStaffAttendance(req(ADMIN, { ...validPatch, reason: "  " })),
      /reason is required/
    );
  });

  test("a future day is rejected", async () => {
    await assert.rejects(
      () => fns.correctStaffAttendance(req(ADMIN, { ...validPatch, day: "2999-01-01" })),
      /future date/
    );
  });

  test("a malformed day is rejected", async () => {
    await assert.rejects(
      () => fns.correctStaffAttendance(req(ADMIN, { ...validPatch, day: "01/09/2026" })),
      /YYYY-MM-DD/
    );
  });

  test("an unknown status is rejected", async () => {
    await assert.rejects(
      () => fns.correctStaffAttendance(req(ADMIN, { ...validPatch, patch: { status: "vacation" } })),
      /status must be one of/
    );
  });

  test("clock-out before clock-in is rejected", async () => {
    await assert.rejects(
      () =>
        fns.correctStaffAttendance(
          req(ADMIN, {
            ...validPatch,
            patch: {
              status: "on_time",
              clockIn: "2026-09-01T09:00:00.000Z",
              clockOut: "2026-09-01T08:00:00.000Z",
            },
          })
        ),
      /before clock-in/
    );
  });
});
