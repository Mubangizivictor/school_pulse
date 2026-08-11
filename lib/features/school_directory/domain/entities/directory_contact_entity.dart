import 'package:equatable/equatable.dart';

class DirectoryContactEntity extends Equatable {
  final String uid;
  final String name;
  final String role;
  final List<String> roles;
  final String schoolId;
  final bool isActive;
  final String? phone;

  const DirectoryContactEntity({
    required this.uid,
    required this.name,
    required this.role,
    this.roles = const [],
    required this.schoolId,
    this.isActive = true,
    this.phone,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    role,
    roles,
    schoolId,
    isActive,
    phone,
  ];
}
