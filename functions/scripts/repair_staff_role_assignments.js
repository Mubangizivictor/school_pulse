/**
 * Repairs users/{uid} docs whose classTeacher/subjectTeacher roles never
 * got a matching row in schools/{schoolId}/staff_role_assignments - the
 * canonical collection the teacher panel and firestore.rules actually
 * trust. This happens for accounts created before createStaffAccount
 * (functions/index.js) was fixed to always write it: the old code only
 * wrote the canonical row when the caller happened to supply an
 * academicYearId, and even then stored a className string instead of a
 * real classId.
 *
 * Scan logic is general - it looks at every staff account with a teaching
 * role, not one specific email - but writes are gated behind --apply and
 * can be narrowed to one account with --only-uid so a first production run
 * touches only a verified account rather than every legacy record at once.
 *
 * Usage:
 *   node scripts/repair_staff_role_assignments.js                # dry run, whole project
 *   node scripts/repair_staff_role_assignments.js --apply                        # apply to every affected account
 *   node scripts/repair_staff_role_assignments.js --apply --only-uid=<uid>       # apply to one account only
 */
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "school-pulse-3d95b" });
const db = admin.firestore();

const APPLY = process.argv.includes("--apply");
const onlyUidArg = process.argv.find((a) => a.startsWith("--only-uid="));
const ONLY_UID = onlyUidArg ? onlyUidArg.split("=")[1] : null;

async function resolveClassId(schoolId, className) {
  if (!className) return null;
  const q = await db
    .collection("classes")
    .where("schoolId", "==", schoolId)
    .where("name", "==", className)
    .get();
  if (q.size === 0) return { error: `no class named "${className}"` };
  if (q.size > 1) return { error: `ambiguous: ${q.size} classes named "${className}"` };
  return { id: q.docs[0].id };
}

async function resolveSubjectId(schoolId, subjectName) {
  if (!subjectName) return null;
  const q = await db
    .collection("subjects")
    .where("schoolId", "==", schoolId)
    .where("name", "==", subjectName)
    .get();
  if (q.size === 0) return { error: `no subject named "${subjectName}"` };
  if (q.size > 1) return { error: `ambiguous: ${q.size} subjects named "${subjectName}"` };
  return { id: q.docs[0].id };
}

async function resolveCurrentAcademicYearId(schoolId) {
  const q = await db
    .collection("academic_years")
    .where("schoolId", "==", schoolId)
    .where("isCurrent", "==", true)
    .limit(1)
    .get();
  if (q.empty) return null;
  return q.docs[0].id;
}

