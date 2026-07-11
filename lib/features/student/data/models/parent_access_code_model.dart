import '../../domain/entities/parent_access_code.dart';

class ParentAccessCodeModel extends ParentAccessCode {
  const ParentAccessCodeModel({
    required super.code,
    required super.studentIds,
    required super.studentNames,
    super.parentName,
    super.isActive,
  });

  factory ParentAccessCodeModel.fromFirestore(Map<String, dynamic> json, String code) {
    return ParentAccessCodeModel(
      code: code,
      studentIds: List<String>.from(json['studentIds'] ?? const []),
      studentNames: List<String>.from(json['studentNames'] ?? const []),
      parentName: json['parentName'] as String?,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentIds': studentIds,
      'studentNames': studentNames,
      'parentName': parentName,
      'isActive': isActive,
    };
  }
}
