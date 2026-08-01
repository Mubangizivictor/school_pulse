import 'package:equatable/equatable.dart';

/// Why a student appears (or no longer appears) against a subject.
enum SubjectEnrollmentStatus {
  active,
  pendingApproval,
  pendingRemoval,
  removed,
  completed;

  static SubjectEnrollmentStatus fromId(String? id) {
    if (id == null) return SubjectEnrollmentStatus.active;
    for (final s in SubjectEnrollmentStatus.values) {
      if (s.name == id) return s;
    }
    return SubjectEnrollmentStatus.active;
  }
}

/// A student's membership of one subject, for one class/stream, in one
/// academic year.
///
/// This - not class membership - is what the Students tab lists. A teacher
/// assigned to Mathematics in Grade 10A sees the students holding an active
/// Mathematics enrollment in Grade 10A, never the whole school and never the
/// whole class if some of them take a different elective.
class SubjectEnrollment extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String studentId;
  final String subjectId;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final SubjectEnrollmentStatus status;

  /// The responsibility the enrollment was created under. Written so the
  /// security rules can check the writer actually held an assignment
  /// covering this subject and class, instead of trusting the request.
  final String roleAssignmentId;

  /// Mandatory subjects cannot be dropped by a teacher without an explicit
  /// admin approval, regardless of the teacher's own removal permission.
  final bool isMandatory;

  final DateTime enrolledAt;
  final String enrolledBy;
  final DateTime? removedAt;
  final String? removedBy;
  final String? removalReason;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;

  const SubjectEnrollment({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.studentId,
    required this.subjectId,
    required this.classId,
    this.streamId,
    required this.academicYearId,
    this.status = SubjectEnrollmentStatus.active,
    this.roleAssignmentId = '',
    this.isMandatory = false,
    required this.enrolledAt,
    this.enrolledBy = '',
    this.removedAt,
    this.removedBy,
    this.removalReason,
    this.effectiveFrom,
    this.effectiveTo,
  });

  bool get isActive => status == SubjectEnrollmentStatus.active;

  /// Whether the enrollment was in force on [date]. Used so a student removed
  /// mid-term still counts for assessments that closed before the removal
  /// took effect - historical marks are never rewritten by a later removal.
  bool wasActiveOn(DateTime date) {
    final from = effectiveFrom ?? enrolledAt;
    if (date.isBefore(from)) return false;
    final to = effectiveTo ?? removedAt;
    if (to != null && date.isAfter(to)) return false;
    return true;
  }

  SubjectEnrollment copyWith({
    String? id,
    SubjectEnrollmentStatus? status,
    String? roleAssignmentId,
    bool? isMandatory,
    DateTime? removedAt,
    String? removedBy,
    String? removalReason,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
  }) {
    return SubjectEnrollment(
      id: id ?? this.id,
      schoolId: schoolId,
      campusId: campusId,
      studentId: studentId,
      subjectId: subjectId,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      status: status ?? this.status,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      isMandatory: isMandatory ?? this.isMandatory,
      enrolledAt: enrolledAt,
      enrolledBy: enrolledBy,
      removedAt: removedAt ?? this.removedAt,
      removedBy: removedBy ?? this.removedBy,
      removalReason: removalReason ?? this.removalReason,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        campusId,
        studentId,
        subjectId,
        classId,
        streamId,
        academicYearId,
        status,
        roleAssignmentId,
        isMandatory,
        enrolledAt,
        enrolledBy,
        removedAt,
        removedBy,
        removalReason,
        effectiveFrom,
        effectiveTo,
      ];
}

/// A student as the Subject Teacher panel needs them: identity plus the
/// subject-scoped numbers, and deliberately nothing else. There is no field
/// here for fee balance, clinical history or discipline records, so those
/// cannot leak into this panel even by accident.
class SubjectStudentSummary extends Equatable {
  final String studentId;
  final String name;
  final String admissionNumber;
  final String? photoUrl;
  final String classId;
  final String className;
  final String? streamId;
  final String? streamName;
  final SubjectEnrollmentStatus enrollmentStatus;
  final bool isMandatory;

  /// Subject-scoped attendance across the lessons of this assignment.
  final int lessonsHeld;
  final int lessonsPresent;

  /// Subject-scoped marks position.
  final int assessmentsMarked;
  final int assessmentsTotal;
  final double? subjectAverage;
  final String? subjectGrade;

  const SubjectStudentSummary({
    required this.studentId,
    required this.name,
    this.admissionNumber = '',
    this.photoUrl,
    this.classId = '',
    this.className = '',
    this.streamId,
    this.streamName,
    this.enrollmentStatus = SubjectEnrollmentStatus.active,
    this.isMandatory = false,
    this.lessonsHeld = 0,
    this.lessonsPresent = 0,
    this.assessmentsMarked = 0,
    this.assessmentsTotal = 0,
    this.subjectAverage,
    this.subjectGrade,
  });

  double? get attendanceRate =>
      lessonsHeld == 0 ? null : (lessonsPresent / lessonsHeld) * 100;

  SubjectStudentSummary copyWith({
    SubjectEnrollmentStatus? enrollmentStatus,
    int? lessonsHeld,
    int? lessonsPresent,
    int? assessmentsMarked,
    int? assessmentsTotal,
    double? subjectAverage,
    String? subjectGrade,
  }) {
    return SubjectStudentSummary(
      studentId: studentId,
      name: name,
      admissionNumber: admissionNumber,
      photoUrl: photoUrl,
      classId: classId,
      className: className,
      streamId: streamId,
      streamName: streamName,
      enrollmentStatus: enrollmentStatus ?? this.enrollmentStatus,
      isMandatory: isMandatory,
      lessonsHeld: lessonsHeld ?? this.lessonsHeld,
      lessonsPresent: lessonsPresent ?? this.lessonsPresent,
      assessmentsMarked: assessmentsMarked ?? this.assessmentsMarked,
      assessmentsTotal: assessmentsTotal ?? this.assessmentsTotal,
      subjectAverage: subjectAverage ?? this.subjectAverage,
      subjectGrade: subjectGrade ?? this.subjectGrade,
    );
  }

  @override
  List<Object?> get props => [
        studentId,
        name,
        admissionNumber,
        photoUrl,
        classId,
        className,
        streamId,
        streamName,
        enrollmentStatus,
        isMandatory,
        lessonsHeld,
        lessonsPresent,
        assessmentsMarked,
        assessmentsTotal,
        subjectAverage,
        subjectGrade,
      ];
}

/// A student who could be added to the subject but is not enrolled yet.
class EligibleStudent extends Equatable {
  final String studentId;
  final String name;
  final String admissionNumber;
  final String? photoUrl;
  final String classId;
  final String className;
  final String? streamId;
  final String? streamName;

  const EligibleStudent({
    required this.studentId,
    required this.name,
    this.admissionNumber = '',
    this.photoUrl,
    this.classId = '',
    this.className = '',
    this.streamId,
    this.streamName,
  });

  @override
  List<Object?> get props => [
        studentId,
        name,
        admissionNumber,
        photoUrl,
        classId,
        className,
        streamId,
        streamName,
      ];
}
