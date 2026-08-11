import 'package:isar/isar.dart';
import '../../data/models/notification_token_isar.dart';
import 'token_local_cache.dart';

TokenLocalCache create({dynamic isar}) => TokenLocalCacheMobile(isar as Isar);

TokenRecord _toRecord(NotificationTokenIsar r) => TokenRecord(
  token: r.token,
  userId: r.userId,
  schoolId: r.schoolId,
  platform: r.platform,
  publishedAt: r.publishedAt,
  lastSeenAt: r.lastSeenAt,
  pendingRevocation: r.pendingRevocation,
  subscribedTopics: r.subscribedTopics,
);

class TokenLocalCacheMobile implements TokenLocalCache {
  final Isar isar;

  TokenLocalCacheMobile(this.isar);

  @override
  Future<TokenRecord?> findByTokenAndUser(String token, String userId) async {
    final row = await isar.notificationTokenIsars
        .filter()
        .tokenEqualTo(token)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<void> upsert(TokenRecord record) async {
    await isar.writeTxn(() async {
      final existing = await isar.notificationTokenIsars
          .filter()
          .tokenEqualTo(record.token)
          .and()
          .userIdEqualTo(record.userId)
          .findFirst();
      if (existing != null) {
        existing.lastSeenAt = record.lastSeenAt;
        existing.publishedAt = record.publishedAt ?? existing.publishedAt;
        existing.pendingRevocation = record.pendingRevocation;
        existing.subscribedTopics = record.subscribedTopics;
        await isar.notificationTokenIsars.put(existing);
      } else {
        final row = NotificationTokenIsar.create(
          token: record.token,
          userId: record.userId,
          schoolId: record.schoolId,
          platform: record.platform,
          lastSeenAt: record.lastSeenAt ?? DateTime.now(),
        );
        row.publishedAt = record.publishedAt;
        await isar.notificationTokenIsars.put(row);
      }
    });
  }

  @override
  Future<List<TokenRecord>> findByUser(String userId) async {
    final rows = await isar.notificationTokenIsars
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<void> deleteByToken(String token, String userId) async {
    await isar.writeTxn(() async {
      final row = await isar.notificationTokenIsars
          .filter()
          .tokenEqualTo(token)
          .and()
          .userIdEqualTo(userId)
          .findFirst();
      if (row != null) {
        await isar.notificationTokenIsars.delete(row.id);
      }
    });
  }

  @override
  Future<List<TokenRecord>> findPendingRevocations() async {
    final rows = await isar.notificationTokenIsars
        .filter()
        .pendingRevocationEqualTo(true)
        .findAll();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<TokenRecord?> mostRecentForUser(String userId) async {
    final row = await isar.notificationTokenIsars
        .filter()
        .userIdEqualTo(userId)
        .sortByLastSeenAtDesc()
        .findFirst();
    return row == null ? null : _toRecord(row);
  }
}
