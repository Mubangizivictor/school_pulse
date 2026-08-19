import '../../domain/entities/staff_identity.dart';

class StaffIdentityModel extends StaffIdentity {
  const StaffIdentityModel({
    required super.staffId,
    required super.schoolId,
    required super.uniqueSystemId,
    required super.qrCodeData,
    super.nfcStatus,
  });

  factory StaffIdentityModel.fromFirestore(Map<String, dynamic> json) {
    return StaffIdentityModel(
      staffId: json['staffId'] as String,
      schoolId: json['schoolId'] as String? ?? '',
      uniqueSystemId: json['uniqueSystemId'] as String,
      qrCodeData: json['qrCodeData'] as String,
      nfcStatus: json['nfcStatus'] as String? ?? 'unassigned',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'staffId': staffId,
      'schoolId': schoolId,
      'uniqueSystemId': uniqueSystemId,
      'qrCodeData': qrCodeData,
      'nfcStatus': nfcStatus,
    };
  }
}
