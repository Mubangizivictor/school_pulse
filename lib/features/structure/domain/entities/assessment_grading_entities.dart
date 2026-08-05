import 'package:equatable/equatable.dart';

/// Structure's own assessment-type definition (CAT, Assignment, Coursework,
/// ...) with a weighting. Named AssessmentTypeDef (not AssessmentType) to
/// avoid colliding with Exams'/Academic's already-wired AssessmentType.
class AssessmentTypeDef extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final double weightPercentage;
  final String description;
  final bool isActive;

  const AssessmentTypeDef({
    required this.id,
    required this.schoolId,
    required this.name,
    this.weightPercentage = 0,
    this.description = '',
    this.isActive = true,
  });

  AssessmentTypeDef copyWith({
    String? id,
    String? schoolId,
    String? name,
    double? weightPercentage,
    String? description,
    bool? isActive,
  }) {
    return AssessmentTypeDef(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      weightPercentage: weightPercentage ?? this.weightPercentage,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    weightPercentage,
    description,
    isActive,
  ];
}

/// Structure's own grading system definition (A-F, 1-9, Percentage,
/// Competency Based, Custom, ...). Named GradingSystemDef to avoid
/// colliding with Exams'/Academic's already-wired GradingSystem.
class GradingSystemDef extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String type;
  final bool isDefault;
  final bool isActive;

  const GradingSystemDef({
    required this.id,
    required this.schoolId,
    required this.name,
    this.type = '',
    this.isDefault = false,
    this.isActive = true,
  });

  GradingSystemDef copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? type,
    bool? isDefault,
    bool? isActive,
  }) {
    return GradingSystemDef(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, type, isDefault, isActive];
}

/// A single grade band (e.g. "A": 80-100) within a GradingSystemDef.
class GradeBand extends Equatable {
  final String id;
  final String schoolId;
  final String gradingSystemId;
  final String grade;
  final double minScore;
  final double maxScore;
  final String remarks;
  final int order;

  const GradeBand({
    required this.id,
    required this.schoolId,
    required this.gradingSystemId,
    required this.grade,
    this.minScore = 0,
    this.maxScore = 0,
    this.remarks = '',
    this.order = 0,
  });

  GradeBand copyWith({
    String? id,
    String? schoolId,
    String? gradingSystemId,
    String? grade,
    double? minScore,
    double? maxScore,
    String? remarks,
    int? order,
  }) {
    return GradeBand(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      gradingSystemId: gradingSystemId ?? this.gradingSystemId,
      grade: grade ?? this.grade,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      remarks: remarks ?? this.remarks,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    gradingSystemId,
    grade,
    minScore,
    maxScore,
    remarks,
    order,
  ];
}
