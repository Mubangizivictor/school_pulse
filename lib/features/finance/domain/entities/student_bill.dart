import 'package:equatable/equatable.dart';
import 'fee_plan.dart';

/// An immutable issued-bill snapshot from `issueStudentBill`
/// (functions/student_fee_billing.js). `issuedTotalUgx` and `lines` are
/// frozen at issuance time and must be rendered exactly as stored - never
/// recomputed against whatever the fee-plan version looks like now.
/// `adjustmentTotalUgx`, `paidTotalUgx`, `balanceUgx`, and `status` are the
/// only fields that change after issuance, and only via
/// applyBillAdjustment/recordStudentPayment/reverseStudentPayment.
class StudentBill extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String status; // open | paid
  final String planId;
  final String planVersionId;
  final String academicYearId;
  final String termId;
  final String classId;
  final int issuedTotalUgx;
  final int paidTotalUgx;
  final int adjustmentTotalUgx;
  final int balanceUgx;
  final List<FeePlanLine> lines;
  final DateTime? issuedAt;

  const StudentBill({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.status,
    required this.planId,
    required this.planVersionId,
    required this.academicYearId,
    required this.termId,
    required this.classId,
    required this.issuedTotalUgx,
    required this.paidTotalUgx,
    required this.adjustmentTotalUgx,
    required this.balanceUgx,
    required this.lines,
    this.issuedAt,
  });

  factory StudentBill.fromJson(String id, Map<String, dynamic> json) {
    final issuedAtRaw = json['issuedAt'];
    return StudentBill(
      id: id,
      schoolId: json['schoolId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      planId: json['planId'] as String? ?? '',
      planVersionId: json['planVersionId'] as String? ?? '',
      academicYearId: json['academicYearId'] as String? ?? '',
      termId: json['termId'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      issuedTotalUgx: (json['issuedTotalUgx'] as num?)?.toInt() ?? 0,
      paidTotalUgx: (json['paidTotalUgx'] as num?)?.toInt() ?? 0,
      adjustmentTotalUgx: (json['adjustmentTotalUgx'] as num?)?.toInt() ?? 0,
      balanceUgx: (json['balanceUgx'] as num?)?.toInt() ?? 0,
      lines: ((json['lines'] as List?) ?? const [])
          .map((l) => FeePlanLine.fromJson((l as Map).cast<String, dynamic>()))
          .toList(),
      // Firestore Timestamp exposes toDate(); tolerate a plain DateTime too
      // (e.g. a fake/in-memory data source used by tests).
      issuedAt: issuedAtRaw == null
          ? null
          : (issuedAtRaw is DateTime ? issuedAtRaw : issuedAtRaw.toDate()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    status,
    planId,
    planVersionId,
    academicYearId,
    termId,
    classId,
    issuedTotalUgx,
    paidTotalUgx,
    adjustmentTotalUgx,
    balanceUgx,
    lines,
    issuedAt,
  ];
}

/// One immutable adjustment record from `applyBillAdjustment` under
/// `.../bills/{billId}/adjustments/{adjustmentId}`.
class BillAdjustment extends Equatable {
  final String id;
  final String billId;
  final String type; // discount | scholarship | waiver
  final int amountUgx;
  final double? percentage;
  final String reason;
  final String? evidenceReference;
  final String approverId;
  final DateTime? createdAt;

  const BillAdjustment({
    required this.id,
    required this.billId,
    required this.type,
    required this.amountUgx,
    this.percentage,
    required this.reason,
    this.evidenceReference,
    required this.approverId,
    this.createdAt,
  });

  factory BillAdjustment.fromJson(String id, Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    return BillAdjustment(
      id: id,
      billId: json['billId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      amountUgx: (json['amountUgx'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble(),
      reason: json['reason'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String?,
      approverId: json['approverId'] as String? ?? '',
      createdAt: createdAtRaw == null
          ? null
          : (createdAtRaw is DateTime ? createdAtRaw : createdAtRaw.toDate()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    billId,
    type,
    amountUgx,
    percentage,
    reason,
    evidenceReference,
    approverId,
    createdAt,
  ];
}

/// One immutable payment (or reversal) record from `recordStudentPayment`/
/// `reverseStudentPayment` under `.../bills/{billId}/payments/{paymentId}`.
/// A reversal is its own record with a negative [amountUgx] and
/// [reversalOfPaymentId] set - the original record's money fields are never
/// mutated, only [reversedByPaymentId]/[reversedAt] are added to it.
class StudentPayment extends Equatable {
  final String id;
  final String billId;
  final String status; // recorded | reversal
  final String method; // cash | mobile_money | bank_transfer
  final int amountUgx;
  final String? referenceNumber;
  final String? payerName;
  final String? payerGuardianId;
  final String receiptNumber;
  final String recordedBy;
  final DateTime? recordedAt;
  final String? reversalOfPaymentId;
  final String? reversedByPaymentId;
  final DateTime? reversedAt;
  final String? amountInWords;
  final String? qrVerificationUrl;
  final String? sourcePendingPaymentId;

  const StudentPayment({
    required this.id,
    required this.billId,
    required this.status,
    required this.method,
    required this.amountUgx,
    this.referenceNumber,
    this.payerName,
    this.payerGuardianId,
    required this.receiptNumber,
    required this.recordedBy,
    this.recordedAt,
    this.reversalOfPaymentId,
    this.reversedByPaymentId,
    this.reversedAt,
    this.amountInWords,
    this.qrVerificationUrl,
    this.sourcePendingPaymentId,
  });

  bool get isReversal => status == 'reversal';
  bool get isReversed => reversedByPaymentId != null;

  factory StudentPayment.fromJson(String id, Map<String, dynamic> json) {
    final recordedAtRaw = json['recordedAt'];
    final reversedAtRaw = json['reversedAt'];
    return StudentPayment(
      id: id,
      billId: json['billId'] as String? ?? '',
      status: json['status'] as String? ?? 'recorded',
      method: json['method'] as String? ?? '',
      amountUgx: (json['amountUgx'] as num?)?.toInt() ?? 0,
      referenceNumber: json['referenceNumber'] as String?,
      payerName: json['payerName'] as String?,
      payerGuardianId: json['payerGuardianId'] as String?,
      receiptNumber: json['receiptNumber'] as String? ?? '',
      recordedBy: json['recordedBy'] as String? ?? '',
      recordedAt: recordedAtRaw == null
          ? null
          : (recordedAtRaw is DateTime
                ? recordedAtRaw
                : recordedAtRaw.toDate()),
      reversalOfPaymentId: json['reversalOfPaymentId'] as String?,
      reversedByPaymentId: json['reversalPaymentId'] as String?,
      reversedAt: reversedAtRaw == null
          ? null
          : (reversedAtRaw is DateTime
                ? reversedAtRaw
                : reversedAtRaw.toDate()),
      amountInWords: json['amountInWords'] as String?,
      qrVerificationUrl: json['qrVerificationUrl'] as String?,
      sourcePendingPaymentId: json['sourcePendingPaymentId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    billId,
    status,
    method,
    amountUgx,
    referenceNumber,
    payerName,
    payerGuardianId,
    receiptNumber,
    recordedBy,
    recordedAt,
    reversalOfPaymentId,
    reversedByPaymentId,
    reversedAt,
    amountInWords,
    qrVerificationUrl,
    sourcePendingPaymentId,
  ];
}
