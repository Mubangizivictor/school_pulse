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
    });
  }

  Future<void> savePolicy(InstitutionPolicy policy) async {
    final ref = _policies(policy.institutionId).doc(policy.id);
    await firestore.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      final oldVersion = (existing.data()?['version'] as num?)?.toInt() ?? 0;
      transaction.set(ref, {
        ...policy.toMap(),
        'version': oldVersion + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      transaction.set(ref.collection('versions').doc('${oldVersion + 1}'), {
        ...policy.toMap(),
        'version': oldVersion + 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

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
