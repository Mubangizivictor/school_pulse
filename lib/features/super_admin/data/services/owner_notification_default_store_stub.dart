import 'owner_notification_isar_store.dart';
import 'owner_notification_store.dart';

/// Non-web (mobile/desktop): the durable, per-owner Isar-backed cache.
OwnerNotificationCacheStore createDefaultOwnerNotificationStore() =>
    OwnerNotificationIsarStore();
