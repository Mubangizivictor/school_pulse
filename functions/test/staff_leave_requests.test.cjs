// Credential-free unit tests for functions/staff_leave_requests.js.
// Exercises the pure guards without an emulator; transaction/idempotency
// behaviour of decideStaffLeave needs the emulator (out of scope here, same
// split as staff_attendance_corrections.test.cjs / .emulator.test.cjs).
const assert = require("node:assert/strict");
const test = require("node:test");

const moduleFactory = require("../staff_leave_requests");
const admin = { firestore: () => ({}) };
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

test("corrector role set matches the rest of staff attendance's role gate", () => {
  const roles = api.__test__.CORRECTOR_ROLES;
  assert.ok(roles.has("schoolAdmin"));
  assert.ok(roles.has("hrOfficer"));
  assert.ok(!roles.has("deputyHead"));
});

test("hasCorrectorRole checks both role and roles[]", () => {
  assert.ok(api.__test__.hasCorrectorRole({ role: "hrOfficer" }));
  assert.ok(api.__test__.hasCorrectorRole({ role: "classTeacher", roles: ["classTeacher", "director"] }));
  assert.ok(!api.__test__.hasCorrectorRole({ role: "classTeacher", roles: ["classTeacher"] }));
});

test("requireActiveMember rejects an unauthenticated request", async () => {
  await assert.rejects(
    () => api.__test__.requireActiveMember({ auth: null }, "schoolA"),
    /signed in/
  );
});

test("requireActiveMember rejects a missing schoolId", async () => {
  await assert.rejects(
    () => api.__test__.requireActiveMember({ auth: { uid: "u" } }, ""),
    /schoolId is required/
  );
});
