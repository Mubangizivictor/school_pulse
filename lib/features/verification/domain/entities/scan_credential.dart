import 'package:equatable/equatable.dart';

/// A single identifying credential presented by a person during a
/// verification scan. All credential kinds resolve through the same
/// IdentityResolver - no credential-type-specific business logic lives
/// outside the resolver/policy layer.
sealed class ScanCredential extends Equatable {
  const ScanCredential();
}

class QrScanCredential extends ScanCredential {
  final String rawPayload;
  final DateTime scannedAt;

  const QrScanCredential({required this.rawPayload, required this.scannedAt});

  @override
  List<Object?> get props => [rawPayload, scannedAt];
}

class NfcScanCredential extends ScanCredential {
  final String cardUid;
  final DateTime scannedAt;

  const NfcScanCredential({required this.cardUid, required this.scannedAt});

  @override
  List<Object?> get props => [cardUid, scannedAt];
}

/// Fingerprint only ever CONFIRMS a claimed identity (1:1 match against
/// that person's stored template via the existing `BiometricDeviceService`
/// / `VerifyFingerprint`) - there is no 1:N fingerprint identification
/// anywhere in the app, so [claimedIdentityId] must already be known
/// before a fingerprint scan is meaningful.
class FingerprintScanCredential extends ScanCredential {
  final String claimedIdentityId;
  final String claimedIdentityType; // 'student' | 'staff'
  final String deviceId;
  final DateTime capturedAt;

  const FingerprintScanCredential({
    required this.claimedIdentityId,
    required this.claimedIdentityType,
    required this.deviceId,
    required this.capturedAt,
  });

  @override
  List<Object?> get props => [
    claimedIdentityId,
    claimedIdentityType,
    deviceId,
    capturedAt,
  ];
}

class ManualCodeScanCredential extends ScanCredential {
  final String code;

  const ManualCodeScanCredential({required this.code});

  @override
  List<Object?> get props => [code];
}

class ParentCodeScanCredential extends ScanCredential {
  final String code;

  /// Set when the calling screen's own child-picker UI has already
  /// disambiguated which linked child is being picked up (a parent code
  /// may cover several siblings) - the resolver uses this directly
  /// instead of re-resolving and losing that choice.
  final String? preSelectedChildId;
  final String? preSelectedChildName;

  const ParentCodeScanCredential({
    required this.code,
    this.preSelectedChildId,
    this.preSelectedChildName,
  });

  @override
  List<Object?> get props => [code, preSelectedChildId, preSelectedChildName];
}

class StaffLookupScanCredential extends ScanCredential {
  final String staffId;

  const StaffLookupScanCredential({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}
