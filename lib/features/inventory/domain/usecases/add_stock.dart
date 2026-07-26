import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/inventory_repository.dart';

class AddStock {
  final InventoryRepository repository;

  AddStock(this.repository);

  Future<Either<Failure, void>> call({
    required String itemId,
    required String itemName,
    required String category,
    required String unit,
    required int lowStockThreshold,
    required int quantity,
  }) async {
    return await repository.addStock(
      itemId: itemId,
      itemName: itemName,
      category: category,
      unit: unit,
      lowStockThreshold: lowStockThreshold,
      quantity: quantity,
    );
  }
}
