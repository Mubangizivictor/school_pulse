import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes the SaaS owner's security preferences.
///
/// Persisted at `super_admin_settings/{ownerId}` under a `security`
/// sub-map, so this document can be shared with sibling owner-settings
/// features (e.g. notification preferences) without field collisions -
/// each feature owns its own top-level key on the same doc.
abstract class SecuritySettingsRemoteDataSource {
  /// Streams the raw `security` map for [ownerId]. Emits an empty map if
  /// the document or the `security` key doesn't exist yet (first run).
  Stream<Map<String, dynamic>> watchSecuritySettings(String ownerId);

  /// Merges [changes] into the `security` sub-map for [ownerId], creating
  /// the parent document if needed.
  Future<void> updateSecuritySettings(
    String ownerId,
    Map<String, dynamic> changes,
  );

  /// Writes a security-relevant audit entry to the same
  /// `super_admin_audit_logs` collection the rest of the owner console
  /// audit trail uses, so these actions show up in Audit Logs too.
  Future<void> logSecurityEvent({
    required String ownerId,
    required String action,
    String? reason,
    Map<String, dynamic> metadata = const {},
  });
}

class SecuritySettingsRemoteDataSourceImpl
    implements SecuritySettingsRemoteDataSource {
  final FirebaseFirestore firestore;

  SecuritySettingsRemoteDataSourceImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> _doc(String ownerId) =>
      firestore.collection('super_admin_settings').doc(ownerId);

  @override
  Stream<Map<String, dynamic>> watchSecuritySettings(String ownerId) {
    return _doc(ownerId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return const {};
      final security = data['security'];
      if (security is Map<String, dynamic>) return security;
      if (security is Map) return Map<String, dynamic>.from(security);
      return const {};
    });
  }

  @override
  Future<void> updateSecuritySettings(
    String ownerId,
    Map<String, dynamic> changes,
  ) async {
    final entries = changes.map(
      (key, value) => MapEntry('security.$key', value),
    );
    await _doc(ownerId).set(entries, SetOptions(merge: true));
  }

  @override
  Future<void> logSecurityEvent({
    required String ownerId,
    required String action,
    String? reason,
    Map<String, dynamic> metadata = const {},
  }) async {
    final id = firestore.collection('super_admin_audit_logs').doc().id;
    await firestore.collection('super_admin_audit_logs').doc(id).set({
      'id': id,
      'ownerId': ownerId,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
      'device': 'Owner Console',
      'reason': ?reason,
      'metadata': metadata,
    });
  }
}
