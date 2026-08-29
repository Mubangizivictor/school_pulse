import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Read + write access for the Bursar Financial Entitlements dashboard.
///
/// Reads: `student_financials` (the same doc `compute()` consumes) for the
/// filter table, and the `financial_entitlement_policy/current` doc for the
/// configured services + thresholds. Writes: only through the deployed
/// `financial_entitlements.js` callables — this class never touches an
/// entitlement collection directly (rules deny it).
class EntitlementsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  EntitlementsRemoteDataSource({
    required this.firestore,
    required this.functions,
  });

  CollectionReference<Map<String, dynamic>> _col(
    String schoolId,
    String name,
  ) => firestore.collection('schools').doc(schoolId).collection(name);

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final res = await functions
        .httpsCallable(name)
        .call<Map<String, dynamic>>(data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ---- reads --------------------------------------------------------

  /// The current entitlement policy doc, or `{}` if none configured.
  Future<Map<String, dynamic>> policy(String schoolId) async {
    final doc = await _col(
      schoolId,
      'financial_entitlement_policy',
    ).doc('current').get();
    return doc.data() ?? const {};
  }

  Stream<Map<String, dynamic>> watchPolicy(String schoolId) => _col(
    schoolId,
    'financial_entitlement_policy',
  ).doc('current').snapshots().map((d) => d.data() ?? const {});

  /// Every learner's `student_financials` doc for the school, keyed by
  /// studentId — the input to the dashboard's payment-band / balance /
  /// scholarship / plan / waiver filters.
  Future<Map<String, LearnerFinancials>> allFinancials(String schoolId) async {
    final snap = await _col(schoolId, 'student_financials').get();
    return {
      for (final d in snap.docs)
        d.id: LearnerFinancials.fromMap(d.id, d.data()),
    };
  }

  /// Recent entitlement audit rows (dashboard "override audit" report).
  Stream<List<Map<String, dynamic>>> watchAudit(
    String schoolId, {
    int limit = 100,
  }) => _col(schoolId, 'financial_entitlement_audit')
      .orderBy('at', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  /// All overrides for a service (report feeds: blocked/expiring/etc).
  Future<List<Map<String, dynamic>>> overridesForService(
    String schoolId,
    String service,
  ) async {
    final snap = await _col(
      schoolId,
      'financial_entitlement_overrides',
    ).where('service', isEqualTo: service).get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // ---- callables --------------------------------------------------

  Future<void> savePolicy({
    required String schoolId,
    required Map<String, dynamic> services,
    int? expiryWarningDays,
    int? secondApprovalThresholdDays,
    bool requireLeadershipApproval = false,
  }) => _call('saveFinancialEntitlementPolicy', {
    'schoolId': schoolId,
    'services': services,
    'expiryWarningDays': ?expiryWarningDays,
    'secondApprovalThresholdDays': ?secondApprovalThresholdDays,
    if (requireLeadershipApproval) 'requireLeadershipApproval': true,
  });

  Future<Map<String, dynamic>> setOverride({
    required String schoolId,
    required String studentId,
    required String service,
    required String decision, // allow | deny
    String? reasonCode,
    String? note,
    int? expiresAtMs,
    bool requireSecondApproval = false,
    String? source, // serviceAdministratorOverride | managementApproval
  }) => _call('setFinancialEntitlementOverride', {
    'schoolId': schoolId,
    'studentId': studentId,
    'service': service,
    'decision': decision,
    'reasonCode': ?reasonCode,
    'note': ?note,
    'expiresAt': ?expiresAtMs,
    if (requireSecondApproval) 'requireSecondApproval': true,
    'source': ?source,
  });

  Future<Map<String, dynamic>> decideOverride({
    required String schoolId,
    required String overrideId,
    required String decision, // approve | reject | revoke | renew
    String? note,
    int? expiresAtMs,
  }) => _call('decideEntitlementOverride', {
    'schoolId': schoolId,
    'overrideId': overrideId,
    'decision': decision,
    'note': ?note,
    'expiresAt': ?expiresAtMs,
  });

  Future<Map<String, dynamic>> learnerProfile({
    required String schoolId,
    required String studentId,
  }) => _call('getLearnerEntitlementProfile', {
    'schoolId': schoolId,
    'studentId': studentId,
  });

  Future<Map<String, dynamic>> bulkAction({
    required String schoolId,
    required String action, // grant | revoke | renew
    required String service,
    required List<String> studentIds,
    String? reasonCode,
    String? note,
    int? expiresAtMs,
    bool requireSecondApproval = false,
    String? bulkActionId,
  }) => _call('bulkEntitlementAction', {
    'schoolId': schoolId,
    'action': action,
    'service': service,
    'studentIds': studentIds,
    'reasonCode': ?reasonCode,
    'note': ?note,
    'expiresAt': ?expiresAtMs,
    if (requireSecondApproval) 'requireSecondApproval': true,
    'bulkActionId': ?bulkActionId,
  });
}

/// The dashboard's per-learner financial snapshot, derived exactly like the
/// server (`financialSummary` in financial_entitlements.js) so filter bands
/// match the entitlement decision.
class LearnerFinancials {
  final String studentId;
  final double totalBilled;
  final double totalPaid;
  final double scholarshipAmount;
  final double discountAmount; // == waiver
  final String? feeStructureId;
  final List<String> applicableRestrictions;

  const LearnerFinancials({
    required this.studentId,
    required this.totalBilled,
    required this.totalPaid,
    required this.scholarshipAmount,
    required this.discountAmount,
    this.feeStructureId,
    this.applicableRestrictions = const [],
  });

  factory LearnerFinancials.fromMap(String id, Map<String, dynamic> m) {
    double n(Object? v) => (v as num?)?.toDouble() ?? 0;
    return LearnerFinancials(
      studentId: id,
      totalBilled: n(m['totalBilled']),
      totalPaid: n(m['totalPaid']),
      scholarshipAmount: n(m['scholarshipAmount']),
      discountAmount: n(m['discountAmount']),
      feeStructureId: m['feeStructureId'] as String?,
      applicableRestrictions:
          ((m['applicableRestrictions'] as List?) ?? const [])
              .map((e) => '$e')
              .toList(),
    );
  }

  double get net => (totalBilled - scholarshipAmount - discountAmount).clamp(
    0,
    double.infinity,
  );

  /// 0..100. Matches the server's derivation.
  int get overallPct {
    if (net <= 0) return totalBilled == 0 ? 100 : 0;
    return (totalPaid / net * 100).clamp(0, 100).round();
  }

  double get balance =>
      totalBilled - totalPaid - scholarshipAmount - discountAmount;

  bool get hasScholarship => scholarshipAmount > 0;
  bool get hasWaiver => discountAmount > 0;
  bool get hasPaymentPlan => (feeStructureId ?? '').isNotEmpty;

  /// The 6 filter bands: 0, 1-24, 25-49, 50-74, 75-99, 100.
  int get band {
    final p = overallPct;
    if (p >= 100) return 5;
    if (p >= 75) return 4;
    if (p >= 50) return 3;
    if (p >= 25) return 2;
    if (p >= 1) return 1;
    return 0;
  }
}

const kEntitlementBands = <String>[
  '0%',
  '1–24%',
  '25–49%',
  '50–74%',
  '75–99%',
  '100%',
];
