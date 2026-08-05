import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/payment_model.dart';
import '../../domain/entities/payment.dart';

abstract class BillingRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices({
    String? schoolId,
    PaymentStatus? status,
  });
  Future<void> createInvoice(InvoiceModel invoice);
  Future<void> markInvoiceAsPaid(String invoiceId, String transactionId);
  Future<String> initiateSubscriptionPayment({
    required String schoolId,
    required double amount,
    required String email,
    required String phoneNumber,
    required String planId,
  });
  Future<bool> verifyPayment(String transactionReference);
  Future<List<TransactionModel>> getTransactionHistory({String? schoolId});
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  BillingRemoteDataSourceImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<List<InvoiceModel>> getInvoices({
    String? schoolId,
    PaymentStatus? status,
  }) async {
    Query query = firestore.collection('invoices');

    if (schoolId != null) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }

    if (status != null) {
      query = query.where(
        'status',
        isEqualTo: status.toString().split('.').last,
      );
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => InvoiceModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createInvoice(InvoiceModel invoice) async {
    await firestore
        .collection('invoices')
        .doc(invoice.id)
        .set(invoice.toJson());
  }

  @override
  Future<void> markInvoiceAsPaid(String invoiceId, String transactionId) async {
    final batch = firestore.batch();

    final invoiceRef = firestore.collection('invoices').doc(invoiceId);
    batch.update(invoiceRef, {
      'status': 'completed',
      'paidAt': DateTime.now().millisecondsSinceEpoch,
    });

    final transRef = firestore.collection('transactions').doc(transactionId);
    batch.update(transRef, {'status': 'completed'});

    await batch.commit();
  }

  @override
  Future<String> initiateSubscriptionPayment({
    required String schoolId,
    required double amount,
    required String email,
    required String phoneNumber,
    required String planId,
  }) async {
    // Calling a Cloud Function to handle Flutterwave/Paystack initialization
    // This is the secure way to handle secrets and provider communication
    try {
      final result = await functions
          .httpsCallable('initiateSubscriptionPayment')
          .call({
            'schoolId': schoolId,
            'amount': amount,
            'email': email,
            'phoneNumber': phoneNumber,
            'planId': planId,
            'currency': 'UGX',
          });

      return result.data['paymentLink'] as String;
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  @override
  Future<bool> verifyPayment(String transactionReference) async {
    try {
      final result = await functions
          .httpsCallable('verifySubscriptionPayment')
          .call({'reference': transactionReference});

      return result.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory({
    String? schoolId,
  }) async {
    Query query = firestore
        .collection('transactions')
        .orderBy('timestamp', descending: true);

    if (schoolId != null) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              TransactionModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
