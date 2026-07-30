import '../../domain/entities/parent_access_code.dart';

class ParentAccessCodeModel extends ParentAccessCode {
  const ParentAccessCodeModel({
    required super.id,
    required super.parentCode,
    required super.schoolId,
    required super.studentIds,
    required super.studentNames,
    super.parentName,
    super.phoneNumber,
    super.pin,
    super.mustChangePin = true,
    super.isActive = true,
    super.deactivationReason,
  });

  factory ParentAccessCodeModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    return ParentAccessCodeModel(
      id: id,
      parentCode: json['parentCode'] ?? json['code'] ?? id,
      schoolId: json['schoolId'] ?? '',
      studentIds: List<String>.from(json['studentIds'] ?? const []),
      studentNames: List<String>.from(json['studentNames'] ?? const []),
      parentName: json['parentName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      pin: json['pin'] as String?,
      mustChangePin: json['mustChangePin'] ?? true,
      isActive: json['isActive'] ?? true,
      deactivationReason: json['deactivationReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'parentCode': parentCode,
      'schoolId': schoolId,
      'studentIds': studentIds,
      'studentNames': studentNames,
      'parentName': parentName,
      'phoneNumber': phoneNumber,
      'pin': pin,
      'mustChangePin': mustChangePin,
      'isActive': isActive,
      'deactivationReason': deactivationReason,
    };
  }
}
