import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/school_event.dart';

class SchoolEventModel extends SchoolEvent {
  const SchoolEventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required super.createdBy,
    super.targetGroups,
    super.type,
  });

  factory SchoolEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      targetGroups: (data['targetGroups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          defaultEventTargetGroups,
      type: SchoolEventType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'general'),
        orElse: () => SchoolEventType.general,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'targetGroups': targetGroups,
      'type': type.name,
    };
  }
}
