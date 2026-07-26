import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/school_event.dart';

class SchoolEventModel extends SchoolEvent {
  const SchoolEventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required super.createdBy,
  });

  factory SchoolEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
    };
  }
}
