import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/counseling_session.dart';

class CounselingSessionModel extends CounselingSession {
  const CounselingSessionModel({
    required super.id,
    required super.studentId,
    required super.counselorId,
    required super.date,
    required super.reason,
    required super.notes,
    required super.recommendations,
    super.linkedIncidentId,
  });

  factory CounselingSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CounselingSessionModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      counselorId: data['counselorId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      notes: data['notes'] ?? '',
      recommendations: data['recommendations'] ?? '',
      linkedIncidentId: data['linkedIncidentId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'counselorId': counselorId,
      'date': Timestamp.fromDate(date),
      'reason': reason,
      'notes': notes,
      'recommendations': recommendations,
      'linkedIncidentId': linkedIncidentId,
    };
  }
}
