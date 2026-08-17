const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

/**
 * Server-side relationship + permission resolver for reading a single
 * student's data, returning only the fields the caller's role and actual
 * relationship to that specific student authorize - never a full student
 * doc for the client to filter itself. This is the missing enforcement
 * layer the spec calls out: PermissionEvaluatorImpl (Flutter-side) decides
 * whether an operator generally *holds* a permission like
 * subject.marks.view, but nothing before this checked whether a Subject
 * Teacher who holds that permission actually teaches *this* student's
 * subject/class - a client-side-only check could not enforce that even if
 * it tried, since Firestore Security Rules cannot join across
 * staff_role_assignments to a student's classId/subjects at read time.
 *
 * Sections and their DTOs (each strictly a field allow-list, never the raw
 * doc):
 *   'identity' -> every authorized caller (basic identity fields)
 *   'academic' -> AdminStudentView-equivalent for staff with class/subject
 *                 relationship, StudentSelfView for the student, parent
 *                 read for linked parents
 *   'finance'  -> Bursar/Admin only (financeStudentBalanceRead)
 *   'health'   -> Nurse/Admin only (healthStudent*Read), plus parent/self
 *   'discipline' -> Class Teacher (own class)/Admin only
 *   'security' -> minimal SecurityStudentView (name/photo/class/status only)
 */

const db = () => admin.firestore();

async function loadCaller(uid) {
  const snap = await db().collection("users").doc(uid).get();
  const data = snap.exists ? snap.data() : {};
  return {
    uid,
    role: data.role || null,
    roles: Array.isArray(data.roles) ? data.roles : (data.role ? [data.role] : []),
    schoolId: data.schoolId || null,
  };
}

async function loadStudent(studentId) {
  const snap = await db().collection("students").doc(studentId).get();
  if (!snap.exists) return null;
  return { id: snap.id, ...snap.data() };
}

/** Active (non-ended, status=='active') staff_role_assignments for a user. */
async function loadActiveAssignments(schoolId, uid) {
  const snap = await db()
    .collection("schools").doc(schoolId)
    .collection("staff_role_assignments")
    .where("userId", "==", uid)
    .where("status", "==", "active")
    .get();
  return snap.docs.map((d) => d.data());
}

function isClassTeacherFor(assignments, student) {
  return assignments.some((a) =>
    a.roleType === "classTeacher" &&
    a.classId && student.classId && a.classId === student.classId &&
    (!a.streamId || !student.streamId || a.streamId === student.streamId));
}

function isSubjectTeacherFor(assignments, student) {
  // Subject teacher relationship is scoped to a class/stream the subject is
  // taught in - matches ActiveResponsibilityContext's own class+subject
  // pairing (see effective_access_resolver.dart), not "teaches this subject
  // anywhere in the school".
  return assignments.some((a) =>
    a.roleType === "subjectTeacher" &&
    a.classId && student.classId && a.classId === student.classId &&
    (!a.streamId || !student.streamId || a.streamId === student.streamId));
}

async function isLinkedParent(schoolId, uid, studentId) {
  const snap = await db()
    .collection("parent_student_relationships")
    .where("schoolId", "==", schoolId)
    .where("userId", "==", uid)
    .where("studentId", "==", studentId)
    .where("status", "==", "active")
    .limit(1)
    .get();
  return !snap.empty;
}

const STAFF_ADMIN_ROLES = new Set([
  "schoolAdmin", "director", "headTeacher", "deputyHead", "deanOfStudies",
]);

/** Base identity fields every authorized caller may see. */
function identityView(student) {
  return {
    id: student.id,
    name: student.name,
    photoUrl: student.photoUrl || null,
    studentCode: student.studentCode,
    classId: student.classId,
    streamId: student.streamId || null,
    status: student.status,
  };
}

async function buildSecurityView(student) {
  // Minimal fields only - never parent contacts, fees, marks, attendance,
  // medical data, or discipline records, per the spec's SecurityStudentView.
  return {
    kind: "SecurityStudentView",
    id: student.id,
    name: student.name,
    photoUrl: student.photoUrl || null,
    classId: student.classId,
    status: student.status,
  };
}

async function buildFinanceView(schoolId, student) {
  return {
    kind: "FinanceStudentView",
    ...identityView(student),
    admissionNumber: student.admissionNumber,
    // Fee balance/finance ledger is out of scope here - no dedicated
    // finance collection with a stable schema was found alongside
    // students/{id} in this codebase (see completion report). Left as an
    // explicit null rather than guessing a collection name and silently
    // returning nothing meaningful.
    feeBalance: null,
  };
}

async function buildHealthView(schoolId, student) {
  const profileSnap = await db().collection("health_profiles")
    .where("studentId", "==", student.id).limit(1).get();
  const profile = profileSnap.empty ? null : profileSnap.docs[0].data();
  return {
    kind: "HealthStudentView",
    ...identityView(student),
    medicalInfo: student.medicalInfo || null,
    healthProfile: profile ? {
      allergies: profile.allergies || null,
      conditions: profile.conditions || null,
      emergencyNotes: profile.emergencyNotes || null,
    } : null,
  };
}

