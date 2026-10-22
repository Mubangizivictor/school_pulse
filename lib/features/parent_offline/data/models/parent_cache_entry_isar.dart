import 'package:isar/isar.dart';

part 'parent_cache_entry_isar.g.dart';

/// Generic tenant + parent + (optional) learner-scoped cache slot for the
/// mobile Parent Portal. Every offline-visible parent screen (home pulse,
/// academics, fees/payment instructions, receipts, messages, announcements,
/// transport/boarding/health/calendar) writes its last-known-good payload
/// here as a JSON blob under a screen-specific [cacheKey], instead of each
/// feature growing its own bespoke Isar collection. This keeps the cache
/// layer additive - no existing repository/BLoC has to change shape to gain
/// offline support, it only needs to also call
/// [ParentCacheDataSource.put] after a successful remote fetch and
/// [ParentCacheDataSource.get] as a fallback when the network is down.
///
/// [compositeKey] is `tenantId|parentId|learnerId|cacheKey` (learnerId is
/// the empty string for parent-level, non-learner-scoped data such as the
/// parent's own profile) - every read/write goes through this key so a
/// tenant/parent/learner mismatch can never surface another party's data.
@collection
class ParentCacheEntryIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String compositeKey;

  @Index()
  late String tenantId;

  @Index()
  late String parentId;

  @Index()
  late String learnerId;

  late String cacheKey;

  /// JSON-encoded payload as produced by the caller's own model's `toJson`.
  late String payloadJson;

  late DateTime updatedAt;

  static String buildCompositeKey({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
  }) => '$tenantId|$parentId|$learnerId|$cacheKey';
}
