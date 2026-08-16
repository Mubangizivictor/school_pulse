enum InstitutionPolicyType {
  attendance,
  parentPortal,
  studentPortal,
  reportRelease,
  financeAccess,
  messaging,
  notifications,
  visitorSecurity,
  boarding,
  transport,
  healthPrivacy,
  dataRetention,
  security,
  biometrics,
  googleSheets,
}

enum PolicyStatus { draft, active, scheduled, superseded, archived }

enum PolicyScopeType {
  institution,
  campus,
  division,
  department,
  programme,
  residentialUnit,
  custom,
}

class PolicyScope {
  final PolicyScopeType type;
  final String? targetId;
  const PolicyScope({this.type = PolicyScopeType.institution, this.targetId});
  Map<String, dynamic> toMap() => {
    'type': type.name,
    if (targetId != null) 'targetId': targetId,
  };
  factory PolicyScope.fromMap(Map<String, dynamic> map) => PolicyScope(
    type: PolicyScopeType.values.byName(
      map['type'] as String? ?? 'institution',
    ),
    targetId: map['targetId'] as String?,
  );
}

/// A versioned, tenant-owned policy envelope. Individual modules interpret
/// only their typed policy type and never need to recreate scope precedence.
class InstitutionPolicy {
  final String id, institutionId, name, createdBy, updatedBy, changeReason;
  final InstitutionPolicyType type;
  final PolicyScope scope;
  final Map<String, dynamic> configuration;
  final PolicyStatus status;
  final int version;
  final DateTime effectiveFrom, createdAt, updatedAt;
  final DateTime? effectiveTo;
  const InstitutionPolicy({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.createdBy,
    required this.updatedBy,
    required this.changeReason,
    required this.type,
    required this.scope,
    required this.configuration,
    required this.status,
    required this.version,
    required this.effectiveFrom,
    required this.createdAt,
    required this.updatedAt,
    this.effectiveTo,
  });
  Map<String, dynamic> toMap() => {
    'institutionId': institutionId,
    'policyType': type.name,
    'policyName': name,
    'scope': scope.toMap(),
    'configuration': configuration,
    'status': status.name,
    'version': version,
    'effectiveFrom': effectiveFrom,
    if (effectiveTo != null) 'effectiveTo': effectiveTo,
    'createdBy': createdBy,
    'updatedBy': updatedBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'changeReason': changeReason,
  };
}
