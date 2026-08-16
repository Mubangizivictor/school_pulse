/**
 * Communication campaigns are an orchestration layer over notifications.
 * They never send a push, email or SMS themselves: publication creates one
 * idempotent notification_request, which the existing delivery service owns.
 */
const { onCall } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { resolveRecipients } = require("./notifications").__internal;

const db = () => admin.firestore();
const FieldValue = admin.firestore.FieldValue;
// Default role grants, mirroring lib/core/permissions/role_permission_defaults.dart
// (_communicationsAdminPermissions / _communicationsEmergencyOnlyPermissions).
// Institutions can grant additional roles via role_permission_overrides, the
// same collection Firestore rules already read for announcement.manage.
const communicationsAdminRoles = new Set(["schoolAdmin", "director", "headTeacher", "deputyHead"]);
const communicationsEmergencyRoles = new Set([...communicationsAdminRoles, "securityHead"]);
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
async function callerHasPermission(schoolId, user, permission) {
  const role = callerRole(user);
  if (permission === "communications.send_emergency") {
    if (communicationsEmergencyRoles.has(role)) return true;
  } else if (communicationsAdminRoles.has(role)) {
    return true;
  }
  const overrideDoc = await db().collection("schools").doc(schoolId)
    .collection("role_permission_overrides").doc(role).get();
  if (!overrideDoc.exists) return false;
  const granted = overrideDoc.data().permissions || [];
  return granted.includes(permission);
}
async function assertPermission(schoolId, user, permission, message) {
  if (!(await callerHasPermission(schoolId, user, permission))) {
    throw new HttpsError("permission-denied", message);
  }
}
function requiredPublishPermission(campaign) {
  return campaign.communicationType === "emergencyAlert"
    ? "communications.send_emergency"
    : "communications.publish";
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
// Writes into the institution's shared operational trace (audit_events),
// the same collection Support/Security/Data Management already use - see
// lib/features/admin/audit_log_screen.dart. No separate communication-only
// audit collection or screen.
async function appendCommunicationAudit(schoolId, actor, action, extra) {
  const ref = db().collection("institutions").doc(schoolId).collection("audit_events").doc();
  await ref.create({
    auditEventId: ref.id, institutionId: schoolId, moduleKey: "communication",
    action, actorId: actor.id, actorNameSnapshot: actor.name || actor.displayName || "School administration",
    status: "success", sensitivity: "normal", source: "cloud_function",
    createdAt: FieldValue.serverTimestamp(), ...extra,
  });
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

async function assertAudienceSendPermission(schoolId, caller, audienceDefinition) {
  const kinds = audienceDefinition.kind === "anyOf"
    ? audienceDefinition.definitions.map((d) => d.kind)
    : [audienceDefinition.kind];
  const needsStaff = kinds.some((k) => k === "all_staff" || k === "roles");
  const needsParents = kinds.some((k) => k === "all_parents" || k === "class_parents" || k === "student_parents");
  const needsStudents = kinds.some((k) => k === "students");
  const needsSchoolWide = kinds.some((k) => k === "school");
  if (needsStaff || needsSchoolWide) {
    await assertPermission(schoolId, caller, "communications.send_staff", "You cannot target staff.");
  }
  if (needsParents || needsSchoolWide) {
    await assertPermission(schoolId, caller, "communications.send_parents", "You cannot target parents.");
  }
  if (needsStudents || needsSchoolWide) {
    await assertPermission(schoolId, caller, "communications.send_students", "You cannot target students.");
  }
}

exports.saveCommunicationDraft = onCall(async (request) => {
  const { schoolId, campaignId, campaign } = request.data || {};
  if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
  assertSafeCampaign(campaign);
  const caller = await authenticatedCaller(request, schoolId);
  const ref = campaignRef(schoolId, campaignId || db().collection("_").doc().id);
  const existing = await ref.get();
  await assertPermission(
    schoolId, caller,
    existing.exists ? "communications.edit_draft" : "communications.create",
    "You cannot create or edit this communication.",
  );
  await assertAudienceSendPermission(schoolId, caller, campaign.audienceDefinition);
  const scheduledAt = optionalTimestamp(campaign.scheduledAt, "scheduledAt");
  const expiresAt = optionalTimestamp(campaign.expiresAt, "expiresAt");
  if (scheduledAt) {
    await assertPermission(schoolId, caller, "communications.schedule", "You cannot schedule communications.");
    if (scheduledAt.toMillis() <= Date.now()) {
      throw new HttpsError("invalid-argument", "Scheduled time must be in the future.");
    }
  }
  if (expiresAt && scheduledAt && expiresAt.toMillis() <= scheduledAt.toMillis()) {
    throw new HttpsError("invalid-argument", "Expiry must be after the scheduled time.");
  }
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
  await appendCommunicationAudit(schoolId, caller, existing.exists ? "draft_edited" : "draft_created", {
    targetDisplaySnapshot: campaign.title.trim(), targetId: id, correlationId: id,
  });
  return { campaignId: id };
});

// Creates a new draft that supersedes an already-published campaign, so a
// correction never silently rewrites content recipients already received.
exports.supersedeCommunicationCampaign = onCall(async (request) => {
  const { schoolId, campaignId } = request.data || {};
  if (!schoolId || !campaignId) throw new HttpsError("invalid-argument", "schoolId and campaignId are required.");
  const caller = await authenticatedCaller(request, schoolId);
  await assertPermission(schoolId, caller, "communications.edit_draft", "You cannot correct this communication.");
  const ref = campaignRef(schoolId, campaignId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found.");
  const original = snap.data();
  if (!["published", "delivered", "partiallyDelivered", "failed"].includes(original.status)) {
    throw new HttpsError("failed-precondition", "Only published communications can be superseded; edit the draft directly instead.");
  }
  const newRef = campaignRef(schoolId, db().collection("_").doc().id);
  const now = FieldValue.serverTimestamp();
  await db().runTransaction(async (tx) => {
    tx.set(newRef, {
      ...original,
      campaignId: newRef.id,
      status: "draft",
      version: (original.version || 1) + 1,
      supersedesCampaignId: campaignId,
      audienceSnapshot: FieldValue.delete(),
      deliverySummary: FieldValue.delete(),
      readSummary: FieldValue.delete(),
      failureSummary: FieldValue.delete(),
      publishedAt: FieldValue.delete(),
      notificationRequestId: FieldValue.delete(),
      createdAt: now,
      updatedAt: now,
    });
    tx.update(ref, { status: "archived", supersededByCampaignId: newRef.id, updatedAt: now });
  });
  await appendCommunicationAudit(schoolId, caller, "campaign_superseded", {
    targetDisplaySnapshot: original.title, targetId: newRef.id, correlationId: campaignId,
    metadata: { originalCampaignId: campaignId },
  });
  return { campaignId: newRef.id };
});

// Estimated reach shown before sending. Uses the same resolver publish uses,
// but returns only a count - never the recipient ids - so a sender previews
// who they are about to reach without the client holding a member list it
// has no rules-based right to read directly.
exports.previewCommunicationAudience = onCall(async (request) => {
  const { schoolId, audienceDefinition } = request.data || {};
  if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
  if (!allowedAudiences.has(audienceDefinition && audienceDefinition.kind)) {
    throw new HttpsError("invalid-argument", "Unsupported audience definition.");
  }
  const caller = await authenticatedCaller(request, schoolId);
  await assertPermission(schoolId, caller, "communications.create", "You cannot preview this audience.");
  await assertAudienceSendPermission(schoolId, caller, audienceDefinition);
  const recipientIds = await resolveRecipients(schoolId, audienceDefinition);
  return { estimatedRecipients: recipientIds.length };
});

exports.publishCommunicationCampaign = onCall(async (request) => {
  const { schoolId, campaignId } = request.data || {};
  if (!schoolId || !campaignId) throw new HttpsError("invalid-argument", "schoolId and campaignId are required.");
  const caller = await authenticatedCaller(request, schoolId);
  const ref = campaignRef(schoolId, campaignId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found.");
  const campaign = snap.data();
  await assertPermission(schoolId, caller, requiredPublishPermission(campaign), "You cannot publish this communication.");
  await assertAudienceSendPermission(schoolId, caller, campaign.audienceDefinition);
  if (!["draft", "approved", "scheduled"].includes(campaign.status)) {
    throw new HttpsError("failed-precondition", "Campaign is not ready to publish.");
  }
  if (campaign.scheduledAt && campaign.scheduledAt.toMillis && campaign.scheduledAt.toMillis() > Date.now()) {
    await ref.update({ status: "scheduled", updatedAt: FieldValue.serverTimestamp() });
    return { status: "scheduled" };
  }
  // Freeze who is being addressed at the moment of publication - later
  // membership changes (a student transferring class, a parent unlinked)
  // must never retroactively change who this already-sent campaign reached.
  const recipientIds = await resolveRecipients(schoolId, campaign.audienceDefinition);
  const audienceSnapshot = {
    resolvedAt: FieldValue.serverTimestamp(),
    recipientCount: recipientIds.length,
    recipientIds: recipientIds.length <= 500 ? recipientIds : recipientIds.slice(0, 500),
    truncated: recipientIds.length > 500,
  };
  const notificationRef = db().collection("notification_requests").doc("campaign_" + campaignId + "_v" + (campaign.version || 1));
  await db().runTransaction(async (tx) => {
    const current = await tx.get(ref);
    if (current.data().status === "published") return;
    tx.set(notificationRef, requestPayload(current.data(), campaignId), { merge: false });
    tx.update(ref, {
      status: "publishing", notificationRequestId: notificationRef.id, audienceSnapshot,
      publishedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
    });
  });
  await appendCommunicationAudit(schoolId, caller, "campaign_published", {
    targetDisplaySnapshot: campaign.title, targetId: campaignId, correlationId: campaignId,
    metadata: { recipientCount: recipientIds.length, channels: campaign.deliveryChannels || ["inApp", "push"] },
  });
  return { status: "publishing", notificationRequestId: notificationRef.id, recipientCount: recipientIds.length };
});

exports.cancelCommunicationCampaign = onCall(async (request) => {
  const { schoolId, campaignId } = request.data || {};
  if (!schoolId || !campaignId) throw new HttpsError("invalid-argument", "schoolId and campaignId are required.");
  const caller = await authenticatedCaller(request, schoolId);
  const ref = campaignRef(schoolId, campaignId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found.");
  const campaign = snap.data();
  await assertPermission(schoolId, caller, "communications.cancel", "You cannot cancel this communication.");
  if (campaign.status !== "scheduled") {
    throw new HttpsError("failed-precondition", "Only scheduled communications can be cancelled.");
  }
  await ref.update({ status: "cancelled", cancelledAt: FieldValue.serverTimestamp(), cancelledBy: caller.id, updatedAt: FieldValue.serverTimestamp() });
  await appendCommunicationAudit(schoolId, caller, "campaign_cancelled", {
    targetDisplaySnapshot: campaign.title, targetId: campaignId, correlationId: campaignId,
  });
  return { status: "cancelled" };
});

exports.reconcileCommunicationCampaigns = onSchedule("every 5 minutes", async () => {
  const due = await db().collectionGroup("communication_campaigns").where("status", "==", "scheduled").where("scheduledAt", "<=", admin.firestore.Timestamp.now()).limit(50).get();
  for (const doc of due.docs) {
    const campaign = doc.data();
    const requestRef = db().collection("notification_requests").doc("campaign_" + doc.id + "_v" + (campaign.version || 1));
    const recipientIds = await resolveRecipients(campaign.schoolId, campaign.audienceDefinition);
    const audienceSnapshot = {
      resolvedAt: FieldValue.serverTimestamp(),
      recipientCount: recipientIds.length,
      recipientIds: recipientIds.length <= 500 ? recipientIds : recipientIds.slice(0, 500),
      truncated: recipientIds.length > 500,
    };
    await db().runTransaction(async (tx) => {
      const fresh = await tx.get(doc.ref);
      if (fresh.data().status !== "scheduled") return;
      tx.set(requestRef, requestPayload(fresh.data(), doc.id));
      tx.update(doc.ref, { status: "publishing", notificationRequestId: requestRef.id, audienceSnapshot, publishedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
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

// --- Templates -------------------------------------------------------------
// Reusable message bodies (fee reminder, school closure, etc). Institution
// wording only; never hardcoded here.

function templateRef(schoolId, templateId) {
  return db().collection("schools").doc(schoolId).collection("communication_templates").doc(templateId);
}
function assertSafeTemplate(input) {
  if (!input || typeof input !== "object") throw new HttpsError("invalid-argument", "template is required.");
  if (typeof input.name !== "string" || !input.name.trim() || input.name.length > 120) {
    throw new HttpsError("invalid-argument", "A template name of up to 120 characters is required.");
  }
  if (typeof input.body !== "string" || !input.body.trim() || input.body.length > 12000) {
    throw new HttpsError("invalid-argument", "Template body is required.");
  }
}

exports.saveCommunicationTemplate = onCall(async (request) => {
  const { schoolId, templateId, template } = request.data || {};
  if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
  assertSafeTemplate(template);
  const caller = await authenticatedCaller(request, schoolId);
  await assertPermission(schoolId, caller, "communications.manage_templates", "You cannot manage communication templates.");
  const ref = templateRef(schoolId, templateId || db().collection("_").doc().id);
  const existing = await ref.get();
  const now = FieldValue.serverTimestamp();
  await ref.set({
    templateId: ref.id, schoolId, name: template.name.trim(),
    communicationType: template.communicationType || "custom",
    shortSummary: template.shortSummary || "", body: template.body.trim(),
    placeholders: Array.isArray(template.placeholders) ? template.placeholders : [],
    createdBy: existing.exists ? existing.data().createdBy : caller.id,
    createdAt: existing.exists ? existing.data().createdAt : now, updatedAt: now,
  }, { merge: true });
  await appendCommunicationAudit(schoolId, caller, existing.exists ? "template_changed" : "template_created", {
    targetDisplaySnapshot: template.name.trim(), targetId: ref.id,
  });
  return { templateId: ref.id };
});

exports.deleteCommunicationTemplate = onCall(async (request) => {
  const { schoolId, templateId } = request.data || {};
  if (!schoolId || !templateId) throw new HttpsError("invalid-argument", "schoolId and templateId are required.");
  const caller = await authenticatedCaller(request, schoolId);
  await assertPermission(schoolId, caller, "communications.manage_templates", "You cannot manage communication templates.");
  await templateRef(schoolId, templateId).delete();
  await appendCommunicationAudit(schoolId, caller, "template_deleted", { targetId: templateId });
  return { deleted: true };
});

// --- Acknowledgements --------------------------------------------------
// A recipient confirms they have seen a notice that requires acknowledgement.
// Written by the recipient themselves only - never on behalf of another
// account - so this reads the caller's own uid from auth, not request.data.

exports.acknowledgeCommunicationCampaign = onCall(async (request) => {
  const { schoolId, campaignId, deviceId } = request.data || {};
  if (!schoolId || !campaignId) throw new HttpsError("invalid-argument", "schoolId and campaignId are required.");
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to acknowledge this notice.");
  const userDoc = await db().collection("users").doc(request.auth.uid).get();
  if (!userDoc.exists || userDoc.data().schoolId !== schoolId) {
    throw new HttpsError("permission-denied", "The active institution does not match this campaign.");
  }
  const campaignSnap = await campaignRef(schoolId, campaignId).get();
  if (!campaignSnap.exists) throw new HttpsError("not-found", "Campaign not found.");
  const campaign = campaignSnap.data();
  if (!["published", "delivered", "partiallyDelivered"].includes(campaign.status)) {
    throw new HttpsError("failed-precondition", "This communication has not been published.");
  }
  const snapshotIds = campaign.audienceSnapshot && campaign.audienceSnapshot.recipientIds;
  if (Array.isArray(snapshotIds) && !campaign.audienceSnapshot.truncated && !snapshotIds.includes(request.auth.uid)) {
    throw new HttpsError("permission-denied", "This communication was not addressed to you.");
  }
  const ackRef = db().collection("schools").doc(schoolId).collection("communication_campaigns")
    .doc(campaignId).collection("communication_acknowledgements").doc(request.auth.uid);
  await ackRef.set({
    userId: request.auth.uid, campaignId, campaignVersion: campaign.version || 1,
    deviceId: deviceId || null, acknowledgedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  return { acknowledged: true };
});

module.exports.__internal = {
  assertSafeCampaign, requestPayload, optionalTimestamp, allowedAudiences,
  callerHasPermission, requiredPublishPermission, communicationsAdminRoles, communicationsEmergencyRoles,
};
