import 'token_local_cache.dart';
import 'token_local_cache_web.dart'
    if (dart.library.io) 'token_local_cache_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
TokenLocalCache createTokenLocalCache({required dynamic isar}) =>
    impl.create(isar: isar);
