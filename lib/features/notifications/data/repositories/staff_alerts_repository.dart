import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_alert.dart';

/// Reads the same Firestore 'alerts' collection that NotificationService
/// writes to (broadcast_sms_screen / sendDirectNotification), and merges
/// the "sent directly to me" and "broadcast to my group" streams into one
/// feed for the staff notification bell.
class StaffAlertsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<StaffAlert>> _watchDirect(String uid) {
    return _firestore
        .collection('alerts')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(StaffAlert.fromDoc).toList());
  }

  Stream<List<StaffAlert>> _watchBroadcasts(List<String> groups) {
    if (groups.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('alerts')
        .where('targets', arrayContainsAny: groups)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(StaffAlert.fromDoc).toList());
  }

  /// Combines both streams client-side (no rxdart dependency needed) -
  /// re-emits the merged, de-duped, timestamp-sorted list whenever either
  /// source stream updates.
  Stream<List<StaffAlert>> watchAllForUser({
    required String uid,
    required List<String> groups,
  }) {
    late final StreamController<List<StaffAlert>> controller;
    List<StaffAlert> direct = [];
    List<StaffAlert> broadcasts = [];
    bool hasDirect = false;
    bool hasBroadcast = groups.isEmpty;
    StreamSubscription? subDirect;
    StreamSubscription? subBroadcast;

    void emit() {
      if (!hasDirect || !hasBroadcast) return;
      final seen = <String>{};
      final merged = [...direct, ...broadcasts].where((a) => seen.add(a.id)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      controller.add(merged);
    }

    controller = StreamController<List<StaffAlert>>.broadcast(
      onListen: () {
        subDirect = _watchDirect(uid).listen(
          (data) {
            direct = data;
            hasDirect = true;
            emit();
          },
          onError: controller.addError,
        );
        if (groups.isNotEmpty) {
          subBroadcast = _watchBroadcasts(groups).listen(
            (data) {
              broadcasts = data;
              hasBroadcast = true;
              emit();
            },
            onError: controller.addError,
          );
        }
      },
      onCancel: () {
        subDirect?.cancel();
        subBroadcast?.cancel();
      },
    );
    return controller.stream;
  }

  Future<void> markRead(String alertId, String uid) {
    return _firestore.collection('alerts').doc(alertId).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> markAllRead(List<StaffAlert> alerts, String uid) async {
    final batch = _firestore.batch();
    for (final a in alerts) {
      if (!a.isReadBy(uid)) {
        batch.update(_firestore.collection('alerts').doc(a.id), {
          'readBy': FieldValue.arrayUnion([uid]),
        });
      }
    }
    await batch.commit();
  }
}
