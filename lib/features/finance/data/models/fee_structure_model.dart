import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/fee_structure.dart';

class FeeStructureModel extends FeeStructure {
  const FeeStructureModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.academicYear,
    required super.term,
    required List<FeeStructureItemModel> super.items,
    super.classId,
    super.programId,
    required super.studentCategory,
  });

  factory FeeStructureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeeStructureModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      name: data['name'] ?? '',
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => FeeStructureItemModel.fromMap(item))
          .toList(),
      classId: data['classId'],
      programId: data['programId'],
      studentCategory: data['studentCategory'] ?? 'Day',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'name': name,
      'academicYear': academicYear,
      'term': term,
      'items': items
          .map((item) => (item as FeeStructureItemModel).toMap())
          .toList(),
      'classId': classId,
      'programId': programId,
      'studentCategory': studentCategory,
    };
  }
}

class FeeStructureItemModel extends FeeStructureItem {
  const FeeStructureItemModel({
    required super.categoryId,
    required super.categoryName,
    required super.amount,
  });

  factory FeeStructureItemModel.fromMap(Map<String, dynamic> map) {
    return FeeStructureItemModel(
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
    };
  }
}
