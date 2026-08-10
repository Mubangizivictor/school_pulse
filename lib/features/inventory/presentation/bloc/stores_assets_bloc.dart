import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/stores_assets_repository.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/procurement_request.dart';
import 'stores_assets_event.dart';
import 'stores_assets_state.dart';

class StoresAssetsBloc extends Bloc<StoresAssetsEvent, StoresAssetsState> {
  final StoresAssetsRepository repository;

  StoresAssetsBloc({required this.repository}) : super(StoresAssetsInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadInventoryItems>(_onLoadInventoryItems);
    on<AddInventoryItemRequested>(_onAddInventoryItem);
    on<UpdateInventoryItemRequested>(_onUpdateInventoryItem);
    on<AdjustStockRequested>(_onAdjustStock);
    on<IssueStockRequested>(_onIssueStock);
    on<LoadAssets>(_onLoadAssets);
    on<AddAssetRequested>(_onAddAsset);
    on<UpdateAssetRequested>(_onUpdateAsset);
    on<ScanAssetQR>(_onScanAssetQR);
    on<DisposeAssetRequested>(_onDisposeAsset);
    on<LoadSuppliers>(_onLoadSuppliers);
    on<AddSupplierRequested>(_onAddSupplier);
    on<LoadPurchaseOrders>(_onLoadPurchaseOrders);
    on<CreatePurchaseOrderRequested>(_onCreatePurchaseOrder);
    on<UpdatePurchaseOrderStatusRequested>(_onUpdatePurchaseOrderStatus);
    on<LoadRepairs>(_onLoadRepairs);
    on<LoadMaintenanceSchedule>(_onLoadMaintenanceSchedule);
    on<RequestRepairRequested>(_onRequestRepair);
    on<ScheduleMaintenanceRequested>(_onScheduleMaintenance);
    on<LoadProcurementRequests>(_onLoadProcurementRequests);
    on<CreateProcurementRequestRequested>(_onCreateProcurementRequest);
    on<UpdateProcurementRequestStatusRequested>(
      _onUpdateProcurementRequestStatus,
    );
    on<SyncOfflineData>(_onSyncOfflineData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<StoresAssetsState> emit,
  ) async {
    emit(StoresAssetsLoading());

    final itemsResult = await repository.getInventoryItems();
    final assetsResult = await repository.getAssets();
    final ordersResult = await repository.getPurchaseOrders();
    final repairsResult = await repository.getRepairRecords();
    final movementsResult = await repository.getRecentMovements();
    final maintenanceResult = await repository.getMaintenanceSchedule();
    final suppliersResult = await repository.getSuppliers();
    final procurementRequestsResult = await repository.getProcurementRequests();

    emit(
      StoresAssetsLoaded(
        items: itemsResult.getOrElse(() => []),
        assets: assetsResult.getOrElse(() => []),
        purchaseOrders: ordersResult.getOrElse(() => []),
        repairs: repairsResult.getOrElse(() => []),
        recentMovements: movementsResult.getOrElse(() => []),
        maintenanceSchedule: maintenanceResult.getOrElse(() => []),
        suppliers: suppliersResult.getOrElse(() => []),
        procurementRequests: procurementRequestsResult.getOrElse(() => []),
      ),
    );
  }

  Future<void> _onLoadInventoryItems(
    LoadInventoryItems event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getInventoryItems();
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to load inventory')),
      (items) {
        if (state is StoresAssetsLoaded) {
          emit((state as StoresAssetsLoaded).copyWith(items: items));
        } else {
          emit(StoresAssetsLoaded(items: items));
        }
      },
    );
  }

