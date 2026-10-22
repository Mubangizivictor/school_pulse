// Credential-free unit tests for functions/staff_attendance_corrections.js.
// Exercises the pure guards (role set, settable-status set) without an
// emulator - mirrors enrollment_audit.test.cjs's approach. The full
// transaction behaviour is covered by
// staff_attendance_corrections.emulator.test.cjs.
const assert = require("node:assert/strict");
const test = require("node:test");

const moduleFactory = require("../staff_attendance_corrections");
const admin = {
  firestore: () => ({}),
};
admin.firestore.FieldValue = { serverTimestamp: () => "ts" };
admin.firestore.Timestamp = { fromDate: (d) => ({ __date: d }) };

const api = moduleFactory({
  admin,
  onCall: (optsOrHandler, maybeHandler) =>
    typeof optsOrHandler === "function" ? optsOrHandler : maybeHandler,
  HttpsError: class extends Error {
    constructor(code, message) {
      super(message);
      this.code = code;
    }
  },
});

test("corrector role set is HR/admin leadership only - deputy head excluded", () => {
  const roles = api.__test__.CORRECTOR_ROLES;
  assert.ok(roles.has("schoolAdmin"));
  assert.ok(roles.has("headTeacher"));
  assert.ok(roles.has("director"));
  assert.ok(roles.has("hrOfficer"));
  assert.ok(!roles.has("deputyHead"));
  assert.ok(!roles.has("classTeacher"));
  assert.ok(!roles.has("bursar"));
});

test("settable status set excludes not_clocked_in", () => {
  const s = api.__test__.SETTABLE_STATUS;
  assert.deepEqual(
    [...s].sort(),
    ["absent", "late", "on_leave", "on_time"].sort()
  );
  assert.ok(!s.has("not_clocked_in"));
});

test("requireCorrector rejects an unauthenticated request before any Firestore read", async () => {
  await assert.rejects(
    () => api.__test__.requireCorrector({ auth: null }, "schoolA"),
    /signed in/
  );
});

test("requireCorrector rejects a missing schoolId", async () => {
  await assert.rejects(
    () => api.__test__.requireCorrector({ auth: { uid: "u" } }, ""),
    /schoolId is required/
  );
});

test("clockIn rejects an unauthenticated request", async () => {
  await assert.rejects(
    () => api.__test__.clockIn({ auth: null, data: { schoolId: "schoolA", staffId: "s1" } }),
    /signed in/
  );
});

test("clockIn rejects a missing staffId before checking auth role", async () => {
  await assert.rejects(
    () => api.__test__.clockIn({ auth: { uid: "u" }, data: { schoolId: "schoolA" } }),
    /staffId is required/
  );
});

test("deriveStatus falls back to on_time when the staff has no shift doc", async () => {
  const leaveQuery = {
    where: () => leaveQuery,
    get: async () => ({ docs: [] }),
  };
  const shiftDocRef = { get: async () => ({ exists: false }) };
  const institutionSubcollections = {
    staff_leave_requests: leaveQuery,
    staff_shifts: { doc: () => shiftDocRef },
  };
  const fakeDb = {
    collection: () => ({
      doc: () => ({
        collection: (name) => institutionSubcollections[name],
      }),
    }),
  };
  const status = await api.__test__.deriveStatus({
    db: fakeDb,
    schoolId: "schoolA",
    staffId: "s1",
    day: "2026-09-16",
    clockIn: new Date("2026-09-16T08:00:00"),
  });
  assert.equal(status, "on_time");
});
