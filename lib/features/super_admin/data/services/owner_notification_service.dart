import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/owner_notification.dart';
import '../../domain/entities/owner_notification_preferences.dart';
import '../mappers/owner_notification_preferences_mapper.dart';

/// SaaS Owner notification client.
///
/// The feed is written server-side to `super_admin_notifications`.
///
/// Owner notification *preferences* (channel toggles, quiet hours, digest
/// frequency) are a separate, client-writable document at
/// `super_admin_settings/{ownerId}` - unlike the notification feed itself,
/// which is server-write-only.
class OwnerNotificationService {
  OwnerNotificationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<OwnerNotification>> watchNotifications() {
    return _firestore
        .collection('super_admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    OwnerNotification.fromJson({...doc.data(), 'id': doc.id}),
              )
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

  /// The signed-in owner's uid, or null if nobody is signed in.
  String? get currentOwnerId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _settingsDoc(String ownerId) =>
      _firestore.collection('super_admin_settings').doc(ownerId);

  /// Streams the owner's notification preferences, defaulting to
  /// [OwnerNotificationPreferences.defaults] until the document (or the
  /// `notification_preferences` field within it) exists.
  Stream<OwnerNotificationPreferences> watchPreferences(String ownerId) {
    return _settingsDoc(ownerId).snapshots().map((snapshot) {
      final data = snapshot.data();
      final prefs = data?[OwnerNotificationPreferencesMapper.fieldName];
      return OwnerNotificationPreferencesMapper.fromFirestore(
        prefs is Map ? Map<String, dynamic>.from(prefs) : null,
        ownerId,
      );
    });
  }

  Future<OwnerNotificationPreferences> getPreferences(String ownerId) async {
    final snapshot = await _settingsDoc(ownerId).get();
    final data = snapshot.data();
    final prefs = data?[OwnerNotificationPreferencesMapper.fieldName];
    return OwnerNotificationPreferencesMapper.fromFirestore(
      prefs is Map ? Map<String, dynamic>.from(prefs) : null,
      ownerId,
    );
  }

  Future<void> savePreferences(OwnerNotificationPreferences preferences) {
    return _settingsDoc(preferences.ownerId).set({
      OwnerNotificationPreferencesMapper.fieldName:
          OwnerNotificationPreferencesMapper.toFirestore(preferences),
    }, SetOptions(merge: true));
  }
}
