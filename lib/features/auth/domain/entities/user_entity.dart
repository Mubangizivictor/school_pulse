import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

export 'package:school_pulse/core/user_roles.dart' show UserRole;

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final UserRole role;
  final String? photoUrl;
  final List<String> studentIds;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.photoUrl,
    this.studentIds = const [],
    this.mustChangePassword = false,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, email, phoneNumber, role, photoUrl, studentIds, mustChangePassword, isActive];
}
