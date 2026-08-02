/// The full granular permission-ID catalog for School Pulse's shared
/// verification system, declared upfront across every module the
/// end-state spec covers so later phases never need a breaking rename.
///
/// Enforced subsets: `security.*`/`verification.*` (Security/Gate),
/// `admission.*` (Admissions), and `health.*`/`finance.*`/`library.*`/
/// `transport.*`/`meals.*` for the Nurse/Bursar/Librarian/Transport
/// Coordinator/Catering Manager information-projection services. Every
/// other ID here is inert until its own phase wires enforcement and
/// `role_permission_defaults` entries for it.
class Permission {
  const Permission._();

  // Attendance
  static const attendanceClassScan = 'attendance.class.scan';
  static const attendanceSubjectScan = 'attendance.subject.scan';
  static const attendanceStaffScan = 'attendance.staff.scan';
  static const attendanceBoardingScan = 'attendance.boarding.scan';
  static const attendanceGateScan = 'attendance.gate.scan';
  static const attendanceOverride = 'attendance.override';

  // Health
  static const healthStudentVerify = 'health.student.verify';
  static const healthStudentBasicRead = 'health.student.basic.read';
  static const healthStudentClinicalRead = 'health.student.clinical.read';
  static const healthStudentVisitCreate = 'health.student.visit.create';
  static const healthStudentEmergencyRead = 'health.student.emergency.read';

  // Meals / catering
  static const mealsVerify = 'meals.verify';
  static const mealsServe = 'meals.serve';
  static const mealsOverride = 'meals.override';
  static const mealsAuditRead = 'meals.audit.read';

  // Transport
  static const transportBoardingVerify = 'transport.boarding.verify';
  static const transportBoardingRecord = 'transport.boarding.record';
  static const transportDropoffRecord = 'transport.dropoff.record';
  static const transportOverride = 'transport.override';

  // Library
  static const libraryMemberVerify = 'library.member.verify';
  static const libraryBorrow = 'library.borrow';
  static const libraryReturn = 'library.return';

  // Finance / bursar - no prior art existed for this domain (unlike
  // health.*/library.*/meals.*/transport.*, which were all pre-declared);
  // added alongside the Bursar information-projection service.
  static const financeStudentVerify = 'finance.student.verify';
  static const financeStudentBalanceRead = 'finance.student.balance.read';

  // Boarding / dormitory
  static const boardingRollcallScan = 'boarding.rollcall.scan';
  static const boardingStudentVerify = 'boarding.student.verify';
  static const boardingOverride = 'boarding.override';

  // Examinations
  static const examEligibilityVerify = 'exam.eligibility.verify';
  static const examAttendanceScan = 'exam.attendance.scan';
  static const examOverride = 'exam.override';

  // Security / gate (Phase 1 - enforced)
  static const securityIdentityVerify = 'security.identity.verify';
  static const securityEntryRecord = 'security.entry.record';
  static const securityExitRecord = 'security.exit.record';
  static const securityOverride = 'security.override';

  // Admissions / enrollment (enforced) - gates AdmissionBloc's
  // EnrollStudentRequested handler, per the product requirement that
  // enrollment is permission-based, never a hardcoded job-title check.
  static const admissionApplicationCreate = 'admission.application.create';
  static const admissionApplicationReview = 'admission.application.review';
  static const admissionEnroll = 'admission.enroll';

  // Student data-visibility scoping
  static const studentBasicRead = 'student.basic.read';
  static const studentFullRead = 'student.full.read';

  // Cross-cutting verification engine (Phase 1 - enforced)
  static const verificationOverride = 'verification.override';
  static const verificationAuditRead = 'verification.audit.read';
  static const verificationDeviceManage = 'verification.device.manage';

  // Notifications (enforced) - gate who may send, broadcast, schedule and
  // inspect notifications, and which deep-link destinations a recipient may
  // actually open. `notification.view` is implicitly held by every signed-in
  // user for their own notifications; it exists here for explicit denial.
  static const notificationView = 'notification.view';
  static const notificationSend = 'notification.send';
  static const notificationSendToParent = 'notification.send_to_parent';
  static const notificationSendToStudent = 'notification.send_to_student';
  static const notificationSendToStaff = 'notification.send_to_staff';
  static const notificationBroadcast = 'notification.broadcast';
  static const notificationSchedule = 'notification.schedule';
  static const notificationCancel = 'notification.cancel';
  static const notificationUseImages = 'notification.use_images';
  static const notificationUseAttachments = 'notification.use_attachments';
  static const notificationSendEmergency = 'notification.send_emergency';
  static const notificationViewDeliveryReports = 'notification.view_delivery_reports';
  static const notificationManageTemplates = 'notification.manage_templates';
  static const notificationManageSettings = 'notification.manage_settings';
  static const notificationAcknowledge = 'notification.acknowledge';
  static const notificationArchive = 'notification.archive';
  static const notificationDelete = 'notification.delete';
  static const notificationSeedTestData = 'notification.seed_test_data';
  static const notificationRunDeliveryTest = 'notification.run_delivery_test';

