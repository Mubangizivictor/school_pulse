/** Server-authored audit trail for the Admission/Enrollment Setup flow.
 *
 * Mirrors support_audit.js's trust model exactly: writes into the SAME
 * `institutions/{schoolId}/audit_events` collection the real audit log
 * screen reads, actor/timestamp are always derived server-side (never
 * trusted from the client payload), and the collection itself has no
 * client-write Firestore rule anywhere in this codebase - this callable is
 * the only path a client has to append to it for enrollment events, same
 * as support_audit.js is the only path for support events. */
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();

  // Keep the allow-list explicit rather than accepting any string - an
  // audit action id is effectively part of this callable's public API and
  // typos/rogue values should fail loudly at call time, not silently
  // produce an unfilterable audit_events doc.
  const allowedActions = new Set([
    "admission_approved",
    "admission_rejected",
    "admission_enrollment_started",
    "enrollment_academic_placement_set",
    "enrollment_finance_set",
    "enrollment_bursary_assigned",
    "enrollment_boarding_assigned",
    "enrollment_club_joined",
    "enrollment_parent_linked",
    "enrollment_identity_issued",
    "enrollment_qr_issued",
    "enrollment_nfc_registered",
    "enrollment_card_generated",
    "enrollment_activated",
  ]);

  function text(value, key, max = 2000, required = false) {
    const out = typeof value === "string" ? value.trim() : "";
    if (required && !out) throw new HttpsError("invalid-argument", `${key} is required.`);
    return out.slice(0, max);
  }

  // Same secret-scrubbing shape as support_audit.js's redact(), duplicated
  // rather than imported so this module has no runtime dependency on
  // support_audit.js's internals (both are trivial enough that keeping
  // them independently readable outweighs the few lines of duplication).
  const secretPattern = /password|passcode|pin|otp|token|api[_-]?key|secret|private[_-]?key|credential/i;
  function redact(value) {
    if (Array.isArray(value)) return value.map(redact);
    if (!value || typeof value !== "object") return value;
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, secretPattern.test(key) ? "[REDACTED]" : redact(item)]),
    );
  }

  /**
   * Verifies the caller is an active, same-school staff member of
   * `institutionId` - the same tenant check support_audit.js's actor()
   * performs, minus the permission-id check (any legitimate staff action
   * that already passed its own Permission.enrollment* gate client-side
   * is allowed to log that it happened; this callable is a trail, not a
   * second authorization gate for the underlying action).
   */
  async function requireSameSchoolStaff(request, institutionId) {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign in is required.");
    const snap = await db.collection("users").doc(request.auth.uid).get();
    const user = snap.data();
    if (!user || user.schoolId !== institutionId || user.isActive === false) {
      throw new HttpsError("permission-denied", "No active institution membership.");
    }
    return { uid: request.auth.uid, user };
  }

  /**
   * Records one enrollment/admission audit event. actorId and createdAt
   * are always server-derived - the client cannot forge either, matching
   * support_audit.js's appendAudit() trust model exactly.
   */
  const recordEnrollmentAuditEvent = onCall(async (request) => {
    const d = request.data || {};
    const institutionId = text(d.schoolId, "schoolId", 160, true);
    const actor = await requireSameSchoolStaff(request, institutionId);

    const action = text(d.action, "action", 80, true);
    if (!allowedActions.has(action)) {
      throw new HttpsError("invalid-argument", `Unsupported audit action: ${action}`);
    }

    const studentId = text(d.studentId, "studentId", 160);
    const applicationId = text(d.applicationId, "applicationId", 160);
    if (!studentId && !applicationId) {
      throw new HttpsError("invalid-argument", "Either studentId or applicationId is required.");
    }

    const reason = text(d.reason, "reason", 1000);
    const metadataSafe = d.metadata && typeof d.metadata === "object" ? redact(d.metadata) : {};

    const ref = db.collection("institutions").doc(institutionId).collection("audit_events").doc();
    await ref.create({
      auditEventId: ref.id,
      institutionId,
      moduleKey: "enrollment",
      eventType: "Enrollment",
      action,
      status: "success",
      sensitivity: "normal",
      source: "cloud_function",
      actorId: actor.uid,
      actorNameSnapshot: text(actor.user.name || actor.user.email || "Staff", "name", 160),
      targetType: studentId ? "student" : "admission_application",
      targetId: studentId || applicationId,
      correlationId: applicationId || studentId,
      reason: reason || null,
      metadataSafe,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { auditEventId: ref.id };
  });

  return { recordEnrollmentAuditEvent, __test__: { allowedActions, redact } };
};