async function main() {
  const usersSnap = await db.collection("users").get();

  let scanned = 0;
  let affected = 0;
  let appliedCount = 0;
  const ambiguities = [];

  for (const userDoc of usersSnap.docs) {
    const uid = userDoc.id;
    const user = userDoc.data();
    const roles = Array.isArray(user.roles) ? user.roles : (user.role ? [user.role] : []);
    const isClassTeacher = roles.includes("classTeacher");
    const isSubjectTeacher = roles.includes("subjectTeacher");
    if (!isClassTeacher && !isSubjectTeacher) continue;
    if (!user.schoolId) continue;

    scanned++;
    const schoolId = user.schoolId;

    const existing = await db
      .collection("schools")
      .doc(schoolId)
      .collection("staff_role_assignments")
      .where("userId", "==", uid)
      .where("status", "==", "active")
      .get();

    const hasClassTeacherRow = existing.docs.some(
      (d) => d.data().roleType === "classTeacher" && d.data().classId
    );
    const hasSubjectTeacherRows = existing.docs.some(
      (d) => d.data().roleType === "subjectTeacher" && d.data().classId
    );

    const missingClassTeacher = isClassTeacher && !hasClassTeacherRow;
    const missingSubjectTeacher = isSubjectTeacher && !hasSubjectTeacherRows;
    if (!missingClassTeacher && !missingSubjectTeacher) continue;

    affected++;
    const isTargetAccount = ONLY_UID ? uid === ONLY_UID : true;
    const verbose = !ONLY_UID || uid === ONLY_UID;

    if (verbose) {
      console.log(`\n[affected] uid=${uid} school=${schoolId} missingClassTeacher=${missingClassTeacher} missingSubjectTeacher=${missingSubjectTeacher}`);
    } else {
      console.log(`[affected] uid=${uid} school=${schoolId} role=${missingClassTeacher ? "classTeacher" : "subjectTeacher"}`);
    }

    if (ONLY_UID && !isTargetAccount) continue;

    const academicYearId = await resolveCurrentAcademicYearId(schoolId);
    if (!academicYearId) {
      console.log(`  SKIP: no current academic year for school ${schoolId}`);
      ambiguities.push({ uid, schoolId, reason: "no current academic year" });
      continue;
    }

    const writes = [];

    if (missingClassTeacher && user.assignedClass) {
      const resolved = await resolveClassId(schoolId, user.assignedClass);
      if (resolved && resolved.error) {
        console.log(`  SKIP classTeacher: ${resolved.error}`);
        ambiguities.push({ uid, schoolId, role: "classTeacher", reason: resolved.error });
      } else if (resolved) {
        writes.push({
          roleType: "classTeacher",
          classId: resolved.id,
          className: user.assignedClass,
        });
        if (verbose) console.log(`  classTeacher -> classId=${resolved.id} (${user.assignedClass})`);
      }
    }

    if (missingSubjectTeacher && Array.isArray(user.subjects)) {
      for (const s of user.subjects) {
        const [classResolved, subjectResolved] = await Promise.all([
          resolveClassId(schoolId, s.className),
          resolveSubjectId(schoolId, s.subjectName),
        ]);
        if (classResolved && classResolved.error) {
          console.log(`  SKIP subjectTeacher(${s.subjectName}/${s.className}): ${classResolved.error}`);
          ambiguities.push({ uid, schoolId, role: "subjectTeacher", reason: classResolved.error });
          continue;
        }
        if (subjectResolved && subjectResolved.error) {
          console.log(`  SKIP subjectTeacher(${s.subjectName}/${s.className}): ${subjectResolved.error}`);
          ambiguities.push({ uid, schoolId, role: "subjectTeacher", reason: subjectResolved.error });
          continue;
        }
        writes.push({
          roleType: "subjectTeacher",
          classId: classResolved.id,
          className: s.className,
          subjectId: subjectResolved.id,
          subjectName: s.subjectName,
        });
        if (verbose) console.log(`  subjectTeacher -> classId=${classResolved.id} subjectId=${subjectResolved.id} (${s.subjectName}/${s.className})`);
      }
    }

    if (writes.length === 0) continue;

    if (!APPLY) {
      console.log(`  DRY RUN: would write ${writes.length} row(s)`);
      continue;
    }

    const batch = db.batch();
    const assignmentsRef = db.collection("schools").doc(schoolId).collection("staff_role_assignments");
    const now = admin.firestore.FieldValue.serverTimestamp();
    for (const w of writes) {
      const permissionScope =
        w.roleType === "classTeacher"
          ? { permissions: ["class.attendance.take", "class.attendance.view"], classId: w.classId, academicYearId, termIds: [] }
          : { permissions: ["subject.marks.enter", "subject.attendance.take"], subjectId: w.subjectId, classId: w.classId, academicYearId, termIds: [] };
      batch.set(assignmentsRef.doc(), {
        schoolId,
        staffId: uid,
        userId: uid,
        roleType: w.roleType,
        academicYearId,
        classId: w.classId,
        className: w.className,
        ...(w.subjectId ? { subjectId: w.subjectId, subjectName: w.subjectName } : {}),
        startDate: now,
        status: "active",
        permissionScope,
        assignedBy: "repair_staff_role_assignments_script",
        assignedAt: now,
      });
    }
    await batch.commit();
    appliedCount += writes.length;
    console.log(`  APPLIED: wrote ${writes.length} row(s)`);
  }

  console.log("\n=== Summary ===");
  console.log(`scanned (teaching-role accounts): ${scanned}`);
  console.log(`affected (missing canonical rows): ${affected}`);
  console.log(`mode: ${APPLY ? `APPLY${ONLY_UID ? ` (only-uid=${ONLY_UID})` : " (project-wide)"}` : "DRY RUN"}`);
  if (APPLY) console.log(`rows written: ${appliedCount}`);
  if (ambiguities.length > 0) {
    console.log(`\nunresolved (${ambiguities.length}) - not written, needs manual review:`);
    ambiguities.forEach((a) => console.log(`  uid=${a.uid} school=${a.schoolId} ${a.role || ""}: ${a.reason}`));
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Fatal error:", err);
    process.exit(1);
  });