  Future<void> _onAddInventoryItem(
    AddInventoryItemRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.addInventoryItem(event.item);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to add item')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItemRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.updateInventoryItem(event.item);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to update item')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onAdjustStock(
    AdjustStockRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.adjustStock(event.adjustment);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to adjust stock')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onIssueStock(
    IssueStockRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.issueStock(event.issue);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to issue stock')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onLoadAssets(
    LoadAssets event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getAssets();
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to load assets')),
      (assets) {
        if (state is StoresAssetsLoaded) {
          emit((state as StoresAssetsLoaded).copyWith(assets: assets));
        } else {
          emit(StoresAssetsLoaded(assets: assets));
        }
      },
    );
  }

  Future<void> _onAddAsset(
    AddAssetRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.addAsset(event.asset);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to add asset')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onUpdateAsset(
    UpdateAssetRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.updateAsset(event.asset);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to update asset')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onScanAssetQR(
    ScanAssetQR event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getAssetByQr(event.qrCode);
    result.fold((failure) => emit(const StoresAssetsError('Asset not found')), (
      asset,
    ) {
      if (state is StoresAssetsLoaded) {
        emit((state as StoresAssetsLoaded).copyWith(scannedAsset: asset));
      } else {
        emit(StoresAssetsLoaded(scannedAsset: asset));
      }
    });
  }

  Future<void> _onDisposeAsset(
    DisposeAssetRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.disposeAsset(event.assetId, event.reason);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to dispose asset')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getSuppliers();
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to load suppliers')),
      (suppliers) {
        if (state is StoresAssetsLoaded) {
          emit((state as StoresAssetsLoaded).copyWith(suppliers: suppliers));
        } else {
          emit(StoresAssetsLoaded(suppliers: suppliers));
        }
      },
    );
  }

  Future<void> _onLoadPurchaseOrders(
    LoadPurchaseOrders event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getPurchaseOrders();
    result.fold(
      (failure) =>
          emit(const StoresAssetsError('Failed to load purchase orders')),
      (orders) {
        if (state is StoresAssetsLoaded) {
          emit((state as StoresAssetsLoaded).copyWith(purchaseOrders: orders));
        } else {
          emit(StoresAssetsLoaded(purchaseOrders: orders));
        }
      },
    );
  }

  Future<void> _onAddSupplier(
    AddSupplierRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.addSupplier(event.supplier);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to add supplier')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onCreatePurchaseOrder(
    CreatePurchaseOrderRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.createPurchaseOrder(event.order);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to create order')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onUpdatePurchaseOrderStatus(
    UpdatePurchaseOrderStatusRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.updatePurchaseOrderStatus(
      event.orderId,
      event.status,
    );
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to update order')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onLoadRepairs(
    LoadRepairs event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getRepairRecords();
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to load repairs')),
      (repairs) {
        if (state is StoresAssetsLoaded) {
          emit((state as StoresAssetsLoaded).copyWith(repairs: repairs));
        } else {
          emit(StoresAssetsLoaded(repairs: repairs));
        }
      },
    );
  }

  Future<void> _onLoadMaintenanceSchedule(
    LoadMaintenanceSchedule event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getMaintenanceSchedule();
    result.fold(
      (failure) =>
          emit(const StoresAssetsError('Failed to load maintenance schedule')),
      (schedule) {
        if (state is StoresAssetsLoaded) {
          emit(
            (state as StoresAssetsLoaded).copyWith(
              maintenanceSchedule: schedule,
            ),
          );
        } else {
          emit(StoresAssetsLoaded(maintenanceSchedule: schedule));
        }
      },
    );
  }

  Future<void> _onRequestRepair(
    RequestRepairRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.requestRepair(event.repair);
    result.fold(
      (failure) => emit(const StoresAssetsError('Failed to request repair')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onScheduleMaintenance(
    ScheduleMaintenanceRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.scheduleMaintenance(event.maintenance);
    result.fold(
      (failure) =>
          emit(const StoresAssetsError('Failed to schedule maintenance')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onLoadProcurementRequests(
    LoadProcurementRequests event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.getProcurementRequests();
    result.fold(
      (failure) =>
          emit(const StoresAssetsError('Failed to load procurement requests')),
      (requests) {
        if (state is StoresAssetsLoaded) {
          emit(
            (state as StoresAssetsLoaded).copyWith(
              procurementRequests: requests,
            ),
          );
        } else {
          emit(StoresAssetsLoaded(procurementRequests: requests));
        }
      },
    );
  }

  Future<void> _onCreateProcurementRequest(
    CreateProcurementRequestRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.createProcurementRequest(event.request);
    result.fold(
      (failure) =>
          emit(const StoresAssetsError('Failed to create procurement request')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onUpdateProcurementRequestStatus(
    UpdateProcurementRequestStatusRequested event,
    Emitter<StoresAssetsState> emit,
  ) async {
    final result = await repository.updateProcurementRequestStatus(
      event.requestId,
      event.status,
      directorNote: event.directorNote,
    );
    result.fold(
      (failure) =>
          emit(const StoresAssetsError('Failed to update procurement request')),
      (_) => add(LoadDashboardData()),
    );
  }

  Future<void> _onSyncOfflineData(
    SyncOfflineData event,
    Emitter<StoresAssetsState> emit,
  ) async {
    await repository.syncOfflineData();
    add(LoadDashboardData());
  }
}

extension on StoresAssetsState {
  StoresAssetsLoaded copyWith({
    List<InventoryItem>? items,
    List<Asset>? assets,
    List<Supplier>? suppliers,
    List<PurchaseOrder>? purchaseOrders,
    List<RepairRecord>? repairs,
    List<MaintenanceRecord>? maintenanceSchedule,
    List<StockMovement>? recentMovements,
    List<ProcurementRequest>? procurementRequests,
    Asset? scannedAsset,
  }) {
    if (this is StoresAssetsLoaded) {
      final s = this as StoresAssetsLoaded;
      return StoresAssetsLoaded(
        items: items ?? s.items,
        assets: assets ?? s.assets,
        suppliers: suppliers ?? s.suppliers,
        purchaseOrders: purchaseOrders ?? s.purchaseOrders,
        repairs: repairs ?? s.repairs,
        maintenanceSchedule: maintenanceSchedule ?? s.maintenanceSchedule,
        recentMovements: recentMovements ?? s.recentMovements,
        procurementRequests: procurementRequests ?? s.procurementRequests,
        scannedAsset: scannedAsset ?? s.scannedAsset,
      );
    }
    return StoresAssetsLoaded(
      items: items ?? [],
      assets: assets ?? [],
      suppliers: suppliers ?? [],
      purchaseOrders: purchaseOrders ?? [],
      repairs: repairs ?? [],
      maintenanceSchedule: maintenanceSchedule ?? [],
      recentMovements: recentMovements ?? [],
      procurementRequests: procurementRequests ?? [],
      scannedAsset: scannedAsset,
    );
  }
}
