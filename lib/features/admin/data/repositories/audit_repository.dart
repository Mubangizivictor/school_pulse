import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log.dart';

class AuditRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AuditLog>> watchRecentLogs({int limit = 10, String? schoolId}) {
    Query<Map<String, dynamic>> query = _firestore.collection('audit_logs');
    if (schoolId != null && schoolId.isNotEmpty) {
      query = query.where('schoolId', isEqualTo: schoolId);
    }
    return query
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
  }) async {
    await _firestore.collection('audit_logs').add({
      'schoolId': ?schoolId,
      'title': title,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }
}
