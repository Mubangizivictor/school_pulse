import 'stores_assets_local_data_source.dart';
import 'stores_assets_local_data_source_stub.dart'
    if (dart.library.js_interop) 'stores_assets_local_data_source_web.dart'
    if (dart.library.io) 'stores_assets_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] only on web.
StoresAssetsLocalDataSource createStoresAssetsLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
