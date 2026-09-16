/**
 * Staff leave requests used to derive an `on_leave` attendance status.
 *
 * Scope is deliberately minimal: this is a read-side feed for the staff
 * attendance dashboard, not a full leave-management module. A staff member
 * may create their own `pending` request; only HR/admin leadership can
 * approve or reject one. There is no edit/cancel path yet - that is a later,
 * separate concern if a real need surfaces.
 *
 * Docs live at `institutions/{schoolId}/staff_leave_requests/{id}`. All
 * writes go through these callables; Firestore rules deny direct writes.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const serverTime = () => admin.firestore.FieldValue.serverTimestamp();

  const CALLABLE_OPTS = { region: "europe-west1" };

  const CORRECTOR_ROLES = new Set([
    "schoolAdmin",
    "headTeacher",
    "director",
    "hrOfficer",
  ]);

  const asText = (value, max) => String(value ?? "").trim().slice(0, max);

  const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
  function dateKey(value, field) {
    const text = asText(value, 10);
    if (!DATE_RE.test(text)) {
      throw new HttpsError("invalid-argument", `${field} must be YYYY-MM-DD.`);
    }
    return text;
  }

  async function loadCaller(uid) {
    const snap = await db.collection("users").doc(uid).get();
    return snap.exists ? snap.data() : null;
  }

  async function requireActiveMember(request, schoolId) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }
    if (!schoolId) {
      throw new HttpsError("invalid-argument", "schoolId is required.");
    }
    const caller = await loadCaller(request.auth.uid);
    if (!caller || !caller.schoolId || caller.isActive === false) {
      throw new HttpsError(
        "permission-denied",
        "No active institution membership."
      );
    }
    if (caller.schoolId !== schoolId) {
      throw new HttpsError(
        "permission-denied",
        "You may only act within your own school."
      );
    }
    return caller;
  }

  function hasCorrectorRole(caller) {
    const roles = [
      caller.role,
      ...(Array.isArray(caller.roles) ? caller.roles : []),
    ];
    return roles.some((r) => CORRECTOR_ROLES.has(r));
  }

  async function requestStaffLeave(request) {
    const data = request.data || {};
    const schoolId = asText(data.schoolId, 200);
    const caller = await requireActiveMember(request, schoolId);

    const startDate = dateKey(data.startDate, "startDate");
    const endDate = dateKey(data.endDate, "endDate");
    if (endDate < startDate) {
      throw new HttpsError(
        "invalid-argument",
        "endDate cannot be before startDate."
      );
    }
    const reason = asText(data.reason, 300);
    if (!reason) {
      throw new HttpsError("invalid-argument", "A reason is required.");
    }

    const ref = db
      .collection("institutions")
      .doc(schoolId)
      .collection("staff_leave_requests")
      .doc();
    await ref.set({
      staffId: request.auth.uid,
      schoolId,
      startDate,
      endDate,
      reason,
      status: "pending",
      requestedBy: request.auth.uid,
      requestedAt: serverTime(),
      approvedBy: null,
      approvedAt: null,
    });

    return { ok: true, id: ref.id };
  }

  async function decideStaffLeave(request) {
    const data = request.data || {};
    const schoolId = asText(data.schoolId, 200);
    const requestId = asText(data.requestId, 200);
    const decision = data.decision === "approved" ? "approved" : data.decision === "rejected" ? "rejected" : null;
    if (!requestId) {
      throw new HttpsError("invalid-argument", "requestId is required.");
    }
    if (!decision) {
      throw new HttpsError(
        "invalid-argument",
        'decision must be "approved" or "rejected".'
      );
    }

    const caller = await requireActiveMember(request, schoolId);
    if (!hasCorrectorRole(caller)) {
      throw new HttpsError(
        "permission-denied",
        "Only an admin, head teacher, director, or HR officer may decide leave requests."
      );
    }

    const ref = db
      .collection("institutions")
      .doc(schoolId)
      .collection("staff_leave_requests")
      .doc(requestId);

    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists || snap.data().schoolId !== schoolId) {
        throw new HttpsError("not-found", "That leave request was not found.");
      }
      const existing = snap.data();
      if (existing.status !== "pending") {
        // Idempotent: re-deciding an already-decided request is a no-op,
        // not an error - guards against double-submit from a flaky network.
        return { ok: true, id: requestId, status: existing.status };
      }
      tx.set(
        ref,
        {
          status: decision,
          approvedBy: request.auth.uid,
          approvedAt: serverTime(),
        },
        { merge: true }
      );

      const auditRef = db
        .collection("institutions")
        .doc(schoolId)
        .collection("audit_events")
        .doc();
      tx.set(auditRef, {
        actorId: request.auth.uid,
        action: `staff_leave_request.${decision}`,
        metadata: { requestId, staffId: existing.staffId },
        createdAt: serverTime(),
      });

      return { ok: true, id: requestId, status: decision };
    });
  }

  return {
    requestStaffLeave: onCall(CALLABLE_OPTS, requestStaffLeave),
    decideStaffLeave: onCall(CALLABLE_OPTS, decideStaffLeave),
    __test__: {
      CORRECTOR_ROLES,
      requireActiveMember,
      hasCorrectorRole,
      requestStaffLeave,
      decideStaffLeave,
    },
  };
};
