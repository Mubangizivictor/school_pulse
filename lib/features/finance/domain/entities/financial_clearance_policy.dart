import 'package:equatable/equatable.dart';

/// The per-school financial-clearance policy (the `financialClearance` map on
/// `schools/{id}/configs/reportReleasePolicy`). Read via
/// `getReportCardClearancePolicy`, written via `saveReportCardClearancePolicy`
/// - never a direct Firestore write, so a change is audited and every
/// finalized report is re-materialised server-side.
enum ClearanceMode {
  fullBalance,
  selectedCategories,
  minimumPercentage;

  static ClearanceMode fromId(String? id) => switch (id) {
    'selectedCategories' => ClearanceMode.selectedCategories,
    'minimumPercentage' => ClearanceMode.minimumPercentage,
    _ => ClearanceMode.fullBalance,
  };

  String get id => name;

  String get label => switch (this) {
    ClearanceMode.fullBalance => 'Full balance',
    ClearanceMode.selectedCategories => 'Selected fee categories',
    ClearanceMode.minimumPercentage => 'Minimum percentage paid',
  };

  String get blurb => switch (this) {
    ClearanceMode.fullBalance =>
      'A learner is cleared when the outstanding balance for the term is UGX 0.',
    ClearanceMode.selectedCategories =>
      'A learner is cleared when every selected fee category is fully paid, '
          'regardless of other charges.',
    ClearanceMode.minimumPercentage =>
      'A learner is cleared once at least the configured percentage of the '
          "term's total fees has been paid.",
  };
}

class FinancialClearancePolicy extends Equatable {
  final ClearanceMode mode;
  final List<String> feeCategoryIds;
  final int minimumPercentagePaid; // 1..100
  final bool compulsoryOnly;
  final String restrictionMessage;
  final bool secondApproverRequired;
  final int secondApproverArrearsThresholdUgx;
  final List<String> secondApproverRoles;
  final int defaultExpiryDays; // 0 = no default expiry

  const FinancialClearancePolicy({
    this.mode = ClearanceMode.fullBalance,
    this.feeCategoryIds = const [],
    this.minimumPercentagePaid = 100,
    this.compulsoryOnly = true,
    this.restrictionMessage = defaultRestrictionMessage,
    this.secondApproverRequired = false,
    this.secondApproverArrearsThresholdUgx = 0,
    this.secondApproverRoles = const ['headTeacher', 'director'],
    this.defaultExpiryDays = 0,
  });

  static const String defaultRestrictionMessage =
      'This report card is currently awaiting financial clearance. '
      'Please contact the school bursar for assistance.';

  factory FinancialClearancePolicy.fromMap(Map<String, dynamic> m) =>
      FinancialClearancePolicy(
        mode: ClearanceMode.fromId(m['mode'] as String?),
        feeCategoryIds: ((m['feeCategoryIds'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        minimumPercentagePaid:
            (m['minimumPercentagePaid'] as num?)?.toInt() ?? 100,
        compulsoryOnly: m['compulsoryOnly'] as bool? ?? true,
        restrictionMessage:
            (m['restrictionMessage'] as String?)?.trim().isNotEmpty == true
            ? m['restrictionMessage'] as String
            : defaultRestrictionMessage,
        secondApproverRequired: m['secondApproverRequired'] as bool? ?? false,
        secondApproverArrearsThresholdUgx:
            (m['secondApproverArrearsThresholdUgx'] as num?)?.toInt() ?? 0,
        secondApproverRoles:
            ((m['secondApproverRoles'] as List?) ??
                    const ['headTeacher', 'director'])
                .whereType<String>()
                .toList(),
        defaultExpiryDays: (m['defaultExpiryDays'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'mode': mode.id,
    'feeCategoryIds': feeCategoryIds,
    'minimumPercentagePaid': minimumPercentagePaid,
    'compulsoryOnly': compulsoryOnly,
    'restrictionMessage': restrictionMessage,
    'secondApproverRequired': secondApproverRequired,
    'secondApproverArrearsThresholdUgx': secondApproverArrearsThresholdUgx,
    'secondApproverRoles': secondApproverRoles,
    'defaultExpiryDays': defaultExpiryDays,
  };

  FinancialClearancePolicy copyWith({
    ClearanceMode? mode,
    List<String>? feeCategoryIds,
    int? minimumPercentagePaid,
    bool? compulsoryOnly,
    String? restrictionMessage,
    bool? secondApproverRequired,
    int? secondApproverArrearsThresholdUgx,
    List<String>? secondApproverRoles,
    int? defaultExpiryDays,
  }) => FinancialClearancePolicy(
    mode: mode ?? this.mode,
    feeCategoryIds: feeCategoryIds ?? this.feeCategoryIds,
    minimumPercentagePaid: minimumPercentagePaid ?? this.minimumPercentagePaid,
    compulsoryOnly: compulsoryOnly ?? this.compulsoryOnly,
    restrictionMessage: restrictionMessage ?? this.restrictionMessage,
    secondApproverRequired:
        secondApproverRequired ?? this.secondApproverRequired,
    secondApproverArrearsThresholdUgx:
        secondApproverArrearsThresholdUgx ??
        this.secondApproverArrearsThresholdUgx,
    secondApproverRoles: secondApproverRoles ?? this.secondApproverRoles,
    defaultExpiryDays: defaultExpiryDays ?? this.defaultExpiryDays,
  );

  @override
  List<Object?> get props => [
    mode,
    feeCategoryIds,
    minimumPercentagePaid,
    compulsoryOnly,
    restrictionMessage,
    secondApproverRequired,
    secondApproverArrearsThresholdUgx,
    secondApproverRoles,
    defaultExpiryDays,
  ];
}

/// The stored-doc metadata the editor shows ("in effect since ...").
class ClearancePolicyMeta extends Equatable {
  final DateTime? effectiveFrom;
  final String? updatedByName;
  final DateTime? updatedAt;
  final bool configured;

  const ClearancePolicyMeta({
    this.effectiveFrom,
    this.updatedByName,
    this.updatedAt,
    this.configured = false,
  });

  factory ClearancePolicyMeta.fromMap(Map<String, dynamic> m) =>
      ClearancePolicyMeta(
        effectiveFrom: _millis(m['effectiveFrom']),
        updatedByName: m['updatedByName'] as String?,
        updatedAt: _millis(m['updatedAt']),
        configured: m['configured'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
    effectiveFrom,
    updatedByName,
    updatedAt,
    configured,
  ];
}

DateTime? _millis(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
  return null;
}
