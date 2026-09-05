/// Guardian consent methods a school's enrolment policy may permit.
///
/// Mirrors `schools/{schoolId}.enrolmentPolicy.consentMethods` (a list of
/// these keys) so staff can only pick a method the tenant has switched on.
enum GuardianConsentMethod {
  guardianSignsNow('guardian_signs_now'),
  secureLink('secure_link'),
  verbal('verbal');

  final String key;
  const GuardianConsentMethod(this.key);

  static GuardianConsentMethod? fromKey(String? key) =>
      GuardianConsentMethod.values.where((m) => m.key == key).firstOrNull;
}

/// Lifecycle of a single consent record. `pending` means a secure link was
/// sent but not yet redeemed by the guardian.
enum GuardianConsentStatus {
  required_('required'),
  pending('pending'),
  captured('captured'),
  expired('expired'),
  withdrawn('withdrawn'),
  needsReview('needs_review');

  final String key;
  const GuardianConsentStatus(this.key);

  static GuardianConsentStatus fromKey(String? key) =>
      GuardianConsentStatus.values.where((s) => s.key == key).firstOrNull ??
      GuardianConsentStatus.required_;
}

/// Immutable snapshot of a guardian-consent event, as written by a Cloud
/// Function under `guardian_consent_records/{id}` and mirrored onto the
/// enrolment draft as `draft.guardianConsent` (latest-state pointer only —
/// the append-only collection is the audit source of truth).
///
/// Never constructed by the client as "captured" directly: every field here
/// is set server-side by `recordGuardianConsentByStaff` or
/// `resolveGuardianConsentLink` after validating the method is permitted by
/// tenant policy and, for a secure link, that the token is unexpired and
/// unused.
class GuardianConsentRecord {
  final String id;
  final String schoolId;
  final String draftId;
  final String? studentId;
  final String guardianId;
  final String guardianName;
  final GuardianConsentMethod method;
  final GuardianConsentStatus status;
  final String policyVersion;
  final String consentTextHash;
  final DateTime? capturedAt;
  final DateTime? expiresAt;
  final String? capturedByStaffId;
  final String? capturedByStaffName;
  final String? witnessName;
  final String? witnessRelationship;
  final String? verbalConsentReference;
  final DateTime? withdrawnAt;
  final String? withdrawnReason;

  const GuardianConsentRecord({
    required this.id,
    required this.schoolId,
    required this.draftId,
    this.studentId,
    required this.guardianId,
    required this.guardianName,
    required this.method,
    required this.status,
    required this.policyVersion,
    required this.consentTextHash,
    this.capturedAt,
    this.expiresAt,
    this.capturedByStaffId,
    this.capturedByStaffName,
    this.witnessName,
    this.witnessRelationship,
    this.verbalConsentReference,
    this.withdrawnAt,
    this.withdrawnReason,
  });

  bool get isValid =>
      status == GuardianConsentStatus.captured &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  factory GuardianConsentRecord.fromMap(String id, Map<String, dynamic> m) {
    DateTime? ts(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      try {
        // Firestore Timestamp has a toDate(); avoid importing
        // cloud_firestore here so this entity stays platform-agnostic.
        return (v as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return GuardianConsentRecord(
      id: id,
      schoolId: m['schoolId'] as String? ?? '',
      draftId: m['draftId'] as String? ?? '',
      studentId: m['studentId'] as String?,
      guardianId: m['guardianId'] as String? ?? '',
      guardianName: m['guardianName'] as String? ?? '',
      method:
          GuardianConsentMethod.fromKey(m['method'] as String?) ??
          GuardianConsentMethod.guardianSignsNow,
      status: GuardianConsentStatus.fromKey(m['status'] as String?),
      policyVersion: m['policyVersion'] as String? ?? '',
      consentTextHash: m['consentTextHash'] as String? ?? '',
      capturedAt: ts(m['capturedAt']),
      expiresAt: ts(m['expiresAt']),
      capturedByStaffId: m['capturedByStaffId'] as String?,
      capturedByStaffName: m['capturedByStaffName'] as String?,
      witnessName: m['witnessName'] as String?,
      witnessRelationship: m['witnessRelationship'] as String?,
      verbalConsentReference: m['verbalConsentReference'] as String?,
      withdrawnAt: ts(m['withdrawnAt']),
      withdrawnReason: m['withdrawnReason'] as String?,
    );
  }
}
