import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:school_pulse/core/network/network_info.dart';

import '../../domain/entities/owner_notification.dart';
import '../../domain/entities/owner_notification_preferences.dart';
import '../mappers/owner_notification_preferences_mapper.dart';
import 'owner_notification_offline_store.dart';

/// SaaS Owner notification client.
///
/// The feed is written server-side to `super_admin_notifications` and read
/// back directly (that collection is owner-readable, scoped per-owner by an
/// `ownerId` field the Firestore rule enforces). Every *mutation* -
/// mark-read, mark-all-read, delete, clear - goes through owner-only
/// callables in `public_functions/owner_notifications_admin.js`; the client
/// never writes a feed document.
///
/// Preferences are read and written exclusively through the
/// `getOwnerNotificationPreferences` / `updateOwnerNotificationPreferences`
/// callables. The backing document (`platform_owner_settings/{ownerId}`) is
/// Admin-SDK-only.
///
/// Offline: when an [OwnerNotificationOfflineStore] is supplied, feed reads
/// fall back to the owner-scoped cache and safe mutations queue while
/// offline, replaying on reconnect. Sensitive owner actions never touch
/// this service and are never cached or queued.
class OwnerNotificationService {
  OwnerNotificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    OwnerNotificationOfflineStore? offlineStore,
    NetworkInfo? networkInfo,
    bool enableOffline = true,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1'),
       _offline = offlineStore ??
           (enableOffline ? OwnerNotificationOfflineStore() : null),
       _network = networkInfo ??
           (enableOffline
               ? (kIsWeb
                     ? const WebNetworkInfo()
                     : NetworkInfoImpl(InternetConnectionChecker()))
               : null);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final OwnerNotificationOfflineStore? _offline;
  final NetworkInfo? _network;

  static const _feedCollection = 'super_admin_notifications';

  Query<Map<String, dynamic>> _feedQuery() {
    final uid = currentOwnerId;
    if (uid != null && uid.isNotEmpty) {
      return _firestore
          .collection(_feedCollection)
          .where('ownerId', whereIn: [uid, ''])
          .orderBy('createdAt', descending: true)
          .limit(100);
    }
    return _firestore
        .collection(_feedCollection)
        .orderBy('createdAt', descending: true)
        .limit(100);
  }