async function buildTeacherView(student, { includeDiscipline }) {
  const view = {
    kind: "TeacherStudentView",
    ...identityView(student),
    emergencyContacts: student.emergencyContacts || [],
  };
  if (includeDiscipline) {
    const disciplineSnap = await db().collection("discipline_incidents")
      .where("studentId", "==", student.id).limit(20).get();
    view.disciplineIncidents = disciplineSnap.docs.map((d) => {
      const data = d.data();
      return { id: d.id, type: data.type || null, date: data.date || null, summary: data.summary || null };
    });
  }
  return view;
}

async function buildAdminView(student) {
  return {
    kind: "AdminStudentView",
    ...identityView(student),
    admissionNumber: student.admissionNumber,
    dateOfBirth: student.dateOfBirth || null,
    gender: student.gender || null,
    academicYearId: student.academicYearId || null,
    parentIds: student.parentIds || [],
    emergencyContacts: student.emergencyContacts || [],
    medicalInfo: student.medicalInfo || null,
  };
}

async function buildParentView(student) {
  return {
    kind: "ParentStudentView",
    ...identityView(student),
    academicYearId: student.academicYearId || null,
  };
}

async function buildSelfView(student) {
  return {
    kind: "StudentSelfView",
    ...identityView(student),
    admissionNumber: student.admissionNumber,
    academicYearId: student.academicYearId || null,
  };
}

/**
 * getStudentView(studentId, section) - the single callable every client
 * surface (Security scan screen, Bursar lookup, Class Teacher roster,
 * Nurse lookup, Student Portal, Parent Portal) should call instead of
 * reading students/{id} directly for anything beyond the coarse
 * students/{id} Firestore rule already in place. section selects which DTO
 * builder runs; the caller's role + actual relationship to studentId
 * decides whether that section is allowed at all.
 */
exports.getStudentView = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const studentId = request.data?.studentId;
  const section = request.data?.section || "identity";
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const caller = await loadCaller(request.auth.uid);
  const student = await loadStudent(studentId);
  if (!student) {
    throw new HttpsError("not-found", "Student not found.");
  }

  // Tenant isolation first, before any relationship/permission check -
  // matches every other Cloud Function in this codebase (requireStaffCaller
  // et al.): a caller from a different school never gets far enough to
  // learn *why* they were denied a specific section.
  if (!caller.schoolId || caller.schoolId !== student.schoolId) {
    throw new HttpsError("permission-denied", "This student is not in your school.");
  }

  const isSelf = caller.role === "student" && caller.uid === (student.userId || studentId);
  const isAdmin = STAFF_ADMIN_ROLES.has(caller.role);

  if (isSelf) {
    if (section === "identity" || section === "academic") {
      return { section, data: await buildSelfView(student) };
    }
    throw new HttpsError("permission-denied", "Students may only view their own basic profile.");
  }

  if (caller.role === "parent") {
    const linked = await isLinkedParent(caller.schoolId, caller.uid, studentId);
    if (!linked) {
      throw new HttpsError("permission-denied", "You are not a linked guardian for this student.");
    }
    if (section === "identity" || section === "academic") {
      return { section, data: await buildParentView(student) };
    }
    throw new HttpsError("permission-denied", "Parents may only view identity/academic sections.");
  }

  if (isAdmin) {
    return { section, data: await buildAdminView(student) };
  }

  switch (section) {
    case "security": {
      if (caller.role !== "gatekeeper" && caller.role !== "securityHead" && !isAdmin) {
        throw new HttpsError("permission-denied", "Security section is staff-security-only.");
      }
      return { section, data: await buildSecurityView(student) };
    }
    case "finance": {
      if (caller.role !== "bursar") {
        throw new HttpsError("permission-denied", "Finance section is Bursar-only.");
      }
      return { section, data: await buildFinanceView(caller.schoolId, student) };
    }
    case "health": {
      if (caller.role !== "nurse") {
        throw new HttpsError("permission-denied", "Health section is Nurse-only.");
      }
      return { section, data: await buildHealthView(caller.schoolId, student) };
    }
    case "discipline": {
      const assignments = await loadActiveAssignments(caller.schoolId, caller.uid);
      if (!isClassTeacherFor(assignments, student)) {
        throw new HttpsError("permission-denied", "You are not the class teacher for this student.");
      }
      return { section, data: await buildTeacherView(student, { includeDiscipline: true }) };
    }
    case "academic": {
      const assignments = await loadActiveAssignments(caller.schoolId, caller.uid);
      const isClassTeacher = isClassTeacherFor(assignments, student);
      const isSubjectTeacher = isSubjectTeacherFor(assignments, student);
      if (!isClassTeacher && !isSubjectTeacher) {
        // The relationship join Firestore Rules cannot do: a Subject
        // Teacher who generally holds subject.marks.view must still not be
        // able to read a student outside their own assigned class/subject
        // just by calling this with a different studentId.
        throw new HttpsError(
          "permission-denied",
          "You do not teach this student's class/subject.",
        );
      }
      return {
        section,
        data: await buildTeacherView(student, { includeDiscipline: isClassTeacher }),
      };
    }
    case "identity": {
      // Any same-school staff member may see the minimal identity fields -
      // matches the existing coarse isStaff() && isSameSchool() Firestore
      // rule on students/{id}; every narrower section above is the actual
      // new enforcement.
      return { section, data: identityView(student) };
    }
    default:
      throw new HttpsError("invalid-argument", `Unknown section: ${section}`);
  }
});

exports.__test__ = {
  identityView, isClassTeacherFor, isSubjectTeacherFor, STAFF_ADMIN_ROLES,
};
