import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/owner_notification.dart';

/// Read-only client for `super_admin_notifications`. The collection is
/// written exclusively by server-side Cloud Functions (see
/// firestore.rules); this service never creates, updates, or deletes a
/// notification document.
class OwnerNotificationService {
  OwnerNotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<OwnerNotification>> getNotifications() async {
    final snapshot = await _firestore
        .collection('super_admin_notifications')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OwnerNotification.fromJson({...doc.data(), 'id': doc.id}))
        .toList(growable: false);
  }
}
