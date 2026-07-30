import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

export 'package:school_pulse/core/user_roles.dart' show UserRole;

class UserEntity extends Equatable {
  final String id; // Internal System ID (UUID)
  final String? staffCode; // Human-Friendly Code (e.g., SMAC749201)
  final String name;
  final String email;
  final String? phoneNumber;
  final List<UserRole> roles;
  final String? photoUrl;
  final List<String> studentIds; // For Parents
  final String? studentId; // For Student users
  final String? assignedClass; // For Class Teachers
  final List<SubjectAssignment>? subjects; // For Subject Teachers
  final String schoolId;
  final String? schoolName;
  final bool isActive;
  final String? deactivationReason;
  final bool mustChangePassword;

  const UserEntity({
    required this.id,
    this.staffCode,
    required this.name,
    required this.email,
    required this.schoolId,
    this.schoolName,
    this.phoneNumber,
    required this.roles,
    this.photoUrl,
    this.studentIds = const [],
    this.studentId,
    this.assignedClass,
    this.subjects,
    this.isActive = true,
    this.deactivationReason,
    this.mustChangePassword = false,
  });

  UserRole get role => roles.first; // Temporary helper for backward compatibility

  @override
  List<Object?> get props => [
        id,
        staffCode,
        name,
        email,
        schoolId,
        schoolName,
        phoneNumber,
        roles,
        photoUrl,
        studentIds,
        studentId,
        assignedClass,
        subjects,
        mustChangePassword,
        isActive,
        deactivationReason,
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
