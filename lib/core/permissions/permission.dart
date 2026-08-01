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
}
