import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_info_model.dart';
import '../../presentation/bloc/transport_coordinator_state.dart';

abstract class TransportRemoteDataSource {
  Future<TransportInfoModel> getTransportInfo(String studentId);
  Future<List<BusRoute>> getActiveRoutes();
  Future<Map<String, dynamic>> getTransportStats();
}

class TransportRemoteDataSourceImpl implements TransportRemoteDataSource {
  final FirebaseFirestore firestore;

  TransportRemoteDataSourceImpl({required this.firestore});

  @override
  Future<TransportInfoModel> getTransportInfo(String studentId) async {
    final snapshot = await firestore
        .collection('transport')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('Transport info not found');
    }
    
    return TransportInfoModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<List<BusRoute>> getActiveRoutes() async {
    final snapshot = await firestore.collection('bus_routes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BusRoute(
        name: data['name'] ?? '',
        busNumber: data['busNumber'] ?? '',
        driver: data['driver'] ?? '',
        studentCount: data['studentCount'] ?? 0,
        status: data['status'] ?? 'Stationary',
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getTransportStats() async {
    final doc = await firestore.collection('stats').doc('transport_summary').get();
    return doc.data() ?? {};
  }
}
