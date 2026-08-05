import 'package:school_pulse/features/student/domain/entities/student_portal_config.dart';

class SystemConfig {
  final String schoolName;
  final String? schoolCode; // e.g., "SMAC"
  final String schoolMotto;
  final String? schoolLogoUrl;
  final String? schoolAddress;
  final String? schoolEmail;
  final String? schoolPhone;
  final String? primaryColor;
  final String? secondaryColor;
  final String currentTerm;
  final String academicYear;
  final DateTime termStart;
  final DateTime termEnd;
  final bool mfaEnabled;
  final String smsGatewayStatus;
  final int smsCredits;
  final StudentPortalConfig studentPortalConfig;
  final List<String> visitorGates;

  SystemConfig({
    required this.schoolName,
    this.schoolCode,
    required this.schoolMotto,
    this.schoolLogoUrl,
    this.schoolAddress,
    this.schoolEmail,
    this.schoolPhone,
    this.primaryColor,
    this.secondaryColor,
    required this.currentTerm,
    required this.academicYear,
    required this.termStart,
    required this.termEnd,
    required this.mfaEnabled,
    required this.smsGatewayStatus,
    required this.smsCredits,
    required this.studentPortalConfig,
    this.visitorGates = const ['Main Gate'],
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'schoolCode': schoolCode,
      'schoolMotto': schoolMotto,
      'schoolLogoUrl': schoolLogoUrl,
      'schoolAddress': schoolAddress,
      'schoolEmail': schoolEmail,
      'schoolPhone': schoolPhone,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'currentTerm': currentTerm,
      'academicYear': academicYear,
      'termStart': termStart.toIso8601String(),
      'termEnd': termEnd.toIso8601String(),
      'mfaEnabled': mfaEnabled,
      'smsGatewayStatus': smsGatewayStatus,
      'smsCredits': smsCredits,
      'studentPortalConfig': studentPortalConfig.toMap(),
      'visitorGates': visitorGates,
    };
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
      schoolName: map['schoolName'] ?? '',
      schoolCode: map['schoolCode'],
      schoolMotto: map['schoolMotto'] ?? '',
      schoolLogoUrl: map['schoolLogoUrl'],
      schoolAddress: map['schoolAddress'],
      schoolEmail: map['schoolEmail'],
      schoolPhone: map['schoolPhone'],
      primaryColor: map['primaryColor'],
      secondaryColor: map['secondaryColor'],
      currentTerm: map['currentTerm'] ?? '',
      academicYear: map['academicYear'] ?? '',
      termStart: DateTime.parse(
        map['termStart'] ?? DateTime.now().toIso8601String(),
      ),
      termEnd: DateTime.parse(
        map['termEnd'] ?? DateTime.now().toIso8601String(),
      ),
      mfaEnabled: map['mfaEnabled'] ?? false,
      smsGatewayStatus: map['smsGatewayStatus'] ?? 'Disconnected',
      smsCredits: map['smsCredits'] ?? 0,
      studentPortalConfig: StudentPortalConfig.fromMap(
        map['studentPortalConfig'] ?? {},
      ),
      visitorGates: map['visitorGates'] != null
          ? List<String>.from(map['visitorGates'])
          : const ['Main Gate'],
    );
  }

  SystemConfig copyWith({
    String? schoolName,
    String? schoolCode,
    String? schoolMotto,
    String? schoolLogoUrl,
    String? schoolAddress,
    String? schoolEmail,
    String? schoolPhone,
    String? primaryColor,
    String? secondaryColor,
    String? currentTerm,
    String? academicYear,
    DateTime? termStart,
    DateTime? termEnd,
    bool? mfaEnabled,
    String? smsGatewayStatus,
    int? smsCredits,
    StudentPortalConfig? studentPortalConfig,
    List<String>? visitorGates,
  }) {
    return SystemConfig(
      schoolName: schoolName ?? this.schoolName,
      schoolCode: schoolCode ?? this.schoolCode,
      schoolMotto: schoolMotto ?? this.schoolMotto,
      schoolLogoUrl: schoolLogoUrl ?? this.schoolLogoUrl,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      schoolPhone: schoolPhone ?? this.schoolPhone,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      currentTerm: currentTerm ?? this.currentTerm,
      academicYear: academicYear ?? this.academicYear,
      termStart: termStart ?? this.termStart,
      termEnd: termEnd ?? this.termEnd,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      smsGatewayStatus: smsGatewayStatus ?? this.smsGatewayStatus,
      smsCredits: smsCredits ?? this.smsCredits,
      studentPortalConfig: studentPortalConfig ?? this.studentPortalConfig,
      visitorGates: visitorGates ?? this.visitorGates,
    );
  }
}
