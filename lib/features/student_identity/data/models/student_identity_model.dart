import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/student_identity.dart';

class StudentIdentityModel extends StudentIdentity {
  const StudentIdentityModel({
    required super.studentId,
    required super.schoolId,
    required super.uniqueSystemId,
    required super.schoolStudentId,
    required super.qrCodeData,
    super.nfcStatus,
    super.qrCredentialStatus,
    super.issuedAt,
    super.lastPrintedAt,
  });

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  factory StudentIdentityModel.fromFirestore(Map<String, dynamic> json) {
    return StudentIdentityModel(
      studentId: json['studentId'] as String,
      schoolId: json['schoolId'] as String? ?? '',
      uniqueSystemId: json['uniqueSystemId'] as String,
      schoolStudentId: json['schoolStudentId'] as String,
      qrCodeData: json['qrCodeData'] as String,
      nfcStatus: json['nfcStatus'] as String? ?? 'unassigned',
      qrCredentialStatus: json['qrCredentialStatus'] as String? ?? 'active',
      issuedAt: _parseTimestamp(json['issuedAt']),
      lastPrintedAt: _parseTimestamp(json['lastPrintedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'uniqueSystemId': uniqueSystemId,
      'schoolStudentId': schoolStudentId,
      'qrCodeData': qrCodeData,
      'nfcStatus': nfcStatus,
      'qrCredentialStatus': qrCredentialStatus,
      if (issuedAt != null) 'issuedAt': Timestamp.fromDate(issuedAt!),
      if (lastPrintedAt != null)
        'lastPrintedAt': Timestamp.fromDate(lastPrintedAt!),
    };
  }
}
