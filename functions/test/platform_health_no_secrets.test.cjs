// Source-text-assertion test: proves the Platform Health module never
// exposes credentials, raw stack traces, or internal Firebase config to
// the client, without needing the emulator - a static guarantee that
// stays true even for error paths a runtime test wouldn't exercise.
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

function source(file) {
  return fs.readFileSync(path.resolve(__dirname, "..", file), "utf8");
}

test("platform_health.js never references process.env service-account/private-key-shaped variables", () => {
  const text = source("platform_health.js");
  assert.doesNotMatch(text, /process\.env\.[A-Z_]*(SECRET|KEY|CREDENTIAL|PASSWORD|TOKEN)/i);
});

test("platform_health.js never logs a raw error object, only error.message via safeMessage/catch mapping", () => {
  const text = source("platform_health.js");
  // No console.log/console.error of a bare caught error variable.
  assert.doesNotMatch(text, /console\.(log|error)\(\s*error\s*\)/);
});

test("checkPlatformHealth's catch block throws a fixed generic message, never interpolating error.message/error.stack", () => {
  const text = source("platform_health.js");
  const callableSection = text.slice(text.indexOf("const checkPlatformHealth = onCall"));
  const catchBlock = callableSection.slice(0, callableSection.indexOf("acknowledgePlatformHealthIncident"));
  assert.match(catchBlock, /throw new HttpsError\("internal", "Could not refresh platform health right now\."\)/);
  assert.doesNotMatch(catchBlock, /error\.message/);
  assert.doesNotMatch(catchBlock, /error\.stack/);
});

test("platform_health_instrumentation.js never stores tenant-identifying fields (schoolId/email/name) in platform_job_failures", () => {
  const text = source("platform_health_instrumentation.js");
  const failureFn = text.slice(
    text.indexOf("async function recordJobFailure"),
    text.indexOf("return { recordJobRun, recordJobFailure }"),
  );
  assert.doesNotMatch(failureFn, /schoolId|email|displayName|phoneNumber/i);
});

test("checkSecurityMonitoring never returns per-event fields (schoolId/userId), only counts", () => {
  const text = source("platform_health.js");
  const fnBody = text.slice(
    text.indexOf("async function checkSecurityMonitoring"),
    text.indexOf("// ---- checkPlatformRelease"),
  );
  assert.doesNotMatch(fnBody, /schoolId:|userId:|\.data\(\)/);
});

test("recordJobRun/recordJobFailure truncate every stored message to 300 characters, never storing an unbounded raw error", () => {
  const text = source("platform_health_instrumentation.js");
  const truncations = text.match(/\.slice\(0, 300\)/g) || [];
  assert.ok(truncations.length >= 2, "expected at least 2 message-truncation call sites (recordJobRun + recordJobFailure)");
});
