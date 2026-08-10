import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/purchase_order.dart';

class PurchaseOrderModel extends PurchaseOrder {
  const PurchaseOrderModel({
    required super.id,
    required super.schoolId,
    required super.orderNumber,
    required super.supplierId,
    required super.supplierName,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.date,
    super.notes,
    required super.createdBy,
    super.approvedBy,
  });

  factory PurchaseOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PurchaseOrderModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      supplierId: data['supplierId'] ?? '',
      supplierName: data['supplierName'] ?? '',
      items: ((data['items'] as List?) ?? const [])
          .whereType<Map>()
          .map((i) => OrderItemModel.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: PurchaseOrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PurchaseOrderStatus.pending,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      createdBy: data['createdBy'] ?? '',
      approvedBy: data['approvedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'orderNumber': orderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((i) => OrderItemModel.fromEntity(i).toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdBy': createdBy,
      'approvedBy': approvedBy,
    };
  }

  factory PurchaseOrderModel.fromEntity(PurchaseOrder order) {
    return PurchaseOrderModel(
      id: order.id,
      schoolId: order.schoolId,
      orderNumber: order.orderNumber,
      supplierId: order.supplierId,
      supplierName: order.supplierName,
      items: order.items,
      totalAmount: order.totalAmount,
      status: order.status,
      date: order.date,
      notes: order.notes,
      createdBy: order.createdBy,
      approvedBy: order.approvedBy,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.itemName,
    required super.quantity,
    required super.unitPrice,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'itemName': itemName, 'quantity': quantity, 'unitPrice': unitPrice};
  }

  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      itemName: item.itemName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    );
  }
}
