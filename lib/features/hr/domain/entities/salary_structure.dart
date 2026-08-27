import 'package:equatable/equatable.dart';

/// A single pay-component line inside a published salary-structure version.
/// All money is integer UGX - mirrors `FeePlanLine`'s validation contract in
/// `functions/staff_payroll_structure.js`'s `asMoney`.
class SalaryStructureLine extends Equatable {
  final String componentId;
  final String name;
  final int amountUgx;
  final bool required;
  final String? componentKey;

  const SalaryStructureLine({
    required this.componentId,
    required this.name,
    required this.amountUgx,
    this.required = true,
    this.componentKey,
  });

  Map<String, dynamic> toJson() => {
    'componentId': componentId,
    'name': name,
    'amountUgx': amountUgx,
    'required': required,
    if (componentKey != null) 'componentKey': componentKey,
  };

  factory SalaryStructureLine.fromJson(Map<String, dynamic> json) =>
      SalaryStructureLine(
        componentId: json['componentId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amountUgx: (json['amountUgx'] as num?)?.toInt() ?? 0,
        required: json['required'] as bool? ?? true,
        componentKey: json['componentKey'] as String?,
      );

  @override
  List<Object?> get props => [
    componentId,
    name,
    amountUgx,
    required,
    componentKey,
  ];
}

/// Selector fields a published salary structure is uniquely keyed by -
/// mirrors `FeePlanSelector`, but keyed on staff designation rather than
/// class/term, since pay grades are set per role, not per academic period.
class SalaryStructureSelector extends Equatable {
  final String designationId;

  const SalaryStructureSelector({required this.designationId});

  factory SalaryStructureSelector.fromJson(Map<String, dynamic> json) =>
      SalaryStructureSelector(
        designationId: json['designationId'] as String? ?? '',
      );

  @override
  List<Object?> get props => [designationId];
}

/// The parent `schools/{schoolId}/salary_structures/{structureId}` document -
/// mirrors `FeePlan`.
class SalaryStructure extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final SalaryStructureSelector selector;
  final String status;
  final int latestVersion;
  final String? currentVersionId;

  const SalaryStructure({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.selector,
    required this.status,
    required this.latestVersion,
    this.currentVersionId,
  });

  factory SalaryStructure.fromJson(String id, Map<String, dynamic> json) =>
      SalaryStructure(
        id: id,
        schoolId: json['schoolId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        selector: SalaryStructureSelector.fromJson(
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

/// One immutable published snapshot under `salary_structures/{id}/versions`.
class SalaryStructureVersion extends Equatable {
  final String id;
  final String structureId;
  final int version;
  final List<SalaryStructureLine> lines;
  final int totalUgx;

  const SalaryStructureVersion({
    required this.id,
    required this.structureId,
    required this.version,
    required this.lines,
    required this.totalUgx,
  });

  factory SalaryStructureVersion.fromJson(
    String id,
    Map<String, dynamic> json,
  ) => SalaryStructureVersion(
    id: id,
    structureId: json['structureId'] as String? ?? '',
    version: (json['version'] as num?)?.toInt() ?? 0,
    lines: ((json['lines'] as List?) ?? const [])
        .map(
          (l) => SalaryStructureLine.fromJson((l as Map).cast<String, dynamic>()),
        )
        .toList(),
    totalUgx: (json['totalUgx'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [id, structureId, version, lines, totalUgx];
}

/// Result of the `findMatchingSalaryStructure` callable - null when no
/// published structure matches the staff member's designation, in which
/// case pay setup must be treated as pending rather than falling back to a
/// client-supplied amount.
class MatchedSalaryStructure extends Equatable {
  final String structureId;
  final String versionId;
  final String name;
  final int totalUgx;
  final List<SalaryStructureLine> lines;

  const MatchedSalaryStructure({
    required this.structureId,
    required this.versionId,
    required this.name,
    required this.totalUgx,
    required this.lines,
  });

  factory MatchedSalaryStructure.fromJson(Map<String, dynamic> json) =>
      MatchedSalaryStructure(
        structureId: json['structureId'] as String? ?? '',
        versionId: json['versionId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        totalUgx: (json['totalUgx'] as num?)?.toInt() ?? 0,
        lines: ((json['lines'] as List?) ?? const [])
            .map(
              (l) => SalaryStructureLine.fromJson(
                (l as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );

  @override
  List<Object?> get props => [structureId, versionId, name, totalUgx, lines];
}
