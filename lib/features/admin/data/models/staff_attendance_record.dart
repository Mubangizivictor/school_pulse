import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAttendanceRecord {
  final String staffId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String status; // 'on_time' | 'late'
  final String location;

  StaffAttendanceRecord({
    required this.staffId,
    required this.clockIn,
    this.clockOut,
    required this.status,
    required this.location,
  });

  factory StaffAttendanceRecord.fromMap(Map<String, dynamic> map) => StaffAttendanceRecord(
        staffId: map['staffId'] ?? '',
        clockIn: (map['clockIn'] as Timestamp).toDate(),
        clockOut: (map['clockOut'] as Timestamp?)?.toDate(),
        status: map['status'] ?? 'on_time',
        location: map['location'] ?? 'Main Gate',
      );
}
