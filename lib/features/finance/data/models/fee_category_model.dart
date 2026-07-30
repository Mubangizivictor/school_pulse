import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/fee_category.dart';

class FeeCategoryModel extends FeeCategory {
  const FeeCategoryModel({
    required super.id,
    required super.schoolId,
    required super.name,
    super.description,
    super.isMandatory,
    super.priority,
  });

  factory FeeCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeeCategoryModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      isMandatory: data['isMandatory'] ?? true,
      priority: data['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'name': name,
      'description': description,
      'isMandatory': isMandatory,
      'priority': priority,
    };
  }
}
