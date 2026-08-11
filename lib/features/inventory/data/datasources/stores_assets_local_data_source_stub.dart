import 'stores_assets_local_data_source.dart';
import 'stores_assets_local_data_source_web.dart';
import 'stores_assets_remote_data_source.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// reuses the web implementation's empty/delegate-and-filter behavior as
/// the safest default.
StoresAssetsLocalDataSource create({dynamic isar, dynamic remote}) =>
    StoresAssetsLocalDataSourceWeb(remote as StoresAssetsRemoteDataSource);
