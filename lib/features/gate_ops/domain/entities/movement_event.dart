import 'package:equatable/equatable.dart';

/// The kind of person a [MovementEvent] or [Visitor]-adjacent record
/// concerns. `pickup` is distinct from `student` because a pickup movement
/// carries the picking-up parent's flattened details alongside the child's
/// `personId`.
enum PersonType { student, staff, visitor, pickup }

/// `in_` avoids the Dart `in` keyword; display maps to 'In'/'Out'.
enum MovementDirection { in_, out }

/// Port of the deleted `security/domain/entities/verification_method.dart`
/// enum, unchanged, so `.label` keeps working without ad hoc re-derivation
/// (e.g. `VerificationSessionBloc._verificationMethodLabel` did this today).
enum VerificationMethod {
  qr('qr', 'QR Code'),
  nfc('nfc', 'NFC'),
  manualCode('manual_code', 'Manual Code'),
  staffLookup('staff_lookup', 'Staff Lookup'),
  parentCode('parent_code', 'Parent Code'),
  fingerprint('fingerprint', 'Fingerprint'),
  none('none', 'None');

  final String id;
  final String label;
  const VerificationMethod(this.id, this.label);

  static VerificationMethod? fromId(String id) {
    for (final method in VerificationMethod.values) {
      if (method.id == id) return method;
    }
    return null;
  }
}

enum SyncStatus { pending, synced, failed }

/// The single unified movement-event concept covering student/staff/
/// pickup/visitor entry-exit uniformly, replacing the deleted `security`
/// module's separate `StudentMovement`/`StaffMovement` entities. See plan
/// section 3 for the full field-by-field rationale.
class MovementEvent extends Equatable {
  final String id; // uuid, primary key
  final String schoolId;
  final String? campusId; // reserved, nullable, not populated in Phase 1
  final String gateId;
  final PersonType personType;
  final String
  personId; // studentId / staffId / visitorId (pickup: child's studentId)
  final String personName; // denormalized for offline display without a join
  final MovementDirection direction;
  final String
  movementType; // Arrival/Late Arrival/Departure/Early Departure/Authorized Pickup - computed, not typed
  final VerificationMethod verificationMethod;
  final String officerId; // auto-populated from session
  final String officerRole; // auto-populated from session (denormalized)
  final String deviceId; // auto-populated from device identity
  final String? deviceName; // reserved, nullable Phase 1
  final String platform; // 'ios' | 'android'
  final String appVersion; // from PackageInfo
  final DateTime actionTimestamp; // local device clock at moment of action
  final DateTime?
  serverTimestamp; // set on successful Firestore push, null until synced
  final SyncStatus syncStatus;
  final String?
  pickupParentCode; // flattened pickup details, only when personType==pickup
  final String? pickupParentName;
  final String? pickupPhoneNumber;

  const MovementEvent({
    required this.id,
    required this.schoolId,
    this.campusId,
    required this.gateId,
    required this.personType,
    required this.personId,
    required this.personName,
    required this.direction,
    required this.movementType,
    required this.verificationMethod,
    required this.officerId,
    required this.officerRole,
    required this.deviceId,
    this.deviceName,
    required this.platform,
    required this.appVersion,
    required this.actionTimestamp,
    this.serverTimestamp,
    required this.syncStatus,
    this.pickupParentCode,
    this.pickupParentName,
    this.pickupPhoneNumber,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    gateId,
    personType,
    personId,
    personName,
    direction,
    movementType,
    verificationMethod,
    officerId,
    officerRole,
    deviceId,
    deviceName,
    platform,
    appVersion,
    actionTimestamp,
    serverTimestamp,
    syncStatus,
    pickupParentCode,
    pickupParentName,
    pickupPhoneNumber,
  ];
}
