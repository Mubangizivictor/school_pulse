import '../../domain/entities/parent_access_code.dart';

class ParentAccessCodeModel extends ParentAccessCode {
  const ParentAccessCodeModel({
    required super.code,
    required super.studentIds,
    required super.studentNames,
    super.parentName,
    super.phoneNumber,
    super.pin,
    super.mustChangePin = true,
    super.isActive = true,
  });

  factory ParentAccessCodeModel.fromFirestore(Map<String, dynamic> json, String code) {
    return ParentAccessCodeModel(
      code: code,
      studentIds: List<String>.from(json['studentIds'] ?? const []),
      studentNames: List<String>.from(json['studentNames'] ?? const []),
      parentName: json['parentName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      pin: json['pin'] as String?,
      mustChangePin: json['mustChangePin'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentIds': studentIds,
      'studentNames': studentNames,
      'parentName': parentName,
      'phoneNumber': phoneNumber,
      'pin': pin,
      'mustChangePin': mustChangePin,
      'isActive': isActive,
    };
  }
}
