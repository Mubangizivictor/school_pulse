import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_info_model.dart';
import '../../presentation/bloc/transport_coordinator_state.dart';

abstract class TransportRemoteDataSource {
  Future<TransportInfoModel> getTransportInfo(String studentId);
  Future<List<BusRoute>> getActiveRoutes();
  Future<Map<String, dynamic>> getTransportStats();
  Future<void> startTrip(String routeId);
  Future<void> endTrip(String routeId);
  Future<void> logStudentPickup(String routeId, String studentId);
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
        id: doc.id,
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
    final doc = await firestore
        .collection('stats')
        .doc('transport_summary')
        .get();
    return doc.data() ?? {};
  }

  @override
  Future<void> startTrip(String routeId) async {
    final routeDoc = await firestore
        .collection('bus_routes')
        .doc(routeId)
        .get();
    final routeName = routeDoc.data()?['name'] ?? 'Your bus route';

    await firestore.collection('bus_routes').doc(routeId).update({
      'status': 'In Transit',
      'lastTripStart': FieldValue.serverTimestamp(),
    });

    // Create a trip record for logs
    await firestore.collection('trips').add({
      'routeId': routeId,
      'routeName': routeName,
      'startTime': FieldValue.serverTimestamp(),
      'status': 'Ongoing',
    });

    // Trigger notification for parents on this route
    // In a real app, we'd use FCM topics like 'route_routeId'
    await firestore.collection('broadcast_queue').add({
      'notification': {
        'title': 'Bus Trip Started',
        'body': 'The bus for route "$routeName" has started its journey.',
      },
      'targets': ['parents', 'route_$routeId'],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> endTrip(String routeId) async {
    await firestore.collection('bus_routes').doc(routeId).update({
      'status': 'Stationary',
      'lastTripEnd': FieldValue.serverTimestamp(),
    });

    final ongoingTrips = await firestore
        .collection('trips')
        .where('routeId', isEqualTo: routeId)
        .where('status', isEqualTo: 'Ongoing')
        .get();

    for (var doc in ongoingTrips.docs) {
      await doc.reference.update({
        'status': 'Completed',
        'endTime': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> logStudentPickup(String routeId, String studentId) async {
    await firestore.collection('pickup_logs').add({
      'routeId': routeId,
      'studentId': studentId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify the specific parent
    final studentDoc = await firestore
        .collection('students')
        .doc(studentId)
        .get();
    final parentId = studentDoc.data()?['parentId'];
    final studentName = studentDoc.data()?['name'] ?? 'Your child';

    if (parentId != null) {
      await firestore.collection('alerts').add({
        'userId': parentId,
        'title': 'Student Picked Up',
        'body': '$studentName has been picked up by the school bus.',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'transport',
      });

      // Also queue for actual push notification if tokens exist
      final tokensSnapshot = await firestore
          .collection('users')
          .doc(parentId)
          .collection('tokens')
          .get();

      for (var doc in tokensSnapshot.docs) {
        await firestore.collection('notification_queue').add({
          'token': doc.id,
          'notification': {
            'title': 'Student Picked Up',
            'body': '$studentName has been picked up by the school bus.',
          },
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
