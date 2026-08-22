import '../entities/student_enums.dart';

/// Keeps lifecycle changes explicit and auditable at the SIS boundary.
/// Terminal records cannot accidentally return to an active class roster.
class StudentLifecyclePolicy {
  const StudentLifecyclePolicy();

  bool canTransition(StudentStatus from, StudentStatus to) {
    if (from == to) return true;
    if (from == StudentStatus.graduated ||
        from == StudentStatus.alumni ||
        from == StudentStatus.deceased ||
        from == StudentStatus.archived) {
      return false;
    }
    return switch (from) {
      StudentStatus.applicant =>
        to == StudentStatus.pendingAdmission || to == StudentStatus.withdrawn,
      StudentStatus.pendingAdmission =>
        to == StudentStatus.admitted || to == StudentStatus.withdrawn,
      StudentStatus.admitted =>
        to == StudentStatus.enrollmentInProgress ||
            to == StudentStatus.active ||
            to == StudentStatus.withdrawn,
      StudentStatus.enrollmentInProgress =>
        to == StudentStatus.active ||
            to == StudentStatus.admitted ||
            to == StudentStatus.withdrawn,
      StudentStatus.active =>
        to == StudentStatus.suspended ||
            to == StudentStatus.transferredOut ||
            to == StudentStatus.withdrawn ||
            to == StudentStatus.graduated ||
            to == StudentStatus.onLeave,
      StudentStatus.suspended || StudentStatus.onLeave =>
        to == StudentStatus.active ||
            to == StudentStatus.withdrawn ||
            to == StudentStatus.transferredOut,
      StudentStatus.transferredIn =>
        to == StudentStatus.active || to == StudentStatus.withdrawn,
      StudentStatus.enrolled =>
        to == StudentStatus.active || to == StudentStatus.withdrawn,
      StudentStatus.deferred =>
        to == StudentStatus.active || to == StudentStatus.withdrawn,
      StudentStatus.completed =>
        to == StudentStatus.graduated || to == StudentStatus.alumni,
      StudentStatus.transferredOut ||
      StudentStatus.withdrawn ||
      StudentStatus.expelled => false,
      StudentStatus.graduated ||
      StudentStatus.alumni ||
      StudentStatus.deceased ||
      StudentStatus.archived => false,
    };
  }
}
