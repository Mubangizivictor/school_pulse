import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PaymentAttemptStatus {
  created,
  pending,
  successful,
  failed,
  expired,
  cancelled,
  unknown,
}

class PaymentAttempt extends Equatable {
  const PaymentAttempt({
    required this.id,
    required this.status,
    required this.realPlanPriceUgx,
    required this.planName,
    required this.currency,
    required this.amount,
    required this.targetEnvironment,
    required this.createdAt,
    this.failureReason,
    this.settledAt,
    this.subscriptionExpiry,
  });

  final String id;
  final PaymentAttemptStatus status;
  final int realPlanPriceUgx;
  final String planName;
  final String currency;
  final num amount;
  final String targetEnvironment;
  final DateTime createdAt;
  final String? failureReason;
  final DateTime? settledAt;
  final DateTime? subscriptionExpiry;

  bool get isSandbox => targetEnvironment == 'sandbox';

  bool get isTerminal =>
      status == PaymentAttemptStatus.successful ||
      status == PaymentAttemptStatus.failed ||
      status == PaymentAttemptStatus.expired ||
      status == PaymentAttemptStatus.cancelled;

  factory PaymentAttempt.fromMap(String id, Map<String, dynamic> data) {
    DateTime? dateFrom(Object? value) {
      if (value is Timestamp) return value.toDate();
      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.round());
      }
      return null;
    }

    return PaymentAttempt(
      id: id,
      status: switch (data['status']?.toString()) {
        'CREATED' => PaymentAttemptStatus.created,
        'PENDING' => PaymentAttemptStatus.pending,
        'SUCCESSFUL' => PaymentAttemptStatus.successful,
        'FAILED' => PaymentAttemptStatus.failed,
        'EXPIRED' => PaymentAttemptStatus.expired,
        'CANCELLED' => PaymentAttemptStatus.cancelled,
        _ => PaymentAttemptStatus.unknown,
      },
      realPlanPriceUgx: (data['realPlanPriceUgx'] as num?)?.round() ?? 0,
      planName: data['planName']?.toString() ?? 'School Pulse plan',
      currency: data['currency']?.toString() ?? 'UGX',
      amount: (data['amount'] is num)
          ? data['amount'] as num
          : num.tryParse(data['amount']?.toString() ?? '') ?? 0,
      targetEnvironment: data['targetEnvironment']?.toString() ?? 'sandbox',
      createdAt: dateFrom(data['createdAt']) ?? DateTime.now(),
      failureReason: data['failureReason']?.toString(),
      settledAt: dateFrom(data['settledAt']),
      subscriptionExpiry: dateFrom(data['subscriptionExpiry']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    realPlanPriceUgx,
    planName,
    currency,
    amount,
    targetEnvironment,
    createdAt,
    failureReason,
    settledAt,
    subscriptionExpiry,
  ];
}
