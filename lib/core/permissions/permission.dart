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

  // School Admin Support + central operational history.
  static const supportView = 'support.view';
  static const supportCreate = 'support.create';
  static const supportReply = 'support.reply';
  static const supportClose = 'support.close';
  static const supportReopen = 'support.reopen';
  static const supportEscalate = 'support.escalate';
  static const supportApproveAccess = 'support.approve_access';
  static const supportRevokeAccess = 'support.revoke_access';
  static const auditView = 'audit.view';
  static const auditViewSecurity = 'audit.view_security';
  static const auditViewSensitive = 'audit.view_sensitive';
  static const auditSearch = 'audit.search';
  static const auditExport = 'audit.export';
  static const auditViewSupportAccess = 'audit.view_support_access';

  // Module Control Center + Institution Policy Engine.
  static const modulesView = 'modules.view';
  static const modulesEnable = 'modules.enable';
  static const modulesDisable = 'modules.disable';
  static const modulesConfigure = 'modules.configure';
  static const policiesView = 'policies.view';
  static const policiesCreate = 'policies.create';
  static const policiesEdit = 'policies.edit';
  static const policiesActivate = 'policies.activate';
  static const policiesArchive = 'policies.archive';
  static const policiesRollback = 'policies.rollback';
  static const policiesSchedule = 'policies.schedule';

  // Institution Health Center. These intentionally govern the read model and
  // human resolution workflow only; source-module records remain protected by
  // their own permissions.
  static const institutionHealthView = 'institution_health.view';
  static const institutionHealthViewSecurity =
      'institution_health.view_security';
  static const institutionHealthViewDataQuality =
      'institution_health.view_data_quality';
  static const institutionHealthViewSubscription =
      'institution_health.view_subscription';
  static const institutionHealthAcknowledge = 'institution_health.acknowledge';
  static const institutionHealthIgnore = 'institution_health.ignore';
  static const institutionHealthRecheck = 'institution_health.recheck';
  static const institutionHealthExport = 'institution_health.export';

  // Subscription Centre. These grant visibility and request authority only;
  // SaaS Owner plan, entitlement and payment-state authority remains server
  // side and is never represented as an institution permission.
  static const subscriptionView = 'subscription.view';
  static const subscriptionViewUsage = 'subscription.view_usage';
  static const subscriptionViewInvoices = 'subscription.view_invoices';
  static const subscriptionDownloadInvoice = 'subscription.download_invoice';
  static const subscriptionDownloadReceipt = 'subscription.download_receipt';
  static const subscriptionRequestUpgrade = 'subscription.request_upgrade';
  static const subscriptionRequestAddon = 'subscription.request_addon';
  static const subscriptionInitiateRenewal = 'subscription.initiate_renewal';
  static const subscriptionViewHistory = 'subscription.view_history';

  // Data Management Center.  These are intentionally independent from the
  // source-module permissions: being able to view students never implies the
  // authority to move a student spreadsheet in or out of the institution.
  static const dataImport = 'data.import';
  static const dataImportStudents = 'data.import_students';
  static const dataImportStaff = 'data.import_staff';
  static const dataImportParents = 'data.import_parents';
  static const dataImportStructure = 'data.import_structure';
  static const dataBulkUpdate = 'data.bulk_update';
  static const dataArchive = 'data.archive';
  static const dataRestoreArchive = 'data.restore_archive';
  static const dataViewQuality = 'data.view_quality';
  static const dataRunQuality = 'data.run_quality';
  static const dataRunMigration = 'data.run_migration';
  static const dataExport = 'data.export';
  static const dataExportSensitive = 'data.export_sensitive';
  static const dataRequestRestore = 'data.request_restore';
  static const dataViewBackupStatus = 'data.view_backup_status';

  // Communication Center. Orchestrates announcements/broadcasts over the
  // existing notification delivery engine; it never grants messaging or
  // push-sending authority on its own — see communication_campaigns.js.
  static const communicationsView = 'communications.view';
  static const communicationsCreate = 'communications.create';
  static const communicationsEditDraft = 'communications.edit_draft';
  static const communicationsSchedule = 'communications.schedule';
  static const communicationsPublish = 'communications.publish';
  static const communicationsCancel = 'communications.cancel';
  static const communicationsArchive = 'communications.archive';
  static const communicationsSendStaff = 'communications.send_staff';
  static const communicationsSendParents = 'communications.send_parents';
  static const communicationsSendStudents = 'communications.send_students';
  static const communicationsSendEmergency = 'communications.send_emergency';
  static const communicationsViewDelivery = 'communications.view_delivery';
  static const communicationsViewAudit = 'communications.view_audit';
  static const communicationsManageTemplates =
      'communications.manage_templates';

  // Central reporting. Kept separate from source-module permissions: viewing
  // a finance screen, for example, must never implicitly permit exporting it.
  static const reportsView = 'reports.view';
  static const reportsExport = 'reports.export';
  static const reportsPrint = 'reports.print';
  static const reportsSchedule = 'reports.schedule';
  static const reportsShare = 'reports.share';
  static const reportsViewSensitive = 'reports.view_sensitive';

  // Appointments & schedule
  static const appointmentsView = 'appointments.view';
  static const appointmentsManage = 'appointments.manage';
  static const appointmentsApprove = 'appointments.approve';

  // Attendance
  static const attendanceClassScan = 'attendance.class.scan';
  static const attendanceSubjectScan = 'attendance.subject.scan';
  static const attendanceStaffScan = 'attendance.staff.scan';
  static const attendanceStaffExport = 'attendance.staff.export';
  static const attendanceStaffCorrect = 'attendance.staff.correct';
  static const attendanceBoardingScan = 'attendance.boarding.scan';
  static const attendanceGateScan = 'attendance.gate.scan';
  static const attendanceMealsScan = 'attendance.meals.scan';
  static const attendanceLibraryScan = 'attendance.library.scan';
  static const attendanceTransportScan = 'attendance.transport.scan';
  static const attendanceVisitorsScan = 'attendance.visitors.scan';
  static const attendanceCustomScan = 'attendance.custom.scan';
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

  // School Admin Security Center. These are deliberately separate from the
  // gate-operation permissions above: viewing a gate log must never imply
  // authority to inspect or terminate another person's authenticated session.
  static const securityView = 'security.view';
  static const securityViewSessions = 'security.view_sessions';
  static const securityRevokeSession = 'security.revoke_session';
  static const securityRevokeAllSessions = 'security.revoke_all_sessions';
  static const securityViewDevices = 'security.view_devices';
  static const securityManageDeviceTrust = 'security.manage_device_trust';
  static const securityViewFailedLogins = 'security.view_failed_logins';
  static const securityLockAccount = 'security.lock_account';
  static const securityUnlockAccount = 'security.unlock_account';
  static const securityForcePasswordReset = 'security.force_password_reset';
  static const securityViewEvents = 'security.view_security_events';
  static const securityResolveAlerts = 'security.resolve_alerts';
  static const securityExport = 'security.export';
  static const securityManagePolicy = 'security.manage_policy';

  // NFC/QR credential lifecycle administration - deliberately separate from
  // securityIdentityVerify (which only lets a gate/attendance operator USE
  // an already-issued credential to identify someone) and from
  // attendance.*.scan (marking attendance with a credential). This gates
  // register/assign/replace/revoke/reactivate - i.e. deciding which
  // physical card identifies which student/staff member - so an ordinary
  // Class Teacher who can scan attendance must not implicitly be able to
  // reassign or revoke anyone's card.
  static const identityCredentialManage = 'identity.credential.manage';

  // Admissions / enrollment (enforced) - gates AdmissionBloc's
  // EnrollStudentRequested handler, per the product requirement that
  // enrollment is permission-based, never a hardcoded job-title check.
  static const admissionApplicationCreate = 'admission.application.create';
  static const admissionApplicationReview = 'admission.application.review';
  static const admissionEnroll = 'admission.enroll';

  // Enrollment Setup Wizard (post-approval placement/finance/boarding/
  // clubs/parent-link/identity confirmation before a student goes active).
  // Deliberately split from admissionEnroll: that permission gates
  // triggering the underlying AdmissionService.enrollStudent status
  // transition, while these gate each wizard step's own side-effecting
  // write so a role can be trusted with e.g. academic placement without
  // also being trusted to grant bursaries or link parents.
  static const enrollmentManage = 'enrollment.manage';
  static const enrollmentAcademicAssign = 'enrollment.academic_assign';
  static const enrollmentFinanceSetup = 'enrollment.finance_setup';
  static const enrollmentBursaryAssign = 'enrollment.bursary_assign';
  static const enrollmentBoardingAssign = 'enrollment.boarding_assign';
  static const enrollmentParentLink = 'enrollment.parent_link';
  static const enrollmentIdentityManage = 'enrollment.identity_manage';
  static const enrollmentCardGenerate = 'enrollment.card_generate';
  static const enrollmentActivate = 'enrollment.activate';

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
  static const notificationViewDeliveryReports =
      'notification.view_delivery_reports';
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
  static const subjectAttendanceEditHistorical =
      'subject.attendance.edit_historical';

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
  static const classAttendanceEditHistorical =
      'class.attendance.edit_historical';
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
  static const classReportRecommendationWrite =
      'class.report.recommendation.write';
  static const classReportSubmit = 'class.report.submit';
  static const classReportGenerate = 'class.report.generate';
  static const classReportShare = 'class.report.share';
  static const classReportExport = 'class.report.export';

  /// Dean-of-Studies-stage report-card review: return with a reason, or
  /// sign and forward to the Headteacher. Distinct from [classReportSubmit]
  /// - a Class Teacher submits their own class's reports, a Dean acts on
  /// any report reaching their queue.
  static const classReportApproveDean = 'class.report.approve.dean';

  /// Headteacher-stage report-card review: return with a reason, or sign to
  /// academically finalize. The terminal academic decision - never confused
  /// with financial release, which is the Bursar's separate concern.
  static const classReportApproveHeadteacher =
      'class.report.approve.headteacher';

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
  static const classTeacherMultiAssignOverride =
      'class.teacher.multi_assign.override';

  // School Calendar - governs create/edit/archive/restore/delete of academic
  // years, terms, holidays, calendar events and calendar settings. Granted
  // to School Administrator by default; any other role only gains it via an
  // explicit per-school `role_permission_overrides` grant. Every other role
  // has read-only calendar access without this permission.
  static const calendarManage = 'calendar.manage';
  static const calendarView = 'calendar.view';
  static const calendarCreate = 'calendar.create';
  static const calendarEdit = 'calendar.edit';
  static const calendarPublish = 'calendar.publish';
  static const calendarCancel = 'calendar.cancel';
  static const calendarArchive = 'calendar.archive';
  static const calendarManageHolidays = 'calendar.manage_holidays';
  static const calendarManageExamWindows = 'calendar.manage_exam_windows';
  static const calendarManageDeadlines = 'calendar.manage_deadlines';
  static const calendarExport = 'calendar.export';
  static const academicYearView = 'academic_year.view';
  static const academicYearCreate = 'academic_year.create';
  static const academicYearEdit = 'academic_year.edit';
  static const academicYearActivate = 'academic_year.activate';
  static const academicYearClose = 'academic_year.close';
  static const academicYearReopen = 'academic_year.reopen';
  static const academicPeriodView = 'academic_period.view';
  static const academicPeriodCreate = 'academic_period.create';
  static const academicPeriodEdit = 'academic_period.edit';
  static const academicPeriodActivate = 'academic_period.activate';
  static const academicPeriodClose = 'academic_period.close';
  static const academicPeriodReopen = 'academic_period.reopen';

  // Announcements - governs create/edit/publish/delete of school-wide
  // announcements. Granted to School Administrator, Head Teacher and
  // Director by default; any other role only gains it via an explicit
  // per-school `role_permission_overrides` grant. Every other role has
  // read-only access to published announcements without this permission.
  static const announcementManage = 'announcement.manage';

  // Structure - governs the school's structural configuration (levels,
  // classes/streams, subjects, departments, years/terms, grading systems,
  // and other Academics/Operations setup screens under Structure). IDs are
  // pre-declared here following this catalog's established pattern, but are
  // not yet enforced anywhere - Structure today is gated only by the
  // coarse Firestore `isStaff()` rule, matching every one of its sibling
  // sub-entities. A future pass should wire real StructureBloc-level
  // enforcement (await PermissionEvaluator.can(...) folded into bloc state,
  // as done in class_reports_bloc.dart/class_announcements_bloc.dart)
  // consistently across all of Structure at once, not just grading.
  static const structureGradingView = 'structure.grading.view';
  static const structureGradingManage = 'structure.grading.manage';

  // Integrations Center. Governs School Admin-only visibility and control of
  // third-party connections (Sheets/Calendar/Email/SMS/Push/Payments/
  // Devices/Printers/Domains/Webhooks). Credentials themselves never cross
  // these permissions - only safe metadata and connection lifecycle actions.
  static const integrationsView = 'integrations.view';
  static const integrationsConfigure = 'integrations.configure';
  static const integrationsConnect = 'integrations.connect';
  static const integrationsDisconnect = 'integrations.disconnect';
  static const integrationsTest = 'integrations.test';
  static const integrationsSync = 'integrations.sync';
  static const integrationsViewLogs = 'integrations.view_logs';
  static const integrationsManagePayments = 'integrations.manage_payments';
  static const integrationsManageCommunication =
      'integrations.manage_communication';
  static const integrationsManageDevices = 'integrations.manage_devices';
  static const integrationsManageDomains = 'integrations.manage_domains';
  static const integrationsManageWebhooks = 'integrations.manage_webhooks';
  static const integrationsManagePrinters = 'integrations.manage_printers';
  static const integrationsViewSensitiveMetadata =
      'integrations.view_sensitive_metadata';

  // Central Approval Center. Mirrors the module-agnostic workflow engine at
  // schools/{id}/approval_requests - source modules keep their own
  // permissions for the underlying record; these only gate the workflow.
  static const approvalsView = 'approvals.view';
  static const approvalsSubmit = 'approvals.submit';
  static const approvalsApprove = 'approvals.approve';
  static const approvalsReject = 'approvals.reject';
  static const approvalsReturn = 'approvals.return';
  static const approvalsDelegate = 'approvals.delegate';
  static const approvalsEscalate = 'approvals.escalate';
  static const approvalsBulk = 'approvals.bulk';
  static const approvalsViewSensitive = 'approvals.view_sensitive';
  static const approvalsManagePolicies = 'approvals.manage_policies';
  static const approvalsViewAudit = 'approvals.view_audit';

  /// Every permission ID declared above, grouped by category for UI
  /// consumers (e.g. the role-permission-override editor) that need to
  /// present the full catalog without hand-copying it - Dart has no
  /// reflection, so this list must be kept in sync manually alongside new
  /// constants. Each entry is `(category, permissionId)`.
  static const List<(String category, String id)> all = [
    ('Attendance', attendanceClassScan),
    ('Attendance', attendanceSubjectScan),
    ('Attendance', attendanceStaffScan),
    ('Attendance', attendanceStaffExport),
    ('Attendance', attendanceStaffCorrect),
    ('Attendance', attendanceBoardingScan),
    ('Attendance', attendanceGateScan),
    ('Attendance', attendanceMealsScan),
    ('Attendance', attendanceLibraryScan),
    ('Attendance', attendanceTransportScan),
    ('Attendance', attendanceVisitorsScan),
    ('Attendance', attendanceCustomScan),
    ('Attendance', attendanceOverride),

    ('Health', healthStudentVerify),
    ('Health', healthStudentBasicRead),
    ('Health', healthStudentClinicalRead),
    ('Health', healthStudentVisitCreate),
    ('Health', healthStudentEmergencyRead),

    ('Meals / Catering', mealsVerify),
    ('Meals / Catering', mealsServe),
    ('Meals / Catering', mealsOverride),
    ('Meals / Catering', mealsAuditRead),

    ('Transport', transportBoardingVerify),
    ('Transport', transportBoardingRecord),
    ('Transport', transportDropoffRecord),
    ('Transport', transportOverride),

    ('Library', libraryMemberVerify),
    ('Library', libraryBorrow),
    ('Library', libraryReturn),

    ('Finance', financeStudentVerify),
    ('Finance', financeStudentBalanceRead),

    ('Boarding', boardingRollcallScan),
    ('Boarding', boardingStudentVerify),
    ('Boarding', boardingOverride),

    ('Examinations', examEligibilityVerify),
    ('Examinations', examAttendanceScan),
    ('Examinations', examOverride),

    ('Security', securityIdentityVerify),
    ('Security', securityEntryRecord),
    ('Security', securityExitRecord),
    ('Security', securityOverride),

    ('Admissions', admissionApplicationCreate),
    ('Admissions', admissionApplicationReview),
    ('Admissions', admissionEnroll),

    ('Enrollment Setup Wizard', enrollmentManage),
    ('Enrollment Setup Wizard', enrollmentAcademicAssign),
    ('Enrollment Setup Wizard', enrollmentFinanceSetup),
    ('Enrollment Setup Wizard', enrollmentBursaryAssign),
    ('Enrollment Setup Wizard', enrollmentBoardingAssign),
    ('Enrollment Setup Wizard', enrollmentParentLink),
    ('Enrollment Setup Wizard', enrollmentIdentityManage),
    ('Enrollment Setup Wizard', enrollmentCardGenerate),
    ('Enrollment Setup Wizard', enrollmentActivate),

    ('Student Data', studentBasicRead),
    ('Student Data', studentFullRead),

    ('Verification', verificationOverride),
    ('Verification', verificationAuditRead),
    ('Verification', verificationDeviceManage),
    ('Verification', identityCredentialManage),

    ('Notifications', notificationView),
    ('Notifications', notificationSend),
    ('Notifications', notificationSendToParent),
    ('Notifications', notificationSendToStudent),
    ('Notifications', notificationSendToStaff),
    ('Notifications', notificationBroadcast),
    ('Notifications', notificationSchedule),
    ('Notifications', notificationCancel),
    ('Notifications', notificationUseImages),
    ('Notifications', notificationUseAttachments),
    ('Notifications', notificationSendEmergency),
    ('Notifications', notificationViewDeliveryReports),
    ('Notifications', notificationManageTemplates),
    ('Notifications', notificationManageSettings),
    ('Notifications', notificationAcknowledge),
    ('Notifications', notificationArchive),
    ('Notifications', notificationDelete),
    ('Notifications', notificationSeedTestData),
    ('Notifications', notificationRunDeliveryTest),

    ('Subject Teacher Panel', subjectStudentsView),
    ('Subject Teacher Panel', subjectStudentEnroll),
    ('Subject Teacher Panel', subjectStudentRemove),
    ('Subject Teacher Panel', subjectStudentHistoricalView),
    ('Subject Teacher Panel', subjectLessonView),
    ('Subject Teacher Panel', subjectLessonStart),
    ('Subject Teacher Panel', subjectLessonComplete),
    ('Subject Teacher Panel', subjectLessonCancel),
    ('Subject Teacher Panel', subjectLessonReschedule),
    ('Subject Teacher Panel', subjectAttendanceTake),
    ('Subject Teacher Panel', subjectAttendanceEdit),
    ('Subject Teacher Panel', subjectAttendanceEditHistorical),
    ('Subject Teacher Panel', subjectLessonNoteCreate),
    ('Subject Teacher Panel', subjectLessonNoteEdit),
    ('Subject Teacher Panel', subjectResourceUpload),
    ('Subject Teacher Panel', subjectResourceShare),
    ('Subject Teacher Panel', subjectAssessmentCreate),
    ('Subject Teacher Panel', subjectMarksView),
    ('Subject Teacher Panel', subjectMarksEnter),
    ('Subject Teacher Panel', subjectMarksEdit),
    ('Subject Teacher Panel', subjectMarksEditSubmitted),
    ('Subject Teacher Panel', subjectMarksSubmit),
    ('Subject Teacher Panel', subjectMarksImport),
    ('Subject Teacher Panel', subjectMarksExport),
    ('Subject Teacher Panel', subjectReportView),
    ('Subject Teacher Panel', subjectReportGenerate),
    ('Subject Teacher Panel', subjectAnalyticsView),
    ('Subject Teacher Panel', subjectParentMessage),
    ('Subject Teacher Panel', subjectStudentMessage),
    ('Subject Teacher Panel', subjectAnnouncementSend),
    ('Subject Teacher Panel', subjectTimetableView),
    ('Subject Teacher Panel', subjectTimetableEdit),

    ('Class Teacher Panel', classStudentsView),
    ('Class Teacher Panel', classStudentProfileView),
    ('Class Teacher Panel', classStudentHistoricalView),
    ('Class Teacher Panel', classStudentNoteWrite),
    ('Class Teacher Panel', classStudentDocumentView),
    ('Class Teacher Panel', classAttendanceTake),
    ('Class Teacher Panel', classAttendanceEdit),
    ('Class Teacher Panel', classAttendanceEditHistorical),
    ('Class Teacher Panel', classAttendanceView),
    ('Class Teacher Panel', classHomeworkCreate),
    ('Class Teacher Panel', classHomeworkPublish),
    ('Class Teacher Panel', classHomeworkEdit),
    ('Class Teacher Panel', classBehaviourRecord),
    ('Class Teacher Panel', classBehaviourView),
    ('Class Teacher Panel', classAchievementRecord),
    ('Class Teacher Panel', classHealthAlertView),
    ('Class Teacher Panel', classLeaveView),
    ('Class Teacher Panel', classParentMessage),
    ('Class Teacher Panel', classAnnouncementCreate),
    ('Class Teacher Panel', classAnnouncementPublish),
    ('Class Teacher Panel', classPerformanceView),
    ('Class Teacher Panel', classComparisonView),
    ('Class Teacher Panel', classInterventionNoteWrite),
    ('Class Teacher Panel', classReportEntry),
    ('Class Teacher Panel', classReportCompetencyEntry),
    ('Class Teacher Panel', classReportConductEntry),
    ('Class Teacher Panel', classReportCommentWrite),
    ('Class Teacher Panel', classReportRecommendationWrite),
    ('Class Teacher Panel', classReportSubmit),
    ('Class Teacher Panel', classReportGenerate),
    ('Class Teacher Panel', classReportShare),
    ('Class Teacher Panel', classReportExport),
    ('Class Teacher Panel', classTaskManage),
    ('Class Teacher Panel', classTaskCollaborate),
    ('Class Teacher Panel', classResourceUpload),
    ('Class Teacher Panel', classResourceShare),
    ('Class Teacher Panel', classResourceDelete),
    ('Class Teacher Panel', classTimetableView),
    ('Class Teacher Panel', classTeacherMultiAssignOverride),
    // A Class Teacher may be granted marks entry for their own class across
    // every subject, not only one they personally teach as a Subject
    // Teacher - the same permission strings the Subject Teacher Panel uses,
    // scoped by this assignment's classId rather than a subjectId.
    ('Class Teacher Panel', subjectAssessmentCreate),
    ('Class Teacher Panel', subjectMarksView),
    ('Class Teacher Panel', subjectMarksEnter),
    ('Class Teacher Panel', subjectMarksEdit),
    ('Class Teacher Panel', subjectMarksSubmit),

    ('School Calendar', calendarManage),
    ('Announcements', announcementManage),

    ('Structure', structureGradingView),
    ('Structure', structureGradingManage),

    ('Integrations Center', integrationsView),
    ('Integrations Center', integrationsConfigure),
    ('Integrations Center', integrationsConnect),
    ('Integrations Center', integrationsDisconnect),
    ('Integrations Center', integrationsTest),
    ('Integrations Center', integrationsSync),
    ('Integrations Center', integrationsViewLogs),
    ('Integrations Center', integrationsManagePayments),
    ('Integrations Center', integrationsManageCommunication),
    ('Integrations Center', integrationsManageDevices),
    ('Integrations Center', integrationsManageDomains),
    ('Integrations Center', integrationsManageWebhooks),
    ('Integrations Center', integrationsManagePrinters),
    ('Integrations Center', integrationsViewSensitiveMetadata),

    ('Central Approval Center', approvalsView),
    ('Central Approval Center', approvalsSubmit),
    ('Central Approval Center', approvalsApprove),
    ('Central Approval Center', approvalsReject),
    ('Central Approval Center', approvalsReturn),
    ('Central Approval Center', approvalsDelegate),
    ('Central Approval Center', approvalsEscalate),
    ('Central Approval Center', approvalsBulk),
    ('Central Approval Center', approvalsViewSensitive),
    ('Central Approval Center', approvalsManagePolicies),
    ('Central Approval Center', approvalsViewAudit),
  ];
}
