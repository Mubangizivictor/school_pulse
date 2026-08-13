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
import '../models/asset_model.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import '../models/repair_model.dart';
import '../models/maintenance_model.dart';
import '../models/procurement_request_model.dart';

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
        await localDataSource.cacheInventoryItems(remoteItems);
        return Right(remoteItems);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      final localItems = await localDataSource.getInventoryItems();
      return Right(localItems);
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
        item,
        isSynced: await networkInfo.isConnected,
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
      return Right(await localDataSource.getRecentMovements());
    }
  }

  @override
  Future<Either<Failure, void>> adjustStock(StockAdjustment adjustment) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.adjustStock(adjustment);
      }
      // Log movement locally
      await localDataSource.saveStockMovement(
        StockMovement(
          id: '',
          itemId: adjustment.itemId,
          itemName: adjustment.itemName,
          type: StockMovementType.restock, // or dynamic based on adjustment
          quantity: adjustment.quantityAdjusted,
          date: adjustment.date,
          note: adjustment.notes,
        ),
        isSynced: isConnected,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> issueStock(StockIssue issue) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.issueStock(issue);
      }
      await localDataSource.saveStockMovement(
        StockMovement(
          id: '',
          itemId: issue.itemId,
          itemName: issue.itemName,
          type: StockMovementType.issue,
          quantity: issue.quantity,
          date: issue.date,
          note: issue.purpose,
        ),
        isSynced: isConnected,
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
        await localDataSource.cacheAssets(assets);
        return Right(assets);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Right(await localDataSource.getAssets());
    }
  }

  @override
  Future<Either<Failure, Asset>> getAssetByQr(String qrCode) async {
    try {
      final asset = await localDataSource.getAssetByQr(qrCode);
      if (asset != null) return Right(asset);
      return Left(CacheFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addAsset(Asset asset) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.addAsset(AssetModel.fromEntity(asset));
      }
      await localDataSource.saveAsset(asset, isSynced: isConnected);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAsset(Asset asset) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.updateAsset(AssetModel.fromEntity(asset));
      }
      await localDataSource.saveAsset(asset, isSynced: isConnected);
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
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.disposeAsset(assetId, reason);
      }
      // Update local asset status
      final asset = await localDataSource.getAssetById(assetId);
      if (asset != null) {
        final updated = Asset(
          id: asset.id,
          schoolId: asset.schoolId,
          assetNumber: asset.assetNumber,
          qrCode: asset.qrCode,
          name: asset.name,
          category: asset.category,
          brand: asset.brand,
          model: asset.model,
          serialNumber: asset.serialNumber,
          purchaseDate: asset.purchaseDate,
          purchasePrice: asset.purchasePrice,
          supplierId: asset.supplierId,
          warrantyExpiry: asset.warrantyExpiry,
          assignedDepartment: asset.assignedDepartment,
          assignedStaffId: asset.assignedStaffId,
          assignedRoom: asset.assignedRoom,
          condition: asset.condition,
          status: AssetStatus.disposed,
          photoUrl: asset.photoUrl,
          documentUrls: asset.documentUrls,
          notes: asset.notes,
          createdAt: asset.createdAt,
          updatedAt: asset.updatedAt,
        );
        await localDataSource.saveAsset(updated, isSynced: isConnected);
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
        await localDataSource.cacheSuppliers(suppliers);
        return Right(suppliers);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Right(await localDataSource.getSuppliers());
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
        await localDataSource.cachePurchaseOrders(orders);
        return Right(orders);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Right(await localDataSource.getPurchaseOrders());
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
        await localDataSource.cacheProcurementRequests(requests);
        return Right(requests);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Right(await localDataSource.getProcurementRequests());
    }
  }

  @override
  Future<Either<Failure, void>> createProcurementRequest(
    ProcurementRequest request,
  ) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.createProcurementRequest(
          ProcurementRequestModel.fromEntity(request),
        );
      }
      await localDataSource.saveProcurementRequest(
        request,
        isSynced: isConnected,
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
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        await remoteDataSource.updateProcurementRequestStatus(
          requestId,
          status,
          directorNote: directorNote,
        );
      }
      final local = await localDataSource.getProcurementRequestById(requestId);
      if (local != null) {
        final updated = local.copyWith(
          status: status,
          directorNote: directorNote ?? local.directorNote,
        );
        await localDataSource.saveProcurementRequest(
          updated,
          isSynced: isConnected,
        );
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
        await localDataSource.cacheRepairRecords(records);
        return Right(records);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Right(await localDataSource.getRepairRecords());
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
        await localDataSource.cacheMaintenanceSchedule(schedule);
        return Right(schedule);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Right(await localDataSource.getMaintenanceSchedule());
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
          await remoteDataSource.updateAsset(AssetModel.fromEntity(asset));
          await localDataSource.saveAsset(asset, isSynced: true);
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
          await localDataSource.saveStockMovement(movement, isSynced: true);
        } catch (_) {}
      }
      final unsyncedRequests = await localDataSource
          .getUnsyncedProcurementRequests();
      for (var request in unsyncedRequests) {
        try {
          await remoteDataSource.createProcurementRequest(
            ProcurementRequestModel.fromEntity(request),
          );
          await localDataSource.saveProcurementRequest(request, isSynced: true);
        } catch (_) {}
      }
    }
  }
}
