import '../../domain/entities/student_identity.dart';

class StudentIdentityModel extends StudentIdentity {
  const StudentIdentityModel({
    required super.studentId,
    required super.uniqueSystemId,
    required super.schoolStudentId,
    required super.qrCodeData,
    super.nfcStatus,
  });

  factory StudentIdentityModel.fromFirestore(Map<String, dynamic> json) {
    return StudentIdentityModel(
      studentId: json['studentId'] as String,
      uniqueSystemId: json['uniqueSystemId'] as String,
      schoolStudentId: json['schoolStudentId'] as String,
      qrCodeData: json['qrCodeData'] as String,
      nfcStatus: json['nfcStatus'] as String? ?? 'unassigned',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'uniqueSystemId': uniqueSystemId,
      'schoolStudentId': schoolStudentId,
      'qrCodeData': qrCodeData,
      'nfcStatus': nfcStatus,
    };
  }
}
