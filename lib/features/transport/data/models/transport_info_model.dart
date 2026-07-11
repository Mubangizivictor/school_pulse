import '../../domain/entities/transport_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransportInfoModel extends TransportInfo {
  const TransportInfoModel({
    required super.studentId,
    required super.routeName,
    required super.stopName,
    required super.status,
  });

  factory TransportInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransportInfoModel(
      studentId: data['studentId'] ?? '',
      routeName: data['routeName'] ?? '',
      stopName: data['stopName'] ?? '',
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'routeName': routeName,
      'stopName': stopName,
      'status': status,
    };
  }
}
