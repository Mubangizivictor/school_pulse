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
    final school = SchoolModel.fromJson(doc.data() ?? {});
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
      final school = SchoolModel.fromJson(doc.data() ?? {});
      return InstitutionContext.fromSchool(
        school,
        isOfflineCached: doc.metadata.isFromCache,
      );
    });
  }
}
