import '../../domain/entities/payment_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRecordModel extends PaymentRecord {
  const PaymentRecordModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    required super.academicYear,
    required super.term,
    required super.amount,
    required super.date,
    required super.method,
    required super.reference,
    required super.receiptNumber,
    required super.feeBreakdown,
    required super.recordedBy,
    super.notes,
  });

  factory PaymentRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRecordModel.fromMap(data, doc.id);
  }

  factory PaymentRecordModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentRecordModel(
      id: id,
      schoolId: data['schoolId'] ?? '',
      studentId: data['studentId'] ?? '',
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      method: data['method'] ?? '',
      reference: data['reference'] ?? '',
      receiptNumber: data['receiptNumber'] ?? '',
      feeBreakdown: Map<String, double>.from(data['feeBreakdown'] ?? {}),
      recordedBy: data['recordedBy'] ?? '',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'studentId': studentId,
      'academicYear': academicYear,
      'term': term,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'method': method,
      'reference': reference,
      'receiptNumber': receiptNumber,
      'feeBreakdown': feeBreakdown,
      'recordedBy': recordedBy,
      'notes': notes,
    };
  }

  Map<String, dynamic> toMap() {
    return toFirestore();
  }
}
