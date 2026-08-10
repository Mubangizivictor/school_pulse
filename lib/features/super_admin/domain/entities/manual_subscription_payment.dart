import 'package:equatable/equatable.dart';

enum ManualPaymentStatus { pendingVerification, approved, rejected }

enum ManualPaymentMethod { mtn, bank }

enum ManualPaymentType { activation, renewal }

class ManualSubscriptionPayment extends Equatable {
  const ManualSubscriptionPayment({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.planId,
    required this.planName,
    required this.paymentType,
    required this.expectedAmount,
    required this.submittedAmount,
    required this.currency,
    required this.method,
    required this.payerName,
    required this.reference,
    required this.paidAt,
    required this.submittedAt,
    required this.status,
    required this.hasProof,
    this.note,
    this.rejectionReason,
    this.reviewedAt,
  });

  final String id;
  final String schoolId;
  final String schoolName;
  final String planId;
  final String planName;
  final ManualPaymentType paymentType;
  final int expectedAmount;
  final int submittedAmount;
  final String currency;
  final ManualPaymentMethod method;
  final String payerName;
  final String reference;
  final DateTime paidAt;
  final DateTime submittedAt;
  final ManualPaymentStatus status;
  final bool hasProof;
  final String? note;
  final String? rejectionReason;
  final DateTime? reviewedAt;

  bool get amountMatches => expectedAmount == submittedAmount;

  factory ManualSubscriptionPayment.fromJson(Map<String, dynamic> json) {
    DateTime date(Object? value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    DateTime? nullableDate(Object? value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    final rawStatus = json['status']?.toString() ?? 'pending_verification';
    final rawMethod = json['method']?.toString() ?? 'mtn';
    final rawType = json['paymentType']?.toString() ?? 'activation';

    return ManualSubscriptionPayment(
      id: json['id']?.toString() ?? '',
      schoolId: json['schoolId']?.toString() ?? '',
      schoolName: json['schoolName']?.toString() ?? 'Unknown school',
      planId: json['planId']?.toString() ?? '',
      planName: json['planName']?.toString() ?? 'School Pulse plan',
      paymentType: rawType == 'renewal'
          ? ManualPaymentType.renewal
          : ManualPaymentType.activation,
      expectedAmount: (json['expectedAmount'] as num?)?.round() ?? 0,
      submittedAmount: (json['submittedAmount'] as num?)?.round() ?? 0,
      currency: json['currency']?.toString() ?? 'UGX',
      method: rawMethod == 'bank'
          ? ManualPaymentMethod.bank
          : ManualPaymentMethod.mtn,
      payerName: json['payerName']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      paidAt: date(json['paidAt']),
      submittedAt: date(json['submittedAt']),
      status: switch (rawStatus) {
        'approved' => ManualPaymentStatus.approved,
        'rejected' => ManualPaymentStatus.rejected,
        _ => ManualPaymentStatus.pendingVerification,
      },
      hasProof: json['hasProof'] == true,
      note: json['note']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      reviewedAt: nullableDate(json['reviewedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    schoolName,
    planId,
    planName,
    paymentType,
    expectedAmount,
    submittedAmount,
    currency,
    method,
    payerName,
    reference,
    paidAt,
    submittedAt,
    status,
    hasProof,
    note,
    rejectionReason,
    reviewedAt,
  ];
}
