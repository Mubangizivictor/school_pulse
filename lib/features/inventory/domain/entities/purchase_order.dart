import 'package:equatable/equatable.dart';

enum PurchaseOrderStatus { pending, approved, ordered, received, cancelled }

class PurchaseOrder extends Equatable {
  final String id;
  final String schoolId;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final List<OrderItem> items;
  final double totalAmount;
  final PurchaseOrderStatus status;
  final DateTime date;
  final String? notes;
  final String createdBy;
  final String? approvedBy;

  const PurchaseOrder({
    required this.id,
    required this.schoolId,
    required this.orderNumber,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.notes,
    required this.createdBy,
    this.approvedBy,
  });

  @override
  List<Object?> get props => [id, schoolId, orderNumber, supplierId, supplierName, items, totalAmount, status, date, notes, createdBy, approvedBy];
}

class OrderItem extends Equatable {
  final String itemName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  @override
  List<Object?> get props => [itemName, quantity, unitPrice];
}
