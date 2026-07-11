import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AlertModel>> getAlerts(List<String> studentIds);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AlertModel>> getAlerts(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    final snapshot = await firestore
        .collection('alerts')
        .where('studentId', whereIn: studentIds)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
  }
}
