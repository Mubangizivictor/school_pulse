import 'token_local_cache.dart';

TokenLocalCache create({dynamic isar}) => const TokenLocalCacheWeb();

/// No local database and no meaningful "retry next launch" story for a
/// browser tab - the Firestore writes in NotificationTokenManager already
/// happen regardless of this cache, so every method here is a no-op/empty.
class TokenLocalCacheWeb implements TokenLocalCache {
  const TokenLocalCacheWeb();

  @override
  Future<TokenRecord?> findByTokenAndUser(String token, String userId) async =>
      null;
  @override
  Future<void> upsert(TokenRecord record) async {}
  @override
  Future<List<TokenRecord>> findByUser(String userId) async => [];
  @override
  Future<void> deleteByToken(String token, String userId) async {}
  @override
  Future<List<TokenRecord>> findPendingRevocations() async => [];
  @override
  Future<TokenRecord?> mostRecentForUser(String userId) async => null;
}
