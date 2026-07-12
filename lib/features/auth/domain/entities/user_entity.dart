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
  final String? assignedClass; // For Class Teachers
  final List<SubjectAssignment>? subjects; // For Subject Teachers
  final bool isActive;
  final bool mustChangePassword;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.photoUrl,
    this.studentIds = const [],
    this.assignedClass,
    this.subjects,
    this.isActive = true,
    this.mustChangePassword = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        role,
        photoUrl,
        studentIds,
        assignedClass,
        subjects,
        mustChangePassword,
        isActive
      ];
}

class SubjectAssignment extends Equatable {
  final String subjectName;
  final String className;

  const SubjectAssignment({
    required this.subjectName,
    required this.className,
  });

  @override
  List<Object?> get props => [subjectName, className];

  Map<String, dynamic> toJson() => {
        'subjectName': subjectName,
        'className': className,
      };

  factory SubjectAssignment.fromJson(Map<String, dynamic> json) =>
      SubjectAssignment(
        subjectName: json['subjectName'] ?? '',
        className: json['className'] ?? '',
      );
}
