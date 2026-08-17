import 'package:isar/isar.dart';

part 'verification_isar_models.g.dart';

/// Maps an opaque/physical credential (NFC card UID, QR token, manual
/// code) to the person it identifies. NFC has no prior mapping anywhere
/// in the app - this is the first table that makes a card UID mean
/// anything offline.
@collection
class CachedCredentialIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String credentialValue;

  late String credentialType; // 'qr' | 'nfc' | 'manualCode'
  late String identityId;
  late String identityType; // 'student' | 'staff'
  @Index()
  late String schoolId;
  late String status; // 'active' | 'revoked'
  late DateTime updatedAt;

  /// Defaults to 1 for rows written before this field existed - Isar
  /// leaves newly-added non-nullable int fields at their Dart default (0)
  /// on old rows, so this is set explicitly wherever a CachedCredentialIsar
  /// is constructed rather than relying on that default.
  int credentialVersion = 1;
}

/// Denylist checked before `CachedCredentialIsar`, so a credential revoked
/// before this device last synced is still rejected offline even if it
/// was never cached locally.
@collection
class RevokedCredentialIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String credentialValue;

  @Index()
  late String schoolId;
  late DateTime revokedAt;
  late String reason;
}

/// The engine's own audit trail - why a scan was allowed/denied - and the
/// offline sync queue for that trail. Distinct from
/// `StudentMovementIsar`/`StaffMovementIsar`, which remain the system of
/// record for the movement itself.
@collection
class VerificationEventIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String eventId;

  @Index()
  late String schoolId;
  @Index()
  late String gateId;
  late String operatorId;
  late String credentialKind;
  late String identityId;
  late String identityType;
  late String outcome;
  String? reasonCode;
  late String direction;
  @Index()
  late DateTime timestamp;
  late String deviceId;
  @Index()
  late bool isSynced;
}

/// Minimal offline device-authorization check. `DeviceIdService` only
/// generates a device id today - it never validates whether that device
/// is allowed to run verification for a given gate/school.
@collection
class AuthorizedDeviceIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String deviceId;

  @Index()
  late String schoolId;
  String? gateId;
  late String label;
  late bool isActive;
  late DateTime registeredAt;
}

/// A cached, versioned snapshot of an operator's resolved permission set,
/// so `PermissionEvaluator` keeps working through a connectivity drop
/// mid-shift instead of locking the gatekeeper out.
@collection
class OperatorPermissionSnapshotIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String operatorId;

  late String schoolId;
  late List<String> permissionIds;
  late int version;
  late DateTime expiresAt;
}
