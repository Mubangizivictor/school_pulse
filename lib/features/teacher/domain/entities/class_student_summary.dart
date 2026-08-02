import 'package:equatable/equatable.dart';

/// Where a student stands in the class register for the current academic year.
/// Sourced from the Student Information System - this panel reads it and
/// never writes it.
enum ClassStudentStatus {
  active,
  transferred,
  withdrawn,
  graduated,
  suspended;

  static ClassStudentStatus fromId(String? id) {
    if (id == null) return ClassStudentStatus.active;
    for (final s in ClassStudentStatus.values) {
      if (s.name == id) return s;
    }
    return ClassStudentStatus.active;
  }
}

/// Whether the student boards or goes home daily. Drives which class-teacher
/// follow-ups apply - a boarder's absence is a matron matter, a day student's
/// is a parent one.
enum ResidencyType {
  day,
  boarding,
  unknown;

  static ResidencyType fromId(String? id) {
    if (id == null) return ResidencyType.unknown;
    for (final r in ResidencyType.values) {
      if (r.name == id) return r;
    }
    return ResidencyType.unknown;
  }
}

/// One student as the Class Teacher panel sees them.
///
/// A deliberately narrow projection: name, placement, and the few flags a
/// class teacher acts on. Fee balances, clinical notes, admission paperwork
/// and discipline files are absent because this panel has no business reading
/// them - the modules that own them expose their own permission-checked
/// interfaces for the parts a class teacher may see.
class ClassStudentSummary extends Equatable {
  final String studentId;
  final String schoolId;
  final String name;
  final String admissionNumber;
  final String? photoUrl;
  final String classId;
  final String className;
  final String? streamId;
  final String? streamName;
  final String academicYearId;
  final ClassStudentStatus status;

  /// Present only where the school records it and the teacher's scope allows
  /// it, so the roster filter can offer it without inventing data.
  final String? gender;
  final ResidencyType residency;
  final String? houseId;
  final String? houseName;

  /// True when the Health module has a safety alert this teacher is cleared
  /// to see - an allergy, a medication time. Never the underlying record.
  final bool hasHealthAlert;

  const ClassStudentSummary({
    required this.studentId,
    required this.schoolId,
    required this.name,
    this.admissionNumber = '',
    this.photoUrl,
    required this.classId,
    this.className = '',
    this.streamId,
    this.streamName,
    required this.academicYearId,
    this.status = ClassStudentStatus.active,
    this.gender,
    this.residency = ResidencyType.unknown,
    this.houseId,
    this.houseName,
    this.hasHealthAlert = false,
  });

  bool get isActive => status == ClassStudentStatus.active;

  /// "P5 East" - the placement label the roster and profile headers show.
  String get placementLabel =>
      [className, streamName].where((e) => e != null && e.isNotEmpty).join(' ');

  /// Two-letter fallback for students with no photo, matching the avatar the
  /// approved roster row draws.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Whether this student matches a free-text roster search. Name, admission
  /// number and student id are all searchable because a teacher chasing an
  /// absentee has whichever one the parent quoted.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        admissionNumber.toLowerCase().contains(q) ||
        studentId.toLowerCase().contains(q);
  }

  @override
  List<Object?> get props => [
        studentId,
        schoolId,
        name,
        admissionNumber,
        photoUrl,
        classId,
        className,
        streamId,
        streamName,
        academicYearId,
        status,
        gender,
        residency,
        houseId,
        houseName,
        hasHealthAlert,
      ];
}
