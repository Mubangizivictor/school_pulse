import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/stock_issue.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/procurement_request.dart';

abstract class StoresAssetsEvent extends Equatable {
  const StoresAssetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends StoresAssetsEvent {}

// Inventory Events
class LoadInventoryItems extends StoresAssetsEvent {}
class AddInventoryItemRequested extends StoresAssetsEvent {
  final InventoryItem item;
  const AddInventoryItemRequested(this.item);
}
class UpdateInventoryItemRequested extends StoresAssetsEvent {
  final InventoryItem item;
  const UpdateInventoryItemRequested(this.item);
}
class AdjustStockRequested extends StoresAssetsEvent {
  final StockAdjustment adjustment;
  const AdjustStockRequested(this.adjustment);
}
class IssueStockRequested extends StoresAssetsEvent {
  final StockIssue issue;
  const IssueStockRequested(this.issue);
}

// Asset Events
class LoadAssets extends StoresAssetsEvent {}
class AddAssetRequested extends StoresAssetsEvent {
  final Asset asset;
  const AddAssetRequested(this.asset);
}
class UpdateAssetRequested extends StoresAssetsEvent {
  final Asset asset;
  const UpdateAssetRequested(this.asset);
}
class ScanAssetQR extends StoresAssetsEvent {
  final String qrCode;
  const ScanAssetQR(this.qrCode);
}
class DisposeAssetRequested extends StoresAssetsEvent {
  final String assetId;
  final String reason;
  const DisposeAssetRequested(this.assetId, this.reason);
}

// Procurement Events
class LoadSuppliers extends StoresAssetsEvent {}
class LoadPurchaseOrders extends StoresAssetsEvent {}
class CreatePurchaseOrderRequested extends StoresAssetsEvent {
  final PurchaseOrder order;
  const CreatePurchaseOrderRequested(this.order);
}

// Procurement Request Events
class LoadProcurementRequests extends StoresAssetsEvent {}
class CreateProcurementRequestRequested extends StoresAssetsEvent {
  final ProcurementRequest request;
  const CreateProcurementRequestRequested(this.request);
}
class UpdateProcurementRequestStatusRequested extends StoresAssetsEvent {
  final String requestId;
  final ProcurementStatus status;
  final String? directorNote;
  const UpdateProcurementRequestStatusRequested(this.requestId, this.status, {this.directorNote});
}

// Repairs & Maintenance
class LoadRepairs extends StoresAssetsEvent {}
class LoadMaintenanceSchedule extends StoresAssetsEvent {}
class RequestRepairRequested extends StoresAssetsEvent {
  final RepairRecord repair;
  const RequestRepairRequested(this.repair);
}
class ScheduleMaintenanceRequested extends StoresAssetsEvent {
  final MaintenanceRecord maintenance;
  const ScheduleMaintenanceRequested(this.maintenance);
}

class SyncOfflineData extends StoresAssetsEvent {}
