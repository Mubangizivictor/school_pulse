import 'branding_local_cache.dart';
import 'branding_local_cache_web.dart'
    if (dart.library.io) 'branding_local_cache_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
BrandingLocalCache createBrandingLocalCache({required dynamic isar}) =>
    impl.create(isar: isar);
