/**
 * Communication campaigns are an orchestration layer over notifications.
 * They never send a push, email or SMS themselves: publication creates one
 * idempotent notification_request, which the existing delivery service owns.
 */
const { onCall } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

const db = () => admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const leadership = new Set(["schoolAdmin", "director", "headTeacher", "deputyHead"]);
const emergencyRoles = new Set([...leadership, "securityHead"]);
const statuses = new Set([
  "draft", "pendingApproval", "approved", "scheduled", "publishing",
  "published", "partiallyDelivered", "delivered", "failed", "cancelled",
  "expired", "archived",
]);
const allowedAudiences = new Set([
  "school", "all_staff", "all_parents", "students", "roles", "users",
  "class_parents", "student_parents", "anyOf",
]);

function callerRole(user) {
  return user.role || (user.roles || [])[0] || "";
}
function canPublish(user, campaign) {
  const role = callerRole(user);
  if (campaign.communicationType === "emergencyAlert") return emergencyRoles.has(role);
  return leadership.has(role);
}
function assertSafeCampaign(input) {
  if (!input || typeof input !== "object") throw new HttpsError("invalid-argument", "campaign is required.");
  if (typeof input.title !== "string" || !input.title.trim() || input.title.length > 160) {
    throw new HttpsError("invalid-argument", "A title of up to 160 characters is required.");
  }
  if (typeof input.body !== "string" || !input.body.trim() || input.body.length > 12000) {
    throw new HttpsError("invalid-argument", "Message body is required.");
  }
  if (!allowedAudiences.has(input.audienceDefinition && input.audienceDefinition.kind)) {
    throw new HttpsError("invalid-argument", "Unsupported audience definition.");
  }
  if (input.audienceDefinition.kind === "anyOf") {
    const definitions = input.audienceDefinition.definitions;
    if (!Array.isArray(definitions) || definitions.length === 0) {
      throw new HttpsError("invalid-argument", "A combined audience needs at least one scope.");
    }
    for (const definition of definitions) {
      if (!allowedAudiences.has(definition && definition.kind) || definition.kind === "anyOf") {
        throw new HttpsError("invalid-argument", "Unsupported audience scope.");
      }
    }
  }
  if (input.status && !statuses.has(input.status)) {
    throw new HttpsError("invalid-argument", "Unsupported campaign status.");
  }
}
function optionalTimestamp(value, field) {
  if (!value) return null;
  const date = value && typeof value.toDate === "function" ? value.toDate() : new Date(value);
  if (Number.isNaN(date.getTime())) throw new HttpsError("invalid-argument", `${field} must be a valid date.`);
  return admin.firestore.Timestamp.fromDate(date);
}
async function authenticatedCaller(request, schoolId) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to manage communications.");
  const userDoc = await db().collection("users").doc(request.auth.uid).get();
  if (!userDoc.exists || userDoc.data().schoolId !== schoolId) {
    throw new HttpsError("permission-denied", "The active institution does not match this campaign.");
  }
  const user = userDoc.data();
  if (user.status === "suspended" || user.disabled === true) {
    throw new HttpsError("permission-denied", "This account is not active.");
  }
  return { id: request.auth.uid, ...user };
}
function campaignRef(schoolId, campaignId) {
  return db().collection("schools").doc(schoolId).collection("communication_campaigns").doc(campaignId);
}
function notificationAudience(audience) {
  // These names deliberately match the existing notification resolver.
  return audience;
}
function requestPayload(campaign, campaignId) {
  return {
    schoolId: campaign.schoolId,
    status: "pending",
    senderId: campaign.senderId,
    senderNameSnapshot: campaign.senderNameSnapshot,
    senderRoleSnapshot: campaign.senderRoleSnapshot || null,
    category: campaign.communicationType === "emergencyAlert" ? "emergency" : "announcements",
    type: "announcement",
    title: campaign.title,
    shortBody: campaign.shortSummary || campaign.body.substring(0, 180),
    fullBody: campaign.body,
    audience: notificationAudience(campaign.audienceDefinition),
    priority: campaign.priority || "medium",
    imageUrl: campaign.imageUrl || null,
    attachments: campaign.attachmentRefs || [],
    expiresAt: campaign.expiresAt || null,
    requiresAcknowledgment: campaign.acknowledgementRequired === true,
    sourceModule: "communication_center",
    sourceEntityId: campaignId,
    deepLinkRoute: "/communications/" + campaignId,
    idempotencyKey: "campaign:" + campaignId + ":v" + (campaign.version || 1),
    metadata: { campaignId, correlationId: campaign.correlationId || campaignId },
  };
}