  // Subject Teacher panel (enforced) - every one of these is meaningless on
  // its own: it is only ever evaluated together with the scope carried by the
  // staff role assignment it was granted through (subject + class + stream +
  // academic year), never as a bare "user is a teacher" check. See
  // `PermissionScope` and `ActiveResponsibilityContext`.
  static const subjectStudentsView = 'subject.students.view';
  static const subjectStudentEnroll = 'subject.student.enroll';
  static const subjectStudentRemove = 'subject.student.remove';
  static const subjectStudentHistoricalView = 'subject.student.historical.view';

  static const subjectLessonView = 'subject.lesson.view';
  static const subjectLessonStart = 'subject.lesson.start';
  static const subjectLessonComplete = 'subject.lesson.complete';
  static const subjectLessonCancel = 'subject.lesson.cancel';
  static const subjectLessonReschedule = 'subject.lesson.reschedule';

  static const subjectAttendanceTake = 'subject.attendance.take';
  static const subjectAttendanceEdit = 'subject.attendance.edit';
  static const subjectAttendanceEditHistorical = 'subject.attendance.edit_historical';

  static const subjectLessonNoteCreate = 'subject.lesson_note.create';
  static const subjectLessonNoteEdit = 'subject.lesson_note.edit';

  static const subjectResourceUpload = 'subject.resource.upload';
  static const subjectResourceShare = 'subject.resource.share';

  static const subjectAssessmentCreate = 'subject.assessment.create';
  static const subjectMarksView = 'subject.marks.view';
  static const subjectMarksEnter = 'subject.marks.enter';
  static const subjectMarksEdit = 'subject.marks.edit';
  static const subjectMarksEditSubmitted = 'subject.marks.edit_submitted';
  static const subjectMarksSubmit = 'subject.marks.submit';
  static const subjectMarksImport = 'subject.marks.import';
  static const subjectMarksExport = 'subject.marks.export';

  static const subjectReportView = 'subject.report.view';
  static const subjectReportGenerate = 'subject.report.generate';
  static const subjectAnalyticsView = 'subject.analytics.view';

  static const subjectParentMessage = 'subject.parent.message';
  static const subjectStudentMessage = 'subject.student.message';
  static const subjectAnnouncementSend = 'subject.announcement.send';

  static const subjectTimetableView = 'subject.timetable.view';
  static const subjectTimetableEdit = 'subject.timetable.edit';

  // Class Teacher panel (enforced) - scoped exactly like the `subject.*` set
  // above, but against the class/stream the Class Teacher assignment names
  // rather than a subject. A teacher who is Class Teacher for P5 East and
  // Subject Teacher for P6 West holds both sets at once on one profile; the
  // scope on each assignment is what keeps the two from bleeding together.
  static const classStudentsView = 'class.students.view';
  static const classStudentProfileView = 'class.student.profile.view';
  static const classStudentHistoricalView = 'class.student.historical.view';
  static const classStudentNoteWrite = 'class.student.note.write';
  static const classStudentDocumentView = 'class.student.document.view';

  static const classAttendanceTake = 'class.attendance.take';
  static const classAttendanceEdit = 'class.attendance.edit';
  static const classAttendanceEditHistorical = 'class.attendance.edit_historical';
  static const classAttendanceView = 'class.attendance.view';

  static const classHomeworkCreate = 'class.homework.create';
  static const classHomeworkPublish = 'class.homework.publish';
  static const classHomeworkEdit = 'class.homework.edit';

  static const classBehaviourRecord = 'class.behaviour.record';
  static const classBehaviourView = 'class.behaviour.view';
  static const classAchievementRecord = 'class.achievement.record';

  static const classHealthAlertView = 'class.health_alert.view';
  static const classLeaveView = 'class.leave.view';

  static const classParentMessage = 'class.parent.message';
  static const classAnnouncementCreate = 'class.announcement.create';
  static const classAnnouncementPublish = 'class.announcement.publish';

  static const classPerformanceView = 'class.performance.view';
  static const classComparisonView = 'class.comparison.view';
  static const classInterventionNoteWrite = 'class.intervention_note.write';

  static const classReportEntry = 'class.report.entry';
  static const classReportCompetencyEntry = 'class.report.competency.entry';
  static const classReportConductEntry = 'class.report.conduct.entry';
  static const classReportCommentWrite = 'class.report.comment.write';
  static const classReportRecommendationWrite = 'class.report.recommendation.write';
  static const classReportSubmit = 'class.report.submit';
  static const classReportGenerate = 'class.report.generate';
  static const classReportShare = 'class.report.share';
  static const classReportExport = 'class.report.export';

  static const classTaskManage = 'class.task.manage';
  static const classTaskCollaborate = 'class.task.collaborate';

  static const classResourceUpload = 'class.resource.upload';
  static const classResourceShare = 'class.resource.share';
  static const classResourceDelete = 'class.resource.delete';

  static const classTimetableView = 'class.timetable.view';

  /// Lets an admin give one staff member a second concurrent Class Teacher
  /// assignment inside the same academic year and campus. Off unless the
  /// school grants it, and every use is reason-bearing and audited - see
  /// `ClassTeacherAssignmentService.validateAssignable`.
  static const classTeacherMultiAssignOverride = 'class.teacher.multi_assign.override';
}
