/**
 * Authorised manual correction of a staff attendance record.
 *
 * Scope is deliberately narrow: this file ONLY lets HR/admin leadership
 * amend an existing day's `staff_attendance` doc (clock-in/out time,
 * status, location) with a mandatory reason. It does NOT create clock-in
 * events or touch payroll - those are separate concerns (see
 * staff_attendance_clockin.js). It DOES fall back to deriving a status from
 * `staff_shifts` / `staff_leave_requests` (see `deriveStatus`) when no
 * explicit status is patched in and there's no prior doc to inherit from -
 * an explicit patch.status always wins over derivation.
 *
 * Every correction:
 *   - upserts the deterministic doc `staff_attendance/{staffId}_{yyyy-mm-dd}`
 *     (idempotent - a re-call with the same patch is a no-op write),
 *   - appends an immutable trail doc under
 *     `institutions/{schoolId}/staff_attendance_corrections`,
 *   - appends an audit event under `institutions/{schoolId}/audit_events`.
 *
 * Auth/audit helpers mirror academic_calendar_billing.js's style rather
 * than importing, so this file stays independently readable.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const serverTime = () => admin.firestore.FieldValue.serverTimestamp();

  // Every callable in this app is europe-west1; the Flutter client reaches
  // it via FirebaseFunctions.instanceFor(region: 'europe-west1'). Must stay
  // in sync or calls 404.
  const CALLABLE_OPTS = { region: "europe-west1" };

  // HR/admin leadership only. Deputy Head can VIEW staff attendance (route
  // gate) but not correct it - same narrowing payroll uses.
  const CORRECTOR_ROLES = new Set([
    "schoolAdmin",
    "headTeacher",
    "director",
    "hrOfficer",
  ]);

  const SETTABLE_STATUS = new Set(["on_time", "late", "on_leave", "absent"]);

  const asText = (value, max) => String(value ?? "").trim().slice(0, max);

  // When no explicit status is patched in and there's no prior doc, derive
  // one from the staff member's shift + any approved leave covering the day,
  // rather than always defaulting to "on_time". An explicit patch.status
  // always wins - this only fills in the gap on first creation.
  async function deriveStatus({ db, schoolId, staffId, day, clockIn }) {
    const leaveSnap = await db
      .collection("institutions")
      .doc(schoolId)
      .collection("staff_leave_requests")
      .where("staffId", "==", staffId)
      .where("status", "==", "approved")
      .where("startDate", "<=", day)
      .get();
    const onLeave = leaveSnap.docs.some((d) => d.data().endDate >= day);
    if (onLeave) return "on_leave";

    const shiftSnap = await db
      .collection("institutions")
      .doc(schoolId)
      .collection("staff_shifts")
      .doc(staffId)
      .get();
    if (!shiftSnap.exists) return "on_time";
    const shift = shiftSnap.data();
    if (!shift.scheduledStart) return "on_time";

    const [h, m] = shift.scheduledStart.split(":").map(Number);
    const threshold = new Date(clockIn);
    threshold.setHours(h, m + (shift.graceMinutes || 0), 0, 0);
    return clockIn.getTime() > threshold.getTime() ? "late" : "on_time";
  }

  function dayKey(day) {
    // `day` is an ISO date string 'YYYY-MM-DD' from the client.
    if (!/^\d{4}-\d{2}-\d{2}$/.test(String(day || ""))) {
      throw new HttpsError("invalid-argument", "day must be YYYY-MM-DD.");
    }
    return day;
  }

  function parseClock(value, day, field) {
    if (value === undefined || value === null || value === "") return undefined;
    const d = value.toDate ? value.toDate() : new Date(value);
    if (Number.isNaN(d.getTime())) {
      throw new HttpsError("invalid-argument", `${field} is not a valid time.`);
    }
    return d;
  }

  async function requireCorrector(request, schoolId) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }
    if (!schoolId) {
      throw new HttpsError("invalid-argument", "schoolId is required.");
    }
    const snap = await db.collection("users").doc(request.auth.uid).get();
    const caller = snap.exists ? snap.data() : null;
    if (!caller || !caller.schoolId || caller.isActive === false) {
      throw new HttpsError(
        "permission-denied",
        "No active institution membership."
      );
    }
    // Cross-tenant denial: never trust a client-passed schoolId to imply
    // authorization by itself.
    if (caller.schoolId !== schoolId) {
      throw new HttpsError(
        "permission-denied",
        "You may only correct attendance for your own school."
      );
    }
    const roles = [
      caller.role,
      ...(Array.isArray(caller.roles) ? caller.roles : []),
    ];
    if (!roles.some((r) => CORRECTOR_ROLES.has(r))) {
      throw new HttpsError(
        "permission-denied",
        "Only an admin, head teacher, director, or HR officer may correct staff attendance."
      );
    }
    return { uid: request.auth.uid, name: caller.name || "" };
  }

  async function handler(request) {
    const data = request.data || {};
    const schoolId = asText(data.schoolId, 200);
    const staffId = asText(data.staffId, 200);
    const day = dayKey(data.day);
    const reason = asText(data.reason, 300);
    const patch = data.patch || {};
    // Optional client-generated idempotency key (e.g. from an offline queue
    // replay). When present and a trail doc with this operationId already
    // exists for this record, the call is a no-op success - guards against
    // a queued correction being sent twice.
    const operationId = data.operationId
      ? asText(data.operationId, 100)
      : null;

    if (!staffId) {
      throw new HttpsError("invalid-argument", "staffId is required.");
    }
    if (!reason) {
      throw new HttpsError("invalid-argument", "A reason is required.");
    }

    const [year, month, dayOfMonth] = day.split("-").map(Number);
    const dayStart = new Date(year, month - 1, dayOfMonth);
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    if (dayStart.getTime() > todayStart.getTime()) {
      throw new HttpsError(
        "invalid-argument",
        "Cannot correct attendance for a future date."
      );
    }

    const { uid, name } = await requireCorrector(request, schoolId);

    // Resolve the staff member's campus server-side - never client-passed.
    const staffSnap = await db.collection("users").doc(staffId).get();
    const staff = staffSnap.exists ? staffSnap.data() : null;
    if (!staff || staff.schoolId !== schoolId) {
      throw new HttpsError(
        "not-found",
        "That staff member is not part of this school."
      );
    }
    const campusId = staff.campusId || null;

    const status = patch.status;
    if (status !== undefined && !SETTABLE_STATUS.has(status)) {
      throw new HttpsError(
        "invalid-argument",
        "status must be one of on_time, late, on_leave, absent."
      );
    }

    const docId = `${staffId}_${day}`;
    const ref = db.collection("staff_attendance").doc(docId);

    if (operationId) {
      const dup = await db
        .collection("institutions")
        .doc(schoolId)
        .collection("staff_attendance_corrections")
        .where("recordId", "==", docId)
        .where("operationId", "==", operationId)
        .limit(1)
        .get();
      if (!dup.empty) {
        return { ok: true, recordId: docId, changedFields: [], duplicate: true };
      }
    }

    // Computed outside the transaction: shift/leave docs aren't mutated by
    // this callable, so there's no consistency requirement tying their read
    // to the attendance-doc write below. Only used as a fallback when there's
    // no explicit patch.status and no prior doc to inherit from.
    const patchClockInForDerivation = parseClock(patch.clockIn, day, "clockIn");
    const derivedStatus = await deriveStatus({
      db,
      schoolId,
      staffId,
      day,
      clockIn: patchClockInForDerivation !== undefined ? patchClockInForDerivation : dayStart,
    });

    const result = await db.runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      const prev = existing.exists ? existing.data() : null;

      const patchClockIn = parseClock(patch.clockIn, day, "clockIn");
      const patchClockOut = parseClock(patch.clockOut, day, "clockOut");

      const nextClockIn =
        patchClockIn !== undefined
          ? patchClockIn
          : prev && prev.clockIn && prev.clockIn.toDate
          ? prev.clockIn.toDate()
          : dayStart;
      const nextClockOut =
        patchClockOut !== undefined
          ? patchClockOut
          : prev && prev.clockOut && prev.clockOut.toDate
          ? prev.clockOut.toDate()
          : null;

      if (nextClockOut && nextClockOut.getTime() < nextClockIn.getTime()) {
        throw new HttpsError(
          "invalid-argument",
          "Clock-out cannot be before clock-in."
        );
      }

      const nextStatus =
        status !== undefined
          ? status
          : prev && prev.status
          ? prev.status
          : derivedStatus;
      const nextLocation =
        patch.location !== undefined
          ? asText(patch.location, 160)
          : prev && prev.location
          ? prev.location
          : "Main Gate";

      const before = prev
        ? {
            clockIn: prev.clockIn || null,
            clockOut: prev.clockOut || null,
            status: prev.status || null,
            location: prev.location || null,
          }
        : null;

      const after = {
        schoolId,
        staffId,
        campusId,
        clockIn: admin.firestore.Timestamp.fromDate(nextClockIn),
        clockOut: nextClockOut
          ? admin.firestore.Timestamp.fromDate(nextClockOut)
          : null,
        status: nextStatus,
        location: nextLocation,
        lastCorrectionAt: serverTime(),
        lastCorrectedBy: uid,
      };

      tx.set(ref, after, { merge: true });

      const changedFields = [];
      for (const key of ["clockIn", "clockOut", "status", "location"]) {
        const b = before ? before[key] : null;
        const a = after[key];
        const bMs = b && b.toDate ? b.toDate().getTime() : b;
        const aMs = a && a.toDate ? a.toDate().getTime() : a;
        if (bMs !== aMs) changedFields.push(key);
      }

      const trailRef = db
        .collection("institutions")
        .doc(schoolId)
        .collection("staff_attendance_corrections")
        .doc();
      tx.set(trailRef, {
        recordId: docId,
        staffId,
        actorId: uid,
        actorName: name,
        reason,
        before,
        after: {
          clockIn: after.clockIn,
          clockOut: after.clockOut,
          status: after.status,
          location: after.location,
        },
        changedFields,
        operationId: operationId || null,
        createdAt: serverTime(),
      });

      const auditRef = db
        .collection("institutions")
        .doc(schoolId)
        .collection("audit_events")
        .doc();
      tx.set(auditRef, {
        actorId: uid,
        action: "staff_attendance.corrected",
        metadata: { staffId, day, changedFields, reason },
        createdAt: serverTime(),
      });

      return { recordId: docId, changedFields };
    });

    return { ok: true, ...result };
  }

  // Authorised "Mark staff attendance" - creates today's clock-in doc if
  // absent. Structurally idempotent: the deterministic doc id
  // `{staffId}_{yyyy-mm-dd}` means a second call for the same staff/day is a
  // transactional merge, never a duplicate doc, so no separate dedup table
  // is needed even without an operationId. Cannot be used to backdate a
  // past day - that is `correctStaffAttendance`'s job.
  async function clockIn(request) {
    const data = request.data || {};
    const schoolId = asText(data.schoolId, 200);
    const staffId = asText(data.staffId, 200);
    if (!staffId) {
      throw new HttpsError("invalid-argument", "staffId is required.");
    }

    const { uid, name } = await requireCorrector(request, schoolId);

    const staffSnap = await db.collection("users").doc(staffId).get();
    const staff = staffSnap.exists ? staffSnap.data() : null;
    if (!staff || staff.schoolId !== schoolId) {
      throw new HttpsError(
        "not-found",
        "That staff member is not part of this school."
      );
    }
    const campusId = staff.campusId || null;

    const now = new Date();
    const day = dayKey(
      `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`
    );
    const location = data.location ? asText(data.location, 160) : "Main Gate";
    const operationId = data.operationId
      ? asText(data.operationId, 100)
      : null;
    const docId = `${staffId}_${day}`;
    const ref = db.collection("staff_attendance").doc(docId);

    const derivedStatus = await deriveStatus({
      db,
      schoolId,
      staffId,
      day,
      clockIn: now,
    });

    const result = await db.runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      if (existing.exists) {
        // Already clocked in today - a second tap is a no-op, not an error,
        // so double-submission never creates a second record or overwrites
        // the original clock-in time.
        return { recordId: docId, alreadyClockedIn: true };
      }
      if (operationId) {
        const dup = await db
          .collection("institutions")
          .doc(schoolId)
          .collection("staff_attendance_corrections")
          .where("recordId", "==", docId)
          .where("operationId", "==", operationId)
          .limit(1)
          .get();
        if (!dup.empty) {
          return { recordId: docId, duplicate: true };
        }
      }

      tx.set(ref, {
        schoolId,
        staffId,
        campusId,
        clockIn: admin.firestore.Timestamp.fromDate(now),
        clockOut: null,
        status: derivedStatus,
        location,
        lastCorrectionAt: serverTime(),
        lastCorrectedBy: uid,
      });

      const trailRef = db
        .collection("institutions")
        .doc(schoolId)
        .collection("staff_attendance_corrections")
        .doc();
      tx.set(trailRef, {
        recordId: docId,
        staffId,
        actorId: uid,
        actorName: name,
        reason: "Marked attendance",
        before: null,
        after: { clockIn: admin.firestore.Timestamp.fromDate(now), clockOut: null, status: derivedStatus, location },
        changedFields: ["clockIn", "status", "location"],
        operationId: operationId || null,
        createdAt: serverTime(),
      });

      const auditRef = db
        .collection("institutions")
        .doc(schoolId)
        .collection("audit_events")
        .doc();
      tx.set(auditRef, {
        actorId: uid,
        action: "staff_attendance.clocked_in",
        metadata: { staffId, day },
        createdAt: serverTime(),
      });

      return { recordId: docId };
    });

    return { ok: true, ...result };
  }

  return {
    correctStaffAttendance: onCall(CALLABLE_OPTS, handler),
    clockInStaff: onCall(CALLABLE_OPTS, clockIn),
    __test__: {
      CORRECTOR_ROLES,
      SETTABLE_STATUS,
      requireCorrector,
      handler,
      deriveStatus,
      clockIn,
    },
  };
};
