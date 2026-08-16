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
  final String description;
  final String scaleType;
  final String gradeFormat;
  final int decimalPlaces;
  final double? passingScore;
  final String? passingGradeCode;
  final bool allowIncomplete;
  final String appliesTo; // school, levels, classes
  final List<String> levelIds;
  final List<String> classIds;
  final List<String> academicYearIds;
  final int version;

  const GradingSystemDef({
    required this.id,
    required this.schoolId,
    required this.name,
    this.type = '',
    this.isDefault = false,
    this.isActive = true,
    this.description = '',
    this.scaleType = 'Range Based',
    this.gradeFormat = 'Letter',
    this.decimalPlaces = 2,
    this.passingScore,
    this.passingGradeCode,
    this.allowIncomplete = false,
    this.appliesTo = 'school',
    this.levelIds = const [],
    this.classIds = const [],
    this.academicYearIds = const [],
    this.version = 1,
  });

  GradingSystemDef copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? type,
    bool? isDefault,
    bool? isActive,
    String? description,
    String? scaleType,
    String? gradeFormat,
    int? decimalPlaces,
    double? passingScore,
    String? passingGradeCode,
    bool? allowIncomplete,
    String? appliesTo,
    List<String>? levelIds,
    List<String>? classIds,
    List<String>? academicYearIds,
    int? version,
  }) {
    return GradingSystemDef(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      scaleType: scaleType ?? this.scaleType,
      gradeFormat: gradeFormat ?? this.gradeFormat,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      passingScore: passingScore ?? this.passingScore,
      passingGradeCode: passingGradeCode ?? this.passingGradeCode,
      allowIncomplete: allowIncomplete ?? this.allowIncomplete,
      appliesTo: appliesTo ?? this.appliesTo,
      levelIds: levelIds ?? this.levelIds,
      classIds: classIds ?? this.classIds,
      academicYearIds: academicYearIds ?? this.academicYearIds,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    type,
    isDefault,
    isActive,
    description,
    scaleType,
    gradeFormat,
    decimalPlaces,
    passingScore,
    passingGradeCode,
    allowIncomplete,
    appliesTo,
    levelIds,
    classIds,
    academicYearIds,
    version,
  ];
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
  final String label;
  final double? gradePoint;
  final bool isPassing;
  final String colorHex;
  final bool hasNumericBoundary;

  const GradeBand({
    required this.id,
    required this.schoolId,
    required this.gradingSystemId,
    required this.grade,
    this.minScore = 0,
    this.maxScore = 0,
    this.remarks = '',
    this.order = 0,
    this.label = '',
    this.gradePoint,
    this.isPassing = true,
    this.colorHex = '',
    this.hasNumericBoundary = true,
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
    String? label,
    double? gradePoint,
    bool? isPassing,
    String? colorHex,
    bool? hasNumericBoundary,
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
      label: label ?? this.label,
      gradePoint: gradePoint ?? this.gradePoint,
      isPassing: isPassing ?? this.isPassing,
      colorHex: colorHex ?? this.colorHex,
      hasNumericBoundary: hasNumericBoundary ?? this.hasNumericBoundary,
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
    label,
    gradePoint,
    isPassing,
    colorHex,
    hasNumericBoundary,
  ];
}
