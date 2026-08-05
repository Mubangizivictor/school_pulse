import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/stock_issue.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/procurement_request.dart';
import '../../domain/repositories/stores_assets_repository.dart';
import '../datasources/stores_assets_remote_data_source.dart';
import '../datasources/stores_assets_local_data_source.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_item_isar.dart';
import '../models/asset_isar.dart';
import '../models/asset_model.dart';
import '../models/supplier_model.dart';
import '../models/supplier_isar.dart';
import '../models/purchase_order_model.dart';
import '../models/purchase_order_isar.dart';
import '../models/repair_model.dart';
import '../models/repair_isar.dart';
import '../models/maintenance_model.dart';
import '../models/maintenance_isar.dart';
import '../models/stock_movement_isar.dart';
import '../models/procurement_request_model.dart';
import '../models/procurement_request_isar.dart';

class StoresAssetsRepositoryImpl implements StoresAssetsRepository {
  final StoresAssetsRemoteDataSource remoteDataSource;
  final StoresAssetsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  StoresAssetsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<InventoryItem>>> getInventoryItems() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteItems = await remoteDataSource.getInventoryItems();
        await localDataSource.cacheInventoryItems(
          remoteItems.map((i) => InventoryItemIsar.fromEntity(i)).toList(),
        );
        return Right(remoteItems);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localItems = await localDataSource.getInventoryItems();
      return Right(localItems.map((i) => i.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> addInventoryItem(InventoryItem item) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addInventoryItem(
          InventoryItemModel.fromEntity(item),
        );
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      // Local addition with sync flag could be implemented here
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateInventoryItem(InventoryItem item) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateInventoryItem(
          InventoryItemModel.fromEntity(item),
        );
      }
      await localDataSource.saveInventoryItem(
        InventoryItemIsar.fromEntity(
          item,
          isSynced: await networkInfo.isConnected,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getRecentMovements() async {
    if (await networkInfo.isConnected) {
      try {
        final movements = await remoteDataSource.getRecentMovements();
        return Right(movements);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localMovements = await localDataSource.getRecentMovements();
      return Right(localMovements.map((m) => m.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> adjustStock(StockAdjustment adjustment) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.adjustStock(adjustment);
      }
      // Log movement locally
      await localDataSource.saveStockMovement(
        StockMovementIsar(
          movementId: '',
          itemId: adjustment.itemId,
          itemName: adjustment.itemName,
          type: StockMovementType.restock, // or dynamic based on adjustment
          quantity: adjustment.quantityAdjusted,
          date: adjustment.date,
          note: adjustment.notes,
          isSynced: await networkInfo.isConnected,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> issueStock(StockIssue issue) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.issueStock(issue);
      }
      await localDataSource.saveStockMovement(
        StockMovementIsar(
          movementId: '',
          itemId: issue.itemId,
          itemName: issue.itemName,
          type: StockMovementType.issue,
          quantity: issue.quantity,
          date: issue.date,
          note: issue.purpose,
          isSynced: await networkInfo.isConnected,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Asset>>> getAssets() async {
    if (await networkInfo.isConnected) {
      try {
        final assets = await remoteDataSource.getAssets();
        await localDataSource.cacheAssets(
          assets.map((a) => AssetIsar.fromEntity(a)).toList(),
        );
        return Right(assets);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localAssets = await localDataSource.getAssets();
      return Right(localAssets.map((a) => a.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, Asset>> getAssetByQr(String qrCode) async {
    try {
      final asset = await localDataSource.getAssetByQr(qrCode);
      if (asset != null) return Right(asset.toEntity());
      return Left(CacheFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addAsset(Asset asset) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.addAsset(AssetModel.fromEntity(asset));
      }
      await localDataSource.saveAsset(
        AssetIsar.fromEntity(asset, isSynced: await networkInfo.isConnected),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAsset(Asset asset) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateAsset(AssetModel.fromEntity(asset));
      }
      await localDataSource.saveAsset(
        AssetIsar.fromEntity(asset, isSynced: await networkInfo.isConnected),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> disposeAsset(
    String assetId,
    String reason,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.disposeAsset(assetId, reason);
      }
      // Update local asset status
      final asset = await localDataSource.getAssetById(assetId);
      if (asset != null) {
        asset.status = AssetStatus.disposed;
        asset.isSynced = await networkInfo.isConnected;
        await localDataSource.saveAsset(asset);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> getSuppliers() async {
    if (await networkInfo.isConnected) {
      try {
        final suppliers = await remoteDataSource.getSuppliers();
        await localDataSource.cacheSuppliers(
          suppliers.map((s) => SupplierIsar.fromEntity(s)).toList(),
        );
        return Right(suppliers);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localSuppliers = await localDataSource.getSuppliers();
      return Right(localSuppliers.map((s) => s.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> addSupplier(Supplier supplier) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.addSupplier(SupplierModel.fromEntity(supplier));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PurchaseOrder>>> getPurchaseOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getPurchaseOrders();
        await localDataSource.cachePurchaseOrders(
          orders.map((o) => PurchaseOrderIsar.fromEntity(o)).toList(),
        );
        return Right(orders);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localOrders = await localDataSource.getPurchaseOrders();
      return Right(localOrders.map((o) => o.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> createPurchaseOrder(PurchaseOrder order) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.createPurchaseOrder(
          PurchaseOrderModel.fromEntity(order),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updatePurchaseOrderStatus(
    String orderId,
    PurchaseOrderStatus status,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updatePurchaseOrderStatus(orderId, status);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProcurementRequest>>>
  getProcurementRequests() async {
    if (await networkInfo.isConnected) {
      try {
        final requests = await remoteDataSource.getProcurementRequests();
        await localDataSource.cacheProcurementRequests(
          requests.map((r) => ProcurementRequestIsar.fromEntity(r)).toList(),
        );
        return Right(requests);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localRequests = await localDataSource.getProcurementRequests();
      return Right(localRequests.map((r) => r.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> createProcurementRequest(
    ProcurementRequest request,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.createProcurementRequest(
          ProcurementRequestModel.fromEntity(request),
        );
      }
      await localDataSource.saveProcurementRequest(
        ProcurementRequestIsar.fromEntity(
          request,
          isSynced: await networkInfo.isConnected,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateProcurementRequestStatus(
    String requestId,
    ProcurementStatus status, {
    String? directorNote,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateProcurementRequestStatus(
          requestId,
          status,
          directorNote: directorNote,
        );
      }
      final local = await localDataSource.getProcurementRequestById(requestId);
      if (local != null) {
        local.status = status;
        if (directorNote != null) local.directorNote = directorNote;
        local.isSynced = await networkInfo.isConnected;
        await localDataSource.saveProcurementRequest(local);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RepairRecord>>> getRepairRecords() async {
    if (await networkInfo.isConnected) {
      try {
        final records = await remoteDataSource.getRepairRecords();
        await localDataSource.cacheRepairRecords(
          records.map((r) => RepairIsar.fromEntity(r)).toList(),
        );
        return Right(records);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localRecords = await localDataSource.getRepairRecords();
      return Right(localRecords.map((r) => r.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> requestRepair(RepairRecord repair) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.requestRepair(
          RepairRecordModel.fromEntity(repair),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceRecord>>>
  getMaintenanceSchedule() async {
    if (await networkInfo.isConnected) {
      try {
        final schedule = await remoteDataSource.getMaintenanceSchedule();
        await localDataSource.cacheMaintenanceSchedule(
          schedule.map((m) => MaintenanceIsar.fromEntity(m)).toList(),
        );
        return Right(schedule);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localSchedule = await localDataSource.getMaintenanceSchedule();
      return Right(localSchedule.map((m) => m.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, void>> scheduleMaintenance(
    MaintenanceRecord maintenance,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.scheduleMaintenance(
          MaintenanceRecordModel.fromEntity(maintenance),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<void> syncOfflineData() async {
    if (await networkInfo.isConnected) {
      final unsyncedAssets = await localDataSource.getUnsyncedAssets();
      for (var asset in unsyncedAssets) {
        try {
          await remoteDataSource.updateAsset(
            AssetModel.fromEntity(asset.toEntity()),
          );
          asset.isSynced = true;
          await localDataSource.saveAsset(asset);
        } catch (_) {}
      }

      final unsyncedMovements = await localDataSource.getUnsyncedMovements();
      for (var movement in unsyncedMovements) {
        try {
          if (movement.type == StockMovementType.issue) {
            await remoteDataSource.issueStock(
              StockIssue(
                id: '',
                itemId: movement.itemId,
                itemName: movement.itemName,
                issuedToId: 'Offline Sync',
                quantity: movement.quantity,
                date: movement.date,
                purpose: movement.note,
                issuedToName:
                    '', // These might need more fields in StockMovementIsar if required
                department: '',
                approvedBy: '',
              ),
            );
          } else {
            await remoteDataSource.adjustStock(
              StockAdjustment(
                id: '',
                itemId: movement.itemId,
                itemName: movement.itemName,
                quantityAdjusted: movement.quantity,
                date: movement.date,
                notes: movement.note,
                reason: AdjustmentReason.other, // Default for offline sync
                adjustedBy: 'Offline Sync',
              ),
            );
          }
          movement.isSynced = true;
          await localDataSource.saveStockMovement(movement);
        } catch (_) {}
      }
      final unsyncedRequests = await localDataSource
          .getUnsyncedProcurementRequests();
      for (var request in unsyncedRequests) {
        try {
          await remoteDataSource.createProcurementRequest(
            ProcurementRequestModel.fromEntity(request.toEntity()),
          );
          request.isSynced = true;
          await localDataSource.saveProcurementRequest(request);
        } catch (_) {}
      }
    }
  }
}
