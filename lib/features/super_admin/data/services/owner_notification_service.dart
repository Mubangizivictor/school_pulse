import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/owner_notification.dart';

/// SaaS Owner notification client.
///
/// The feed is written server-side to `super_admin_notifications`. Critical
/// delivery diagnostics/test calls use authenticated Cloud Functions so the UI
/// can distinguish "no token", "email not configured" and real send failures.
class OwnerNotificationService {
  OwnerNotificationService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<OwnerNotification>> watchNotifications() {
    return _firestore
        .collection('super_admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OwnerNotification.fromJson({...doc.data(), 'id': doc.id}))
              .toList(growable: false),
        );
  }

  Future<List<OwnerNotification>> getNotifications() async {
    final snapshot = await _firestore
        .collection('super_admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    return snapshot.docs
        .map((doc) => OwnerNotification.fromJson({...doc.data(), 'id': doc.id}))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getHealth() async {
    final callable = _functions.httpsCallable('getOwnerNotificationHealth');
    final result = await callable.call<Map<String, dynamic>>();
    return Map<String, dynamic>.from(result.data);
  }

  Future<Map<String, dynamic>> sendTest() async {
    final callable = _functions.httpsCallable('testOwnerNotificationDelivery');
    final result = await callable.call<Map<String, dynamic>>();
    return Map<String, dynamic>.from(result.data);
  }
}
