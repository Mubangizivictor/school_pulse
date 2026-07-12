import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    required super.role,
    super.photoUrl,
    super.studentIds = const [],
    super.assignedClass,
    super.subjects,
    super.mustChangePassword = false,
    super.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'parent'),
        orElse: () => UserRole.parent,
      ),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'photoUrl': photoUrl,
      'studentIds': studentIds,
      'assignedClass': assignedClass,
      'subjects': subjects?.map((e) => e.toJson()).toList(),
      'mustChangePassword': mustChangePassword,
      'isActive': isActive,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
      photoUrl: entity.photoUrl,
      studentIds: entity.studentIds,
      assignedClass: entity.assignedClass,
      subjects: entity.subjects,
      mustChangePassword: entity.mustChangePassword,
      isActive: entity.isActive,
    );
  }
}
