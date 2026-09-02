const test = require("node:test");
const assert = require("node:assert/strict");

function fakeAdmin() {
  const firestore = () => ({
    collection: () => ({
      doc: () => ({
        get: async () => ({ exists: false }),
        set: async () => {},
        delete: async () => {},
      }),
      where: function () { return this; },
      limit: function () { return this; },
      get: async () => ({ empty: true, size: 0, docs: [] }),
    }),
    collectionGroup: () => ({
      where: function () { return this; },
      limit: function () { return this; },
      get: async () => ({ empty: true, size: 0, docs: [] }),
    }),
  });
  firestore.FieldValue = { serverTimestamp: () => "SERVER_TIMESTAMP", increment: (n) => `INCREMENT(${n})` };
  firestore.Timestamp = { fromMillis: (ms) => ({ toMillis: () => ms }) };
  return {
    firestore,
    auth: () => ({ listUsers: async () => ({ users: [] }) }),
    storage: () => ({ bucket: () => null }),
  };
}

function buildModule(adminOverrides = {}) {
  const admin = { ...fakeAdmin(), ...adminOverrides };
  const onCall = (fn) => fn;
  const HttpsError = class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  };
  const requireOwner = async () => ({ uid: "owner-1" });
  const mod = require("../platform_health")({ admin, onCall, HttpsError, requireOwner });
  return { mod, admin, HttpsError };
}

test("rollup: all operational -> operational", () => {
  const { mod } = buildModule();
  const status = mod.__internal.rollup({
    a: { status: "operational" }, b: { status: "operational" },
  });
  assert.equal(status, "operational");
});

test("rollup: not_configured components are excluded from the pass/fail computation", () => {
  const { mod } = buildModule();
  const status = mod.__internal.rollup({
    a: { status: "operational" }, b: { status: "not_configured" },
  });
  assert.equal(status, "operational");
});

test("rollup: any configured outage makes the whole rollup outage", () => {
  const { mod } = buildModule();
  const status = mod.__internal.rollup({
    a: { status: "operational" }, b: { status: "outage" }, c: { status: "not_configured" },
  });
  assert.equal(status, "outage");
});

test("rollup: degraded or unknown (with no outage) makes the whole rollup degraded", () => {
  const { mod } = buildModule();
  assert.equal(mod.__internal.rollup({ a: { status: "degraded" } }), "degraded");
  assert.equal(mod.__internal.rollup({ a: { status: "unknown" } }), "degraded");
});

test("rollup: all not_configured (nothing configured at all) is treated as operational, not a false negative", () => {
  const { mod } = buildModule();
  const status = mod.__internal.rollup({
    a: { status: "not_configured" }, b: { status: "not_configured" },
  });
  assert.equal(status, "operational");
});

test("summarize: operational status produces the exact required sentence", () => {
  const { mod } = buildModule();
  const text = mod.__internal.summarize("operational", {});
  assert.equal(text, "All monitored services are operational.");
});

test("summarize: non-operational status reports a count, never raw internals", () => {
  const { mod } = buildModule();
  const text = mod.__internal.summarize("degraded", {
    a: { status: "operational" },
    b: { status: "degraded" },
    c: { status: "outage" },
    d: { status: "not_configured" },
  });
  assert.equal(text, "2 checks need attention.");
  assert.doesNotMatch(text, /error|Error|stack|Exception/);
});

test("summarize: singular phrasing for exactly one check needing attention", () => {
  const { mod } = buildModule();
  const text = mod.__internal.summarize("degraded", {
    a: { status: "degraded" }, b: { status: "operational" },
  });
  assert.equal(text, "1 check needs attention.");
});

test("withTimeout resolves to the fallback value when the wrapped promise never settles in time", async () => {
  const { mod } = buildModule();
  const neverResolves = new Promise(() => {});
  const result = await mod.__internal.withTimeout(neverResolves, 20, "fallback-value");
  assert.equal(result, "fallback-value");
});

