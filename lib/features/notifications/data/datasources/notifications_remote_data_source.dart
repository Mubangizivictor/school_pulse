import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';

abstract class NotificationsRemoteDataSource {
  /// [groups] are the broadcast target groups this parent belongs to (e.g.
  /// 'Parents', 'Class:P.1') - without it, BroadcastSmsScreen announcements
  /// never show up here even though they show up in the staff notification
  /// bell (see StaffAlertsRepository, which does the equivalent merge).
  Future<List<AlertModel>> getAlerts(List<String> studentIds, {List<String> groups = const []});
  Future<void> markAlertRead(String alertId, String uid);
  Future<void> sendNotification({
    required String title,
    required String body,
    required List<String> targetGroups,
    String? imageUrl,
  });
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AlertModel>> getAlerts(List<String> studentIds, {List<String> groups = const []}) async {
    if (studentIds.isEmpty && groups.isEmpty) return [];
    try {
      final results = await Future.wait([
        _getStudentAlerts(studentIds),
        _getBroadcastAlerts(groups),
      ]);
      final seen = <String>{};
      final merged = [...results[0], ...results[1]]
          .where((a) => seen.add(a.id))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return merged;
    } catch (e) {
      // This will print the Link to create the Parent Index in your terminal
      debugPrint('PARENT NOTIFICATION ERROR: $e');
      return []; // Return empty instead of hanging
    }
  }

  Future<List<AlertModel>> _getStudentAlerts(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    final snapshot = await firestore
        .collection('alerts')
        .where('studentId', whereIn: studentIds)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
  }

  Future<List<AlertModel>> _getBroadcastAlerts(List<String> groups) async {
    if (groups.isEmpty) return [];
    final snapshot = await firestore
        .collection('alerts')
        .where('targets', arrayContainsAny: groups)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> markAlertRead(String alertId, String uid) {
    return firestore.collection('alerts').doc(alertId).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String body,
    required List<String> targetGroups,
    String? imageUrl,
  }) async {
    final timestamp = FieldValue.serverTimestamp();

    // 1. Create the 'alert' document in Firestore
    await firestore.collection('alerts').add({
      'title': title,
      'body': body,
      'targets': targetGroups,
      'timestamp': timestamp,
      'type': 'Push',
      'status': 'sent',
      'imageUrl': imageUrl,
      'readBy': [],
    });

    // 2. Trigger FCM via broadcast_queue
    await firestore.collection('broadcast_queue').add({
      'notification': {
        'title': title,
        'body': body,
        'image': imageUrl,
      },
      'targets': targetGroups,
      'status': 'pending',
      'createdAt': timestamp,
    });
  }
}
