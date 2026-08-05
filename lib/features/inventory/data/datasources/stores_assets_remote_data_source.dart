import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_movement_model.dart';
import '../models/asset_model.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import '../models/repair_model.dart';
import '../models/maintenance_model.dart';
import '../models/procurement_request_model.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/stock_issue.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/procurement_request.dart';

abstract class StoresAssetsRemoteDataSource {
  // Inventory
  Future<List<InventoryItemModel>> getInventoryItems();
  Future<List<StockMovementModel>> getRecentMovements();
  Future<void> addInventoryItem(InventoryItemModel item);
  Future<void> updateInventoryItem(InventoryItemModel item);
  Future<void> adjustStock(StockAdjustment adjustment);
  Future<void> issueStock(StockIssue issue);

  // Assets
  Future<List<AssetModel>> getAssets();
  Future<void> addAsset(AssetModel asset);
  Future<void> updateAsset(AssetModel asset);
  Future<void> disposeAsset(String assetId, String reason);

  // Procurement
  Future<List<SupplierModel>> getSuppliers();
  Future<void> addSupplier(SupplierModel supplier);
  Future<List<PurchaseOrderModel>> getPurchaseOrders();
  Future<void> createPurchaseOrder(PurchaseOrderModel order);
  Future<void> updatePurchaseOrderStatus(
    String orderId,
    PurchaseOrderStatus status,
  );

  // Procurement Requests
  Future<List<ProcurementRequestModel>> getProcurementRequests();
  Future<void> createProcurementRequest(ProcurementRequestModel request);
  Future<void> updateProcurementRequestStatus(
    String requestId,
    ProcurementStatus status, {
    String? directorNote,
  });

  // Repairs & Maintenance
  Future<List<RepairRecordModel>> getRepairRecords();
  Future<void> requestRepair(RepairRecordModel repair);
  Future<List<MaintenanceRecordModel>> getMaintenanceSchedule();
  Future<void> scheduleMaintenance(MaintenanceRecordModel maintenance);
}

class StoresAssetsRemoteDataSourceImpl implements StoresAssetsRemoteDataSource {
  final FirebaseFirestore firestore;

  StoresAssetsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    final snapshot = await firestore
        .collection('inventory_items')
        .orderBy('name')
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<StockMovementModel>> getRecentMovements() async {
    final snapshot = await firestore
        .collection('inventory_movements')
        .orderBy('date', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => StockMovementModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addInventoryItem(InventoryItemModel item) async {
    await firestore
        .collection('inventory_items')
        .doc(item.id.isEmpty ? null : item.id)
        .set(item.toFirestore());
  }

  @override
  Future<void> updateInventoryItem(InventoryItemModel item) async {
    await firestore
        .collection('inventory_items')
        .doc(item.id)
        .update(item.toFirestore());
  }

  @override
  Future<void> adjustStock(StockAdjustment adjustment) async {
    final batch = firestore.batch();
    final itemRef = firestore
        .collection('inventory_items')
        .doc(adjustment.itemId);

    batch.update(itemRef, {
      'quantity': FieldValue.increment(adjustment.quantityAdjusted),
    });

    final movementRef = firestore.collection('inventory_movements').doc();
    batch.set(movementRef, {
      'itemId': adjustment.itemId,
      'itemName': adjustment.itemName,
      'type': 'adjustment',
      'quantity': adjustment.quantityAdjusted,
      'date': Timestamp.fromDate(adjustment.date),
      'note': adjustment.notes,
      'reason': adjustment.reason.name,
      'adjustedBy': adjustment.adjustedBy,
    });

    await batch.commit();
  }

  @override
  Future<void> issueStock(StockIssue issue) async {
    final batch = firestore.batch();
    final itemRef = firestore.collection('inventory_items').doc(issue.itemId);

    batch.update(itemRef, {'quantity': FieldValue.increment(-issue.quantity)});

    final movementRef = firestore.collection('inventory_movements').doc();
    batch.set(movementRef, {
      'itemId': issue.itemId,
      'itemName': issue.itemName,
      'type': 'issue',
      'quantity': issue.quantity,
      'date': Timestamp.fromDate(issue.date),
      'note': issue.purpose,
      'issuedTo': issue.issuedToName,
      'department': issue.department,
      'approvedBy': issue.approvedBy,
    });

    await batch.commit();
  }

  // Assets Implementation
  @override
  Future<List<AssetModel>> getAssets() async {
    final snapshot = await firestore.collection('assets').orderBy('name').get();
    return snapshot.docs.map((doc) => AssetModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addAsset(AssetModel asset) async {
    await firestore
        .collection('assets')
        .doc(asset.id.isEmpty ? null : asset.id)
        .set(asset.toFirestore());
  }

  @override
  Future<void> updateAsset(AssetModel asset) async {
    await firestore
        .collection('assets')
        .doc(asset.id)
        .update(asset.toFirestore());
  }

  @override
  Future<void> disposeAsset(String assetId, String reason) async {
    await firestore.collection('assets').doc(assetId).update({
      'status': AssetStatus.disposed.name,
      'disposalReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Procurement Implementation
  @override
  Future<List<SupplierModel>> getSuppliers() async {
    final snapshot = await firestore
        .collection('suppliers')
        .orderBy('name')
        .get();
    return snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addSupplier(SupplierModel supplier) async {
    await firestore
        .collection('suppliers')
        .doc(supplier.id.isEmpty ? null : supplier.id)
        .set(supplier.toFirestore());
  }

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    final snapshot = await firestore
        .collection('purchase_orders')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PurchaseOrderModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> createPurchaseOrder(PurchaseOrderModel order) async {
    await firestore
        .collection('purchase_orders')
        .doc(order.id.isEmpty ? null : order.id)
        .set(order.toFirestore());
  }

  @override
  Future<void> updatePurchaseOrderStatus(
    String orderId,
    PurchaseOrderStatus status,
  ) async {
    await firestore.collection('purchase_orders').doc(orderId).update({
      'status': status.name,
    });
  }

  @override
  Future<List<ProcurementRequestModel>> getProcurementRequests() async {
    final snapshot = await firestore
        .collection('procurement_requests')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ProcurementRequestModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> createProcurementRequest(ProcurementRequestModel request) async {
    await firestore
        .collection('procurement_requests')
        .doc(request.id.isEmpty ? null : request.id)
        .set(request.toFirestore());
  }

  @override
  Future<void> updateProcurementRequestStatus(
    String requestId,
    ProcurementStatus status, {
    String? directorNote,
  }) async {
    final data = {'status': status.name};
    if (directorNote != null) data['directorNote'] = directorNote;
    await firestore
        .collection('procurement_requests')
        .doc(requestId)
        .update(data);
  }

  // Repairs & Maintenance Implementation
  @override
  Future<List<RepairRecordModel>> getRepairRecords() async {
    final snapshot = await firestore
        .collection('repair_records')
        .orderBy('requestDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => RepairRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> requestRepair(RepairRecordModel repair) async {
    await firestore
        .collection('repair_records')
        .doc(repair.id.isEmpty ? null : repair.id)
        .set(repair.toFirestore());
  }

  @override
  Future<List<MaintenanceRecordModel>> getMaintenanceSchedule() async {
    final snapshot = await firestore
        .collection('maintenance_records')
        .orderBy('scheduledDate')
        .get();
    return snapshot.docs
        .map((doc) => MaintenanceRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> scheduleMaintenance(MaintenanceRecordModel maintenance) async {
    await firestore
        .collection('maintenance_records')
        .doc(maintenance.id.isEmpty ? null : maintenance.id)
        .set(maintenance.toFirestore());
  }
}
