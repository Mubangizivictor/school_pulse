import '../../domain/entities/health_visit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthVisitModel extends HealthVisit {
  const HealthVisitModel({
    required super.id,
    required super.studentId,
    required super.date,
    required super.reason,
    required super.treatment,
    required super.medication,
  });

  factory HealthVisitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthVisitModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      treatment: data['treatment'] ?? '',
      medication: data['medication'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'reason': reason,
      'treatment': treatment,
      'medication': medication,
    };
  }
}
