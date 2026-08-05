import 'package:equatable/equatable.dart';

enum GradingType {
  percentage,
  letterGrade,
  competencyBased,
  gradePoints,
  passFail,
}

class GradingSystem extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final GradingType type;
  final List<GradeRange> ranges;
  final bool isDefault;

  const GradingSystem({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.type,
    required this.ranges,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, schoolId, name, type, ranges, isDefault];
}

class GradeRange extends Equatable {
  final String grade; // e.g., 'A', 'D1', 'Distinction'
  final double minScore;
  final double maxScore;
  final String remarks;
  final double? gradePoint;
  final String? performanceLevel; // For competency-based

  const GradeRange({
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.remarks,
    this.gradePoint,
    this.performanceLevel,
  });

  @override
  List<Object?> get props => [
    grade,
    minScore,
    maxScore,
    remarks,
    gradePoint,
    performanceLevel,
  ];
}
