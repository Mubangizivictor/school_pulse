import '../../domain/entities/payment.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.schoolId,
    required super.invoiceId,
    required super.amount,
    super.currency,
    required super.status,
    required super.method,
    required super.timestamp,
    required super.providerReference,
    super.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      invoiceId: json['invoiceId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UGX',
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method'],
        orElse: () => PaymentMethod.mobileMoney,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      providerReference: json['providerReference'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'invoiceId': invoiceId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'providerReference': providerReference,
      'metadata': metadata,
    };
  }
}

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.schoolId,
    required super.schoolName,
    required super.planId,
    required super.amount,
    required super.dueDate,
    super.paidAt,
    required super.status,
    required super.billingPeriod,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      schoolName: json['schoolName'] ?? '',
      planId: json['planId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
      paidAt: json['paidAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['paidAt']) : null,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      billingPeriod: json['billingPeriod'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'planId': planId,
      'amount': amount,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'paidAt': paidAt?.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'billingPeriod': billingPeriod,
    };
  }
}
