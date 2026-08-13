import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/procurement_request.dart';
import 'stores_assets_local_data_source.dart';
import 'stores_assets_remote_data_source.dart';

StoresAssetsLocalDataSource create({dynamic isar, dynamic remote}) =>
    StoresAssetsLocalDataSourceWeb(remote as StoresAssetsRemoteDataSource);

/// No local database on web. StoresAssetsRepositoryImpl always has
/// connectivity in practice on web (no offline warehouse-scanning use
/// case), so it always takes its "fetch remote, cache" branch - this
/// class's get* methods are consequently not on any real read path
/// (mirroring StructureLocalDataSourceWeb's reasoning) and return
/// empty/delegate-and-filter for the few single-item lookups that have no
/// direct remote equivalent. cache*/save* are no-ops; getUnsynced* always
/// empty since every write already went to Firestore.
class StoresAssetsLocalDataSourceWeb implements StoresAssetsLocalDataSource {
  final StoresAssetsRemoteDataSource remote;

  StoresAssetsLocalDataSourceWeb(this.remote);

  @override
  Future<List<InventoryItem>> getInventoryItems() async => [];
  @override
  Future<void> cacheInventoryItems(List<InventoryItem> items) async {}
  @override
  Future<void> saveStockMovement(
    StockMovement movement, {
    bool isSynced = true,
  }) async {}
  @override
  Future<List<StockMovement>> getRecentMovements() async => [];

  @override
  Future<List<Asset>> getAssets() async => [];
  @override
  Future<void> cacheAssets(List<Asset> assets) async {}
  @override
  Future<Asset?> getAssetByQr(String qrCode) async {
    final assets = await remote.getAssets();
    for (final asset in assets) {
      if (asset.qrCode == qrCode) return asset;
    }
    return null;
  }

  @override
  Future<void> saveAsset(Asset asset, {bool isSynced = true}) async {}
  @override
  Future<Asset?> getAssetById(String assetId) async {
    final assets = await remote.getAssets();
    for (final asset in assets) {
      if (asset.id == assetId) return asset;
    }
    return null;
  }

  @override
  Future<void> saveInventoryItem(
    InventoryItem item, {
    bool isSynced = true,
  }) async {}

  @override
  Future<List<Supplier>> getSuppliers() async => [];
  @override
  Future<void> cacheSuppliers(List<Supplier> suppliers) async {}
  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async => [];
  @override
  Future<void> cachePurchaseOrders(List<PurchaseOrder> orders) async {}
  @override
  Future<List<ProcurementRequest>> getProcurementRequests() async => [];
  @override
  Future<void> cacheProcurementRequests(
    List<ProcurementRequest> requests,
  ) async {}
  @override
  Future<void> saveProcurementRequest(
    ProcurementRequest request, {
    bool isSynced = true,
  }) async {}
  @override
  Future<ProcurementRequest?> getProcurementRequestById(
    String requestId,
  ) async => null;

  @override
  Future<List<RepairRecord>> getRepairRecords() async => [];
  @override
  Future<void> cacheRepairRecords(List<RepairRecord> records) async {}
  @override
  Future<List<MaintenanceRecord>> getMaintenanceSchedule() async => [];
  @override
  Future<void> cacheMaintenanceSchedule(
    List<MaintenanceRecord> records,
  ) async {}

  @override
  Future<List<Asset>> getUnsyncedAssets() async => [];
  @override
  Future<List<StockMovement>> getUnsyncedMovements() async => [];
  @override
  Future<List<ProcurementRequest>> getUnsyncedProcurementRequests() async => [];
}
