import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/discipline_incident.dart';

class DisciplineIncidentModel extends DisciplineIncident {
  const DisciplineIncidentModel({
    required super.id,
    required super.studentId,
    required super.date,
    required super.description,
    required super.severity,
    required super.resolution,
    required super.counselingNotes,
    super.punishment,
  });

  factory DisciplineIncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DisciplineIncidentModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      severity: Severity.values.firstWhere(
        (e) => e.name == (data['severity'] ?? 'info'),
        orElse: () => Severity.info,
      ),
      resolution: data['resolution'] ?? '',
      counselingNotes: data['counselingNotes'] ?? '',
      punishment: data['punishment'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'description': description,
      'severity': severity.name,
      'resolution': resolution,
      'counselingNotes': counselingNotes,
      'punishment': punishment,
    };
  }
}
