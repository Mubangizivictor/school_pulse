/// Plain (non-Isar) versions of the verification module's offline cache
/// records. These are the actual "domain" shape for a feature that never
/// had a separate entity layer - the models used to be Isar-annotated
/// directly (see verification_isar_models.dart, mobile-only now). Kept
/// mutable to match the existing call sites, which mutate fields in place
/// (e.g. `existing.status = 'revoked'`) rather than reconstructing.

class CachedCredential {
  String credentialValue;
  String credentialType; // 'qr' | 'nfc' | 'manualCode'
  String identityId;
  String identityType; // 'student' | 'staff'
  String schoolId;
  String status; // 'active' | 'revoked'
  DateTime updatedAt;

  CachedCredential({
    required this.credentialValue,
    required this.credentialType,
    required this.identityId,
    required this.identityType,
    required this.schoolId,
    required this.status,
    required this.updatedAt,
  });
}

class RevokedCredential {
  String credentialValue;
  String schoolId;
  DateTime revokedAt;
  String reason;

  RevokedCredential({
    required this.credentialValue,
    required this.schoolId,
    required this.revokedAt,
    required this.reason,
  });
}

class VerificationEvent {
  String eventId;
  String schoolId;
  String gateId;
  String operatorId;
  String credentialKind;
  String identityId;
  String identityType;
  String outcome;
  String? reasonCode;
  String direction;
  DateTime timestamp;
  String deviceId;
  bool isSynced;

  VerificationEvent({
    required this.eventId,
    required this.schoolId,
    required this.gateId,
    required this.operatorId,
    required this.credentialKind,
    required this.identityId,
    required this.identityType,
    required this.outcome,
    this.reasonCode,
    required this.direction,
    required this.timestamp,
    required this.deviceId,
    required this.isSynced,
  });
}

class AuthorizedDevice {
  String deviceId;
  String schoolId;
  String? gateId;
  String label;
  bool isActive;
  DateTime registeredAt;

  AuthorizedDevice({
    required this.deviceId,
    required this.schoolId,
    this.gateId,
    required this.label,
    required this.isActive,
    required this.registeredAt,
  });
}

class OperatorPermissionSnapshot {
  String operatorId;
  String schoolId;
  List<String> permissionIds;
  int version;
  DateTime expiresAt;

  OperatorPermissionSnapshot({
    required this.operatorId,
    required this.schoolId,
    required this.permissionIds,
    required this.version,
    required this.expiresAt,
  });
}