test("withTimeout resolves to the real value when the wrapped promise settles first", async () => {
  const { mod } = buildModule();
  const fast = Promise.resolve("real-value");
  const result = await mod.__internal.withTimeout(fast, 1000, "fallback-value");
  assert.equal(result, "real-value");
});

test("jobStatus: no run yet -> unknown", () => {
  const { mod } = buildModule();
  const status = mod.__internal.jobStatus(null);
  assert.equal(status.status, "unknown");
});

test("jobStatus: last run failed -> degraded", () => {
  const { mod } = buildModule();
  const status = mod.__internal.jobStatus({
    lastStatus: "failure",
    lastRunAt: { toMillis: () => Date.now() },
    expectedIntervalMinutes: 15,
  });
  assert.equal(status.status, "degraded");
});

test("jobStatus: stale (last run more than 2x its expected interval ago) -> degraded", () => {
  const { mod } = buildModule();
  const status = mod.__internal.jobStatus({
    lastStatus: "success",
    lastRunAt: { toMillis: () => Date.now() - 45 * 60 * 1000 },
    expectedIntervalMinutes: 15,
  });
  assert.equal(status.status, "degraded");
});

test("jobStatus: recent success run -> operational", () => {
  const { mod } = buildModule();
  const status = mod.__internal.jobStatus({
    lastStatus: "success",
    lastRunAt: { toMillis: () => Date.now() },
    expectedIntervalMinutes: 15,
  });
  assert.equal(status.status, "operational");
});

test("worstOf: outage beats degraded beats unknown beats operational", () => {
  const { mod } = buildModule();
  assert.equal(mod.__internal.worstOf(["operational", "unknown", "degraded", "outage"]), "outage");
  assert.equal(mod.__internal.worstOf(["operational", "unknown", "degraded"]), "degraded");
  assert.equal(mod.__internal.worstOf(["operational", "unknown"]), "unknown");
  assert.equal(mod.__internal.worstOf(["operational"]), "operational");
});

test("safeMessage: falls back to the provided default for an empty/non-string value", () => {
  const { mod } = buildModule();
  assert.equal(mod.__internal.safeMessage("", "fallback"), "fallback");
  assert.equal(mod.__internal.safeMessage(null, "fallback"), "fallback");
  assert.equal(mod.__internal.safeMessage(undefined, "fallback"), "fallback");
});

test("safeMessage: truncates to 300 characters", () => {
  const { mod } = buildModule();
  const long = "x".repeat(1000);
  assert.equal(mod.__internal.safeMessage(long, "fallback").length, 300);
});

test("checkPlatformHealth requires the real requireOwner guard, not a bespoke check", async () => {
  let called = false;
  const admin = fakeAdmin();
  const onCall = (fn) => fn;
  const HttpsError = class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  };
  const requireOwner = async () => { called = true; return { uid: "owner-1" }; };
  const mod = require("../platform_health")({ admin, onCall, HttpsError, requireOwner });
  await mod.checkPlatformHealth({ auth: { uid: "owner-1" } });
  assert.equal(called, true, "checkPlatformHealth must call requireOwner");
});

test("checkPlatformHealth never leaks a raw error/stack to the caller on an unexpected failure", async () => {
  const admin = fakeAdmin();
  admin.firestore = () => { throw new Error("some internal database secret detail"); };
  const onCall = (fn) => fn;
  const HttpsError = class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  };
  const requireOwner = async () => ({ uid: "owner-1" });
  const mod = require("../platform_health")({ admin, onCall, HttpsError, requireOwner });
  await assert.rejects(
    () => mod.checkPlatformHealth({ auth: { uid: "owner-1" } }),
    (err) => {
      assert.ok(err instanceof HttpsError);
      assert.equal(err.code, "internal");
      assert.doesNotMatch(err.message, /secret|database|internal database/i);
      return true;
    },
  );
});
