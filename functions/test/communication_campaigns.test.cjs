const test = require("node:test");
const assert = require("node:assert/strict");
const { __internal } = require("../communication_campaigns");

test("campaign request is bound to one versioned idempotency key", () => {
  const request = __internal.requestPayload({
    schoolId: "school-a", senderId: "admin-a", senderNameSnapshot: "Admin",
    title: "Closure", body: "School is closed today.", audienceDefinition: { kind: "all_parents" },
    version: 2, communicationType: "emergencyAlert", acknowledgementRequired: true,
  }, "campaign-a");
  assert.equal(request.idempotencyKey, "campaign:campaign-a:v2");
  assert.equal(request.category, "emergency");
  assert.equal(request.requiresAcknowledgment, true);
});

test("combined audiences reject nested or empty definitions", () => {
  assert.throws(() => __internal.assertSafeCampaign({
    title: "Notice", body: "Body", audienceDefinition: { kind: "anyOf", definitions: [] },
  }));
  assert.throws(() => __internal.assertSafeCampaign({
    title: "Notice", body: "Body", audienceDefinition: { kind: "anyOf", definitions: [{ kind: "anyOf" }] },
  }));
});

test("scheduled timestamps accept ISO input and reject invalid dates", () => {
  assert.equal(__internal.optionalTimestamp("2026-12-01T10:00:00Z", "scheduledAt").toDate().toISOString(), "2026-12-01T10:00:00.000Z");
  assert.throws(() => __internal.optionalTimestamp("not-a-date", "scheduledAt"));
});
