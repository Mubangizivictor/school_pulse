import 'package:equatable/equatable.dart';
import 'relationship_enums.dart';

/// A historical placement record. Student.classId/streamId/academicYearId
/// remain the "current" denormalized pointer every existing module already
/// queries directly - this collection exists purely to stop those changes
/// from being overwritten with no history, by recording a snapshot each
/// time placement actually changes.
class StudentEnrolment extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final EnrolmentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? reason;
  final String recordedBy;
  final DateTime createdAt;

  const StudentEnrolment({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.classId,
    this.streamId,
    required this.academicYearId,
    this.status = EnrolmentStatus.active,
    required this.startDate,
    this.endDate,
    this.reason,
    required this.recordedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        studentId,
        classId,
        streamId,
        academicYearId,
        status,
        startDate,
        endDate,
        reason,
        recordedBy,
        createdAt,
      ];
}
