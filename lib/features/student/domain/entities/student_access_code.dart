import 'package:equatable/equatable.dart';

/// A single code that grants one student direct login access. Doc ID in
/// Firestore IS the code, mirroring [ParentAccessCode] but scoped to one
/// student instead of a sibling group.
class StudentAccessCode extends Equatable {
  final String id;
  final String studentCode;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String? phoneNumber;
  final bool mustChangePin;

  final bool isActive;
  final String? deactivationReason;
  final DateTime? lastLoginAt;

  String get code => studentCode;

  const StudentAccessCode({
    required this.id,
    required this.studentCode,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    this.phoneNumber,
    this.mustChangePin = true,
    this.isActive = true,
    this.deactivationReason,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
    id,
    studentCode,
    schoolId,
    studentId,
    studentName,
    phoneNumber,
    mustChangePin,
    isActive,
    deactivationReason,
    lastLoginAt,
  ];
}
