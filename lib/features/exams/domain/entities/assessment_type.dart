import 'package:equatable/equatable.dart';

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
