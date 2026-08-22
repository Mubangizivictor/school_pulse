/**
 * Upgrades existing schools/{schoolId}/staff_role_assignments rows whose
 * roleType is classTeacher/subjectTeacher to the current, fuller
 * RESPONSIBILITY_DEFAULT_PERMISSIONS set in functions/index.js.
 *
 * Needed because that map was originally "intentionally narrow" (2
 * permissions each - e.g. classTeacher only had attendance.take/view, never
 * class.students.view), so every Class/Subject Teacher assignment written
 * before the map was expanded is missing permissions their own panel
 * requires just to load - e.g. the dashboard's classStudentsView check.
 * createStaffAccount and overrideClassTeacherAssignment both stamp
 * permissionScope.permissions from this same map going forward, so this is
 * a one-time catch-up for rows written under the old, narrower map.
 *
 * Only ADDS permissions currently missing from the row's set - never
 * removes a permission the row already has (e.g. from a school-specific
 * grant), so a school that customized a row is not silently reset.
 *
 * Usage:
 *   node scripts/backfill_teacher_permissions.js                # dry run, whole project
 *   node scripts/backfill_teacher_permissions.js --apply                    # apply to every affected row
 *   node scripts/backfill_teacher_permissions.js --apply --only-uid=<uid>   # apply to one account's rows only
 */
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "school-pulse-3d95b" });
const db = admin.firestore();

const APPLY = process.argv.includes("--apply");
const onlyUidArg = process.argv.find((a) => a.startsWith("--only-uid="));
const ONLY_UID = onlyUidArg ? onlyUidArg.split("=")[1] : null;

// Mirrors functions/index.js RESPONSIBILITY_DEFAULT_PERMISSIONS - kept as a
// literal copy rather than a shared import since this is a one-time repair
// script, not a code path the Cloud Function itself runs.
const CURRENT_DEFAULTS = {
  classTeacher: [
    "class.students.view", "class.student.profile.view",
    "class.attendance.take", "class.attendance.edit", "class.attendance.view",
    "class.homework.create", "class.homework.publish", "class.homework.edit",
    "class.behaviour.record", "class.behaviour.view", "class.achievement.record",
    "class.leave.view",
    "class.parent.message", "class.announcement.create", "class.announcement.publish",
    "class.performance.view",
    "class.report.entry", "class.report.competency.entry", "class.report.conduct.entry",
    "class.report.comment.write", "class.report.recommendation.write",
    "class.report.submit", "class.report.generate", "class.report.share", "class.report.export",
    "class.task.manage", "class.task.collaborate",
    "class.resource.upload", "class.resource.share",
    "class.timetable.view",
  ],
  subjectTeacher: [
    "subject.students.view", "subject.student.enroll", "subject.student.remove",
    "subject.lesson.view", "subject.lesson.start", "subject.lesson.complete",
    "subject.attendance.take", "subject.attendance.edit",
    "subject.resource.upload", "subject.resource.share",
    "subject.assessment.create",
    "subject.marks.view", "subject.marks.enter", "subject.marks.edit", "subject.marks.submit",
    "subject.report.view", "subject.report.generate",
    "subject.parent.message", "subject.student.message", "subject.announcement.send",
    "subject.timetable.view",
  ],
};

async function main() {
  let scanned = 0;
  let affected = 0;
  let updated = 0;

  const schoolsSnap = await db.collection("schools").get();

  for (const schoolDoc of schoolsSnap.docs) {
    const schoolId = schoolDoc.id;
    const assignmentsSnap = await db
      .collection("schools")
      .doc(schoolId)
      .collection("staff_role_assignments")
      .where("roleType", "in", ["classTeacher", "subjectTeacher"])
      .where("status", "==", "active")
      .get();

    for (const doc of assignmentsSnap.docs) {
      const data = doc.data();
      if (ONLY_UID && data.userId !== ONLY_UID) continue;

      scanned++;
      const target = CURRENT_DEFAULTS[data.roleType];
      if (!target) continue;

      const existing = (data.permissionScope && data.permissionScope.permissions) || [];
      const missing = target.filter((p) => !existing.includes(p));
      if (missing.length === 0) continue;

      affected++;
      const merged = [...existing, ...missing];
      console.log(
        `[affected] school=${schoolId} assignment=${doc.id} userId=${data.userId} roleType=${data.roleType} adding ${missing.length} permission(s): ${missing.join(", ")}`
      );

      if (!APPLY) continue;

      await doc.ref.update({
        "permissionScope.permissions": merged,
      });
      updated++;
    }
  }

  console.log("\n=== Summary ===");
  console.log(`scanned (active classTeacher/subjectTeacher rows${ONLY_UID ? ` for uid=${ONLY_UID}` : ""}): ${scanned}`);
  console.log(`affected (missing at least one current default permission): ${affected}`);
  console.log(`mode: ${APPLY ? `APPLY${ONLY_UID ? ` (only-uid=${ONLY_UID})` : " (project-wide)"}` : "DRY RUN"}`);
  if (APPLY) console.log(`rows updated: ${updated}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Fatal error:", err);
    process.exit(1);
  });
