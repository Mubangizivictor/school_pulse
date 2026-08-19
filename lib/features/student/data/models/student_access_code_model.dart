import '../../domain/entities/student_access_code.dart';

/// Note: the stored `pin` is a server-side hash (see functions/vendor/
/// pin-auth.js) - it is deliberately never read back into this model. Admin
/// screens only need isActive/mustChangePin/lastLoginAt, never the PIN
/// itself.
class StudentAccessCodeModel extends StudentAccessCode {
  const StudentAccessCodeModel({
    required super.id,
    required super.studentCode,
    required super.schoolId,
    required super.studentId,
    required super.studentName,
    super.phoneNumber,
    super.mustChangePin = true,
    super.isActive = true,
    super.deactivationReason,
    super.lastLoginAt,
  });

  factory StudentAccessCodeModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    final lastLogin = json['lastLoginAt'];
    return StudentAccessCodeModel(
      id: id,
      studentCode: json['studentCode'] ?? id,
      schoolId: json['schoolId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      mustChangePin: json['mustChangePin'] ?? true,
      isActive: json['isActive'] ?? true,
      deactivationReason: json['deactivationReason'] as String?,
      lastLoginAt: lastLogin == null
          ? null
          : (lastLogin is DateTime
                ? lastLogin
                : (lastLogin.toDate() as DateTime)),
    );
  }
}
