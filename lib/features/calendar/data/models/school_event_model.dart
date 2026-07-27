import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/user_roles.dart';
import '../../domain/entities/school_event.dart';

class SchoolEventModel extends SchoolEvent {
  const SchoolEventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required super.createdBy,
    super.targetRoles,
    super.type,
    super.responsiblePerson,
  });

  factory SchoolEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      targetRoles: (data['targetRoles'] as List<dynamic>?)
              ?.map((e) => UserRole.values.firstWhere((r) => r.name == e))
              .toList() ??
          const [],
      type: SchoolEventType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'general'),
        orElse: () => SchoolEventType.general,
      ),
      responsiblePerson: data['responsiblePerson'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'targetRoles': targetRoles.map((e) => e.name).toList(),
      'type': type.name,
      'responsiblePerson': responsiblePerson,
    };
  }
}
