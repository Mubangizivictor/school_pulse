import '../domain/entities/school_branding.dart';

/// No Isar/isar-model import here on purpose - see
/// branding_local_cache_mobile.dart for why. Mobile and web/stub
/// implementations are selected at compile time via
/// branding_local_cache_factory.dart's conditional import.
///
/// Best-effort local caching of the active school's branding so it paints
/// instantly on next launch. Web has no local database - get always
/// misses (BrandingBloc falls through to GetSchoolBranding) and save/clear
/// are no-ops.
abstract class BrandingLocalCache {
  Future<SchoolBranding?> get();
  Future<void> save(SchoolBranding branding);
  Future<void> clear();
}
