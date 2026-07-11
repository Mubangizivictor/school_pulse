import '../../domain/entities/fee_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeeItemModel extends FeeItem {
  const FeeItemModel({
    required super.id,
    required super.studentId,
    required super.category,
    required super.amount,
    required super.status,
    required super.dueDate,
  });

  factory FeeItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeeItemModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: FeeStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'due'),
        orElse: () => FeeStatus.due,
      ),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'category': category,
      'amount': amount,
      'status': status.name,
      'dueDate': Timestamp.fromDate(dueDate),
    };
  }
}
