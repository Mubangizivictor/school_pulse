import 'package:isar/isar.dart';

part 'owner_notification_isar.g.dart';

/// Owner-only cached notification row.
///
/// Lives ONLY in the dedicated, per-owner Isar instance opened by
/// [OwnerNotificationIsarStore] (instance name
/// `owner_notifications_<ownerUid>`). It is never added to the app-wide
/// Isar schema list in `isar_bootstrap_mobile.dart`, so no school-role
/// code path can open, query or even name this collection.
///
/// Nothing sensitive is persisted: id, title, a short body, category /
/// severity tokens and timestamps. No payment amounts, no raw references,
/// no credentials.
@collection
class OwnerNotificationIsar {
  Id get isarId => fastHash(remoteId);

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index()
  late String ownerId;

  late String type;
  late String status;
  late String title;
  late String body;
  late String schoolName;

  /// [OwnerNotificationCategory.wire]
  late String category;

  /// [OwnerNotificationSeverity.name]
  late String severity;

  /// Already-masked reference string, or empty.
  late String reference;

  late bool platformHealthDegraded;

  late DateTime createdAt;

  DateTime? cachedAt;
}

/// FNV-1a 64-bit — the hash Isar's own docs recommend for turning a string
/// key into a stable [Id].
int fastHash(String string) {
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
