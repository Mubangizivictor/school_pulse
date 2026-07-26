import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/subscription.dart';
import '../models/payment_transaction.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<Subscription> watchSubscription() {
    return _firestore.collection('subscription').doc('current').snapshots().map(
          (doc) => Subscription.fromFirestore(doc.data()),
        );
  }

  Stream<List<PaymentTransaction>> watchRecentTransactions() {
    return _firestore
        .collection('payment_transactions')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(PaymentTransaction.fromFirestore).toList());
  }

  /// Calls the `initiateMobileMoneyCharge` Cloud Function, which prompts the
  /// subscriber's phone for a Mobile Money PIN approval (MTN MoMo "Request
  /// to Pay" or Airtel Money Collection). Returns the transaction id so the
  /// UI can watch it for a status update.
  Future<String> initiateMobileMoneyCharge({
    required String provider,
    required String phoneNumber,
    required int amountUgx,
  }) async {
    final callable = _functions.httpsCallable('initiateMobileMoneyCharge');
    final result = await callable.call<Map<String, dynamic>>({
      'provider': provider,
      'phoneNumber': phoneNumber,
      'amountUgx': amountUgx,
    });
    return result.data['transactionId'] as String;
  }
}
