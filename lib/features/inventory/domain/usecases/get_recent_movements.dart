import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_movement.dart';
import '../repositories/inventory_repository.dart';

class GetRecentMovements {
  final InventoryRepository repository;

  GetRecentMovements(this.repository);

  Future<Either<Failure, List<StockMovement>>> call() async {
    return await repository.getRecentMovements();
  }
}
