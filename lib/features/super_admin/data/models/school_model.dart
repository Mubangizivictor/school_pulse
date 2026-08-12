import '../../domain/entities/school.dart';

class SchoolModel extends School {
  const SchoolModel({
    required super.id,
    required super.name,
    required super.tenantId,
    required super.address,
    required super.contactEmail,
    required super.contactPhone,
    super.status,
    required super.subscriptionPlanId,
    required super.createdAt,
    required super.subscriptionExpiry,
    super.enabledFeatures,
    super.metadata,
    super.classification,
    super.classificationOther,
    super.divisions,
    super.displayLabel,
    super.accessMode,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      tenantId: json['tenantId'] ?? '',
      address: json['address'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      status: SchoolStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SchoolStatus.trial,
      ),
      subscriptionPlanId: json['subscriptionPlanId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['subscriptionExpiry'])
          : DateTime.now(),
      enabledFeatures: List<String>.from(json['enabledFeatures'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      classification: InstitutionClassification.values.firstWhere(
        (e) => e.name == json['classification'],
        orElse: () => InstitutionClassification.other,
      ),
      classificationOther: json['classificationOther'] as String?,
      divisions: (json['divisions'] as List<dynamic>? ?? [])
          .map((d) => _divisionFromJson(Map<String, dynamic>.from(d as Map)))
          .toList(),
      displayLabel: json['displayLabel'] as String?,
      accessMode: json['accessMode'] as String?,
    );
  }

  static InstitutionDivision _divisionFromJson(Map<String, dynamic> json) {
    return InstitutionDivision(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      levelHint: InstitutionClassification.values.firstWhere(
        (e) => e.name == json['levelHint'],
        orElse: () => InstitutionClassification.other,
      ),
      isActive: json['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  static Map<String, dynamic> _divisionToJson(InstitutionDivision d) {
    return {
      'id': d.id,
      'name': d.name,
      'levelHint': d.levelHint.name,
      'isActive': d.isActive,
      'metadata': d.metadata,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tenantId': tenantId,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'status': status.toString().split('.').last,
      'subscriptionPlanId': subscriptionPlanId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'subscriptionExpiry': subscriptionExpiry.millisecondsSinceEpoch,
      'enabledFeatures': enabledFeatures,
      'metadata': metadata,
      'classification': classification.name,
      'classificationOther': classificationOther,
      'divisions': divisions.map(_divisionToJson).toList(),
      'displayLabel': displayLabel,
      if (accessMode != null) 'accessMode': accessMode,
    };
  }
}
