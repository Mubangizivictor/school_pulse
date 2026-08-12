import '../entities/payment_attempt.dart';

enum PaymentMethod { mtnMomo }

abstract class SubscriptionPaymentRepository {
  Future<String> initiatePayment({
    required PaymentMethod method,
    required String phoneNumber,
  });

  Future<PaymentAttempt> checkPaymentStatus(String paymentId);

  Stream<PaymentAttempt> watchPayment(String paymentId);
}
