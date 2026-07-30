import 'package:equatable/equatable.dart';

/// Unlimited, school-configurable grading systems - percentage, letter
/// grades, competency-based (Uganda's lower secondary CBC), grade points,
/// or pass/fail. Never hardcoded.
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

  GradingSystem copyWith({
    String? name,
    GradingType? type,
    List<GradeRange>? ranges,
    bool? isDefault,
  }) {
    return GradingSystem(
      id: id,
      schoolId: schoolId,
      name: name ?? this.name,
      type: type ?? this.type,
      ranges: ranges ?? this.ranges,
      isDefault: isDefault ?? this.isDefault,
    );
  }

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