  Stream<List<OwnerNotification>> watchNotifications() {
    return _feedQuery().snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => OwnerNotification.fromJson({...doc.data(), 'id': doc.id}))
          .toList(growable: false);
      final ownerId = currentOwnerId;
      final store = _offline;
      if (ownerId != null && store != null) {
        // Fire-and-forget: keep the owner-scoped cache warm and evict any
        // row/queued action that no longer exists server-side.
        store.writeCache(ownerId, items);
        store.reconcile(ownerId, items.map((n) => n.id).toSet());
      }
      return items;
    });
  }

  Future<List<OwnerNotification>> getNotifications() async {
    final ownerId = currentOwnerId;
    try {
      final snapshot = await _feedQuery().get();
      final items = snapshot.docs
          .map((doc) => OwnerNotification.fromJson({...doc.data(), 'id': doc.id}))
          .toList(growable: false);
      if (ownerId != null && _offline != null) {
        await _offline.writeCache(ownerId, items);
      }
      return items;
    } catch (error) {
      // Offline / unreachable: serve the owner-scoped cache if we have one.
      if (ownerId != null && _offline != null) {
        final cached = await _offline.readCache(ownerId);
        if (cached.isNotEmpty) return cached;
      }
      rethrow;
    }
  }

  /// Cached feed for an offline-first render before the live stream resolves.
  Future<List<OwnerNotification>> cachedNotifications() async {
    final ownerId = currentOwnerId;
    if (ownerId == null || _offline == null) return const [];
    return _offline.readCache(ownerId);
  }

  Future<int> pendingActionCount() async {
    final ownerId = currentOwnerId;
    if (ownerId == null || _offline == null) return 0;
    return _offline.pendingCount(ownerId);
  }

  /// The signed-in owner's uid, or null if nobody is signed in.
  String? get currentOwnerId => _auth.currentUser?.uid;

  Future<bool> get _online async => (await _network?.isConnected) ?? true;

  // ---- Feed mutations (owner-only callables, offline-queued) ----------

  Future<void> markRead(String notificationId) async {
    await _mutate(
      online: () => _functions
          .httpsCallable('markOwnerNotificationRead')
          .call({'id': notificationId}),
      queue: (store, ownerId) => store.enqueue(
        ownerId: ownerId,
        type: OwnerQueuedActionType.markRead,
        notificationId: notificationId,
      ),
    );
  }

  Future<int> markAllRead() async {
    final result = await _mutate(
      online: () => _functions.httpsCallable('markAllOwnerNotificationsRead').call(),
      queue: (store, ownerId) => store.enqueue(
        ownerId: ownerId,
        type: OwnerQueuedActionType.markAllRead,
      ),
    );
    final data = result?.data;
    if (data is Map && data['updated'] is num) {
      return (data['updated'] as num).toInt();
    }
    return 0;
  }

  Future<void> deleteNotification(String notificationId) async {
    await _mutate(
      online: () => _functions
          .httpsCallable('deleteOwnerNotification')
          .call({'id': notificationId}),
      queue: (store, ownerId) => store.enqueue(
        ownerId: ownerId,
        type: OwnerQueuedActionType.delete,
        notificationId: notificationId,
      ),
    );
  }

  Future<int> clearAll() async {
    final result = await _mutate(
      online: () => _functions.httpsCallable('clearOwnerNotifications').call(),
      queue: (store, ownerId) => store.enqueue(
        ownerId: ownerId,
        type: OwnerQueuedActionType.clearAll,
      ),
    );
    final data = result?.data;
    if (data is Map && data['deleted'] is num) {
      return (data['deleted'] as num).toInt();
    }
    return 0;
  }

  /// Runs [online] when connected; otherwise records the safe action in the
  /// owner queue (if an offline store is configured) and returns null so the
  /// caller can show an "applies when you reconnect" state.
  Future<HttpsCallableResult?> _mutate({
    required Future<HttpsCallableResult> Function() online,
    required Future<void> Function(
      OwnerNotificationOfflineStore store,
      String ownerId,
    ) queue,
  }) async {
    final store = _offline;
    final ownerId = currentOwnerId;
    if (store != null && ownerId != null && !(await _online)) {
      await queue(store, ownerId);
      return null;
    }
    try {
      return await online();
    } catch (error) {
      // A transient network failure at call time also queues, when possible.
      if (store != null && ownerId != null && _looksTransient(error)) {
        await queue(store, ownerId);
        return null;
      }
      rethrow;
    }
  }

  bool _looksTransient(Object error) {
    final v = error.toString().toLowerCase();
    return v.contains('unavailable') ||
        v.contains('network') ||
        v.contains('deadline') ||
        v.contains('timeout');
  }

  /// Replays queued safe actions in order. Call on reconnect / app resume.
  Future<OwnerQueueSyncResult> syncPending() async {
    final store = _offline;
    final ownerId = currentOwnerId;
    if (store == null || ownerId == null) {
      return const OwnerQueueSyncResult(synced: 0, dropped: 0, remaining: 0);
    }
    return store.sync(
      ownerId: ownerId,
      send: (action) async {
        try {
          switch (action.type) {
            case OwnerQueuedActionType.markRead:
              await _functions
                  .httpsCallable('markOwnerNotificationRead')
                  .call({'id': action.notificationId});
            case OwnerQueuedActionType.markAllRead:
              await _functions
                  .httpsCallable('markAllOwnerNotificationsRead')
                  .call();
            case OwnerQueuedActionType.delete:
              await _functions
                  .httpsCallable('deleteOwnerNotification')
                  .call({'id': action.notificationId});
            case OwnerQueuedActionType.clearAll:
              await _functions.httpsCallable('clearOwnerNotifications').call();
            case OwnerQueuedActionType.updatePreferences:
              await _functions
                  .httpsCallable('updateOwnerNotificationPreferences')
                  .call({'notificationPreferences': action.payload});
          }
        } on FirebaseFunctionsException catch (e) {
          // Permanent: the target is gone or we are not allowed. Drop it
          // rather than retrying forever. `not-found` on a delete/mark is
          // effectively success (already removed).
          if (e.code == 'not-found' ||
              e.code == 'permission-denied' ||
              e.code == 'unauthenticated' ||
              e.code == 'invalid-argument') {
            throw OwnerPermanentSyncError(e.code);
          }
          rethrow;
        }
      },
    );
  }

  /// Wipes the owner-scoped cache + queue. Call on logout, account switch,
  /// role loss or session revocation.
  Future<void> clearOfflineState({String? ownerId}) async {
    final store = _offline;
    if (store == null) return;
    final id = ownerId ?? currentOwnerId;
    if (id != null) {
      await store.clearForOwner(id);
    } else {
      await store.clearEverything();
    }
  }

  // ---- Preferences (owner-only callables) -----------------------------

  Future<OwnerNotificationPreferences> getPreferences(String ownerId) async {
    final result = await _functions
        .httpsCallable('getOwnerNotificationPreferences')
        .call();
    return _prefsFromCallable(result.data, ownerId);
  }

  Future<OwnerNotificationPreferences> savePreferences(
    OwnerNotificationPreferences preferences,
  ) async {
    final payload =
        OwnerNotificationPreferencesMapper.toCallablePayload(preferences);
    final store = _offline;
    // Preference updates are a safe queued action too, but only when a
    // store is configured and we're offline.
    if (store != null && !(await _online)) {
      await store.enqueue(
        ownerId: preferences.ownerId,
        type: OwnerQueuedActionType.updatePreferences,
        payload: payload,
      );
      return preferences;
    }
    final result = await _functions
        .httpsCallable('updateOwnerNotificationPreferences')
        .call({'notificationPreferences': payload});
    return _prefsFromCallable(result.data, preferences.ownerId);
  }

  OwnerNotificationPreferences _prefsFromCallable(Object? data, String ownerId) {
    if (data is Map && data['notificationPreferences'] is Map) {
      return OwnerNotificationPreferencesMapper.fromCallable(
        Map<String, dynamic>.from(data['notificationPreferences'] as Map),
        ownerId,
      );
    }
    return OwnerNotificationPreferences.defaults(ownerId);
  }
}
