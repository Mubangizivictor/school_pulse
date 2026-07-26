import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InventoryItem>>> getItems() async {
    try {
      final items = await remoteDataSource.getItems();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getRecentMovements() async {
    try {
      final movements = await remoteDataSource.getRecentMovements();
      return Right(movements);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addStock({
    required String itemId,
    required String itemName,
    required String category,
    required String unit,
    required int lowStockThreshold,
    required int quantity,
  }) async {
    try {
      await remoteDataSource.addStock(
        itemId: itemId,
        itemName: itemName,
        category: category,
        unit: unit,
        lowStockThreshold: lowStockThreshold,
        quantity: quantity,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> issueItem({required String itemId, required int quantity, required String note}) async {
    try {
      await remoteDataSource.issueItem(itemId: itemId, quantity: quantity, note: note);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
