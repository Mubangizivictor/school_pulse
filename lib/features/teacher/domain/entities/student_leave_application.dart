import 'package:equatable/equatable.dart';

/// How far a leave application has travelled through the boarding queue.
///
/// These mirror the `status` strings the Patron/Matron module already writes
/// to `boarding_leave_requests`; the class teacher only ever reads them.
enum StudentLeaveStatus {
  pending,
  approved,
  rejected,
  out,
  returned;

  static StudentLeaveStatus fromRaw(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'approved':
        return StudentLeaveStatus.approved;
      case 'rejected':
      case 'declined':
        return StudentLeaveStatus.rejected;
      case 'out':
        return StudentLeaveStatus.out;
      case 'returned':
        return StudentLeaveStatus.returned;
      default:
        return StudentLeaveStatus.pending;
    }
  }

  String get label => switch (this) {
    StudentLeaveStatus.pending => 'Pending',
    StudentLeaveStatus.approved => 'Approved',
    StudentLeaveStatus.rejected => 'Rejected',
    StudentLeaveStatus.out => 'Out',
    StudentLeaveStatus.returned => 'Returned',
  };
}

/// One leave application for a student, as the Class Teacher may see it.
///
/// This is a read projection over the boarding leave queue that the
/// Patron/Matron already owns - the class teacher can raise an application
/// (via `submitClassTeacherLeaveApplication`) and follow its progress, but
/// approval stays with the boarding staff who hold that permission.
class StudentLeaveApplication extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String reason;
  final String? destination;
  final DateTime departureDate;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final StudentLeaveStatus status;
  final String? approvedByName;

  /// Whether this application was raised from the Class Teacher panel, as
  /// opposed to by the patron or a parent - shown so a teacher can tell their
  /// own request apart from one already in the queue.
  final bool raisedByClassTeacher;
  final String? requestedByName;
  final DateTime? createdAt;

  const StudentLeaveApplication({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.reason,
    required this.departureDate,
    required this.expectedReturnDate,
    required this.status,
    this.destination,
    this.actualReturnDate,
    this.approvedByName,
    this.raisedByClassTeacher = false,
    this.requestedByName,
    this.createdAt,
  });

  /// Still away past the date they were due back. Mirrors the boarding
  /// module's own overdue rule so both panels agree on what "late" means.
  bool get isOverdue =>
      status == StudentLeaveStatus.out &&
      DateTime.now().isAfter(expectedReturnDate);

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    reason,
    destination,
    departureDate,
    expectedReturnDate,
    actualReturnDate,
    status,
    approvedByName,
    raisedByClassTeacher,
    requestedByName,
    createdAt,
  ];
}
