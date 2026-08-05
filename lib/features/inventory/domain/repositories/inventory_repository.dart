import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/inventory_item.dart';
import '../entities/stock_movement.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryItem>>> getItems();
  Future<Either<Failure, List<StockMovement>>> getRecentMovements();
  Future<Either<Failure, void>> addStock({
    required String itemId,
    required String itemName,
    required String category,
    required String unit,
    required int lowStockThreshold,
    required int quantity,
  });
  Future<Either<Failure, void>> issueItem({
    required String itemId,
    required int quantity,
    required String note,
  });
}
