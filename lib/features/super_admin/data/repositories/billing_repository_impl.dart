import '../../domain/entities/payment.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';
import '../models/payment_model.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource remoteDataSource;

  BillingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Invoice>> getInvoices({
    String? schoolId,
    PaymentStatus? status,
  }) async {
    return await remoteDataSource.getInvoices(
      schoolId: schoolId,
      status: status,
    );
  }

  @override
  Future<void> createInvoice(Invoice invoice) async {
    final model = InvoiceModel(
      id: invoice.id,
      schoolId: invoice.schoolId,
      schoolName: invoice.schoolName,
      planId: invoice.planId,
      amount: invoice.amount,
      dueDate: invoice.dueDate,
      paidAt: invoice.paidAt,
      status: invoice.status,
      billingPeriod: invoice.billingPeriod,
    );
    await remoteDataSource.createInvoice(model);
  }

  @override
  Future<void> markInvoiceAsPaid(String invoiceId, String transactionId) async {
    await remoteDataSource.markInvoiceAsPaid(invoiceId, transactionId);
  }

  @override
  Future<String> initiateSubscriptionPayment({
    required String schoolId,
    required double amount,
    required String email,
    required String phoneNumber,
    required String planId,
  }) async {
    return await remoteDataSource.initiateSubscriptionPayment(
      schoolId: schoolId,
      amount: amount,
      email: email,
      phoneNumber: phoneNumber,
      planId: planId,
    );
  }

  @override
  Future<bool> verifyPayment(String transactionReference) async {
    return await remoteDataSource.verifyPayment(transactionReference);
  }

  @override
  Future<List<Transaction>> getTransactionHistory({String? schoolId}) async {
    return await remoteDataSource.getTransactionHistory(schoolId: schoolId);
  }
}
