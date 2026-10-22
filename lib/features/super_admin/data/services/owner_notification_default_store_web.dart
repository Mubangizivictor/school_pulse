import 'owner_notification_offline_store.dart';

/// Web: SharedPreferences-backed cache. Never imports the Isar store, so
/// dart2js never sees its 64-bit hash constants.
OwnerNotificationCacheStore createDefaultOwnerNotificationStore() =>
    OwnerNotificationOfflineStore();