exports.saveCommunicationDraft = onCall(async (request) => {
  const { schoolId, campaignId, campaign } = request.data || {};
  if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
  assertSafeCampaign(campaign);
  const caller = await authenticatedCaller(request, schoolId);
  if (!canPublish(caller, campaign)) throw new HttpsError("permission-denied", "You cannot create this communication.");
  const ref = campaignRef(schoolId, campaignId || db().collection("_").doc().id);
  const scheduledAt = optionalTimestamp(campaign.scheduledAt, "scheduledAt");
  const expiresAt = optionalTimestamp(campaign.expiresAt, "expiresAt");
  if (scheduledAt && scheduledAt.toMillis() <= Date.now()) {
    throw new HttpsError("invalid-argument", "Scheduled time must be in the future.");
  }
  if (expiresAt && scheduledAt && expiresAt.toMillis() <= scheduledAt.toMillis()) {
    throw new HttpsError("invalid-argument", "Expiry must be after the scheduled time.");
  }
  const existing = await ref.get();
  if (existing.exists && !["draft", "pendingApproval", "approved"].includes(existing.data().status)) {
    throw new HttpsError("failed-precondition", "Published communications cannot be edited; duplicate it to create a correction.");
  }
  const now = FieldValue.serverTimestamp();
  const id = ref.id;
  await ref.set({
    campaignId: id, schoolId, title: campaign.title.trim(), shortSummary: campaign.shortSummary || "",
    body: campaign.body.trim(), communicationType: campaign.communicationType || "announcement",
    priority: campaign.priority || "medium", sensitivity: campaign.sensitivity || "normal",
    senderId: caller.id, senderNameSnapshot: caller.name || caller.displayName || "School administration",
    senderRoleSnapshot: callerRole(caller), senderDepartmentSnapshot: caller.department || null,
    audienceDefinition: campaign.audienceDefinition, deliveryChannels: campaign.deliveryChannels || ["inApp", "push"],
    imageUrl: campaign.imageUrl || null, attachmentRefs: campaign.attachmentRefs || [],
    scheduledAt, expiresAt,
    acknowledgementRequired: campaign.acknowledgementRequired === true,
    status: campaign.scheduledAt ? "scheduled" : "draft", version: existing.exists ? (existing.data().version || 1) : 1,
    correlationId: existing.exists ? existing.data().correlationId : id, createdAt: existing.exists ? existing.data().createdAt : now,
    updatedAt: now,
  }, { merge: true });
  await db().collection("schools").doc(schoolId).collection("communication_audit").add({
    action: existing.exists ? "draft_edited" : "draft_created", campaignId: id, actorId: caller.id,
    audience: campaign.audienceDefinition, channels: campaign.deliveryChannels || ["inApp", "push"], createdAt: now,
  });
  return { campaignId: id };
});

exports.publishCommunicationCampaign = onCall(async (request) => {
  const { schoolId, campaignId } = request.data || {};
  if (!schoolId || !campaignId) throw new HttpsError("invalid-argument", "schoolId and campaignId are required.");
  const caller = await authenticatedCaller(request, schoolId);
  const ref = campaignRef(schoolId, campaignId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found.");
  const campaign = snap.data();
  if (!canPublish(caller, campaign)) throw new HttpsError("permission-denied", "You cannot publish this communication.");
  if (!["draft", "approved", "scheduled"].includes(campaign.status)) {
    throw new HttpsError("failed-precondition", "Campaign is not ready to publish.");
  }
  if (campaign.scheduledAt && campaign.scheduledAt.toMillis && campaign.scheduledAt.toMillis() > Date.now()) {
    await ref.update({ status: "scheduled", updatedAt: FieldValue.serverTimestamp() });
    return { status: "scheduled" };
  }
  const notificationRef = db().collection("notification_requests").doc("campaign_" + campaignId + "_v" + (campaign.version || 1));
  await db().runTransaction(async (tx) => {
    const current = await tx.get(ref);
    if (current.data().status === "published") return;
    tx.set(notificationRef, requestPayload(current.data(), campaignId), { merge: false });
    tx.update(ref, { status: "publishing", notificationRequestId: notificationRef.id, publishedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
  });
  return { status: "publishing", notificationRequestId: notificationRef.id };
});

exports.cancelCommunicationCampaign = onCall(async (request) => {
  const { schoolId, campaignId } = request.data || {};
  const caller = await authenticatedCaller(request, schoolId);
  const ref = campaignRef(schoolId, campaignId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found.");
  if (!canPublish(caller, snap.data()) || snap.data().status !== "scheduled") {
    throw new HttpsError("failed-precondition", "Only scheduled communications can be cancelled.");
  }
  await ref.update({ status: "cancelled", cancelledAt: FieldValue.serverTimestamp(), cancelledBy: caller.id, updatedAt: FieldValue.serverTimestamp() });
  return { status: "cancelled" };
});

exports.reconcileCommunicationCampaigns = onSchedule("every 5 minutes", async () => {
  const due = await db().collectionGroup("communication_campaigns").where("status", "==", "scheduled").where("scheduledAt", "<=", admin.firestore.Timestamp.now()).limit(50).get();
  for (const doc of due.docs) {
    const campaign = doc.data();
    const requestRef = db().collection("notification_requests").doc("campaign_" + doc.id + "_v" + (campaign.version || 1));
    await db().runTransaction(async (tx) => {
      const fresh = await tx.get(doc.ref);
      if (fresh.data().status !== "scheduled") return;
      tx.set(requestRef, requestPayload(fresh.data(), doc.id));
      tx.update(doc.ref, { status: "publishing", notificationRequestId: requestRef.id, publishedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    });
  }
  const publishing = await db().collectionGroup("communication_campaigns").where("status", "==", "publishing").limit(100).get();
  for (const doc of publishing.docs) {
    const campaign = doc.data();
    if (!campaign.notificationRequestId) continue;
    const request = await db().collection("notification_requests").doc(campaign.notificationRequestId).get();
    if (!request.exists) continue;
    const data = request.data();
    if (data.status === "sent") await doc.ref.update({ status: data.failureCount > 0 ? "partiallyDelivered" : "delivered", deliverySummary: { totalAudience: data.recipientCount || 0, pushSent: data.successCount || 0, pushFailed: data.failureCount || 0 }, updatedAt: FieldValue.serverTimestamp() });
    if (data.status === "failed") await doc.ref.update({ status: "failed", failureSummary: { reason: data.error || "Delivery request failed" }, updatedAt: FieldValue.serverTimestamp() });
  }
});

module.exports.__internal = { assertSafeCampaign, requestPayload, optionalTimestamp, allowedAudiences };
