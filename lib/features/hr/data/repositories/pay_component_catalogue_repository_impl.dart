import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pay_component_catalogue_item.dart';
import '../../domain/repositories/pay_component_catalogue_repository.dart';

class PayComponentCatalogueRepositoryImpl
    implements PayComponentCatalogueRepository {
  final FirebaseFirestore firestore;

  PayComponentCatalogueRepositoryImpl({required this.firestore});

  @override
  Stream<List<PayComponentCatalogueItem>> watchCatalogue(String schoolId) {
    return firestore
        .collection('schools/$schoolId/pay_component_catalogue')
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => PayComponentCatalogueItem.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, void>> saveItem(PayComponentCatalogueItem item) async {
    try {
      final collection = firestore.collection(
        'schools/${item.schoolId}/pay_component_catalogue',
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
    String componentId,
  ) async {
    try {
      await firestore
          .doc('schools/$schoolId/pay_component_catalogue/$componentId')
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
