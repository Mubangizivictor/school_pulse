/** Scoped teacher permission lists shared by the demo seed scripts
 *  (seed_primary_demo.js, seed_demo_school_emulator.js). Staff role
 *  assignments carry these explicitly: PermissionScope.grants() does not
 *  fall back to role defaults. */
// Keep the demo Class Teacher role usable end-to-end. These are the same
// scoped capabilities granted by the in-app demo seeder, not administrator
// permissions, so the account can only work with its assigned class.
const CLASS_TEACHER_PERMISSIONS = [
  'class.students.view',
  'class.student.profile.view',
  'class.student.historical.view',
  'class.student.note.write',
  'class.attendance.take',
  'class.attendance.edit',
  'class.attendance.view',
  'class.homework.create',
  'class.homework.publish',
  'class.homework.edit',
  'class.behaviour.record',
  'class.behaviour.view',
  'class.achievement.record',
  'class.health_alert.view',
  'class.leave.view',
  'class.parent.message',
  'class.announcement.create',
  'class.announcement.publish',
  'class.performance.view',
  'class.intervention_note.write',
  'class.report.entry',
  'class.report.competency.entry',
  'class.report.conduct.entry',
  'class.report.comment.write',
  'class.report.recommendation.write',
  'class.report.submit',
  'class.report.generate',
  'class.report.share',
  'class.report.export',
  'class.task.manage',
  'class.task.collaborate',
  'class.resource.upload',
  'class.resource.share',
  'class.timetable.view',
];

// Scoped Subject Teacher capabilities - Mathematics/Primary 1 only, per the
// active_responsibility_context.can(...) checks in SubjectResourceRepository
// and the equivalent subject-scoped repositories. Deliberately excludes
// every class.* permission: this account must not be able to reach Class
// Teacher-only capabilities (final reports, competencies, conduct).
const SUBJECT_TEACHER_PERMISSIONS = [
  'subject.students.view',
  'subject.student.historical.view',
  'subject.lesson.view',
  'subject.lesson.start',
  'subject.lesson.complete',
  'subject.attendance.take',
  'subject.attendance.edit',
  'subject.lesson_note.create',
  'subject.lesson_note.edit',
  'subject.resource.upload',
  'subject.resource.share',
  'subject.assessment.create',
  'subject.marks.view',
  'subject.marks.enter',
  'subject.marks.edit',
  'subject.marks.submit',
  'subject.report.view',
  'subject.report.generate',
  'subject.analytics.view',
  'subject.parent.message',
  'subject.student.message',
  'subject.timetable.view',
];

module.exports = { CLASS_TEACHER_PERMISSIONS, SUBJECT_TEACHER_PERMISSIONS };
