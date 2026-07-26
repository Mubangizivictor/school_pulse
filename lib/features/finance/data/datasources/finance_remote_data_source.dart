import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_item_model.dart';
import '../models/payment_record_model.dart';

abstract class FinanceRemoteDataSource {
  Future<List<FeeItemModel>> getFees(String studentId);
  Future<List<PaymentRecordModel>> getPaymentHistory(String studentId);
  Future<void> processPayment(PaymentRecordModel payment);
  Future<List<FeeItemModel>> getAllFees();
  Future<List<PaymentRecordModel>> getAllPaymentHistory();
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final FirebaseFirestore firestore;

  FinanceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<FeeItemModel>> getFees(String studentId) async {
    final snapshot = await firestore
        .collection('fees')
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs.map((doc) => FeeItemModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<PaymentRecordModel>> getPaymentHistory(String studentId) async {
    final snapshot = await firestore
        .collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => PaymentRecordModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> processPayment(PaymentRecordModel payment) async {
    await firestore.collection('payments').add(payment.toFirestore());
  }

  @override
  Future<List<FeeItemModel>> getAllFees() async {
    final snapshot = await firestore.collection('fees').get();
    return snapshot.docs.map((doc) => FeeItemModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<PaymentRecordModel>> getAllPaymentHistory() async {
    final snapshot = await firestore
        .collection('payments')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => PaymentRecordModel.fromFirestore(doc)).toList();
  }
}
