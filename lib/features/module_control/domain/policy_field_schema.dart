import 'institution_policy.dart';

enum PolicyFieldKind { boolean, number, text, singleChoice }

class PolicyFieldOption {
  final String value, label;
  const PolicyFieldOption(this.value, this.label);
}

class PolicyFieldSpec {
  final String key, label;
  final String? helperText;
  final PolicyFieldKind kind;
  final dynamic defaultValue;
  final List<PolicyFieldOption> options;
  const PolicyFieldSpec({
    required this.key,
    required this.label,
    required this.kind,
    this.helperText,
    this.defaultValue,
    this.options = const [],
  });
}

/// Typed configuration shape per policy type, driving the generic policy
/// editor so a new policy type only needs a field list here rather than a
/// bespoke screen. Values are read/written as a plain configuration map so
/// operational modules keep resolving policies through [PolicyResolver]
/// without depending on this UI-facing schema.
class PolicyFieldSchema {
  static List<PolicyFieldSpec> forType(InstitutionPolicyType type) {
    switch (type) {
      case InstitutionPolicyType.attendance:
        return const [
          PolicyFieldSpec(key: 'gateAttendance', label: 'Gate attendance enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'subjectAttendance', label: 'Subject attendance enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'staffAttendance', label: 'Staff attendance enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'lateThresholdMinutes', label: 'Late threshold (minutes)', kind: PolicyFieldKind.number, defaultValue: 15),
          PolicyFieldSpec(key: 'gracePeriodMinutes', label: 'Grace period (minutes)', kind: PolicyFieldKind.number, defaultValue: 5),
          PolicyFieldSpec(key: 'correctionWindowHours', label: 'Correction window (hours)', kind: PolicyFieldKind.number, defaultValue: 24),
          PolicyFieldSpec(key: 'requiresApproval', label: 'Corrections require approval', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'parentVisibility', label: 'Visible to parents', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'offlineMarking', label: 'Allow offline marking', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.parentPortal:
        return const [
          PolicyFieldSpec(key: 'portalEnabled', label: 'Parent Portal enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'attendanceVisible', label: 'Attendance visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'resultsVisible', label: 'Results visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'feeVisible', label: 'Fee balance visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'reportDownloadAllowed', label: 'Report download allowed', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'messagingAvailable', label: 'Messaging available', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'healthAlertsVisible', label: 'Health alerts visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'disciplineVisible', label: 'Discipline visible', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'relationshipLimit', label: 'Max guardians per student', kind: PolicyFieldKind.number, defaultValue: 4),
          PolicyFieldSpec(key: 'relationshipLocking', label: 'Lock relationships after verification', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.studentPortal:
        return const [
          PolicyFieldSpec(key: 'portalEnabled', label: 'Student Portal enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'resultsVisible', label: 'Results visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'attendanceVisible', label: 'Attendance visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'feesVisible', label: 'Fees visible', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'timetableVisible', label: 'Timetable visible', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'messagingEnabled', label: 'Messaging enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'profileCorrectionRequests', label: 'Allow profile correction requests', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'officialRecordReadOnly', label: 'Official record read-only', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.reportRelease:
        return const [
          PolicyFieldSpec(key: 'requiresApproval', label: 'Requires approval before release', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'parentVisible', label: 'Visible to parents on release', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'studentVisible', label: 'Visible to students on release', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'downloadAllowed', label: 'Download permitted', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'printAllowed', label: 'Print permitted', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'feeClearanceRequired', label: 'Fee clearance required', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'feeClearancePercentage', label: 'Required payment percentage', kind: PolicyFieldKind.number, defaultValue: 100),
          PolicyFieldSpec(key: 'rankingVisible', label: 'Ranking visible', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'teacherCommentsVisible', label: 'Teacher comments visible', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.financeAccess:
        return const [
          PolicyFieldSpec(key: 'parentFeeVisible', label: 'Parent fee visibility', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'studentFeeVisible', label: 'Student fee visibility', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'receiptVisible', label: 'Receipt visibility', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'paymentInitiationEnabled', label: 'Payment initiation enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'partialPaymentAllowed', label: 'Partial payment allowed', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'feeClearancePercentage', label: 'Clearance percentage rule', kind: PolicyFieldKind.number, defaultValue: 0),
        ];
      case InstitutionPolicyType.messaging:
        return const [
          PolicyFieldSpec(key: 'enabled', label: 'Messaging enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'parentMessagingEnabled', label: 'Parent messaging enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'studentMessagingEnabled', label: 'Student messaging enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'staffToStaffEnabled', label: 'Staff-to-staff messaging', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'broadcastAllowed', label: 'Broadcast permitted', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'attachmentsAllowed', label: 'Attachments allowed', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'readReceipts', label: 'Read receipts', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'retentionDays', label: 'Message retention (days)', kind: PolicyFieldKind.number, defaultValue: 365),
        ];
      case InstitutionPolicyType.notifications:
        return const [
          PolicyFieldSpec(key: 'pushEnabled', label: 'Push notifications enabled', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'attendanceAlerts', label: 'Attendance alerts', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'feeAlerts', label: 'Fee alerts', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'reportAlerts', label: 'Report alerts', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'emergencyAlerts', label: 'Emergency alerts (mandatory)', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'quietHoursStart', label: 'Quiet hours start (24h)', kind: PolicyFieldKind.text, defaultValue: '21:00'),
          PolicyFieldSpec(key: 'quietHoursEnd', label: 'Quiet hours end (24h)', kind: PolicyFieldKind.text, defaultValue: '06:00'),
        ];
      case InstitutionPolicyType.visitorSecurity:
        return const [
          PolicyFieldSpec(key: 'registrationRequired', label: 'Visitor registration required', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'photoCaptureRequired', label: 'Photo capture required', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'idDocumentRequired', label: 'ID document capture required', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'hostApprovalRequired', label: 'Host approval required', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'retentionDays', label: 'Visitor record retention (days)', kind: PolicyFieldKind.number, defaultValue: 180),
          PolicyFieldSpec(key: 'pickupVerificationRequired', label: 'Parent pickup verification required', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.boarding:
        return const [
          PolicyFieldSpec(key: 'enabled', label: 'Boarding enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'morningRollCall', label: 'Morning roll call', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'eveningRollCall', label: 'Evening roll call', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'weekendRollCall', label: 'Weekend roll call', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'leaveApprovalRequired', label: 'Leave requires approval', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'parentVisibility', label: 'Parent visibility', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.transport:
        return const [
          PolicyFieldSpec(key: 'enabled', label: 'Transport enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'parentVisibility', label: 'Parent visibility', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'dropOffConfirmation', label: 'Drop-off confirmation required', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'liveTrackingAvailable', label: 'Live tracking available', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'routeChangeRequestsAllowed', label: 'Route-change requests allowed', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.healthPrivacy:
        return const [
          PolicyFieldSpec(key: 'parentHealthAlerts', label: 'Parent health alerts', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'studentHealthVisible', label: 'Student health visibility', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'staffClinicAccess', label: 'Staff clinic record access', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'sensitiveNoteVisible', label: 'Sensitive-note visibility', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'retentionDays', label: 'Health document retention (days)', kind: PolicyFieldKind.number, defaultValue: 1825),
        ];
      case InstitutionPolicyType.dataRetention:
        return const [
          PolicyFieldSpec(key: 'visitorPhotosDays', label: 'Visitor photos (days)', kind: PolicyFieldKind.number, defaultValue: 180),
          PolicyFieldSpec(key: 'attendanceEvidenceDays', label: 'Attendance evidence (days)', kind: PolicyFieldKind.number, defaultValue: 365),
          PolicyFieldSpec(key: 'messagesDays', label: 'Messages (days)', kind: PolicyFieldKind.number, defaultValue: 365),
          PolicyFieldSpec(key: 'auditLogsDays', label: 'Audit logs (days)', kind: PolicyFieldKind.number, defaultValue: 1825),
          PolicyFieldSpec(key: 'exportsDays', label: 'Exports (days)', kind: PolicyFieldKind.number, defaultValue: 90),
        ];
      case InstitutionPolicyType.security:
        return const [
          PolicyFieldSpec(key: 'passwordMinimumLength', label: 'Password minimum length', kind: PolicyFieldKind.number, defaultValue: 8),
          PolicyFieldSpec(key: 'sessionDurationMinutes', label: 'Session duration (minutes)', kind: PolicyFieldKind.number, defaultValue: 60),
          PolicyFieldSpec(key: 'failedLoginLockoutAttempts', label: 'Failed-login lockout attempts', kind: PolicyFieldKind.number, defaultValue: 5),
          PolicyFieldSpec(key: 'temporaryPasswordExpiryHours', label: 'Temporary password expiry (hours)', kind: PolicyFieldKind.number, defaultValue: 48),
          PolicyFieldSpec(key: 'parentCodeExpiryHours', label: 'Parent code expiry (hours)', kind: PolicyFieldKind.number, defaultValue: 24),
          PolicyFieldSpec(key: 'sensitiveActionReauth', label: 'Reauthenticate for sensitive actions', kind: PolicyFieldKind.boolean, defaultValue: true),
        ];
      case InstitutionPolicyType.biometrics:
        return const [
          PolicyFieldSpec(key: 'enabled', label: 'Biometrics enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'fingerprintAllowed', label: 'Fingerprint allowed', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'faceAllowed', label: 'Face recognition allowed', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'consentRequired', label: 'Consent required', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'manualFallback', label: 'Manual fallback available', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'retentionDays', label: 'Biometric data retention (days)', kind: PolicyFieldKind.number, defaultValue: 365),
        ];
      case InstitutionPolicyType.googleSheets:
        return const [
          PolicyFieldSpec(key: 'attendanceExportEnabled', label: 'Attendance export enabled', kind: PolicyFieldKind.boolean, defaultValue: false),
          PolicyFieldSpec(key: 'manualSyncAllowed', label: 'Manual sync allowed', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'adminOnlyConnection', label: 'Admin-only connection control', kind: PolicyFieldKind.boolean, defaultValue: true),
          PolicyFieldSpec(key: 'exportFrequency', label: 'Export frequency', kind: PolicyFieldKind.singleChoice, defaultValue: 'daily', options: [
            PolicyFieldOption('manual', 'Manual only'),
            PolicyFieldOption('daily', 'Daily'),
            PolicyFieldOption('weekly', 'Weekly'),
          ]),
        ];
    }
  }

  static Map<String, dynamic> defaults(InstitutionPolicyType type) => {
    for (final field in forType(type)) field.key: field.defaultValue,
  };
}
