import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fee_catalogue_item.dart';

/// Reusable named charges scoped to a school. Not money-authoritative, so
/// (unlike fee plans) this is plain tenant-scoped Firestore read/write - no
/// callable function needed.
abstract class FeeCatalogueRepository {
  Stream<List<FeeCatalogueItem>> watchCatalogue(String schoolId);

  Future<Either<Failure, void>> saveItem(FeeCatalogueItem item);

  Future<Either<Failure, void>> deleteItem(String schoolId, String chargeId);
}
