/** Tenant-scoped Support + Audit callables.  Source modules remain the owner
 * of their business records; this module only persists a redacted operational
 * trace and the institution/support conversation. */
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const adminRoles = ["director", "headTeacher", "schoolAdmin"];
  const secret = /password|passcode|pin|otp|token|api[_-]?key|secret|private[_-]?key|credential/i;
  const allowedStatuses = new Set(["submitted", "open", "assigned", "investigating", "waiting_for_institution", "waiting_for_school_pulse", "workaround_provided", "resolved", "closed", "reopened", "cancelled"]);

  function redact(value) {
    if (Array.isArray(value)) return value.map(redact);
    if (!value || typeof value !== "object") return value;
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, secret.test(key) ? "[REDACTED]" : redact(item)]));
  }
  async function actor(request, institutionId, permission) {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign in is required.");
    const snap = await db.collection("users").doc(request.auth.uid).get();
    const user = snap.data();
    if (!user || user.schoolId !== institutionId || user.isActive === false) throw new HttpsError("permission-denied", "No active institution membership.");
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    const permitted = roles.some((r) => adminRoles.includes(r)) || (user.permissions || []).includes(permission);
    if (!permitted) throw new HttpsError("permission-denied", "Your current role does not have this permission.");
    return { uid: request.auth.uid, user, roles };
  }
  async function appendAudit(institutionId, event) {
    const ref = db.collection("institutions").doc(institutionId).collection("audit_events").doc();
    await ref.create(redact({ auditEventId: ref.id, institutionId, status: "success", sensitivity: "normal", source: "cloud_function", createdAt: admin.firestore.FieldValue.serverTimestamp(), ...event }));
    return ref.id;
  }
  function text(value, key, max = 4000, required = false) {
    const out = typeof value === "string" ? value.trim() : "";
    if (required && !out) throw new HttpsError("invalid-argument", `${key} is required.`);
    return out.slice(0, max);
  }
  function supportRef(institutionId, id) { return db.doc(`institutions/${institutionId}/support_requests/${id}`); }

  const submitInstitutionSupportRequest = onCall(async (request) => {
    const d = request.data || {}; const institutionId = text(d.institutionId, "institutionId", 160, true);
    const a = await actor(request, institutionId, "support.create");
    const requestId = text(d.supportRequestId, "supportRequestId", 160, true);
    const ref = supportRef(institutionId, requestId);
    const now = admin.firestore.FieldValue.serverTimestamp();
    await db.runTransaction(async (tx) => {
      if ((await tx.get(ref)).exists) return; // idempotent client retry
      tx.create(ref, redact({ supportRequestId: requestId, institutionId, submittedBy: a.uid,
        submittedByNameSnapshot: text(a.user.name || a.user.email || "Institution user", "name", 160),
        accountType: a.user.role || "staff", activeWorkspace: "school", moduleKey: text(d.moduleKey, "moduleKey", 80, true),
        category: text(d.category, "category", 100, true), subject: text(d.subject, "subject", 180, true),
        description: text(d.description, "description", 6000, true), priority: ["low", "normal", "high", "urgent"].includes(d.priority) ? d.priority : "normal",
        severity: "untriaged", status: "submitted", affectedPlatform: text(d.affectedPlatform || "School Pulse", "platform", 80),
        appVersion: text(d.appVersion, "appVersion", 80), deviceMetadata: redact(d.deviceMetadata || {}), browserMetadata: redact(d.browserMetadata || {}),
        reproductionSteps: text(d.reproductionSteps, "reproductionSteps", 4000), expectedBehavior: text(d.expectedBehavior, "expectedBehavior", 3000), actualBehavior: text(d.actualBehavior, "actualBehavior", 3000),
        attachments: [], screenshots: [], correlationIds: Array.isArray(d.correlationIds) ? d.correlationIds.slice(0, 20) : [], relatedRecordIds: Array.isArray(d.relatedRecordIds) ? d.relatedRecordIds.slice(0, 20) : [],
        submittedAt: now, updatedAt: now, firstResponseAt: null, resolvedAt: null, closedAt: null, version: 1 }));
    });
    await appendAudit(institutionId, { moduleKey: "support", eventType: "Create", action: "support_request_created", actorId: a.uid, actorNameSnapshot: a.user.name || "Institution user", targetType: "support_request", targetId: requestId, targetDisplaySnapshot: text(d.subject, "subject", 180), correlationId: requestId, metadataSafe: { category: d.category, priority: d.priority || "normal" } });
    return { supportRequestId: requestId };
  });

  const addInstitutionSupportResponse = onCall(async (request) => {
    const d = request.data || {}; const institutionId = text(d.institutionId, "institutionId", 160, true); const a = await actor(request, institutionId, "support.reply");
    const requestId = text(d.supportRequestId, "supportRequestId", 160, true); const body = text(d.body, "body", 6000, true); const ref = supportRef(institutionId, requestId);
    if (!(await ref.get()).exists) throw new HttpsError("not-found", "Support request not found.");
    const response = ref.collection("responses").doc();
    await response.create(redact({ responseId: response.id, supportRequestId: requestId, institutionId, authorType: "institution", authorId: a.uid, authorDisplayName: a.user.name || "Institution user", body, attachments: [], visibility: "institution_visible", createdAt: admin.firestore.FieldValue.serverTimestamp(), editedAt: null }));
    await ref.update({ status: "waiting_for_school_pulse", updatedAt: admin.firestore.FieldValue.serverTimestamp(), version: admin.firestore.FieldValue.increment(1) });
    await appendAudit(institutionId, { moduleKey: "support", eventType: "Update", action: "support_response_added", actorId: a.uid, targetType: "support_request", targetId: requestId, correlationId: requestId });
    return { responseId: response.id };
  });
  const addInstitutionSupportAttachment = onCall(async (request) => {
    const d = request.data || {}; const institutionId = text(d.institutionId, "institutionId", 160, true); const a = await actor(request, institutionId, "support.create");
    const requestId = text(d.supportRequestId, "supportRequestId", 160, true); const path = text(d.path, "path", 600, true);
    if (!path.startsWith(`institutions/${institutionId}/support/${requestId}/`)) throw new HttpsError("permission-denied", "Attachment path is outside this request.");
    const type = text(d.contentType, "contentType", 100, true); if (!["image/png", "image/jpeg", "image/webp", "application/pdf", "text/csv"].includes(type)) throw new HttpsError("invalid-argument", "This file type is not allowed.");
    const ref = supportRef(institutionId, requestId); const row = await ref.get(); if (!row.exists || row.data().submittedBy !== a.uid) throw new HttpsError("permission-denied", "You cannot attach to this request.");
    await ref.update({ attachments: admin.firestore.FieldValue.arrayUnion({ name: text(d.name, "name", 180, true), path, contentType: type }), updatedAt: admin.firestore.FieldValue.serverTimestamp() }); return { ok: true };
  });
  const changeInstitutionSupportStatus = onCall(async (request) => {
    const d = request.data || {}; const institutionId = text(d.institutionId, "institutionId", 160, true); const a = await actor(request, institutionId, "support.close"); const status = text(d.status, "status", 80, true);
    if (!allowedStatuses.has(status) || !["closed", "reopened", "cancelled"].includes(status)) throw new HttpsError("invalid-argument", "Unsupported institution status transition.");
    const requestId = text(d.supportRequestId, "supportRequestId", 160, true); const ref = supportRef(institutionId, requestId); const prior = await ref.get(); if (!prior.exists) throw new HttpsError("not-found", "Support request not found.");
    await ref.update({ status, updatedAt: admin.firestore.FieldValue.serverTimestamp(), closedAt: status === "closed" ? admin.firestore.FieldValue.serverTimestamp() : null, version: admin.firestore.FieldValue.increment(1) });
    await ref.collection("status_history").add({ status, actorId: a.uid, actorType: "institution", reason: text(d.reason, "reason", 500), createdAt: admin.firestore.FieldValue.serverTimestamp() });
    await appendAudit(institutionId, { moduleKey: "support", eventType: "Update", action: `support_${status}`, actorId: a.uid, targetType: "support_request", targetId: requestId, previousValueSummary: { status: prior.data().status }, newValueSummary: { status }, reason: text(d.reason, "reason", 500), correlationId: requestId }); return { ok: true };
  });
  const decideSupportAccess = onCall(async (request) => {
    const d = request.data || {}; const institutionId = text(d.institutionId, "institutionId", 160, true); const a = await actor(request, institutionId, "support.approve_access"); const decision = text(d.decision, "decision", 20, true);
    if (!["approved", "rejected", "revoked"].includes(decision)) throw new HttpsError("invalid-argument", "Unsupported access decision."); const ref = db.doc(`institutions/${institutionId}/support_access_requests/${text(d.supportAccessRequestId, "supportAccessRequestId", 160, true)}`); const snap = await ref.get(); if (!snap.exists) throw new HttpsError("not-found", "Support access request not found.");
    const row = snap.data(); if (decision === "approved" && row.requestedByPlatformUser === a.uid) throw new HttpsError("permission-denied", "Support cannot approve its own request.");
    const expiry = row.expiresAt || admin.firestore.Timestamp.fromMillis(Date.now() + Math.min(Number(row.durationMinutes || 30), 480) * 60000);
    await ref.update({ status: decision === "approved" ? "active" : decision, approvedBy: a.uid, approvedAt: admin.firestore.FieldValue.serverTimestamp(), expiresAt: expiry, revokedAt: decision === "revoked" ? admin.firestore.FieldValue.serverTimestamp() : null });
    await appendAudit(institutionId, { moduleKey: "support", eventType: "Support Access", action: `support_access_${decision}`, actorId: a.uid, targetType: "support_access", targetId: ref.id, supportAccessSessionId: decision === "approved" ? ref.id : null, metadataSafe: { requestedScope: row.requestedScope || [] } }); return { ok: true };
  });
  const expireSupportAccess = onCall(async () => { const now = admin.firestore.Timestamp.now(); const rows = await db.collectionGroup("support_access_requests").where("status", "==", "active").where("expiresAt", "<=", now).get(); await Promise.all(rows.docs.map(async (doc) => { await doc.ref.update({ status: "expired", expiredAt: admin.firestore.FieldValue.serverTimestamp() }); await appendAudit(doc.data().institutionId, { moduleKey: "support", eventType: "Support Access", action: "support_access_expired", targetType: "support_access", targetId: doc.id, supportAccessSessionId: doc.id }); })); return { expired: rows.size }; });
  return { submitInstitutionSupportRequest, addInstitutionSupportResponse, addInstitutionSupportAttachment, changeInstitutionSupportStatus, decideSupportAccess, expireSupportAccess, __test__: { redact } };
};
