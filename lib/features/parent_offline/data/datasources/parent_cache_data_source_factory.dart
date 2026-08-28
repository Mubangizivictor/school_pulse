import 'parent_cache_data_source.dart';
import 'parent_cache_data_source_web.dart'
    if (dart.library.io) 'parent_cache_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop - the web implementation ignores
/// it and returns a no-op cache (see ParentCacheDataSourceWeb doc).
ParentCacheDataSource createParentCacheDataSource({required dynamic isar}) =>
    impl.create(isar: isar);
