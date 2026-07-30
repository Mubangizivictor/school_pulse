import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.academicYear,
    required super.term,
    required super.allocatedAmount,
    super.spentAmount = 0,
    super.description,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      name: data['name'] ?? '',
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
      allocatedAmount: (data['allocatedAmount'] ?? 0).toDouble(),
      spentAmount: (data['spentAmount'] ?? 0).toDouble(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'name': name,
      'academicYear': academicYear,
      'term': term,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'description': description,
    };
  }
}
