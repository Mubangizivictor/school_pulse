import 'package:equatable/equatable.dart';

/// Mirrors StudentIdentity's shape for staff, but there's no admission
/// number equivalent - staffCode (already on UserEntity) is the
/// human-facing id, so this only carries the printable/auditable
/// uniqueSystemId plus the signed QR credential and NFC lifecycle status.
class StaffIdentity extends Equatable {
  final String staffId; // Reference to UserEntity.id (Firestore uid)
  final String schoolId;
  final String uniqueSystemId; // SP-STAFF-a82jd92
  final String qrCodeData; // Signed envelope: id + issuedAt + schoolId + HMAC

  // 'unassigned' | 'active' | 'revoked'.
  final String nfcStatus;

  const StaffIdentity({
    required this.staffId,
    required this.schoolId,
    required this.uniqueSystemId,
    required this.qrCodeData,
    this.nfcStatus = 'unassigned',
  });

  @override
  List<Object?> get props => [
    staffId,
    schoolId,
    uniqueSystemId,
    qrCodeData,
    nfcStatus,
  ];
}
