import '../entities/payment.dart';

abstract class BillingRepository {
  Future<List<Invoice>> getInvoices({String? schoolId, PaymentStatus? status});
  Future<void> createInvoice(Invoice invoice);
  Future<void> markInvoiceAsPaid(String invoiceId, String transactionId);
  
  // Payment Gateway Logic
  Future<String> initiateSubscriptionPayment({
    required String schoolId,
    required double amount,
    required String email,
    required String phoneNumber,
    required String planId,
  });

  Future<bool> verifyPayment(String transactionReference);
  
  Future<List<Transaction>> getTransactionHistory({String? schoolId});
}
