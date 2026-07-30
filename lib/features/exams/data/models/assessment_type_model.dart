import '../../domain/entities/assessment_type.dart';

class AssessmentTypeModel extends AssessmentType {
  const AssessmentTypeModel({
    required super.id,
    required super.name,
    required super.code,
    required super.weight,
    required super.maxMark,
    required super.passingMark,
    required super.academicTerm,
    required super.academicYear,
    super.subjectId,
    super.classId,
    super.status,
  });

  factory AssessmentTypeModel.fromMap(Map<String, dynamic> map, String id) {
    return AssessmentTypeModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      maxMark: (map['maxMark'] ?? 100).toDouble(),
      passingMark: (map['passingMark'] ?? 0).toDouble(),
      academicTerm: map['academicTerm'] ?? '',
      academicYear: map['academicYear'] ?? '',
      subjectId: map['subjectId'],
      classId: map['classId'],
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'weight': weight,
      'maxMark': maxMark,
      'passingMark': passingMark,
      'academicTerm': academicTerm,
      'academicYear': academicYear,
      'subjectId': subjectId,
      'classId': classId,
      'status': status,
    };
  }
}
