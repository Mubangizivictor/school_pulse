import 'package:equatable/equatable.dart';

/// A single charge line inside a published fee-plan version. All money is
/// integer UGX - see `functions/student_fee_billing.js`'s `asMoney`
/// validator, which rejects anything that isn't a non-negative safe integer.
class FeePlanLine extends Equatable {
  final String chargeId;
  final String name;
  final int amountUgx;
  final bool required;
  final String? serviceKey;

  const FeePlanLine({
    required this.chargeId,
    required this.name,
    required this.amountUgx,
    this.required = true,
    this.serviceKey,
  });

  Map<String, dynamic> toJson() => {
    'chargeId': chargeId,
    'name': name,
    'amountUgx': amountUgx,
    'required': required,
    if (serviceKey != null) 'serviceKey': serviceKey,
  };

  factory FeePlanLine.fromJson(Map<String, dynamic> json) => FeePlanLine(
    chargeId: json['chargeId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    amountUgx: (json['amountUgx'] as num?)?.toInt() ?? 0,
    required: json['required'] as bool? ?? true,
    serviceKey: json['serviceKey'] as String?,
  );

  FeePlanLine copyWith({
    String? chargeId,
    String? name,
    int? amountUgx,
    bool? required,
    String? serviceKey,
  }) => FeePlanLine(
    chargeId: chargeId ?? this.chargeId,
    name: name ?? this.name,
    amountUgx: amountUgx ?? this.amountUgx,
    required: required ?? this.required,
    serviceKey: serviceKey ?? this.serviceKey,
  );

  @override
  List<Object?> get props => [chargeId, name, amountUgx, required, serviceKey];
}

/// selector fields a published plan is uniquely keyed by. Mirrors the
/// backend's `selector` object exactly (see `publishFeePlan`).
class FeePlanSelector extends Equatable {
  final String academicYearId;
  final String termId;
  final String classId;
  final String studentCategory;

  const FeePlanSelector({
    required this.academicYearId,
    required this.termId,
    required this.classId,
    required this.studentCategory,
  });

  factory FeePlanSelector.fromJson(Map<String, dynamic> json) =>
      FeePlanSelector(
        academicYearId: json['academicYearId'] as String? ?? '',
        termId: json['termId'] as String? ?? '',
        classId: json['classId'] as String? ?? '',
        studentCategory: json['studentCategory'] as String? ?? '',
      );

  @override
  List<Object?> get props => [academicYearId, termId, classId, studentCategory];
}

/// The parent `schools/{schoolId}/fee_plans/{planId}` document - the
/// mutable "pointer" that tracks which version is currently published.
/// Individual versions (see [FeePlanVersion]) are immutable once created.
class FeePlan extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final FeePlanSelector selector;

  /// draft | published | archived. "draft" is a client-side-only concept in
  /// Phase 1 (nothing is written to Firestore until Publish is pressed);
  /// "published" and "archived" are real statuses on the Firestore doc.
  final String status;
  final int latestVersion;
  final String? currentVersionId;

  const FeePlan({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.selector,
    required this.status,
    required this.latestVersion,
    this.currentVersionId,
  });

  factory FeePlan.fromJson(String id, Map<String, dynamic> json) => FeePlan(
    id: id,
    schoolId: json['schoolId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    selector: FeePlanSelector.fromJson(
      (json['selector'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    status: json['status'] as String? ?? 'draft',
    latestVersion: (json['latestVersion'] as num?)?.toInt() ?? 0,
    currentVersionId: json['currentVersionId'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    selector,
    status,
    latestVersion,
    currentVersionId,
  ];
}

/// One immutable published snapshot under `fee_plans/{planId}/versions`.
class FeePlanVersion extends Equatable {
  final String id;
  final String planId;
  final int version;
  final List<FeePlanLine> lines;
  final int totalUgx;

  const FeePlanVersion({
    required this.id,
    required this.planId,
    required this.version,
    required this.lines,
    required this.totalUgx,
  });

  factory FeePlanVersion.fromJson(String id, Map<String, dynamic> json) =>
      FeePlanVersion(
        id: id,
        planId: json['planId'] as String? ?? '',
        version: (json['version'] as num?)?.toInt() ?? 0,
        lines: ((json['lines'] as List?) ?? const [])
            .map((l) => FeePlanLine.fromJson((l as Map).cast<String, dynamic>()))
            .toList(),
        totalUgx: (json['totalUgx'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [id, planId, version, lines, totalUgx];
}

/// Result of the `findMatchingFeePlan` callable - null when no published
/// plan matches, in which case the caller must treat billing as pending
/// rather than falling back to any client-supplied amount.
class MatchedFeePlan extends Equatable {
  final String planId;
  final String versionId;
  final String name;
  final int totalUgx;
  final List<FeePlanLine> lines;

  const MatchedFeePlan({
    required this.planId,
    required this.versionId,
    required this.name,
    required this.totalUgx,
    required this.lines,
  });

  factory MatchedFeePlan.fromJson(Map<String, dynamic> json) =>
      MatchedFeePlan(
        planId: json['planId'] as String? ?? '',
        versionId: json['versionId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        totalUgx: (json['totalUgx'] as num?)?.toInt() ?? 0,
        lines: ((json['lines'] as List?) ?? const [])
            .map((l) => FeePlanLine.fromJson((l as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  List<Object?> get props => [planId, versionId, name, totalUgx, lines];
}
