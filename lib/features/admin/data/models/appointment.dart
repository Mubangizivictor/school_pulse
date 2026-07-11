import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String visitorName;
  final String purpose;
  final DateTime scheduledTime;
  final String status; // 'pending', 'checked_in', 'cancelled', 'completed'
  final String hostStaffId;

  Appointment({
    required this.id,
    required this.visitorName,
    required this.purpose,
    required this.scheduledTime,
    required this.status,
    required this.hostStaffId,
  });

  Map<String, dynamic> toMap() {
    return {
      'visitorName': visitorName,
      'purpose': purpose,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status,
      'hostStaffId': hostStaffId,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      visitorName: map['visitorName'] ?? '',
      purpose: map['purpose'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      hostStaffId: map['hostStaffId'] ?? '',
    );
  }
}
