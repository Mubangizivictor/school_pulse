import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_visit_model.dart';

abstract class HealthRemoteDataSource {
  Future<List<HealthVisitModel>> getHealthVisits(String studentId);
  Future<List<HealthVisitModel>> getAllHealthVisits();
  Future<void> logHealthVisit(HealthVisitModel visit);
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final FirebaseFirestore firestore;

  HealthRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<HealthVisitModel>> getHealthVisits(String studentId) async {
    final snapshot = await firestore
        .collection('health_visits')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => HealthVisitModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<HealthVisitModel>> getAllHealthVisits() async {
    final snapshot = await firestore
        .collection('health_visits')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => HealthVisitModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> logHealthVisit(HealthVisitModel visit) async {
    await firestore.collection('health_visits').add(visit.toFirestore());
  }
}
