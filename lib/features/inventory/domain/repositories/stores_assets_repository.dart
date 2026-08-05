import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/inventory_item.dart';
import '../entities/asset.dart';
import '../entities/supplier.dart';
import '../entities/purchase_order.dart';
import '../entities/stock_movement.dart';
import '../entities/repair.dart';
import '../entities/maintenance.dart';
import '../entities/stock_issue.dart';
import '../entities/stock_adjustment.dart';
import '../entities/procurement_request.dart';

abstract class StoresAssetsRepository {
  // Inventory
  Future<Either<Failure, List<InventoryItem>>> getInventoryItems();
  Future<Either<Failure, void>> addInventoryItem(InventoryItem item);
  Future<Either<Failure, void>> updateInventoryItem(InventoryItem item);
  Future<Either<Failure, List<StockMovement>>> getRecentMovements();
  Future<Either<Failure, void>> adjustStock(StockAdjustment adjustment);
  Future<Either<Failure, void>> issueStock(StockIssue issue);

  // Assets
  Future<Either<Failure, List<Asset>>> getAssets();
  Future<Either<Failure, Asset>> getAssetByQr(String qrCode);
  Future<Either<Failure, void>> addAsset(Asset asset);
  Future<Either<Failure, void>> updateAsset(Asset asset);
  Future<Either<Failure, void>> disposeAsset(String assetId, String reason);

  // Procurement
  Future<Either<Failure, List<Supplier>>> getSuppliers();
  Future<Either<Failure, void>> addSupplier(Supplier supplier);
  Future<Either<Failure, List<PurchaseOrder>>> getPurchaseOrders();
  Future<Either<Failure, void>> createPurchaseOrder(PurchaseOrder order);
  Future<Either<Failure, void>> updatePurchaseOrderStatus(
    String orderId,
    PurchaseOrderStatus status,
  );

  // Procurement Requests
  Future<Either<Failure, List<ProcurementRequest>>> getProcurementRequests();
  Future<Either<Failure, void>> createProcurementRequest(
    ProcurementRequest request,
  );
  Future<Either<Failure, void>> updateProcurementRequestStatus(
    String requestId,
    ProcurementStatus status, {
    String? directorNote,
  });

  // Repairs & Maintenance
  Future<Either<Failure, List<RepairRecord>>> getRepairRecords();
  Future<Either<Failure, void>> requestRepair(RepairRecord repair);
  Future<Either<Failure, List<MaintenanceRecord>>> getMaintenanceSchedule();
  Future<Either<Failure, void>> scheduleMaintenance(
    MaintenanceRecord maintenance,
  );

  // Offline Sync
  Future<void> syncOfflineData();
}
