import 'package:equatable/equatable.dart';

/// A school-configurable assessment structure (CAT, Midterm, Final Exam,
/// Project, Coursework, etc). Never hardcoded - schools define their own
/// with their own weighting.
class AssessmentType extends Equatable {
  final String id;
  final String name;
  final String code;
  final double weight; // Percentage weight in final calculation
  final double maxMark;
  final double passingMark;
  final String academicTerm;
  final String academicYear;
  final String? subjectId; // Optional if generic for all subjects
  final String? classId; // Optional if generic for all classes
  final String status; // e.g., 'active', 'archived'

  const AssessmentType({
    required this.id,
    required this.name,
    required this.code,
    required this.weight,
    required this.maxMark,
    required this.passingMark,
    required this.academicTerm,
    required this.academicYear,
    this.subjectId,
    this.classId,
    this.status = 'active',
  });

  AssessmentType copyWith({
    String? name,
    String? code,
    double? weight,
    double? maxMark,
    double? passingMark,
    String? academicTerm,
    String? academicYear,
    String? subjectId,
    String? classId,
    String? status,
  }) {
    return AssessmentType(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      weight: weight ?? this.weight,
      maxMark: maxMark ?? this.maxMark,
      passingMark: passingMark ?? this.passingMark,
      academicTerm: academicTerm ?? this.academicTerm,
      academicYear: academicYear ?? this.academicYear,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    weight,
    maxMark,
    passingMark,
    academicTerm,
    academicYear,
    subjectId,
    classId,
    status,
  ];
}
