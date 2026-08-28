import 'package:equatable/equatable.dart';

/// A reconciliation-queue entry from `schools/{schoolId}/pending_payments`
/// (`functions/payment_codes.js`). Never auto-confirmed - a parent's "I've
/// paid" claim or a provider/bank-feed webhook (once connected) both land
/// here as evidence, and only a bursar's `confirmPendingPayment`/
/// `rejectPendingPayment` call moves it to a real, receipted payment.
class PendingPayment extends Equatable {
  final String id;
  final String studentId;
  final String paymentCode;
  final String channel; // mtn_momo | airtel_money | bank | other
  final String? providerTransactionId;
  final int amountUgx;
  final String? claimedByParentUid;
  final String? evidenceRef;
  final String status; // pending | confirmed | rejected
  final String? resultingPaymentId;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const PendingPayment({
    required this.id,
    required this.studentId,
    required this.paymentCode,
    required this.channel,
    this.providerTransactionId,
    required this.amountUgx,
    this.claimedByParentUid,
    this.evidenceRef,
    required this.status,
    this.resultingPaymentId,
    this.rejectionReason,
    this.createdAt,
    this.resolvedAt,
  });

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory PendingPayment.fromJson(String id, Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final resolvedAtRaw = json['resolvedAt'];
    return PendingPayment(
      id: id,
      studentId: json['studentId'] as String? ?? '',
      paymentCode: json['paymentCode'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      providerTransactionId: json['providerTransactionId'] as String?,
      amountUgx: (json['amountUgx'] as num?)?.toInt() ?? 0,
      claimedByParentUid: json['claimedByParentUid'] as String?,
      evidenceRef: json['evidenceRef'] as String?,
      status: json['status'] as String? ?? 'pending',
      resultingPaymentId: json['resultingPaymentId'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: createdAtRaw == null
          ? null
          : (createdAtRaw is DateTime ? createdAtRaw : createdAtRaw.toDate()),
      resolvedAt: resolvedAtRaw == null
          ? null
          : (resolvedAtRaw is DateTime
                ? resolvedAtRaw
                : resolvedAtRaw.toDate()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    paymentCode,
    channel,
    providerTransactionId,
    amountUgx,
    claimedByParentUid,
    evidenceRef,
    status,
    resultingPaymentId,
    rejectionReason,
    createdAt,
    resolvedAt,
  ];
}
