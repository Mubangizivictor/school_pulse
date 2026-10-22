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

  // 'active' | 'replaced'. Tracks the QR credential's own lifecycle
  // independently of nfcStatus - a card can be revoked while the QR stays
  // active, or vice versa.
  final String qrCredentialStatus;

  // When this identity was first issued (server-set, never client-chosen).
  // Null for identities issued before this field existed.
  final DateTime? issuedAt;

  // Last time the printable School ID (front/back card) was previewed or
  // printed, recorded via the identity_school_id_previewed audit action.
  final DateTime? lastPrintedAt;

  const StudentIdentity({
    required this.studentId,
    required this.schoolId,
    required this.uniqueSystemId,
    required this.schoolStudentId,
    required this.qrCodeData,
    this.nfcStatus = 'unassigned',
    this.qrCredentialStatus = 'active',
    this.issuedAt,
    this.lastPrintedAt,
  });

  StudentIdentity copyWith({
    String? nfcStatus,
    String? qrCredentialStatus,
    DateTime? issuedAt,
    DateTime? lastPrintedAt,
  }) {
    return StudentIdentity(
      studentId: studentId,
      schoolId: schoolId,
      uniqueSystemId: uniqueSystemId,
      schoolStudentId: schoolStudentId,
      qrCodeData: qrCodeData,
      nfcStatus: nfcStatus ?? this.nfcStatus,
      qrCredentialStatus: qrCredentialStatus ?? this.qrCredentialStatus,
      issuedAt: issuedAt ?? this.issuedAt,
      lastPrintedAt: lastPrintedAt ?? this.lastPrintedAt,
    );
  }

  @override
  List<Object?> get props => [
    studentId,
    schoolId,
    uniqueSystemId,
    schoolStudentId,
    qrCodeData,
    nfcStatus,
    qrCredentialStatus,
    issuedAt,
    lastPrintedAt,
  ];
}
