import '../domain/entities/school_branding.dart';
import 'branding_local_cache.dart';

BrandingLocalCache create({dynamic isar}) => const BrandingLocalCacheWeb();

/// No local database on web - always misses, save/clear are no-ops.
class BrandingLocalCacheWeb implements BrandingLocalCache {
  const BrandingLocalCacheWeb();

  @override
  Future<SchoolBranding?> get() async => null;

  @override
  Future<void> save(SchoolBranding branding) async {}

  @override
  Future<void> clear() async {}
}
