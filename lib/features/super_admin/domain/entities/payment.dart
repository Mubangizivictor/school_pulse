import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, completed, failed, refunded }

enum PaymentMethod { mobileMoney, card, bankTransfer, cash }

class Transaction extends Equatable {
  final String id;
  final String schoolId;
  final String invoiceId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime timestamp;
  final String providerReference; // e.g., Flutterwave/Paystack Ref
  final Map<String, dynamic> metadata;

  const Transaction({
    required this.id,
    required this.schoolId,
    required this.invoiceId,
    required this.amount,
    this.currency = 'UGX',
    required this.status,
    required this.method,
    required this.timestamp,
    required this.providerReference,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    invoiceId,
    amount,
    currency,
    status,
    method,
    timestamp,
    providerReference,
    metadata,
  ];
}

class Invoice extends Equatable {
  final String id;
  final String schoolId;
  final String schoolName;
  final String planId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidAt;
  final PaymentStatus status;
  final String billingPeriod; // e.g., "Term 1 2024" or "Year 2024"

  const Invoice({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.planId,
    required this.amount,
    required this.dueDate,
    this.paidAt,
    required this.status,
    required this.billingPeriod,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    schoolName,
    planId,
    amount,
    dueDate,
    paidAt,
    status,
    billingPeriod,
  ];
}
