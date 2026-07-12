import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/gatekeeper_state.dart';

abstract class GatekeeperRemoteDataSource {
  Future<List<VisitorLog>> getRecentVisitors();
  Future<int> getStudentsInCount();
  Future<int> getStudentsOutCount();
  Future<void> logVisitor(VisitorLog visitor);
  Future<void> signExit(String visitorId);
}

class GatekeeperRemoteDataSourceImpl implements GatekeeperRemoteDataSource {
  final FirebaseFirestore firestore;

  GatekeeperRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<VisitorLog>> getRecentVisitors() async {
    final snapshot = await firestore
        .collection('visitor_logs')
        .orderBy('entryTime', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VisitorLog(
        id: doc.id,
        name: data['name'] ?? '',
        purpose: data['purpose'] ?? '',
        entryTime: (data['entryTime'] as Timestamp).toDate(),
        exitTime: data['exitTime'] != null ? (data['exitTime'] as Timestamp).toDate() : null,
        status: data['status'] ?? '',
      );
    }).toList();
  }

  @override
  Future<int> getStudentsInCount() async {
    // This would typically query a 'daily_attendance_summary' or similar
    final doc = await firestore.collection('stats').doc('attendance_summary').get();
    return doc.data()?['studentsIn'] ?? 0;
  }

  @override
  Future<int> getStudentsOutCount() async {
    final doc = await firestore.collection('stats').doc('attendance_summary').get();
    return doc.data()?['studentsOut'] ?? 0;
  }

  @override
  Future<void> logVisitor(VisitorLog visitor) async {
    await firestore.collection('visitor_logs').add({
      'name': visitor.name,
      'purpose': visitor.purpose,
      'entryTime': Timestamp.fromDate(visitor.entryTime),
      'status': 'Checked In',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signExit(String visitorId) async {
    await firestore.collection('visitor_logs').doc(visitorId).update({
      'exitTime': FieldValue.serverTimestamp(),
      'status': 'Checked Out',
    });
  }
}
