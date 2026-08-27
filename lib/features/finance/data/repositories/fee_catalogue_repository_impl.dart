import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/fee_catalogue_item.dart';
import '../../domain/repositories/fee_catalogue_repository.dart';

class FeeCatalogueRepositoryImpl implements FeeCatalogueRepository {
  final FirebaseFirestore firestore;

  FeeCatalogueRepositoryImpl({required this.firestore});

  @override
  Stream<List<FeeCatalogueItem>> watchCatalogue(String schoolId) {
    return firestore
        .collection('schools/$schoolId/fee_catalogue')
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => FeeCatalogueItem.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, void>> saveItem(FeeCatalogueItem item) async {
    try {
      final collection = firestore.collection(
        'schools/${item.schoolId}/fee_catalogue',
      );
      if (item.id.isEmpty) {
        await collection.add(item.toJson());
      } else {
        await collection.doc(item.id).set(item.toJson(), SetOptions(merge: true));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(
    String schoolId,
    String chargeId,
  ) async {
    try {
      await firestore
          .doc('schools/$schoolId/fee_catalogue/$chargeId')
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
