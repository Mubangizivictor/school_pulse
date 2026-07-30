import '../../domain/entities/grading_system.dart';

class GradingSystemModel extends GradingSystem {
  const GradingSystemModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.type,
    required super.ranges,
    super.isDefault,
  });

  factory GradingSystemModel.fromMap(Map<String, dynamic> map, String id) {
    return GradingSystemModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      type: GradingType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => GradingType.percentage,
      ),
      ranges: (map['ranges'] as List? ?? [])
          .map((r) => GradeRangeModel.fromMap(r as Map<String, dynamic>))
          .toList(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'type': type.toString().split('.').last,
      'ranges': ranges.map((r) => (r as GradeRangeModel).toMap()).toList(),
      'isDefault': isDefault,
    };
  }
}

class GradeRangeModel extends GradeRange {
  const GradeRangeModel({
    required super.grade,
    required super.minScore,
    required super.maxScore,
    required super.remarks,
    super.gradePoint,
    super.performanceLevel,
  });

  factory GradeRangeModel.fromMap(Map<String, dynamic> map) {
    return GradeRangeModel(
      grade: map['grade'] ?? '',
      minScore: (map['minScore'] ?? 0).toDouble(),
      maxScore: (map['maxScore'] ?? 0).toDouble(),
      remarks: map['remarks'] ?? '',
      gradePoint: (map['gradePoint'])?.toDouble(),
      performanceLevel: map['performanceLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'minScore': minScore,
      'maxScore': maxScore,
      'remarks': remarks,
      'gradePoint': gradePoint,
      'performanceLevel': performanceLevel,
    };
  }
}
