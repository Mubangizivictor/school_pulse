import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.studentId,
    required super.date,
    required super.status,
    super.note,
  });

  factory AttendanceRecordModel.fromFirestore(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      studentId: json['studentId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      status: StudentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StudentStatus.present,
      ),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'note': note,
    };
  }
}
