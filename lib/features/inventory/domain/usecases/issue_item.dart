import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/inventory_repository.dart';

class IssueItem {
  final InventoryRepository repository;

  IssueItem(this.repository);

  Future<Either<Failure, void>> call({required String itemId, required int quantity, required String note}) async {
    return await repository.issueItem(itemId: itemId, quantity: quantity, note: note);
  }
}
