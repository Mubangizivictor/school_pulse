import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';

/// Firestore mapping for [SubscriptionCycle]. Read-only from the client -
/// `subscription_cycles` docs are written exclusively by Cloud Functions
/// (functions/academic_calendar_billing.js confirmAcademicCalendar and
/// public_functions/subscription_cycle_billing.js), so this model only ever
/// needs `fromFirestore`; there is no `toJson`/write path here.
class SubscriptionCycleModel extends SubscriptionCycle {
  const SubscriptionCycleModel({
    required super.id,
    required super.schoolId,
    required super.subscriptionId,
    required super.academicYearId,
    required super.termId,
    required super.termNumber,
    required super.termStart,
    required super.termEnd,
    super.invoiceIssuedAt,
    required super.paymentDueAt,
    required super.graceEndsAt,
    super.planSnapshot,
    super.pricingSnapshot,
    super.pricingReviewRequired,
    super.pricingReviewReason,
    super.discountSnapshot,
    super.paymentStatus,
    super.cycleStatus,
    super.createdAt,
    super.updatedAt,
  });

  factory SubscriptionCycleModel.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    // planSnapshot: best-effort/nullable - only ever present on cycles
    // generated before Phase 3A's pricing-band engine. Parsing it into
    // empty-string placeholders when absent would make "no plan data"
    // indistinguishable from "a plan with blank fields", so we simply don't
    // build one when the key is missing.
    final planSnapshotJson = json['planSnapshot'];
    final planSnapshot = planSnapshotJson is Map
        ? SubscriptionPlanSnapshot(
            planId: planSnapshotJson['planId'] ?? '',
            planName: planSnapshotJson['planName'] ?? '',
            features: List<String>.from(
              planSnapshotJson['features'] ?? const [],
            ),
            price: (planSnapshotJson['price'] ?? 0).toDouble(),
            currency: planSnapshotJson['currency'] ?? 'UGX',
          )
        : null;

    final pricingSnapshotJson = json['pricingSnapshot'];
    final pricingSnapshot = pricingSnapshotJson is Map
        ? StudentPricingSnapshot(
            bandId: pricingSnapshotJson['bandId']?.toString() ?? '',
            minStudents: ((pricingSnapshotJson['minStudents'] ?? 0) as num)
                .toInt(),
            maxStudents: pricingSnapshotJson['maxStudents'] == null
                ? null
                : (pricingSnapshotJson['maxStudents'] as num).toInt(),
            amountUgx: ((pricingSnapshotJson['amountUgx'] ?? 0) as num)
                .toInt(),
            currency: pricingSnapshotJson['currency']?.toString() ?? 'UGX',
            verifiedStudentCount:
                ((pricingSnapshotJson['verifiedStudentCount'] ?? 0) as num)
                    .toInt(),
            countedAt:
                _parseDate(pricingSnapshotJson['countedAt']) ?? DateTime.now(),
          )
        : null;

    return SubscriptionCycleModel(
      id: id,
      schoolId: json['schoolId'] ?? '',
      subscriptionId: json['subscriptionId'] ?? '',
      academicYearId: json['academicYearId'] ?? '',
      termId: json['termId'] ?? '',
      termNumber: (json['termNumber'] ?? 0) as int,
      termStart: _parseDate(json['termStart']) ?? DateTime.now(),
      termEnd: _parseDate(json['termEnd']) ?? DateTime.now(),
      invoiceIssuedAt: _parseDate(json['invoiceIssuedAt']),
      paymentDueAt: _parseDate(json['paymentDueAt']) ?? DateTime.now(),
      graceEndsAt: _parseDate(json['graceEndsAt']) ?? DateTime.now(),
      planSnapshot: planSnapshot,
      pricingSnapshot: pricingSnapshot,
      pricingReviewRequired: json['pricingReviewRequired'] == true,
      pricingReviewReason: json['pricingReviewReason']?.toString(),
      discountSnapshot: json['discountSnapshot'] is Map
          ? Map<String, dynamic>.from(json['discountSnapshot'] as Map)
          : null,
      paymentStatus: SubscriptionCyclePaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => SubscriptionCyclePaymentStatus.unpaid,
      ),
      cycleStatus: SubscriptionCycleStatus.values.firstWhere(
        (e) => e.name == json['cycleStatus'],
        orElse: () => SubscriptionCycleStatus.upcoming,
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
