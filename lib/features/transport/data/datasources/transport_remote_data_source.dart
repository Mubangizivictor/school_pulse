import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_info_model.dart';

abstract class TransportRemoteDataSource {
  Future<TransportInfoModel> getTransportInfo(String studentId);
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
}
