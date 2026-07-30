import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.category,
    required super.quantity,
    required super.unit,
    required super.lowStockThreshold,
    super.maximumStock,
    super.reorderLevel,
    super.warehouseLocation,
    super.storeLocation,
    super.expiryDate,
  });

  factory InventoryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItemModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      quantity: (data['quantity'] ?? 0) as int,
      unit: data['unit'] ?? 'Units',
      lowStockThreshold: (data['lowStockThreshold'] ?? 0) as int,
      maximumStock: data['maximumStock'] as int?,
      reorderLevel: data['reorderLevel'] as int?,
      warehouseLocation: data['warehouseLocation'] as String?,
      storeLocation: data['storeLocation'] as String?,
      expiryDate: data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
      'maximumStock': maximumStock,
      'reorderLevel': reorderLevel,
      'warehouseLocation': warehouseLocation,
      'storeLocation': storeLocation,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }

  factory InventoryItemModel.fromEntity(InventoryItem entity) {
    return InventoryItemModel(
      id: entity.id,
      schoolId: entity.schoolId,
      name: entity.name,
      category: entity.category,
      quantity: entity.quantity,
      unit: entity.unit,
      lowStockThreshold: entity.lowStockThreshold,
      maximumStock: entity.maximumStock,
      reorderLevel: entity.reorderLevel,
      warehouseLocation: entity.warehouseLocation,
      storeLocation: entity.storeLocation,
      expiryDate: entity.expiryDate,
    );
  }
}
