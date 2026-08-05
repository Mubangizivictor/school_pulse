import 'package:isar/isar.dart';
import '../../domain/entities/purchase_order.dart';

part 'purchase_order_isar.g.dart';

@collection
class PurchaseOrderIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String orderId;

  late String schoolId;
  late String orderNumber;
  late String supplierId;
  late String supplierName;
  late List<OrderItemEmbeddable> items;
  late double totalAmount;

  @enumerated
  late PurchaseOrderStatus status;

  late DateTime date;
  String? notes;
  late String createdBy;
  String? approvedBy;
  late bool isSynced;

  PurchaseOrderIsar();

  PurchaseOrder toEntity() {
    return PurchaseOrder(
      id: orderId,
      schoolId: schoolId,
      orderNumber: orderNumber,
      supplierId: supplierId,
      supplierName: supplierName,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      status: status,
      date: date,
      notes: notes,
      createdBy: createdBy,
      approvedBy: approvedBy,
    );
  }

  factory PurchaseOrderIsar.fromEntity(
    PurchaseOrder entity, {
    bool isSynced = true,
  }) {
    return PurchaseOrderIsar()
      ..orderId = entity.id
      ..schoolId = entity.schoolId
      ..orderNumber = entity.orderNumber
      ..supplierId = entity.supplierId
      ..supplierName = entity.supplierName
      ..items = entity.items
          .map((e) => OrderItemEmbeddable.fromEntity(e))
          .toList()
      ..totalAmount = entity.totalAmount
      ..status = entity.status
      ..date = entity.date
      ..notes = entity.notes
      ..createdBy = entity.createdBy
      ..approvedBy = entity.approvedBy
      ..isSynced = isSynced;
  }
}

@embedded
class OrderItemEmbeddable {
  late String itemName;
  late int quantity;
  late double unitPrice;

  OrderItemEmbeddable();

  OrderItem toEntity() {
    return OrderItem(
      itemName: itemName,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  factory OrderItemEmbeddable.fromEntity(OrderItem entity) {
    return OrderItemEmbeddable()
      ..itemName = entity.itemName
      ..quantity = entity.quantity
      ..unitPrice = entity.unitPrice;
  }
}
