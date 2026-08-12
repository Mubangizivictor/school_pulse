import 'package:equatable/equatable.dart';

enum SchoolStatus { active, suspended, trial, archived }

/// Broad institution classification. Descriptive only — never restricts
/// which modules or features an institution can enable. [other] pairs with
/// [School.classificationOther] for a free-text label when nothing here fits.
enum InstitutionClassification {
  kindergarten,
  primary,
  secondary,
  combined,
  vocational,
  technicalInstitute,
  college,
  university,
  specialNeeds,
  trainingCentre,
  multiCampus,
  other,
}

/// A configurable education division within one institution tenant
/// (e.g. "Kindergarten", "Undergraduate"). Divisions are admin-curated and
/// bounded in number, so they're embedded on the School doc rather than
/// stored as a separate collection.
class InstitutionDivision extends Equatable {
  final String id;
  final String name;
  final InstitutionClassification levelHint;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const InstitutionDivision({
    required this.id,
    required this.name,
    this.levelHint = InstitutionClassification.other,
    this.isActive = true,
    this.metadata = const {},
  });

  InstitutionDivision copyWith({
    String? name,
    InstitutionClassification? levelHint,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return InstitutionDivision(
      id: id,
      name: name ?? this.name,
      levelHint: levelHint ?? this.levelHint,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, name, levelHint, isActive, metadata];
}

class School extends Equatable {
  final String id;
  final String name;
  final String tenantId;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final SchoolStatus status;
  final String subscriptionPlanId;
  final DateTime createdAt;
  final DateTime subscriptionExpiry;
  final List<String> enabledFeatures;
  final Map<String, dynamic> metadata;
  final InstitutionClassification classification;
  final String? classificationOther;
  final List<InstitutionDivision> divisions;
  final String? displayLabel;

  /// Server-written subscription access state ('full' | 'readOnly' |
  /// 'blocked'). Null on schools not yet touched by the Cloud Functions that
  /// write it (payment approval, hourly lifecycle sweep) - callers should
  /// treat null the same way [AccessMode.fromRaw] does, not assume 'full'
  /// blindly at every call site.
  final String? accessMode;

  const School({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.status = SchoolStatus.trial,
    required this.subscriptionPlanId,
    required this.createdAt,
    required this.subscriptionExpiry,
    this.enabledFeatures = const [],
    this.metadata = const {},
    this.classification = InstitutionClassification.other,
    this.classificationOther,
    this.divisions = const [],
    this.displayLabel,
    this.accessMode,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    tenantId,
    address,
    contactEmail,
    contactPhone,
    status,
    subscriptionPlanId,
    createdAt,
    subscriptionExpiry,
    enabledFeatures,
    metadata,
    classification,
    classificationOther,
    divisions,
    displayLabel,
    accessMode,
  ];

  School copyWith({
    String? name,
    String? address,
    String? contactEmail,
    String? contactPhone,
    SchoolStatus? status,
    String? subscriptionPlanId,
    DateTime? subscriptionExpiry,
    List<String>? enabledFeatures,
    Map<String, dynamic>? metadata,
    InstitutionClassification? classification,
    String? classificationOther,
    List<InstitutionDivision>? divisions,
    String? displayLabel,
    String? accessMode,
  }) {
    return School(
      id: id,
      name: name ?? this.name,
      tenantId: tenantId,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      createdAt: createdAt,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      metadata: metadata ?? this.metadata,
      classification: classification ?? this.classification,
      classificationOther: classificationOther ?? this.classificationOther,
      divisions: divisions ?? this.divisions,
      displayLabel: displayLabel ?? this.displayLabel,
      accessMode: accessMode ?? this.accessMode,
    );
  }
}
