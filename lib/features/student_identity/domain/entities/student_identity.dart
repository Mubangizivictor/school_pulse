import 'package:equatable/equatable.dart';

class StudentIdentity extends Equatable {
  final String studentId; // Reference to Student.id (Firestore)
  final String uniqueSystemId; // SP-STUDENT-a82jd92
  final String schoolStudentId; // MH-2026-000001 (Admission Number format)
  final String qrCodeData; // Usually just the uniqueSystemId

  const StudentIdentity({
    required this.studentId,
    required this.uniqueSystemId,
    required this.schoolStudentId,
    required this.qrCodeData,
  });

  @override
  List<Object?> get props => [studentId, uniqueSystemId, schoolStudentId, qrCodeData];
}
