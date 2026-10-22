const test = require("node:test");
const assert = require("node:assert/strict");

// A minimal fake admin.firestore() that records set()/add() calls without a
// real Firestore connection - proves recordJobRun/recordJobFailure write
// the right shape and never let a raw error/stack leak into lastError,
// without needing the emulator for pure logic.
function fakeAdmin() {
  const writes = [];
  const firestore = () => ({
    collection: (name) => ({
      doc: (id) => ({
        set: async (data, opts) => {
          writes.push({ collection: name, id, data, opts });
        },
      }),
      add: async (data) => {
        writes.push({ collection: name, id: null, data });
      },
    }),
  });
  firestore.FieldValue = { serverTimestamp: () => "SERVER_TIMESTAMP" };
  return { admin: { firestore }, writes };
}

const buildInstrumentation = require("../platform_health_instrumentation");

test("recordJobRun records a success run with the job's own return value passed through", async () => {
  const { admin, writes } = fakeAdmin();
  const { recordJobRun } = buildInstrumentation({ admin });
  const result = await recordJobRun("testJob", 15, async () => "ok");
  assert.equal(result, "ok");
  assert.equal(writes.length, 1);
  assert.equal(writes[0].collection, "job_runs");
  assert.equal(writes[0].id, "testJob");
  assert.equal(writes[0].data.lastStatus, "success");
  assert.equal(writes[0].data.lastError, null);
  assert.equal(writes[0].data.expectedIntervalMinutes, 15);
  assert.equal(writes[0].opts.merge, true);
});

test("recordJobRun records a failure run and rethrows the original error unchanged", async () => {
  const { admin, writes } = fakeAdmin();
  const { recordJobRun } = buildInstrumentation({ admin });
  const boom = new Error("boom");
  await assert.rejects(
    () => recordJobRun("testJob", 5, async () => { throw boom; }),
    (err) => err === boom, // exact same error object/rethrow, not wrapped
  );
  assert.equal(writes[0].data.lastStatus, "failure");
  assert.equal(writes[0].data.lastError, "boom");
});

test("recordJobRun truncates a long error message and never stores a stack trace", async () => {
  const { admin, writes } = fakeAdmin();
  const { recordJobRun } = buildInstrumentation({ admin });
  const longMessage = "x".repeat(1000);
  await assert.rejects(() => recordJobRun("testJob", 5, async () => {
    throw new Error(longMessage);
  }));
  assert.equal(writes[0].data.lastError.length, 300);
  assert.ok(!writes[0].data.lastError.includes("at Object"), "must not contain a stack-trace-looking substring");
});

test("recordJobFailure writes category/source/referenceId/message with no tenant-identifying fields", async () => {
  const { admin, writes } = fakeAdmin();
  const { recordJobFailure } = buildInstrumentation({ admin });
  await recordJobFailure("payment_processing", "initiateMobileMoneyCharge", "txn-123", "Provider timeout");
  assert.equal(writes.length, 1);
  assert.equal(writes[0].collection, "platform_job_failures");
  assert.deepEqual(Object.keys(writes[0].data).sort(), ["category", "createdAt", "message", "referenceId", "source"]);
  assert.equal(writes[0].data.category, "payment_processing");
  assert.equal(writes[0].data.referenceId, "txn-123");
});

test("recordJobFailure truncates a long message and defaults a missing referenceId to null", async () => {
  const { admin, writes } = fakeAdmin();
  const { recordJobFailure } = buildInstrumentation({ admin });
  await recordJobFailure("school_onboarding", "provisionSchoolAdmin", undefined, "x".repeat(1000));
  assert.equal(writes[0].data.referenceId, null);
  assert.equal(writes[0].data.message.length, 300);
});
