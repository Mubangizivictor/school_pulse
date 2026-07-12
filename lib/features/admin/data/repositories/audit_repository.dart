import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log.dart';

class AuditRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AuditLog>> watchRecentLogs({int limit = 10}) {
    return _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLog.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> logAction({
    required String title,
    required String description,
    required String iconName,
    required String colorHex,
    String? userId,
  }) async {
    await _firestore.collection('audit_logs').add({
      'title': title,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }
}
