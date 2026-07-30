class BiometricSettings {
  final bool enableBiometrics;
  final bool enableFingerprintAttendance;
  final bool enableGateVerification;
  final bool enableLibraryVerification;
  final bool enableExamVerification;
  final bool enableStaffAttendance;
  final bool enableStudentAttendance;
  final bool allowQrFallback;
  final bool requireFingerprintAndQr;
  final bool offlineVerificationEnabled;

  BiometricSettings({
    this.enableBiometrics = false,
    this.enableFingerprintAttendance = false,
    this.enableGateVerification = false,
    this.enableLibraryVerification = false,
    this.enableExamVerification = false,
    this.enableStaffAttendance = false,
    this.enableStudentAttendance = false,
    this.allowQrFallback = true,
    this.requireFingerprintAndQr = false,
    this.offlineVerificationEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'enableBiometrics': enableBiometrics,
      'enableFingerprintAttendance': enableFingerprintAttendance,
      'enableGateVerification': enableGateVerification,
      'enableLibraryVerification': enableLibraryVerification,
      'enableExamVerification': enableExamVerification,
      'enableStaffAttendance': enableStaffAttendance,
      'enableStudentAttendance': enableStudentAttendance,
      'allowQrFallback': allowQrFallback,
      'requireFingerprintAndQr': requireFingerprintAndQr,
      'offlineVerificationEnabled': offlineVerificationEnabled,
    };
  }

  factory BiometricSettings.fromMap(Map<String, dynamic> map) {
    return BiometricSettings(
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

  BiometricSettings copyWith({
    bool? enableBiometrics,
    bool? enableFingerprintAttendance,
    bool? enableGateVerification,
    bool? enableLibraryVerification,
    bool? enableExamVerification,
    bool? enableStaffAttendance,
    bool? enableStudentAttendance,
    bool? allowQrFallback,
    bool? requireFingerprintAndQr,
    bool? offlineVerificationEnabled,
  }) {
    return BiometricSettings(
      enableBiometrics: enableBiometrics ?? this.enableBiometrics,
      enableFingerprintAttendance: enableFingerprintAttendance ?? this.enableFingerprintAttendance,
      enableGateVerification: enableGateVerification ?? this.enableGateVerification,
      enableLibraryVerification: enableLibraryVerification ?? this.enableLibraryVerification,
      enableExamVerification: enableExamVerification ?? this.enableExamVerification,
      enableStaffAttendance: enableStaffAttendance ?? this.enableStaffAttendance,
      enableStudentAttendance: enableStudentAttendance ?? this.enableStudentAttendance,
      allowQrFallback: allowQrFallback ?? this.allowQrFallback,
      requireFingerprintAndQr: requireFingerprintAndQr ?? this.requireFingerprintAndQr,
      offlineVerificationEnabled: offlineVerificationEnabled ?? this.offlineVerificationEnabled,
    );
  }
}
