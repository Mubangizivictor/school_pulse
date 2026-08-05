import 'package:isar/isar.dart';
import '../../domain/entities/inventory_item.dart';

part 'inventory_item_isar.g.dart';

@collection
class InventoryItemIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String itemId;

  late String schoolId;
  late String name;
  late String category;
  late int quantity;
  late String unit;
  late int lowStockThreshold;
  int? maximumStock;
  int? reorderLevel;
  String? warehouseLocation;
  String? storeLocation;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;

  InventoryItemIsar();

  InventoryItem toEntity() {
    return InventoryItem(
      id: itemId,
      schoolId: schoolId,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      lowStockThreshold: lowStockThreshold,
      maximumStock: maximumStock,
      reorderLevel: reorderLevel,
      warehouseLocation: warehouseLocation,
      storeLocation: storeLocation,
    );
  }

  factory InventoryItemIsar.fromEntity(
    InventoryItem entity, {
    bool isSynced = true,
  }) {
    return InventoryItemIsar()
      ..itemId = entity.id
      ..schoolId = entity.schoolId
      ..name = entity.name
      ..category = entity.category
      ..quantity = entity.quantity
      ..unit = entity.unit
      ..lowStockThreshold = entity.lowStockThreshold
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isSynced = isSynced;
  }
}
