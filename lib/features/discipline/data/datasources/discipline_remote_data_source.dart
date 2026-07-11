import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discipline_incident_model.dart';

abstract class DisciplineRemoteDataSource {
  Future<List<DisciplineIncidentModel>> getDisciplineIncidents(String studentId);
  Future<List<DisciplineIncidentModel>> getRecentDisciplineIncidents();
}

class DisciplineRemoteDataSourceImpl implements DisciplineRemoteDataSource {
  final FirebaseFirestore firestore;

  DisciplineRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DisciplineIncidentModel>> getDisciplineIncidents(String studentId) async {
    final snapshot = await firestore
        .collection('discipline_incidents')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => DisciplineIncidentModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<DisciplineIncidentModel>> getRecentDisciplineIncidents() async {
    final snapshot = await firestore
        .collection('discipline_incidents')
        .orderBy('date', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => DisciplineIncidentModel.fromFirestore(doc)).toList();
  }
}
