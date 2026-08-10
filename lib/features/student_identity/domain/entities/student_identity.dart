import 'package:equatable/equatable.dart';

class StudentIdentity extends Equatable {
  final String studentId; // Reference to Student.id (Firestore)
  final String schoolId; // Tenant scope - required for Firestore rule isolation
  final String uniqueSystemId; // SP-STUDENT-a82jd92
  final String schoolStudentId; // MH-2026-000001 (Admission Number format)
  final String qrCodeData; // Signed envelope: id + issuedAt + schoolId + HMAC

  // 'unassigned' | 'active' | 'revoked'. No physical card is bound at
  // generation time - NFC assignment is a separate future phase. This is
  // just the placeholder slot so an identity record always has a status.
  final String nfcStatus;

  const StudentIdentity({
    required this.studentId,
    required this.schoolId,
    required this.uniqueSystemId,
    required this.schoolStudentId,
    required this.qrCodeData,
    this.nfcStatus = 'unassigned',
  });

  @override
  List<Object?> get props => [
    studentId,
    schoolId,
    uniqueSystemId,
    schoolStudentId,
    qrCodeData,
    nfcStatus,
  ];
}
