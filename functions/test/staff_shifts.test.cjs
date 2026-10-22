// Credential-free unit tests for functions/staff_shifts.js. Mirrors
// staff_attendance_corrections.test.cjs's approach: exercise the pure guards
// without an emulator.
const assert = require("node:assert/strict");
const test = require("node:test");

const moduleFactory = require("../staff_shifts");
const admin = {
  firestore: () => ({}),
};
admin.firestore.FieldValue = { serverTimestamp: () => "ts" };

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

test("corrector role set matches staff_attendance_corrections' role gate", () => {
  const roles = api.__test__.CORRECTOR_ROLES;
  assert.ok(roles.has("schoolAdmin"));
  assert.ok(roles.has("headTeacher"));
  assert.ok(roles.has("director"));
  assert.ok(roles.has("hrOfficer"));
  assert.ok(!roles.has("deputyHead"));
});

test("requireCorrector rejects an unauthenticated request", async () => {
  await assert.rejects(
    () => api.__test__.requireCorrector({ auth: null }, "schoolA"),
    /signed in/
  );
});

test("parseTimeOfDay accepts a valid 24-hour time", () => {
  assert.equal(api.__test__.parseTimeOfDay("08:00", "scheduledStart"), "08:00");
  assert.equal(api.__test__.parseTimeOfDay("23:59", "scheduledStart"), "23:59");
});

test("parseTimeOfDay rejects malformed times", () => {
  for (const bad of ["8:00", "25:00", "08:60", "", "noon"]) {
    assert.throws(
      () => api.__test__.parseTimeOfDay(bad, "scheduledStart"),
      /24-hour time/
    );
  }
});

test("parseDaysOfWeek dedupes and sorts valid entries", () => {
  assert.deepEqual(api.__test__.parseDaysOfWeek([3, 1, 3, 5]), [1, 3, 5]);
});

test("parseDaysOfWeek rejects an empty array or out-of-range values", () => {
  assert.throws(() => api.__test__.parseDaysOfWeek([]), /non-empty array/);
  assert.throws(() => api.__test__.parseDaysOfWeek([0]), /integers 1-7/);
  assert.throws(() => api.__test__.parseDaysOfWeek([8]), /integers 1-7/);
});
