import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pay_component_catalogue_item.dart';

/// Reusable named pay components scoped to a school. Not money-authoritative,
/// so (unlike salary structures) this is plain tenant-scoped Firestore
/// read/write - no callable function needed.
abstract class PayComponentCatalogueRepository {
  Stream<List<PayComponentCatalogueItem>> watchCatalogue(String schoolId);

  Future<Either<Failure, void>> saveItem(PayComponentCatalogueItem item);

  Future<Either<Failure, void>> deleteItem(String schoolId, String componentId);
}
