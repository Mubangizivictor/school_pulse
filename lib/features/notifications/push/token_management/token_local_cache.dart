/// Plain (non-Isar) local bookkeeping record for one device's FCM token -
/// see notification_token_isar.dart (mobile-only now) for the persisted
/// shape. Mutable to match the existing call sites, which mutate fields in
/// place rather than reconstructing.
class TokenRecord {
  String token;
  String userId;
  String schoolId;
  String platform;
  DateTime? publishedAt;
  DateTime? lastSeenAt;
  bool pendingRevocation;
  List<String> subscribedTopics;

  TokenRecord({
    required this.token,
    required this.userId,
    required this.schoolId,
    required this.platform,
    this.publishedAt,
    this.lastSeenAt,
    this.pendingRevocation = false,
    this.subscribedTopics = const [],
  });
}

/// No Isar/isar-model import here on purpose - see
/// token_local_cache_mobile.dart for why. Mobile and web/stub
/// implementations are selected at compile time via
/// token_local_cache_factory.dart's conditional import.
///
/// This is a local retry-queue/bookkeeping layer for FCM token
/// publish/revocation - the Firestore writes in NotificationTokenManager
/// happen regardless of this cache. Web has no local database and no
/// meaningful "retry revocation next launch" story for a browser tab, so
/// all methods are no-ops/empty there.
abstract class TokenLocalCache {
  Future<TokenRecord?> findByTokenAndUser(String token, String userId);
  Future<void> upsert(TokenRecord record);
  Future<List<TokenRecord>> findByUser(String userId);
  Future<void> deleteByToken(String token, String userId);
  Future<List<TokenRecord>> findPendingRevocations();
  Future<TokenRecord?> mostRecentForUser(String userId);
}
