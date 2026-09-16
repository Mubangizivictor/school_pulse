/**
 * Staff shift/roster records used to derive scheduled-shift display and
 * late/absent status for staff attendance.
 *
 * One current doc per staff member at
 * `institutions/{schoolId}/staff_shifts/{staffId}`. Written only by the
 * `setStaffShift` callable (HR/admin leadership, same role gate as
 * `correctStaffAttendance`); Firestore rules deny all direct client writes.
 *
 * Auth/audit helpers are duplicated rather than shared with
 * staff_attendance_corrections.js, matching that file's own stated
 * convention of staying independently readable.
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

  const TIME_RE = /^([01]\d|2[0-3]):([0-5]\d)$/;

  function parseTimeOfDay(value, field) {
    const text = asText(value, 5);
    if (!TIME_RE.test(text)) {
      throw new HttpsError(
        "invalid-argument",
        `${field} must be a 24-hour time like "08:00".`
      );
    }
    return text;
  }

  function parseDaysOfWeek(value) {
    if (!Array.isArray(value) || value.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "daysOfWeek must be a non-empty array of 1-7 (Mon-Sun)."
      );
    }
    const days = value.map((d) => Number(d));
    if (days.some((d) => !Number.isInteger(d) || d < 1 || d > 7)) {
      throw new HttpsError(
        "invalid-argument",
        "daysOfWeek entries must be integers 1-7."
      );
    }
    return [...new Set(days)].sort((a, b) => a - b);
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
    if (caller.schoolId !== schoolId) {
      throw new HttpsError(
        "permission-denied",
        "You may only manage shifts for your own school."
      );
    }
    const roles = [
      caller.role,
      ...(Array.isArray(caller.roles) ? caller.roles : []),
    ];
    if (!roles.some((r) => CORRECTOR_ROLES.has(r))) {
      throw new HttpsError(
        "permission-denied",
        "Only an admin, head teacher, director, or HR officer may set staff shifts."
      );
    }
    return { uid: request.auth.uid };
  }

  async function handler(request) {
    const data = request.data || {};
    const schoolId = asText(data.schoolId, 200);
    const staffId = asText(data.staffId, 200);
    if (!staffId) {
      throw new HttpsError("invalid-argument", "staffId is required.");
    }

    const { uid } = await requireCorrector(request, schoolId);

    const staffSnap = await db.collection("users").doc(staffId).get();
    const staff = staffSnap.exists ? staffSnap.data() : null;
    if (!staff || staff.schoolId !== schoolId) {
      throw new HttpsError(
        "not-found",
        "That staff member is not part of this school."
      );
    }

    const scheduledStart = parseTimeOfDay(data.scheduledStart, "scheduledStart");
    const scheduledEnd = parseTimeOfDay(data.scheduledEnd, "scheduledEnd");
    const daysOfWeek = parseDaysOfWeek(data.daysOfWeek);
    const graceMinutes = Number.isFinite(Number(data.graceMinutes))
      ? Math.max(0, Math.min(120, Math.round(Number(data.graceMinutes))))
      : 0;

    const ref = db
      .collection("institutions")
      .doc(schoolId)
      .collection("staff_shifts")
      .doc(staffId);

    await ref.set(
      {
        staffId,
        schoolId,
        campusId: staff.campusId || null,
        scheduledStart,
        scheduledEnd,
        daysOfWeek,
        graceMinutes,
        updatedAt: serverTime(),
        updatedBy: uid,
      },
      { merge: true }
    );

    return { ok: true, staffId };
  }

  return {
    setStaffShift: onCall(CALLABLE_OPTS, handler),
    __test__: { CORRECTOR_ROLES, requireCorrector, handler, parseTimeOfDay, parseDaysOfWeek },
  };
};
