const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { requirePlatformOwner, OwnerAuthorizationError } = require("./vendor/owner-auth");

// Mirrors isStaff() in firestore.rules: any non-parent, non-student role.
// The Admin SDK bypasses Firestore rules entirely, so this check is the
// only gate on who may call these functions - it must happen here, same
// pattern as createStaffAccount's callerRoles check in index.js.
function isStaffRole(role) {
  return role && role !== "parent" && role !== "student";
}

const ACTIVE_ENROLMENT_STATUSES = new Set(["active"]);

async function requireStaffCaller(auth) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const db = admin.firestore();
  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  if (!isStaffRole(callerData.role)) {
    throw new HttpsError("permission-denied", "Only staff can manage student records.");
  }
  const schoolId = callerData.schoolId || null;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }
  return { db, schoolId };
}

/**
 * Creates a student record inside a transaction that also enforces the
 * school's subscription.maxStudents cap (denormalized onto schools/{id} by
 * payments.js:approveManualPayment). Replaces the old direct client
 * firestore.batch() write in student_remote_data_source.dart, which had no
 * way to see - let alone atomically check - a live student count: Firestore
 * Security Rules cannot run aggregation queries, so the cap can only be
 * enforced where a real read-then-write transaction is possible.
 *
 * A cap of 0 (or a school with no subscription.maxStudents set at all) is
 * treated as uncapped - matches the existing UI convention where
 * plan.maxStudents > 0 gates whether the limit chip even renders
 * (subscription_plans_screen.dart).
 *
 * Shared by both createStudent (direct creation) and finalizeAdmission (the
 * admissions workflow) via the optional `application` payload, since both
 * paths create exactly one student doc and both can equally push a school
 * over its cap - splitting them into two separate cap-checking functions
 * would just duplicate the same transaction.
 */
