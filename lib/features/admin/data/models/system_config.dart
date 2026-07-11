class SystemConfig {
  final String schoolName;
  final String schoolMotto;
  final String currentTerm;
  final String academicYear;
  final DateTime termStart;
  final DateTime termEnd;
  final bool mfaEnabled;
  final String smsGatewayStatus;
  final int smsCredits;

  SystemConfig({
    required this.schoolName,
    required this.schoolMotto,
    required this.currentTerm,
    required this.academicYear,
    required this.termStart,
    required this.termEnd,
    required this.mfaEnabled,
    required this.smsGatewayStatus,
    required this.smsCredits,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'schoolMotto': schoolMotto,
      'currentTerm': currentTerm,
      'academicYear': academicYear,
      'termStart': termStart.toIso8601String(),
      'termEnd': termEnd.toIso8601String(),
      'mfaEnabled': mfaEnabled,
      'smsGatewayStatus': smsGatewayStatus,
      'smsCredits': smsCredits,
    };
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
      schoolName: map['schoolName'] ?? '',
      schoolMotto: map['schoolMotto'] ?? '',
      currentTerm: map['currentTerm'] ?? '',
      academicYear: map['academicYear'] ?? '',
      termStart: DateTime.parse(map['termStart'] ?? DateTime.now().toIso8601String()),
      termEnd: DateTime.parse(map['termEnd'] ?? DateTime.now().toIso8601String()),
      mfaEnabled: map['mfaEnabled'] ?? false,
      smsGatewayStatus: map['smsGatewayStatus'] ?? 'Disconnected',
      smsCredits: map['smsCredits'] ?? 0,
    );
  }
}
