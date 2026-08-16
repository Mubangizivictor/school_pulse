import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/institution_policy.dart';

class ModuleConfiguration {
  final String moduleKey;
  final bool entitled, enabled;
  final String setupStatus, reason;
  final int version;
  final DateTime? updatedAt;
  final String? updatedBy;
  const ModuleConfiguration({
    required this.moduleKey,
    this.entitled = false,
    this.enabled = false,
    this.setupStatus = 'notStarted',
    this.reason = '',
    this.version = 0,
    this.updatedAt,
    this.updatedBy,
  });
  factory ModuleConfiguration.fromMap(String key, Map<String, dynamic>? data) =>
      ModuleConfiguration(
        moduleKey: key,
        entitled: data?['entitled'] == true,
        enabled: data?['enabled'] == true,
        setupStatus: data?['setupStatus'] as String? ?? 'notStarted',
        reason: data?['reason'] as String? ?? '',
        version: (data?['configurationVersion'] as num?)?.toInt() ?? 0,
        updatedAt: (data?['updatedAt'] as Timestamp?)?.toDate(),
        updatedBy: data?['updatedBy'] as String?,
      );
}

/// Firestore source of truth. Entitlements are only readable here: a school
/// administrator cannot write them; server-side subscription code owns them.
class ModuleControlRepository {
  final FirebaseFirestore firestore;
  ModuleControlRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _modules(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('module_configuration');
  CollectionReference<Map<String, dynamic>> _policies(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('institution_policies');
  CollectionReference<Map<String, dynamic>> _audit(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('module_policy_audit');
  Stream<Map<String, ModuleConfiguration>> watchModules(String schoolId) =>
      _modules(schoolId).snapshots().map(
        (snap) => {
          for (final doc in snap.docs)
            doc.id: ModuleConfiguration.fromMap(doc.id, doc.data()),
        },
      );
  Stream<List<InstitutionPolicy>> watchPolicies(String schoolId) =>
      _policies(schoolId).snapshots().map(
        (snap) => snap.docs.map((d) => _policy(d.id, d.data())).toList(),
      );
  Future<void> setModuleEnabled({
    required String schoolId,
    required String moduleKey,
    required bool enabled,
    required String actorId,
    required String reason,
  }) async {
    final ref = _modules(schoolId).doc(moduleKey);
    await firestore.runTransaction((transaction) async {
      final before = await transaction.get(ref);
      final data = before.data() ?? <String, dynamic>{};
      if (data['entitled'] != true) {
        throw StateError(
          'This module is not included in the current subscription.',
        );
      }
      transaction.set(ref, {
        'institutionId': schoolId,
        'moduleKey': moduleKey,
        'enabled': enabled,
        'configurationVersion':
            ((data['configurationVersion'] as num?)?.toInt() ?? 0) + 1,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actorId,
        'reason': reason,
        if (enabled)
          'enabledAt': FieldValue.serverTimestamp()
        else
          'disabledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(_audit(schoolId).doc(), {
        'action': enabled ? 'module_enabled' : 'module_disabled',
        'moduleKey': moduleKey,
        'actorId': actorId,
        'reason': reason,
        'previousValue': data['enabled'] == true,
        'newValue': enabled,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Persists a new policy version. Pass [previousVersion] (from the last
  /// loaded policy, or null when creating) so the audit trail records what
  /// changed without re-reading inside the transaction — callers already
  /// hold the current value from `watchPolicies`.
  Future<void> savePolicy(
    InstitutionPolicy policy, {
    InstitutionPolicy? previousVersion,
  }) async {
    final ref = _policies(policy.institutionId).doc(policy.id);
    await firestore.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      final oldVersion = (existing.data()?['version'] as num?)?.toInt() ?? 0;
      final newVersion = oldVersion + 1;
      transaction.set(ref, {
        ...policy.toMap(),
        'version': newVersion,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(ref.collection('versions').doc('$newVersion'), {
        ...policy.toMap(),
        'version': newVersion,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(_audit(policy.institutionId).doc(), {
        'action': 'policy_${policy.status.name}',
        'policyId': policy.id,
        'policyType': policy.type.name,
        'actorId': policy.updatedBy,
        'reason': policy.changeReason,
        'previousStatus': previousVersion?.status.name,
        'newStatus': policy.status.name,
        'version': newVersion,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<Map<String, dynamic>>> watchAudit(
    String schoolId, {
    int limit = 100,
  }) => _audit(
    schoolId,
  ).orderBy('timestamp', descending: true).limit(limit).snapshots().map(
    (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
  );

  Stream<List<InstitutionPolicy>> watchPolicyVersions(
    String schoolId,
    String policyId,
  ) => _policies(schoolId)
      .doc(policyId)
      .collection('versions')
      .orderBy('version', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => _policy(policyId, d.data())).toList());

  InstitutionPolicy _policy(String id, Map<String, dynamic> d) =>
      InstitutionPolicy(
        id: id,
        institutionId: d['institutionId'] as String,
        name: d['policyName'] as String? ?? '',
        createdBy: d['createdBy'] as String? ?? '',
        updatedBy: d['updatedBy'] as String? ?? '',
        changeReason: d['changeReason'] as String? ?? '',
        type: InstitutionPolicyType.values.byName(d['policyType'] as String),
        scope: PolicyScope.fromMap(
          Map<String, dynamic>.from(d['scope'] as Map? ?? const {}),
        ),
        configuration: Map<String, dynamic>.from(
          d['configuration'] as Map? ?? const {},
        ),
        status: PolicyStatus.values.byName(d['status'] as String? ?? 'draft'),
        version: (d['version'] as num?)?.toInt() ?? 1,
        effectiveFrom:
            (d['effectiveFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
        effectiveTo: (d['effectiveTo'] as Timestamp?)?.toDate(),
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
