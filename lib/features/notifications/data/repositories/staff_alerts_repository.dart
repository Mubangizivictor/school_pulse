import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    StreamSubscription? subDirect;
    StreamSubscription? subBroadcast;

    void emit() {
      final seen = <String>{};
      final merged =
          [...direct, ...broadcasts].where((a) => seen.add(a.id)).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (kDebugMode) {
        print('StaffAlertsRepository: Emitting ${merged.length} alerts');
      }
      if (!controller.isClosed) {
        controller.add(merged);
      }
    }

    controller = StreamController<List<StaffAlert>>.broadcast(
      onListen: () {
        if (kDebugMode) {
          print('StaffAlertsRepository: Watching alerts for $uid');
        }

        // Use a small delay to ensure the UI listener is fully attached
        // before we emit the initial empty state.
        Future.delayed(const Duration(milliseconds: 100), () => emit());

        subDirect = _watchDirect(uid).listen(
          (data) {
            direct = data;
            emit();
          },
          onError: (e) {
            if (kDebugMode) {
              print(
                'StaffAlertsRepository: Direct alerts error (Index likely building): $e',
              );
            }
            direct = [];
            emit();
          },
        );

        if (groups.isNotEmpty) {
          subBroadcast = _watchBroadcasts(groups).listen(
            (data) {
              broadcasts = data;
              emit();
            },
            onError: (e) {
              if (kDebugMode) {
                print('StaffAlertsRepository: Broadcast alerts error: $e');
              }
              broadcasts = [];
              emit();
            },
          );
        } else {
          emit(); // Trigger initial empty state if no groups
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

  Future<void> deleteAlert(String alertId) {
    return _firestore.collection('alerts').doc(alertId).delete();
  }
}