exports.createStudentWithCapacityCheck = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const student = request.data?.student;
  const recordedBy = request.data?.recordedBy || request.auth.uid;
  const application = request.data?.application || null;

  if (!student || typeof student !== "object") {
    throw new HttpsError("invalid-argument", "Student data is required.");
  }
  const schoolId = student.schoolId || callerSchoolId;
  if (schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "Cannot create a student for a different school.");
  }
  if (application && application.id && application.schoolId && application.schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "Cannot finalize an admission for a different school.");
  }

  const schoolRef = db.collection("schools").doc(schoolId);
  const studentRef = db.collection("students").doc();
  const enrolmentRef = db.collection("student_enrolments").doc();
  const applicationRef = application?.id
    ? db.collection("admission_applications").doc(application.id)
    : null;

  const result = await db.runTransaction(async (tx) => {
    const schoolSnap = await tx.get(schoolRef);
    if (!schoolSnap.exists) {
      throw new HttpsError("failed-precondition", "School not found.");
    }
    const school = schoolSnap.data() || {};
    const subscription = school.subscription && typeof school.subscription === "object" ? school.subscription : {};
    const maxStudents = Number(subscription.maxStudents || 0);
    const activeStudentCount = Number(subscription.activeStudentCount || 0);
    if (maxStudents > 0 && activeStudentCount >= maxStudents) {
      throw new HttpsError(
        "resource-exhausted",
        `This school has reached its ${subscription.planName || "current"} plan's ${maxStudents}-student limit. Upgrade the plan to continue enrolling students.`,
      );
    }

    // The Flutter client sends dateOfBirth as an ISO string (callables
    // can't carry a Firestore Timestamp over the wire) - convert back so
    // the stored shape matches every other writer of this collection.
    // StudentModel.fromMap() on the client already accepts either shape.
    const dateOfBirth = typeof student.dateOfBirth === "string"
      ? admin.firestore.Timestamp.fromDate(new Date(student.dateOfBirth))
      : student.dateOfBirth;
    const studentData = { ...student, id: studentRef.id, schoolId, dateOfBirth };
    tx.set(studentRef, studentData);
    tx.set(enrolmentRef, {
      schoolId,
      studentId: studentRef.id,
      classId: student.classId ?? null,
      streamId: student.streamId ?? null,
      academicYearId: student.academicYearId ?? null,
      status: "active",
      startDate: admin.firestore.Timestamp.now(),
      reason: application ? "initial admission" : "direct creation",
      recordedBy,
      createdAt: admin.firestore.Timestamp.now(),
    });
    if (applicationRef) {
      tx.update(applicationRef, {
        status: "admitted",
        studentId: studentRef.id,
        admissionNumber: student.admissionNumber ?? null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    tx.set(schoolRef, {
      subscription: { ...subscription, activeStudentCount: activeStudentCount + 1 },
    }, { merge: true });

    return { studentId: studentRef.id };
  });

  return result;
});

/**
 * Changes a student's enrolment status and keeps schools/{id}.subscription.
 * activeStudentCount in sync in the same transaction - capacity means
 * ACTIVE enrolled students only (excludes graduated/withdrawn/transferred/
 * alumni per the billing spec), so a status change crossing that boundary
 * must adjust the counter, not just the student doc.
 */
exports.updateStudentStatusWithCapacityAdjustment = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const studentId = request.data?.studentId;
  const status = request.data?.status;
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }
  if (typeof status !== "string" || !status) {
    throw new HttpsError("invalid-argument", "status is required.");
  }

  const studentRef = db.collection("students").doc(studentId);

  await db.runTransaction(async (tx) => {
    const studentSnap = await tx.get(studentRef);
    if (!studentSnap.exists) {
      throw new HttpsError("not-found", "Student not found.");
    }
    const studentData = studentSnap.data() || {};
    const schoolId = studentData.schoolId;
    if (schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot modify a student from a different school.");
    }
    const previousStatus = studentData.status;
    const wasActive = ACTIVE_ENROLMENT_STATUSES.has(previousStatus);
    const willBeActive = ACTIVE_ENROLMENT_STATUSES.has(status);

    tx.update(studentRef, {
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (wasActive !== willBeActive) {
      const schoolRef = db.collection("schools").doc(schoolId);
      const schoolSnap = await tx.get(schoolRef);
      if (schoolSnap.exists) {
        const school = schoolSnap.data() || {};
        const subscription = school.subscription && typeof school.subscription === "object" ? school.subscription : {};
        const current = Number(subscription.activeStudentCount || 0);
        const next = Math.max(0, current + (willBeActive ? 1 : -1));
        tx.set(schoolRef, {
          subscription: { ...subscription, activeStudentCount: next },
        }, { merge: true });
      }
    }
  });

  return { ok: true };
});

/**
 * One-time backfill: writes the true current active-student count onto
 * every school's subscription.activeStudentCount. Required before
 * createStudentWithCapacityCheck takes real traffic - a fresh counter
 * starting at 0 would let every existing school silently over-provision up
 * to maxStudents *additional* students beyond what they actually have,
 * since the counter only increments from here, it never re-syncs to
 * reality on its own. Owner-only; run once manually, not on a schedule.
 */
exports.backfillActiveStudentCounts = onCall(async (request) => {
  const db = admin.firestore();
  try {
    await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }

  const schoolsSnap = await db.collection("schools").get();
  const results = [];
  for (const schoolDoc of schoolsSnap.docs) {
    const schoolId = schoolDoc.id;
    const countSnap = await db.collection("students")
      .where("schoolId", "==", schoolId)
      .where("status", "==", "active")
      .count()
      .get();
    const activeStudentCount = countSnap.data().count;
    const school = schoolDoc.data() || {};
    const subscription = school.subscription && typeof school.subscription === "object" ? school.subscription : {};
    await schoolDoc.ref.set({
      subscription: { ...subscription, activeStudentCount },
    }, { merge: true });
    results.push({ schoolId, activeStudentCount });
  }
  return { ok: true, schools: results };
});
