import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.staffCode,
    required super.name,
    required super.email,
    required super.schoolId,
    super.schoolName,
    super.phoneNumber,
    required super.roles,
    super.photoUrl,
    super.studentIds = const [],
    super.assignedClass,
    super.subjects,
    super.mustChangePassword = false,
    super.isActive = true,
    super.deactivationReason,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<UserRole> roles = [];
    if (json['roles'] != null) {
      roles = (json['roles'] as List)
          .map((r) => UserRole.values.firstWhere(
                (e) => e.name == r,
                orElse: () => UserRole.parent,
              ))
          .toList();
    } else if (json['role'] != null) {
      // Handle legacy single role
      roles = [
        UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.parent,
        )
      ];
    } else {
      roles = [UserRole.parent];
    }

    return UserModel(
      id: json['id'] ?? '',
      staffCode: json['staffCode'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      schoolId: json['schoolId'] ?? '',
      schoolName: json['schoolName'],
      phoneNumber: json['phoneNumber'],
      roles: roles,
      photoUrl: json['photoUrl'],
      studentIds: List<String>.from(json['studentIds'] ?? const []),
      assignedClass: json['assignedClass'],
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
              .map((i) => SubjectAssignment.fromJson(i))
              .toList()
          : null,
      mustChangePassword: json['mustChangePassword'] ?? false,
      isActive: json['isActive'] ?? true,
      deactivationReason: json['deactivationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffCode': staffCode,
      'name': name,
      'email': email,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'phoneNumber': phoneNumber,
      // Cloud Functions (e.g. billing role checks) still read the singular
      // 'role' field, so keep it in sync with the primary (first) role.
      'role': roles.isNotEmpty ? roles.first.name : null,
      'roles': roles.map((e) => e.name).toList(),
      'photoUrl': photoUrl,
      'studentIds': studentIds,
      'assignedClass': assignedClass,
      'subjects': subjects?.map((e) => e.toJson()).toList(),
      'mustChangePassword': mustChangePassword,
      'isActive': isActive,
      'deactivationReason': deactivationReason,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      staffCode: entity.staffCode,
      name: entity.name,
      email: entity.email,
      schoolId: entity.schoolId,
      schoolName: entity.schoolName,
      phoneNumber: entity.phoneNumber,
      roles: entity.roles,
      photoUrl: entity.photoUrl,
      studentIds: entity.studentIds,
      assignedClass: entity.assignedClass,
      subjects: entity.subjects,
      mustChangePassword: entity.mustChangePassword,
      isActive: entity.isActive,
      deactivationReason: entity.deactivationReason,
    );
  }
}
