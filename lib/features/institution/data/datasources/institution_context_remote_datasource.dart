import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/super_admin/data/models/school_model.dart';

abstract class InstitutionContextRemoteDataSource {
  Future<InstitutionContext> loadContext(String institutionId);
  Stream<InstitutionContext> watchContext(String institutionId);
}

class InstitutionContextRemoteDataSourceImpl
    implements InstitutionContextRemoteDataSource {
  final FirebaseFirestore firestore;

  InstitutionContextRemoteDataSourceImpl({required this.firestore});

  @override
  Future<InstitutionContext> loadContext(String institutionId) async {
    final doc = await firestore.collection('schools').doc(institutionId).get();
    if (!doc.exists) {
      throw StateError('Institution context was not found.');
    }
    final school = SchoolModel.fromJson({
      ...?doc.data(),
      // The path is authoritative. Older documents do not consistently
      // duplicate their ID in their fields.
      'id': doc.id,
    });
    return InstitutionContext.fromSchool(
      school,
      isOfflineCached: doc.metadata.isFromCache,
    );
  }

  @override
  Stream<InstitutionContext> watchContext(String institutionId) {
    return firestore
        .collection('schools')
        .doc(institutionId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
          if (!doc.exists) {
            throw StateError('Institution context was not found.');
          }
          final school = SchoolModel.fromJson({...?doc.data(), 'id': doc.id});
          return InstitutionContext.fromSchool(
            school,
            isOfflineCached: doc.metadata.isFromCache,
          );
        });
  }
}
