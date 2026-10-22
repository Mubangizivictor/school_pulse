import 'package:isar/isar.dart';

part 'owner_notification_queue_isar.g.dart';

/// A durable, replayable *safe* owner action, persisted in the dedicated
/// per-owner Isar instance (`owner_notifications_<ownerUid>`).
///
/// Only safe actions are ever stored here: mark read, mark all read,
/// archive/delete one, clear all, and preference updates. Sensitive owner
/// actions (approve payment, alter subscription, change school lifecycle /
/// domains / permissions) never touch this queue and are blocked while
/// offline.
@collection
class OwnerNotificationQueueIsar {
  Id get isarId => fastHashQueue(idempotencyKey);

  @Index(unique: true, replace: true)
  late String idempotencyKey;

  @Index()
  late String ownerId;

  /// [OwnerQueuedActionType.name]
  late String type;

  String? notificationId;

  /// JSON-encoded preference payload for `updatePreferences`, else null.
  String? payloadJson;

  late DateTime createdAt;

  late int attempts;

  String? lastError;
}

int fastHashQueue(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
