import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';

class BiometricSettingsModel extends BiometricSettings {
  BiometricSettingsModel({
    super.enableBiometrics,
    super.enableFingerprintAttendance,
    super.enableGateVerification,
    super.enableLibraryVerification,
    super.enableExamVerification,
    super.enableStaffAttendance,
    super.enableStudentAttendance,
    super.allowQrFallback,
    super.requireFingerprintAndQr,
    super.offlineVerificationEnabled,
  });

  factory BiometricSettingsModel.fromEntity(BiometricSettings entity) {
    return BiometricSettingsModel(
      enableBiometrics: entity.enableBiometrics,
      enableFingerprintAttendance: entity.enableFingerprintAttendance,
      enableGateVerification: entity.enableGateVerification,
      enableLibraryVerification: entity.enableLibraryVerification,
      enableExamVerification: entity.enableExamVerification,
      enableStaffAttendance: entity.enableStaffAttendance,
      enableStudentAttendance: entity.enableStudentAttendance,
      allowQrFallback: entity.allowQrFallback,
      requireFingerprintAndQr: entity.requireFingerprintAndQr,
      offlineVerificationEnabled: entity.offlineVerificationEnabled,
    );
  }

  factory BiometricSettingsModel.fromMap(Map<String, dynamic> map) {
    return BiometricSettingsModel(
      enableBiometrics: map['enableBiometrics'] ?? false,
      enableFingerprintAttendance: map['enableFingerprintAttendance'] ?? false,
      enableGateVerification: map['enableGateVerification'] ?? false,
      enableLibraryVerification: map['enableLibraryVerification'] ?? false,
      enableExamVerification: map['enableExamVerification'] ?? false,
      enableStaffAttendance: map['enableStaffAttendance'] ?? false,
      enableStudentAttendance: map['enableStudentAttendance'] ?? false,
      allowQrFallback: map['allowQrFallback'] ?? true,
      requireFingerprintAndQr: map['requireFingerprintAndQr'] ?? false,
      offlineVerificationEnabled: map['offlineVerificationEnabled'] ?? false,
    );
  }
}
