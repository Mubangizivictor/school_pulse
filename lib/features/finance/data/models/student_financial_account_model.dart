import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/student_financial_account.dart';
import 'payment_record_model.dart';

class StudentFinancialAccountModel extends StudentFinancialAccount {
  const StudentFinancialAccountModel({
    required super.studentId,
    required super.schoolId,
    required super.academicYear,
    required super.term,
    required super.feeStructureId,
    super.scholarshipAmount = 0,
    super.discountAmount = 0,
    required super.totalBilled,
    required super.totalPaid,
    required List<PaymentRecordModel> super.paymentHistory,
    super.applicableRestrictions = const [],
  });

  factory StudentFinancialAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentFinancialAccountModel(
      studentId: doc.id,
      schoolId: data['schoolId'] ?? '',
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
      feeStructureId: data['feeStructureId'] ?? '',
      scholarshipAmount: (data['scholarshipAmount'] ?? 0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      totalBilled: (data['totalBilled'] ?? 0).toDouble(),
      totalPaid: (data['totalPaid'] ?? 0).toDouble(),
      paymentHistory: (data['paymentHistory'] as List? ?? [])
          .map((item) => PaymentRecordModel.fromMap(
                item as Map<String, dynamic>,
                item['id'] ?? '',
              ))
          .toList(),
      applicableRestrictions: List<String>.from(data['applicableRestrictions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'academicYear': academicYear,
      'term': term,
      'feeStructureId': feeStructureId,
      'scholarshipAmount': scholarshipAmount,
      'discountAmount': discountAmount,
      'totalBilled': totalBilled,
      'totalPaid': totalPaid,
      'paymentHistory': paymentHistory
          .map((item) => (item as PaymentRecordModel).toMap())
          .toList(),
      'applicableRestrictions': applicableRestrictions,
    };
  }
}
