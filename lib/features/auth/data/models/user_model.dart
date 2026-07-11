import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    required super.role,
    super.photoUrl,
    super.studentIds,
    super.mustChangePassword,
    super.isActive,
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
      mustChangePassword: entity.mustChangePassword,
      isActive: entity.isActive,
    );
  }
}
