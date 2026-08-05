import 'package:isar/isar.dart';
import '../models/inventory_item_isar.dart';
import '../models/asset_isar.dart';
import '../models/supplier_isar.dart';
import '../models/purchase_order_isar.dart';
import '../models/repair_isar.dart';
import '../models/maintenance_isar.dart';
import '../models/stock_movement_isar.dart';
import '../models/procurement_request_isar.dart';

abstract class StoresAssetsLocalDataSource {
  // Inventory
  Future<List<InventoryItemIsar>> getInventoryItems();
  Future<void> cacheInventoryItems(List<InventoryItemIsar> items);
  Future<void> saveStockMovement(StockMovementIsar movement);
  Future<List<StockMovementIsar>> getRecentMovements();

  // Assets
  Future<List<AssetIsar>> getAssets();
  Future<void> cacheAssets(List<AssetIsar> assets);
  Future<AssetIsar?> getAssetByQr(String qrCode);
  Future<void> saveAsset(AssetIsar asset);
  Future<AssetIsar?> getAssetById(String assetId);
  Future<void> saveInventoryItem(InventoryItemIsar item);

  // Procurement
  Future<List<SupplierIsar>> getSuppliers();
  Future<void> cacheSuppliers(List<SupplierIsar> suppliers);
  Future<List<PurchaseOrderIsar>> getPurchaseOrders();
  Future<void> cachePurchaseOrders(List<PurchaseOrderIsar> orders);
  Future<List<ProcurementRequestIsar>> getProcurementRequests();
  Future<void> cacheProcurementRequests(List<ProcurementRequestIsar> requests);
  Future<void> saveProcurementRequest(ProcurementRequestIsar request);
  Future<ProcurementRequestIsar?> getProcurementRequestById(String requestId);

  // Repairs & Maintenance
  Future<List<RepairIsar>> getRepairRecords();
  Future<void> cacheRepairRecords(List<RepairIsar> records);
  Future<List<MaintenanceIsar>> getMaintenanceSchedule();
  Future<void> cacheMaintenanceSchedule(List<MaintenanceIsar> records);

  // Sync helpers
  Future<List<AssetIsar>> getUnsyncedAssets();
  Future<List<StockMovementIsar>> getUnsyncedMovements();
  Future<List<ProcurementRequestIsar>> getUnsyncedProcurementRequests();
}

class StoresAssetsLocalDataSourceImpl implements StoresAssetsLocalDataSource {
  final Isar isar;

  StoresAssetsLocalDataSourceImpl({required this.isar});

  @override
  Future<List<InventoryItemIsar>> getInventoryItems() async {
    return await isar.inventoryItemIsars.where().findAll();
  }

  @override
  Future<void> cacheInventoryItems(List<InventoryItemIsar> items) async {
    await isar.writeTxn(() async {
      await isar.inventoryItemIsars.clear();
      await isar.inventoryItemIsars.putAll(items);
    });
  }

  @override
  Future<void> saveStockMovement(StockMovementIsar movement) async {
    await isar.writeTxn(() async {
      await isar.stockMovementIsars.put(movement);
    });
  }

  @override
  Future<List<StockMovementIsar>> getRecentMovements() async {
    return await isar.stockMovementIsars
        .where()
        .sortByDateDesc()
        .limit(50)
        .findAll();
  }

  @override
  Future<List<AssetIsar>> getAssets() async {
    return await isar.assetIsars.where().findAll();
  }

  @override
  Future<void> cacheAssets(List<AssetIsar> assets) async {
    await isar.writeTxn(() async {
      await isar.assetIsars.clear();
      await isar.assetIsars.putAll(assets);
    });
  }

  @override
  Future<AssetIsar?> getAssetByQr(String qrCode) async {
    return await isar.assetIsars.filter().qrCodeEqualTo(qrCode).findFirst();
  }

  @override
  Future<void> saveAsset(AssetIsar asset) async {
    await isar.writeTxn(() async {
      await isar.assetIsars.put(asset);
    });
  }

  @override
  Future<AssetIsar?> getAssetById(String assetId) async {
    return await isar.assetIsars.filter().assetIdEqualTo(assetId).findFirst();
  }

  @override
  Future<void> saveInventoryItem(InventoryItemIsar item) async {
    await isar.writeTxn(() async {
      await isar.inventoryItemIsars.put(item);
    });
  }

  @override
  Future<List<SupplierIsar>> getSuppliers() async {
    return await isar.supplierIsars.where().findAll();
  }

  @override
  Future<void> cacheSuppliers(List<SupplierIsar> suppliers) async {
    await isar.writeTxn(() async {
      await isar.supplierIsars.clear();
      await isar.supplierIsars.putAll(suppliers);
    });
  }

  @override
  Future<List<PurchaseOrderIsar>> getPurchaseOrders() async {
    return await isar.purchaseOrderIsars.where().findAll();
  }

  @override
  Future<void> cachePurchaseOrders(List<PurchaseOrderIsar> orders) async {
    await isar.writeTxn(() async {
      await isar.purchaseOrderIsars.clear();
      await isar.purchaseOrderIsars.putAll(orders);
    });
  }

  @override
  Future<List<ProcurementRequestIsar>> getProcurementRequests() async {
    return await isar.procurementRequestIsars
        .where()
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<void> cacheProcurementRequests(
    List<ProcurementRequestIsar> requests,
  ) async {
    await isar.writeTxn(() async {
      await isar.procurementRequestIsars.clear();
      await isar.procurementRequestIsars.putAll(requests);
    });
  }

  @override
  Future<void> saveProcurementRequest(ProcurementRequestIsar request) async {
    await isar.writeTxn(() async {
      await isar.procurementRequestIsars.put(request);
    });
  }

  @override
  Future<ProcurementRequestIsar?> getProcurementRequestById(
    String requestId,
  ) async {
    return await isar.procurementRequestIsars
        .filter()
        .requestIdEqualTo(requestId)
        .findFirst();
  }

  @override
  Future<List<RepairIsar>> getRepairRecords() async {
    return await isar.repairIsars.where().findAll();
  }

  @override
  Future<void> cacheRepairRecords(List<RepairIsar> records) async {
    await isar.writeTxn(() async {
      await isar.repairIsars.clear();
      await isar.repairIsars.putAll(records);
    });
  }

  @override
  Future<List<MaintenanceIsar>> getMaintenanceSchedule() async {
    return await isar.maintenanceIsars.where().findAll();
  }

  @override
  Future<void> cacheMaintenanceSchedule(List<MaintenanceIsar> records) async {
    await isar.writeTxn(() async {
      await isar.maintenanceIsars.clear();
      await isar.maintenanceIsars.putAll(records);
    });
  }

  @override
  Future<List<AssetIsar>> getUnsyncedAssets() async {
    return await isar.assetIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<List<StockMovementIsar>> getUnsyncedMovements() async {
    return await isar.stockMovementIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<ProcurementRequestIsar>> getUnsyncedProcurementRequests() async {
    return await isar.procurementRequestIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }
}
