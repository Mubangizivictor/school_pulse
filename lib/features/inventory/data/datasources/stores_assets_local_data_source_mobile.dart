import 'package:isar/isar.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/procurement_request.dart';
import '../models/inventory_item_isar.dart';
import '../models/asset_isar.dart';
import '../models/supplier_isar.dart';
import '../models/purchase_order_isar.dart';
import '../models/repair_isar.dart';
import '../models/maintenance_isar.dart';
import '../models/stock_movement_isar.dart';
import '../models/procurement_request_isar.dart';
import 'stores_assets_local_data_source.dart';

StoresAssetsLocalDataSource create({dynamic isar, dynamic remote}) =>
    StoresAssetsLocalDataSourceImpl(isar: isar as Isar);

class StoresAssetsLocalDataSourceImpl implements StoresAssetsLocalDataSource {
  final Isar isar;

  StoresAssetsLocalDataSourceImpl({required this.isar});

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    final cached = await isar.inventoryItemIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheInventoryItems(List<InventoryItem> items) async {
    await isar.writeTxn(() async {
      await isar.inventoryItemIsars.clear();
      await isar.inventoryItemIsars.putAll(
        items.map(InventoryItemIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> saveStockMovement(
    StockMovement movement, {
    bool isSynced = true,
  }) async {
    await isar.writeTxn(() async {
      await isar.stockMovementIsars.put(
        StockMovementIsar.fromEntity(movement, isSynced: isSynced),
      );
    });
  }

  @override
  Future<List<StockMovement>> getRecentMovements() async {
    final cached = await isar.stockMovementIsars
        .where()
        .sortByDateDesc()
        .limit(50)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<Asset>> getAssets() async {
    final cached = await isar.assetIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAssets(List<Asset> assets) async {
    await isar.writeTxn(() async {
      await isar.assetIsars.clear();
      await isar.assetIsars.putAll(assets.map(AssetIsar.fromEntity).toList());
    });
  }

  @override
  Future<Asset?> getAssetByQr(String qrCode) async {
    final found = await isar.assetIsars
        .filter()
        .qrCodeEqualTo(qrCode)
        .findFirst();
    return found?.toEntity();
  }

  @override
  Future<void> saveAsset(Asset asset, {bool isSynced = true}) async {
    await isar.writeTxn(() async {
      await isar.assetIsars.put(
        AssetIsar.fromEntity(asset, isSynced: isSynced),
      );
    });
  }

  @override
  Future<Asset?> getAssetById(String assetId) async {
    final found = await isar.assetIsars
        .filter()
        .assetIdEqualTo(assetId)
        .findFirst();
    return found?.toEntity();
  }

  @override
  Future<void> saveInventoryItem(
    InventoryItem item, {
    bool isSynced = true,
  }) async {
    await isar.writeTxn(() async {
      await isar.inventoryItemIsars.put(
        InventoryItemIsar.fromEntity(item, isSynced: isSynced),
      );
    });
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final cached = await isar.supplierIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheSuppliers(List<Supplier> suppliers) async {
    await isar.writeTxn(() async {
      await isar.supplierIsars.clear();
      await isar.supplierIsars.putAll(
        suppliers.map(SupplierIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final cached = await isar.purchaseOrderIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cachePurchaseOrders(List<PurchaseOrder> orders) async {
    await isar.writeTxn(() async {
      await isar.purchaseOrderIsars.clear();
      await isar.purchaseOrderIsars.putAll(
        orders.map(PurchaseOrderIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<ProcurementRequest>> getProcurementRequests() async {
    final cached = await isar.procurementRequestIsars
        .where()
        .sortByDateDesc()
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheProcurementRequests(
    List<ProcurementRequest> requests,
  ) async {
    await isar.writeTxn(() async {
      await isar.procurementRequestIsars.clear();
      await isar.procurementRequestIsars.putAll(
        requests.map(ProcurementRequestIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<void> saveProcurementRequest(
    ProcurementRequest request, {
    bool isSynced = true,
  }) async {
    await isar.writeTxn(() async {
      await isar.procurementRequestIsars.put(
        ProcurementRequestIsar.fromEntity(request, isSynced: isSynced),
      );
    });
  }

  @override
  Future<ProcurementRequest?> getProcurementRequestById(
    String requestId,
  ) async {
    final found = await isar.procurementRequestIsars
        .filter()
        .requestIdEqualTo(requestId)
        .findFirst();
    return found?.toEntity();
  }

  @override
  Future<List<RepairRecord>> getRepairRecords() async {
    final cached = await isar.repairIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheRepairRecords(List<RepairRecord> records) async {
    await isar.writeTxn(() async {
      await isar.repairIsars.clear();
      await isar.repairIsars.putAll(
        records.map(RepairIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceSchedule() async {
    final cached = await isar.maintenanceIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheMaintenanceSchedule(List<MaintenanceRecord> records) async {
    await isar.writeTxn(() async {
      await isar.maintenanceIsars.clear();
      await isar.maintenanceIsars.putAll(
        records.map(MaintenanceIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<Asset>> getUnsyncedAssets() async {
    final cached = await isar.assetIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<StockMovement>> getUnsyncedMovements() async {
    final cached = await isar.stockMovementIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<ProcurementRequest>> getUnsyncedProcurementRequests() async {
    final cached = await isar.procurementRequestIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }
}
