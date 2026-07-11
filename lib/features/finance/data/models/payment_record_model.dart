import '../../domain/entities/payment_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRecordModel extends PaymentRecord {
  const PaymentRecordModel({
    required super.id,
    required super.studentId,
    required super.amount,
    required super.date,
    required super.method,
    required super.reference,
  });

  factory PaymentRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRecordModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      method: data['method'] ?? '',
      reference: data['reference'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'method': method,
      'reference': reference,
    };
  }
}
