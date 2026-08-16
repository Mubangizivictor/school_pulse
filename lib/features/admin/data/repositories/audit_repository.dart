import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log.dart';

class AuditRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AuditLog>> watchRecentLogs({
    int limit = 10,
    required String schoolId,
  }) {
    return _firestore
        .collection('audit_logs')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLog.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> logAction({
    String? schoolId,
    required String title,
    required String description,
    required String iconName,
    required String colorHex,
    String? userId,
    String? relatedEntityId,
  }) async {
    await _firestore.collection('audit_logs').add({
      'schoolId': ?schoolId,
      'title': title,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'relatedEntityId': ?relatedEntityId,
    });
  }

  /// History for one related record (a role definition or role assignment
  /// id, say), newest first. Backs the Role Details "History" tab.
  Stream<List<AuditLog>> watchLogsForEntity({
    required String schoolId,
    required String relatedEntityId,
    int limit = 50,
  }) {
    return _firestore
        .collection('audit_logs')
        .where('schoolId', isEqualTo: schoolId)
        .where('relatedEntityId', isEqualTo: relatedEntityId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLog.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
