import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/alert.dart';

class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.studentId,
    required super.title,
    required super.message,
    required super.severity,
    required super.timestamp,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data()!;
    return AlertModel(
      id: doc.id,
      studentId: json['studentId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == (json['severity'] ?? 'info'),
        orElse: () => AlertSeverity.info,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'title': title,
      'message': message,
      'severity': severity.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
