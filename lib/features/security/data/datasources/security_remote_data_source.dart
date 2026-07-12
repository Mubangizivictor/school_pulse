import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/security_state.dart';

abstract class SecurityRemoteDataSource {
  Future<Map<String, dynamic>> getSecurityStats();
  Future<List<SecurityAlert>> getRecentAlerts();
}

class SecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  final FirebaseFirestore firestore;

  SecurityRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Map<String, dynamic>> getSecurityStats() async {
    final doc = await firestore.collection('stats').doc('security_summary').get();
    return doc.data() ?? {};
  }

  @override
  Future<List<SecurityAlert>> getRecentAlerts() async {
    final snapshot = await firestore
        .collection('security_alerts')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SecurityAlert(
        title: data['title'] ?? '',
        time: data['time'] ?? '', // Ideally this would be calculated from a Timestamp
        severity: data['severity'] ?? 'low',
      );
    }).toList();
  }
}
