import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/entities/procurement_request.dart';

abstract class StoresAssetsState extends Equatable {
  const StoresAssetsState();

  @override
  List<Object?> get props => [];
}

class StoresAssetsInitial extends StoresAssetsState {}

class StoresAssetsLoading extends StoresAssetsState {}

class StoresAssetsLoaded extends StoresAssetsState {
  final List<InventoryItem> items;
  final List<Asset> assets;
  final List<Supplier> suppliers;
  final List<PurchaseOrder> purchaseOrders;
  final List<RepairRecord> repairs;
  final List<MaintenanceRecord> maintenanceSchedule;
  final List<StockMovement> recentMovements;
  final List<ProcurementRequest> procurementRequests;
  final Asset? scannedAsset;

  const StoresAssetsLoaded({
    this.items = const [],
    this.assets = const [],
    this.suppliers = const [],
    this.purchaseOrders = const [],
    this.repairs = const [],
    this.maintenanceSchedule = const [],
    this.recentMovements = const [],
    this.procurementRequests = const [],
    this.scannedAsset,
  });

  // Computed properties for Dashboard
  double get totalStockValue => items.fold(0, (sum, item) => sum + (item.quantity * 0)); // Price not in entity yet
  int get lowStockCount => items.where((i) => i.isLowStock).length;
  int get outOfStockCount => items.where((i) => i.isOutOfStock).length;
  int get pendingPurchaseRequests => procurementRequests.where((o) => o.status == ProcurementStatus.pending).length;
  int get assetsUnderRepair => repairs.where((r) => r.status == RepairStatus.inProgress).length;
  int get repairsDue => repairs.where((r) => r.status == RepairStatus.pending).length;

  @override
  List<Object?> get props => [items, assets, suppliers, purchaseOrders, repairs, maintenanceSchedule, recentMovements, procurementRequests, scannedAsset];
}

class StoresAssetsError extends StoresAssetsState {
  final String message;
  const StoresAssetsError(this.message);

  @override
  List<Object?> get props => [message];
}
