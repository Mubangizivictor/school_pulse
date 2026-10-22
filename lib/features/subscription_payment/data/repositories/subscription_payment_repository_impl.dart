import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/payment_attempt.dart';
import '../../domain/repositories/subscription_payment_repository.dart';

class SubscriptionPaymentRepositoryImpl
    implements SubscriptionPaymentRepository {
  SubscriptionPaymentRepositoryImpl({
    required this._functions,
    required this._firestore,
  });

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  @override
  Future<String> initiatePayment({
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    // Only one provider is implemented server-side today; the method
    // parameter exists so this interface doesn't need to change when Airtel
    // Money is added later.
    final callable = _functions.httpsCallable('initiateMtnPayment');
    final result = await callable.call<Map<String, dynamic>>({
      'phoneNumber': phoneNumber,
    });
    final paymentId = result.data['paymentId']?.toString();
    if (paymentId == null || paymentId.isEmpty) {
      throw StateError('School Pulse did not return a payment reference.');
    }
    return paymentId;
  }

  @override
  Future<PaymentAttempt> checkPaymentStatus(String paymentId) async {
    final callable = _functions.httpsCallable('checkMtnPaymentStatus');
    final result = await callable.call<Map<String, dynamic>>({
      'paymentId': paymentId,
    });
    final data = Map<String, dynamic>.from(result.data);
    return PaymentAttempt.fromMap(paymentId, data);
  }

  @override
  Stream<PaymentAttempt> watchPayment(String paymentId) {
    return _firestore
        .collection('mtn_payments')
        .doc(paymentId)
        .snapshots()
        .where((snapshot) => snapshot.data() != null)
        .map((snapshot) => PaymentAttempt.fromMap(paymentId, snapshot.data()!));
  }
}
