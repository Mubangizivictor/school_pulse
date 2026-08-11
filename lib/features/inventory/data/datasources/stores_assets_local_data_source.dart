import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/procurement_request.dart';

/// No Isar/isar-model import here on purpose - see
/// stores_assets_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// stores_assets_local_data_source_factory.dart's conditional import.
///
/// Mobile is offline-first for warehouse/asset-scanning workflows done on
/// a device without signal - writes land here first, with a sync queue
/// (isSynced/getUnsynced*). Web writes go straight to Firestore, so
/// getUnsynced* always returns empty there.
abstract class StoresAssetsLocalDataSource {
  // Inventory
  Future<List<InventoryItem>> getInventoryItems();
  Future<void> cacheInventoryItems(List<InventoryItem> items);
  Future<void> saveStockMovement(StockMovement movement, {bool isSynced});
  Future<List<StockMovement>> getRecentMovements();

  // Assets
  Future<List<Asset>> getAssets();
  Future<void> cacheAssets(List<Asset> assets);
  Future<Asset?> getAssetByQr(String qrCode);
  Future<void> saveAsset(Asset asset, {bool isSynced});
  Future<Asset?> getAssetById(String assetId);
  Future<void> saveInventoryItem(InventoryItem item, {bool isSynced});

  // Procurement
  Future<List<Supplier>> getSuppliers();
  Future<void> cacheSuppliers(List<Supplier> suppliers);
  Future<List<PurchaseOrder>> getPurchaseOrders();
  Future<void> cachePurchaseOrders(List<PurchaseOrder> orders);
  Future<List<ProcurementRequest>> getProcurementRequests();
  Future<void> cacheProcurementRequests(List<ProcurementRequest> requests);
  Future<void> saveProcurementRequest(
    ProcurementRequest request, {
    bool isSynced,
  });
  Future<ProcurementRequest?> getProcurementRequestById(String requestId);

  // Repairs & Maintenance
  Future<List<RepairRecord>> getRepairRecords();
  Future<void> cacheRepairRecords(List<RepairRecord> records);
  Future<List<MaintenanceRecord>> getMaintenanceSchedule();
  Future<void> cacheMaintenanceSchedule(List<MaintenanceRecord> records);

  // Sync helpers
  Future<List<Asset>> getUnsyncedAssets();
  Future<List<StockMovement>> getUnsyncedMovements();
  Future<List<ProcurementRequest>> getUnsyncedProcurementRequests();
}
