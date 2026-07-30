import 'package:isar/isar.dart';
import '../../domain/entities/stock_movement.dart';

part 'stock_movement_isar.g.dart';

@collection
class StockMovementIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String movementId;

  late String itemId;
  late String itemName;

  @enumerated
  late StockMovementType type;

  late int quantity;
  late DateTime date;
  late String note;
  late bool isSynced;

  StockMovementIsar({
    this.movementId = '',
    this.itemId = '',
    this.itemName = '',
    this.type = StockMovementType.restock,
    this.quantity = 0,
    required this.date,
    this.note = '',
    this.isSynced = false,
  });

  factory StockMovementIsar.fromEntity(StockMovement entity, {bool isSynced = true}) {
    return StockMovementIsar(date: entity.date)
      ..movementId = entity.id
      ..itemId = entity.itemId
      ..itemName = entity.itemName
      ..type = entity.type
      ..quantity = entity.quantity
      ..note = entity.note
      ..isSynced = isSynced;
  }

  StockMovement toEntity() {
    return StockMovement(
      id: movementId,
      itemId: itemId,
      itemName: itemName,
      type: type,
      quantity: quantity,
      date: date,
      note: note,
    );
  }
}
