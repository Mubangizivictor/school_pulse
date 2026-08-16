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

test("emergency alerts require send_emergency; other types require publish", () => {
  assert.equal(__internal.requiredPublishPermission({ communicationType: "emergencyAlert" }), "communications.send_emergency");
  assert.equal(__internal.requiredPublishPermission({ communicationType: "announcement" }), "communications.publish");
});

test("default role grants short-circuit the Firestore override lookup", async () => {
  // schoolAdmin/director/headTeacher/deputyHead get every communications.*
  // permission without a role_permission_overrides read; securityHead only
  // gets communications.send_emergency this way. This mirrors
  // lib/core/permissions/role_permission_defaults.dart so the two never
  // silently drift apart.
  for (const role of __internal.communicationsAdminRoles) {
    assert.equal(await __internal.callerHasPermission("school-a", { role }, "communications.publish"), true);
  }
  assert.equal(await __internal.callerHasPermission("school-a", { role: "securityHead" }, "communications.send_emergency"), true);
});
